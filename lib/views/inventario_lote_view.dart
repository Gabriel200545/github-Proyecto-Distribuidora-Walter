import 'package:flutter/material.dart';
import '../models/inventario_lote_model.dart';
import '../services/inventario_lote_service.dart';

class InventarioLoteView extends StatefulWidget {
  const InventarioLoteView({super.key});

  @override
  State<InventarioLoteView> createState() => _InventarioLoteViewState();
}

class _InventarioLoteViewState extends State<InventarioLoteView> {
  List<InventarioLote> inventarioLotes = [];

  @override
  void initState() {
    super.initState();
    _loadInventarioLotes();
  }

  Future<void> _loadInventarioLotes() async {
    final data = await InventarioLoteService.getInventarioLotes();
    setState(() {
      inventarioLotes = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Inventario'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inventarioLotes.length,
        itemBuilder: (context, index) {
          final item = inventarioLotes[index];
          return Card(
            color: const Color(0xFF1A033D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                'Producto: ${item.nombreProducto}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Bodega: ${item.nombreBodega}\n'
                'Lote: ${item.codigoLote}\n'
                'Stock: ${item.stock} ${item.abreviaturaUnidad}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
