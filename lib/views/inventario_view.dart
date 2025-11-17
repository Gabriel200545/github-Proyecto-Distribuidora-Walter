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

  @override
  void initState() {
    super.initState();
    _loadInventarios();
  }

  Future<void> _loadInventarios() async {
    final data = await InventarioService.getInventarios();
    setState(() {
      inventarios = data;
    });
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
              title: Text(
                inventario.nombreProducto,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${inventario.nombreBodega}\nStock: ${inventario.stock} ${inventario.abreviaturaUnidad}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
