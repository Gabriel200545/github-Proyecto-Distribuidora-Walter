import 'package:flutter/material.dart';
import '../models/lote_model.dart';
import '../services/lote_service.dart';

class LoteView extends StatefulWidget {
  const LoteView({super.key});

  @override
  State<LoteView> createState() => _LoteViewState();
}

class _LoteViewState extends State<LoteView> {
  List<LoteModel> lotes = [];
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _nombreProductoController = TextEditingController();
  final TextEditingController _fechaFabricacionController = TextEditingController();
  final TextEditingController _fechaCaducidadController = TextEditingController();
  final TextEditingController _idProveedorController = TextEditingController();
  final TextEditingController _nombreProveedorController = TextEditingController();
  final TextEditingController _observacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _idProductoController.dispose();
    _nombreProductoController.dispose();
    _fechaFabricacionController.dispose();
    _fechaCaducidadController.dispose();
    _idProveedorController.dispose();
    _nombreProveedorController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _loadLotes() async {
    final data = await LoteService.getLotes();
    setState(() {
      lotes = data;
    });
  }

  Future<void> _mostrarDialogo({LoteModel? lote}) async {
    if (lote != null) {
      _codigoController.text = lote.codigo;
      _idProductoController.text = lote.idProducto.toString();
      _nombreProductoController.text = lote.nombreProducto;
      _fechaFabricacionController.text =
          lote.fechaFabricacion?.toIso8601String() ?? '';
      _fechaCaducidadController.text =
          lote.fechaCaducidad?.toIso8601String() ?? '';
      _idProveedorController.text = lote.idProveedor.toString();
      _nombreProveedorController.text = lote.nombreProveedor;
      _observacionController.text = lote.observacion ?? '';
    } else {
      _codigoController.clear();
      _idProductoController.clear();
      _nombreProductoController.clear();
      _fechaFabricacionController.clear();
      _fechaCaducidadController.clear();
      _idProveedorController.clear();
      _nombreProveedorController.clear();
      _observacionController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          lote == null ? 'Nuevo Lote' : 'Editar Lote',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _codigoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Código',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
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
                controller: _nombreProductoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre Producto',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _fechaFabricacionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Fecha Fabricación (YYYY-MM-DD)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _fechaCaducidadController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Fecha Caducidad (YYYY-MM-DD)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _idProveedorController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'ID Proveedor',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _nombreProveedorController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre Proveedor',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _observacionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Observación',
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
              final codigo = _codigoController.text.trim();
              final idProducto = int.tryParse(_idProductoController.text.trim()) ?? 0;
              final nombreProducto = _nombreProductoController.text.trim();
              final fechaFab = DateTime.tryParse(_fechaFabricacionController.text.trim());
              final fechaCad = DateTime.tryParse(_fechaCaducidadController.text.trim());
              final idProveedor = int.tryParse(_idProveedorController.text.trim()) ?? 0;
              final nombreProveedor = _nombreProveedorController.text.trim();
              final observacion = _observacionController.text.trim();

              if (codigo.isEmpty || nombreProducto.isEmpty || nombreProveedor.isEmpty) return;

              if (lote == null) {
                await LoteService.createLote(
                  LoteModel(
                    idLote: 0,
                    codigo: codigo,
                    idProducto: idProducto,
                    nombreProducto: nombreProducto,
                    fechaFabricacion: fechaFab,
                    fechaCaducidad: fechaCad,
                    idProveedor: idProveedor,
                    nombreProveedor: nombreProveedor,
                    observacion: observacion.isEmpty ? null : observacion,
                  ),
                );
              } else {
                lote.codigo = codigo;
                lote.idProducto = idProducto;
                lote.nombreProducto = nombreProducto;
                lote.fechaFabricacion = fechaFab;
                lote.fechaCaducidad = fechaCad;
                lote.idProveedor = idProveedor;
                lote.nombreProveedor = nombreProveedor;
                lote.observacion = observacion.isEmpty ? null : observacion;
                await LoteService.updateLote(lote);
              }

              Navigator.pop(context);
              _loadLotes();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(LoteModel lote) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar este lote?', style: TextStyle(color: Colors.white70)),
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
      await LoteService.deleteLote(lote.idLote);
      _loadLotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Lotes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lotes.length,
        itemBuilder: (context, index) {
          final lote = lotes[index];
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text('${lote.codigo} - ${lote.nombreProducto}', style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                'Proveedor: ${lote.nombreProveedor}\nFabricación: ${lote.fechaFabricacion?.toIso8601String() ?? "-"} | Caducidad: ${lote.fechaCaducidad?.toIso8601String() ?? "-"}\nObservación: ${lote.observacion ?? "-"}',
                style: const TextStyle(color: Colors.white70),
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(lote: lote),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(lote),
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