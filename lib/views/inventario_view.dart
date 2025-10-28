import 'package:flutter/material.dart';
import '../models/inventario_model.dart';
import '../services/inventario_service.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  List<Inventario> inventarios = [];
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _idBodegaController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventarios();
  }

  @override
  void dispose() {
    _idProductoController.dispose();
    _idBodegaController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadInventarios() async {
    final data = await InventarioService.getInventarios();
    setState(() {
      inventarios = data;
    });
  }

  Future<void> _mostrarDialogo({Inventario? inventario}) async {
    if (inventario != null) {
      _idProductoController.text = inventario.idProducto.toString();
      _idBodegaController.text = inventario.idBodega.toString();
      _stockController.text = inventario.stock.toString();
    } else {
      _idProductoController.clear();
      _idBodegaController.clear();
      _stockController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          inventario == null ? 'Nuevo Inventario' : 'Editar Inventario',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _idProductoController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'ID Producto',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: _idBodegaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'ID Bodega',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Stock',
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
              final idProducto = int.tryParse(_idProductoController.text.trim()) ?? 0;
              final idBodega = int.tryParse(_idBodegaController.text.trim()) ?? 0;
              final stock = double.tryParse(_stockController.text.trim()) ?? 0.0;

              if (idProducto == 0 || idBodega == 0) return;

              if (inventario == null) {
                await InventarioService.createInventario(
                  Inventario(idProducto: idProducto, idBodega: idBodega, stock: stock),
                );
              } else {
                inventario.idProducto = idProducto;
                inventario.idBodega = idBodega;
                inventario.stock = stock;
                await InventarioService.updateInventario(inventario);
              }

              Navigator.pop(context);
              _loadInventarios();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Inventario inventario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar este inventario?', style: TextStyle(color: Colors.white70)),
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
      await InventarioService.deleteInventario(inventario.idProducto, inventario.idBodega);
      _loadInventarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Inventario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inventarios.length,
        itemBuilder: (context, index) {
          final inventario = inventarios[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text('Producto ID: ${inventario.idProducto}', style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                'Bodega ID: ${inventario.idBodega}\nStock: ${inventario.stock}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(inventario: inventario),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(inventario),
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