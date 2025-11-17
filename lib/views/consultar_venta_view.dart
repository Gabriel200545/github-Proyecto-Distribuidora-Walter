import 'package:flutter/material.dart';
import '../models/consultar_venta_model.dart';
import '../services/consultar_venta_service.dart';
import '../utils/consultar_venta_pdf.dart';

class ConsultarVentaView extends StatefulWidget {
  const ConsultarVentaView({super.key});

  @override
  State<ConsultarVentaView> createState() => _ConsultarVentaViewState();
}

class _ConsultarVentaViewState extends State<ConsultarVentaView> {
  late Future<List<Venta>> _ventasFuture;
  Map<int, String> clientes = {};

  @override
  void initState() {
    super.initState();
    // Inicializamos con un Future vacío para evitar LateInitializationError
    _ventasFuture = Future.value([]);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final cli = await ConsultarVentaService.obtenerClientes();
      setState(() {
        clientes = cli;
        _ventasFuture = ConsultarVentaService.obtenerVentas();
      });
    } catch (e) {
      setState(() {
        _ventasFuture = Future.error('Error al cargar datos: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120321),
      appBar: AppBar(
        title: const Text('Consultar Venta'),
        backgroundColor: const Color(0xFF6A1B9A),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Venta>>(
        future: _ventasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay ventas registradas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final ventas = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: ventas.map((venta) {
                final nombreCliente =
                    clientes[venta.idCliente] ?? 'Cliente ${venta.idCliente}';
                return Card(
                  color: const Color(0xFF1E0447),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    collapsedTextColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    title: Text(
                      'Venta #${venta.idVenta} — $nombreCliente',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Fecha: ${venta.fecha.toLocal().toString().split(" ")[0]}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFF6A1B9A),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Producto',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Cant.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Unidad',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Precio',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Total',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                                rows: venta.detalles.map((d) {
                                  final total = d.cantidad * d.precioUnitario;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          d.nombreProducto,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${d.cantidad}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          d.abreviaturaUnidad,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          d.precioUnitario.toStringAsFixed(2),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          total.toStringAsFixed(2),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                generarFacturaPDF(venta, nombreCliente);
                              },
                              icon: const Icon(Icons.print),
                              label: const Text('Imprimir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
