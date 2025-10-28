import 'package:flutter/material.dart';
import '../models/unidad_medida_model.dart';
import '../services/unidad_de_medida_service.dart';

class UnidadMedidaView extends StatefulWidget {
  const UnidadMedidaView({super.key});

  @override
  State<UnidadMedidaView> createState() => _UnidadMedidaViewState();
}

class _UnidadMedidaViewState extends State<UnidadMedidaView> {
  List<UnidadMedida> unidades = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _abreviacionController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUnidades();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _abreviacionController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  Future<void> _loadUnidades() async {
    final data = await UnidadMedidaService.getUnidades();
    setState(() {
      unidades = data;
    });
  }

  Future<void> _mostrarDialogo({UnidadMedida? unidad}) async {
    if (unidad != null) {
      _nombreController.text = unidad.nombre;
      _abreviacionController.text = unidad.abreviacion;
      _tipoController.text = unidad.tipoUnidad;
    } else {
      _nombreController.clear();
      _abreviacionController.clear();
      _tipoController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          unidad == null ? 'Nueva Unidad' : 'Editar Unidad',
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
              controller: _abreviacionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Abreviación',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: _tipoController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tipo de Unidad',
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
              final abreviacion = _abreviacionController.text.trim();
              final tipo = _tipoController.text.trim();

              if (nombre.isEmpty || abreviacion.isEmpty || tipo.isEmpty) return;

              if (unidad == null) {
                await UnidadMedidaService.createUnidad(
                  UnidadMedida(
                    idUnidad: 0, // El id lo genera el backend
                    nombre: nombre,
                    abreviacion: abreviacion,
                    tipoUnidad: tipo,
                  ),
                );
              } else {
                unidad.nombre = nombre;
                unidad.abreviacion = abreviacion;
                unidad.tipoUnidad = tipo;
                await UnidadMedidaService.updateUnidad(unidad);
              }

              Navigator.pop(context);
              _loadUnidades();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(UnidadMedida unidad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar esta unidad?', style: TextStyle(color: Colors.white70)),
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
      await UnidadMedidaService.deleteUnidad(unidad.idUnidad);
      _loadUnidades();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Unidades de Medida'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: unidades.length,
        itemBuilder: (context, index) {
          final unidad = unidades[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(unidad.nombre, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                '${unidad.abreviacion} - ${unidad.tipoUnidad}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(unidad: unidad),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(unidad),
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