import 'package:flutter/material.dart';
import '../models/marca_model.dart';
import '../services/marca_service.dart';

class MarcaView extends StatefulWidget {
  const MarcaView({super.key});

  @override
  State<MarcaView> createState() => _MarcaViewState();
}

class _MarcaViewState extends State<MarcaView> {
  List<Marca> marcas = [];
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMarcas();
  }

  Future<void> _loadMarcas() async {
    try {
      final data = await MarcaService.getMarcas();
      setState(() => marcas = data);
    } catch (e) {
      debugPrint('Error cargando marcas: $e');
    }
  }

  Future<void> _mostrarDialogo({Marca? marca}) async {
    if (marca != null) {
      _nombreController.text = marca.nombre;
    } else {
      _nombreController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          marca == null ? 'Nueva Marca' : 'Editar Marca',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nombreController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: Colors.white70),
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

              if (marca == null) {
                await MarcaService.createMarca(Marca(nombre: nombre));
              } else {
                marca.nombre = nombre;
                await MarcaService.updateMarca(marca);
              }

              if (mounted) Navigator.pop(context);
              _loadMarcas();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Marca marca) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar esta marca?', style: TextStyle(color: Colors.white70)),
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
      await MarcaService.deleteMarca(marca.idMarca);
      _loadMarcas();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Marcas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: marcas.length,
        itemBuilder: (context, index) {
          final marca = marcas[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(marca.nombre, style: const TextStyle(color: Colors.white)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(marca: marca),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(marca),
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
