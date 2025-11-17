// views/devolucion_compra_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/consultar_compra_model.dart';
import '../services/consultar_compra_service.dart';
import '../services/devolucion_compra_service.dart';

class DevolucionCompraView extends StatefulWidget {
  const DevolucionCompraView({super.key});

  @override
  State<DevolucionCompraView> createState() => _DevolucionCompraViewState();
}

class _DevolucionCompraViewState extends State<DevolucionCompraView> {
  List<Compra> compras = [];
  Compra? compraSeleccionada;
  final _motivoCtrl = TextEditingController();
  bool loading = true;
  String usuarioRegistro = 'admin'; // o desde tu sesión

  @override
  void initState() {
    super.initState();
    cargarCompras();
  }

  Future<void> cargarCompras() async {
    try {
      compras = await ConsultarCompraService.obtenerCompras();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar compras: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> registrarDevolucion() async {
    if (compraSeleccionada == null || _motivoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una compra y escriba un motivo.'),
        ),
      );
      return;
    }

    final devolucion = {
      'idCompra': compraSeleccionada!.idCompra,
      'motivo': _motivoCtrl.text.trim(),
      'usuarioRegistro': usuarioRegistro,
    };

    try {
      await DevolucionCompraService.registrarDevolucion(devolucion);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Devolución registrada correctamente.')),
      );

      setState(() {
        compraSeleccionada = null;
        _motivoCtrl.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al registrar devolución: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Devolución de Compra'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<Compra>(
                      value: compraSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Seleccione una compra',
                        border: OutlineInputBorder(),
                      ),
                      items: compras
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                'Compra #${c.idCompra} - ${formatter.format(c.fecha)}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (c) => setState(() => compraSeleccionada = c),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _motivoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de la devolución',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: registrarDevolucion,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Registrar Devolución'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Usuario: $usuarioRegistro\nFecha: ${formatter.format(DateTime.now())}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
