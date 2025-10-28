import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class UsuarioView extends StatefulWidget {
  const UsuarioView({super.key});

  @override
  State<UsuarioView> createState() => _UsuarioViewState();
}

class _UsuarioViewState extends State<UsuarioView> {
  List<Usuario> usuarios = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final Color colorPrincipal = const Color(0xFF6A1B9A);

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    try {
      final data = await UsuarioService.getUsuarios();
      setState(() => usuarios = data);
    } catch (e) {
      debugPrint('Error cargando usuarios: $e');
    }
  }

  Future<void> _mostrarDialogoNuevo() async {
    _nombreController.clear();
    _contrasenaController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text(
          'Nuevo Usuario',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nombreController, 'Nombre'),
            _buildTextField(_contrasenaController, 'Contrasena'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              final nombre = _nombreController.text.trim();
              final contrasena = _contrasenaController.text.trim();
              if (nombre.isEmpty || contrasena.isEmpty) return;

              final usuario = Usuario(nombre: nombre, contrasena: contrasena);
              await UsuarioService.createUsuario(usuario);

              if (mounted) Navigator.pop(context);
              _loadUsuarios();
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.purpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que quieres eliminar este usuario?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await UsuarioService.deleteUsuario(usuario.idUsuario);
      _loadUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Usuarios'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(
                usuario.nombre,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Roles: ${usuario.roles.join(', ')}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmarEliminar(usuario),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrincipal,
        onPressed: _mostrarDialogoNuevo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
