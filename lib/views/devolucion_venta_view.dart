// views/devolucion_venta_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/devolucion_venta_service.dart';

class DevolucionVentaView extends StatefulWidget {
  const DevolucionVentaView({super.key});

  @override
  State<DevolucionVentaView> createState() => _DevolucionVentaViewState();
}

class _DevolucionVentaViewState extends State<DevolucionVentaView> {
  List<Venta> ventas = [];
  Venta? ventaSeleccionada;
  final _motivoCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _usuarioCtrl.text = "Desconocido"; // por defecto
    cargarVentas();
  }

  Future<void> cargarVentas() async {
    try {
      setState(() => loading = true);
      ventas = await DevolucionVentaService.obtenerVentas();
      if (ventas.isNotEmpty) {
        ventaSeleccionada = ventas.first;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar ventas: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> registrarDevolucion() async {
    if (ventaSeleccionada == null || _motivoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una venta y escribir un motivo.'),
        ),
      );
      return;
    }

    final devolucion = {
      "idVenta": ventaSeleccionada!.idVenta,
      "motivo": _motivoCtrl.text.trim(),
      "usuarioRegistro": _usuarioCtrl.text.trim(),
    };

    try {
      await DevolucionVentaService.registrarDevolucionVenta(devolucion);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Devolución registrada exitosamente.')),
      );
      _motivoCtrl.clear();
      // mantener usuario y fecha
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al registrar devolución: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Devolución de Venta"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<Venta>(
                            value: ventaSeleccionada,
                            decoration: const InputDecoration(
                              labelText: "Seleccione una venta",
                              border: OutlineInputBorder(),
                            ),
                            items: ventas
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(
                                      'Venta #${v.idVenta} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(v.fecha))}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => ventaSeleccionada = v),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _motivoCtrl,
                            decoration: const InputDecoration(
                              labelText: "Motivo de la devolución",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _usuarioCtrl,
                            decoration: const InputDecoration(
                              labelText: "Usuario",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: registrarDevolucion,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Registrar Devolución"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Fecha: $fechaActual',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
