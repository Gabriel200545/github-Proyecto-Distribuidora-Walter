import 'package:flutter/material.dart';
import '../models/rol_model.dart';
import '../models/usuario_model.dart';
import '../services/rol_service.dart';
import '../services/usuario_service.dart';

class AsignarRolView extends StatefulWidget {
  const AsignarRolView({super.key});

  @override
  State<AsignarRolView> createState() => _AsignarRolViewState();
}

class _AsignarRolViewState extends State<AsignarRolView> {
  List<Usuario> usuarios = [];
  List<Rol> roles = [];
  Usuario? usuarioSeleccionado;
  Rol? rolSeleccionado;

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final u = await UsuarioService.getUsuarios();
      final r = await RolService.getRoles();
      if (!mounted) return;

      setState(() {
        usuarios = u;
        roles = r;

        // Actualizar usuarioSeleccionado
        if (usuarioSeleccionado != null) {
          final encontrado = usuarios
              .where((x) => x.nombre == usuarioSeleccionado!.nombre)
              .toList();
          usuarioSeleccionado = encontrado.isNotEmpty ? encontrado.first : null;
        }

        // Actualizar rolSeleccionado
        if (rolSeleccionado != null) {
          final encontradoRol = roles
              .where((x) => x.idRol == rolSeleccionado!.idRol)
              .toList();
          rolSeleccionado = encontradoRol.isNotEmpty
              ? encontradoRol.first
              : null;
        }

        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
    }
  }

  Future<void> _asignarRol() async {
    if (usuarioSeleccionado == null || rolSeleccionado == null) return;

    final exito = await RolService.asignarRolUsuario(
      usuarioSeleccionado!.idUsuario,
      rolSeleccionado!.idRol,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exito ? 'Rol asignado correctamente' : 'Error al asignar rol',
        ),
      ),
    );
    await _cargarDatos();
  }

  Future<void> _quitarRol(String nombreRol) async {
    if (usuarioSeleccionado == null) return;

    final rol = roles.firstWhere(
      (r) => r.nombre == nombreRol,
      orElse: () => Rol(idRol: 0, nombre: ''),
    );
    if (rol.idRol == 0) return;

    final exito = await RolService.quitarRolUsuario(
      usuarioSeleccionado!.idUsuario,
      rol.idRol,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exito ? 'Rol eliminado correctamente' : 'Error al eliminar rol',
        ),
      ),
    );
    await _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Roles'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<Usuario>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona un Usuario',
                    ),
                    items: usuarios
                        .map(
                          (u) => DropdownMenuItem<Usuario>(
                            value: u,
                            child: Text(u.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        usuarioSeleccionado = val;
                        rolSeleccionado = null;
                      });
                    },
                    initialValue: usuarioSeleccionado,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Rol>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona un Rol',
                    ),
                    items: roles
                        .map(
                          (r) => DropdownMenuItem<Rol>(
                            value: r,
                            child: Text(r.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        rolSeleccionado = val;
                      });
                    },
                    initialValue: rolSeleccionado,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _asignarRol,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                    ),
                    child: const Text('Asignar Rol'),
                  ),
                  const SizedBox(height: 24),
                  if (usuarioSeleccionado != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Roles asignados:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              children: usuarioSeleccionado!.roles
                                  .map(
                                    (rNombre) => ListTile(
                                      title: Text(rNombre),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _quitarRol(rNombre),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
