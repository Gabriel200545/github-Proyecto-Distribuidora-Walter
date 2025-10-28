import 'package:flutter/material.dart';
import '../models/bodega_model.dart';
import '../services/bodega_service.dart';

class BodegaView extends StatefulWidget {
  const BodegaView({super.key});

  @override
  State<BodegaView> createState() => _BodegaViewState();
}

class _BodegaViewState extends State<BodegaView> {
  List<Bodega> bodegas = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBodegas();
  }

  Future<void> _loadBodegas() async {
    final data = await BodegaService.getBodegas();
    setState(() {
      bodegas = data;
    });
  }

  Future<void> _mostrarDialogo({Bodega? bodega}) async {
    if (bodega != null) {
      _nombreController.text = bodega.nombre;
      _ubicacionController.text = bodega.ubicacion;
    } else {
      _nombreController.clear();
      _ubicacionController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          bodega == null ? 'Nueva Bodega' : 'Editar Bodega',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
              controller: _ubicacionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final nombre = _nombreController.text.trim();
              final ubicacion = _ubicacionController.text.trim();
              if (nombre.isEmpty || ubicacion.isEmpty) return;

              if (bodega == null) {
                await BodegaService.createBodega(Bodega(nombre: nombre, ubicacion: ubicacion));
              } else {
                bodega.nombre = nombre;
                bodega.ubicacion = ubicacion;
                await BodegaService.updateBodega(bodega);
              }

              Navigator.pop(context);
              _loadBodegas();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Bodega bodega) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar esta bodega?', style: TextStyle(color: Colors.white70)),
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
      await BodegaService.deleteBodega(bodega.idBodega);
      _loadBodegas();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Bodegas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bodegas.length,
        itemBuilder: (context, index) {
          final bodega = bodegas[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(
                bodega.nombre,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                bodega.ubicacion,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(bodega: bodega),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(bodega),
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
