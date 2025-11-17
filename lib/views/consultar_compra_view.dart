import 'package:flutter/material.dart';
import '../models/consultar_compra_model.dart';
import '../services/consultar_compra_service.dart';
import '../utils/consultar_compra_pdf.dart';

class ConsultarCompraView extends StatefulWidget {
  const ConsultarCompraView({super.key});

  @override
  State<ConsultarCompraView> createState() => _ConsultarCompraViewState();
}

class _ConsultarCompraViewState extends State<ConsultarCompraView> {
  late Future<List<Compra>> _comprasFuture; // ✅ siempre inicializado
  Map<int, String> proveedores = {};

  @override
  void initState() {
    super.initState();
    // Inicializamos con un Future vacío para evitar LateInitializationError
    _comprasFuture = Future.value([]);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final provs = await ConsultarCompraService.obtenerProveedores();
      setState(() {
        proveedores = provs;
        _comprasFuture = ConsultarCompraService.obtenerCompras();
      });
    } catch (e) {
      setState(() {
        _comprasFuture = Future.error('Error al cargar datos: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120321),
      appBar: AppBar(
        title: const Text('Consultar Compra'),
        backgroundColor: const Color(0xFF6A1B9A),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Compra>>(
        future: _comprasFuture,
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
                'No hay compras registradas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final compras = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: compras.map((compra) {
                final nombreProveedor =
                    proveedores[compra.idProveedor] ??
                    'Proveedor ${compra.idProveedor}';

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
                      'Compra #${compra.idCompra} — $nombreProveedor',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Fecha: ${compra.fecha.toLocal().toString().split(" ")[0]}',
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
                                rows: compra.detalles.map((d) {
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
                                generarCompraPDF(compra, nombreProveedor);
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
