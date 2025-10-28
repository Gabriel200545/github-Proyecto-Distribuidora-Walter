import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteView extends StatefulWidget {
  const ClienteView({super.key});

  @override
  State<ClienteView> createState() => _ClienteViewState();
}

class _ClienteViewState extends State<ClienteView> {
  List<Cliente> clientes = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    try {
      final data = await ClienteService.getClientes();
      setState(() => clientes = data);
    } catch (e) {
      debugPrint('Error cargando clientes: $e');
    }
  }

  Future<void> _mostrarDialogo({Cliente? cliente}) async {
    if (cliente != null) {
      _nombreController.text = cliente.nombre;
      _direccionController.text = cliente.direccion;
      _telefonoController.text = cliente.telefono;
      _correoController.text = cliente.correo;
    } else {
      _nombreController.clear();
      _direccionController.clear();
      _telefonoController.clear();
      _correoController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          cliente == null ? 'Nuevo Cliente' : 'Editar Cliente',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nombreController, 'Nombre'),
              _buildTextField(_direccionController, 'Dirección'),
              _buildTextField(_telefonoController, 'Teléfono'),
              _buildTextField(_correoController, 'Correo'),
            ],
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
              final direccion = _direccionController.text.trim();
              final telefono = _telefonoController.text.trim();
              final correo = _correoController.text.trim();
              if (nombre.isEmpty || direccion.isEmpty || telefono.isEmpty || correo.isEmpty) return;

              if (cliente == null) {
                await ClienteService.createCliente(
                  Cliente(
                    nombre: nombre,
                    direccion: direccion,
                    telefono: telefono,
                    correo: correo,
                  ),
                );
              } else {
                cliente.nombre = nombre;
                cliente.direccion = direccion;
                cliente.telefono = telefono;
                cliente.correo = correo;
                await ClienteService.updateCliente(cliente);
              }

              if (mounted) Navigator.pop(context);
              _loadClientes();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
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

  Future<void> _confirmarEliminar(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar este cliente?', style: TextStyle(color: Colors.white70)),
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
      await ClienteService.deleteCliente(cliente.idCliente);
      _loadClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Clientes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final cliente = clientes[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(cliente.nombre, style: const TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dirección: ${cliente.direccion}', style: const TextStyle(color: Colors.white70)),
                  Text('Teléfono: ${cliente.telefono}', style: const TextStyle(color: Colors.white70)),
                  Text('Correo: ${cliente.correo}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(cliente: cliente),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(cliente),
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
