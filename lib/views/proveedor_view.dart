// proveedor_view.dart
import 'package:flutter/material.dart';
import '../models/proveedor_model.dart';
import '../services/proveedor_service.dart';

class ProveedorView extends StatefulWidget {
  const ProveedorView({super.key});

  @override
  State<ProveedorView> createState() => _ProveedorViewState();
}

class _ProveedorViewState extends State<ProveedorView> {
  List<Proveedor> proveedores = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProveedores();
  }

  Future<void> _loadProveedores() async {
    try {
      final data = await ProveedorService.getProveedores();
      setState(() => proveedores = data);
    } catch (e) {
      debugPrint('Error cargando proveedores: $e');
    }
  }

  Future<void> _mostrarDialogo({Proveedor? proveedor}) async {
    if (proveedor != null) {
      _nombreController.text = proveedor.nombre;
      _contactoController.text = proveedor.contacto;
      _telefonoController.text = proveedor.telefono;
      _correoController.text = proveedor.correo;
    } else {
      _nombreController.clear();
      _contactoController.clear();
      _telefonoController.clear();
      _correoController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          proveedor == null ? 'Nuevo Proveedor' : 'Editar Proveedor',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _contactoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Contacto',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _telefonoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _correoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
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
              final contacto = _contactoController.text.trim();
              final telefono = _telefonoController.text.trim();
              final correo = _correoController.text.trim();
              if (nombre.isEmpty || contacto.isEmpty) return;

              if (proveedor == null) {
                await ProveedorService.createProveedor(
                  Proveedor(
                    nombre: nombre,
                    contacto: contacto,
                    telefono: telefono,
                    correo: correo,
                  ),
                );
              } else {
                proveedor.nombre = nombre;
                proveedor.contacto = contacto;
                proveedor.telefono = telefono;
                proveedor.correo = correo;
                await ProveedorService.updateProveedor(proveedor);
              }

              if (mounted) Navigator.pop(context);
              _loadProveedores();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Proveedor proveedor) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar este proveedor?', style: TextStyle(color: Colors.white70)),
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
      await ProveedorService.deleteProveedor(proveedor.idProveedor);
      _loadProveedores();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Proveedores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: proveedores.length,
        itemBuilder: (context, index) {
          final proveedor = proveedores[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proveedor.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Contacto: ${proveedor.contacto}', style: const TextStyle(color: Colors.white70)),
                  Text('Teléfono: ${proveedor.telefono}', style: const TextStyle(color: Colors.white70)),
                  Text('Correo: ${proveedor.correo}', style: const TextStyle(color: Colors.white70)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                        onPressed: () => _mostrarDialogo(proveedor: proveedor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmarEliminar(proveedor),
                      ),
                    ],
                  )
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
