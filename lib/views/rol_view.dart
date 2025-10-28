import 'package:flutter/material.dart';
import '../models/rol_model.dart';
import '../services/rol_service.dart';

class RolView extends StatefulWidget {
  const RolView({super.key});

  @override
  State<RolView> createState() => _RolViewState();
}

class _RolViewState extends State<RolView> {
  List<Rol> roles = [];
  final TextEditingController _nombreController = TextEditingController();
  final Color colorPrincipal = const Color(0xFF6A1B9A);

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final data = await RolService.getRoles();
      setState(() => roles = data);
    } catch (e) {
      debugPrint('Error cargando roles: $e');
    }
  }

  Future<void> _mostrarDialogo({Rol? rol}) async {
    if (rol != null) {
      _nombreController.text = rol.nombre;
    } else {
      _nombreController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          rol == null ? 'Nuevo Rol' : 'Editar Rol',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nombreController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final nombre = _nombreController.text.trim();
              if (nombre.isEmpty) return;

              bool success;
              if (rol == null) {
                success = await RolService.crearRol(nombre);
              } else {
                success = await RolService.editarRol(rol.idRol, nombre);
              }

              if (success) {
                if (mounted) Navigator.pop(context);
                _loadRoles();
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Rol rol) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: Text('¿Seguro que quieres eliminar el rol "${rol.nombre}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final success = await RolService.eliminarRol(rol.idRol);
      if (success) _loadRoles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Roles'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final rol = roles[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(rol.nombre, style: const TextStyle(color: Colors.white)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(rol: rol),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(rol),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrincipal,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogo(),
      ),
    );
  }
}
