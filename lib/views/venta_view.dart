// views/venta_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/venta_model.dart';
import '../models/producto_model.dart';
import '../models/unidad_medida_model.dart';
import '../models/cliente_model.dart';
import '../models/conversion_model.dart';
import 'package:collection/collection.dart';

import '../services/venta_service.dart';
import '../services/producto_service.dart';
import '../services/unidad_de_medida_service.dart';
import '../services/cliente_service.dart';
import '../services/conversion_service.dart';
import '../services/consultar_compra_service.dart';

class VentaView extends StatefulWidget {
  const VentaView({super.key});

  @override
  State<VentaView> createState() => _VentaViewState();
}

class _VentaViewState extends State<VentaView> {
  // catálogos
  List<Cliente> clientes = [];
  List<Producto> productos = [];
  List<UnidadMedida> unidades = [];
  List<ConversionModel> conversiones = [];

  // filtros
  List<UnidadMedida> unidadesFiltradas = [];

  // selección y detalles
  Cliente? clienteSeleccionado;
  Producto? productoSeleccionado;
  UnidadMedida? unidadSeleccionada;
  final _cantidadCtrl = TextEditingController();

  List<DetalleVentaRequest> detalles = [];

  bool loading = true;
  final factorVenta = 1.15; // 15% margen igual que en tu web

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      clientes = await ClienteService.getClientes();
      productos = await ProductoService.getProductos();
      unidades = await UnidadMedidaService.getUnidades();
      conversiones = await ConversionService.getConversiones();
      unidadesFiltradas = List.from(unidades);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar catálogos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // --- LÓGICA DE CONVERSIONES (como la web) ---
  double obtenerFactorConversion(int unidadDesde, int unidadHasta) {
    if (unidadDesde == unidadHasta) return 1.0;

    final directa = conversiones.firstWhere(
      (c) => c.idUnidadDesde == unidadDesde && c.idUnidadHasta == unidadHasta,
      orElse: () => ConversionModel(
        idConversion: 0,
        idUnidadDesde: 0,
        idUnidadHasta: 0,
        factor: 0,
      ),
    );
    if (directa.factor != 0) return directa.factor;

    final inversa = conversiones.firstWhere(
      (c) => c.idUnidadDesde == unidadHasta && c.idUnidadHasta == unidadDesde,
      orElse: () => ConversionModel(
        idConversion: 0,
        idUnidadDesde: 0,
        idUnidadHasta: 0,
        factor: 0,
      ),
    );
    if (inversa.factor != 0) return 1 / inversa.factor;

    return 1.0;
  }

  void filtrarUnidadesPorProducto() {
    if (productoSeleccionado == null) {
      unidadesFiltradas = List.from(unidades);
    } else {
      final unidadBase = unidades.firstWhere(
        (u) => u.idUnidad == productoSeleccionado!.idUnidadMedida,
        orElse: () => UnidadMedida(
          idUnidad: 0,
          nombre: '-',
          abreviacion: '-',
          tipoUnidad: '-',
        ),
      );
      final tipo = unidadBase.tipoUnidad;
      unidadesFiltradas = unidades.where((u) => u.tipoUnidad == tipo).toList();
    }
    unidadSeleccionada = unidadesFiltradas.isNotEmpty
        ? unidadesFiltradas.first
        : null;
    setState(() {});
  }

  // Obtener último precio de compra desde compras
  Future<double?> obtenerUltimoPrecioCompraDesdeCompras(int idProducto) async {
    try {
      // 🔹 Obtenemos todas las compras con sus detalles
      final compras = await ConsultarCompraService.obtenerCompras();

      // 🔹 Recorremos desde la última hacia la primera (para obtener la más reciente)
      for (int i = compras.length - 1; i >= 0; i--) {
        final compra = compras[i];

        // 🔹 Buscamos el detalle que coincida con el producto
        final detalle = compra.detalles.firstWhereOrNull(
          (d) => d.idProducto == idProducto,
        );

        // 🔹 Si encontramos detalle válido, retornamos su precio unitario
        if (detalle != null) {
          return detalle.precioUnitario;
        }
      }

      // 🔹 Si no se encuentra precio, devolvemos null
      return null;
    } catch (e) {
      // ⚠️ Manejo de errores
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al obtener compras: $e')));
      }
      return null;
    }
  }

  Future<void> agregarDetalle() async {
    if (productoSeleccionado == null || unidadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona producto y unidad.")),
      );
      return;
    }

    final cantidad = double.tryParse(_cantidadCtrl.text) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cantidad debe ser mayor a 0.")),
      );
      return;
    }

    final precioCompra = await obtenerUltimoPrecioCompraDesdeCompras(
      productoSeleccionado!.idProducto,
    );
    if (precioCompra == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se encontró precio de compra para el producto."),
        ),
      );
      return;
    }

    final factorConv = obtenerFactorConversion(
      productoSeleccionado!.idUnidadMedida,
      unidadSeleccionada!.idUnidad,
    );

    final precioUnitarioConvertido = (precioCompra / factorConv) * factorVenta;

    final detalle = DetalleVentaRequest(
      idProducto: productoSeleccionado!.idProducto,
      cantidad: cantidad,
      idUnidadMedida: unidadSeleccionada!.idUnidad,
      precioCompra: precioCompra,
      precioUnitario: precioUnitarioConvertido,
    );

    setState(() {
      detalles.add(detalle);
      _cantidadCtrl.clear();
    });
  }

  void eliminarDetalle(int idx) {
    setState(() {
      detalles.removeAt(idx);
    });
  }

  double get subtotalConMargen {
    double subtotal = 0;
    for (final d in detalles) {
      final precio = d.precioUnitario ?? 0;
      subtotal += precio * d.cantidad;
    }
    return subtotal;
  }

  double get subtotalSinMargen => subtotalConMargen / factorVenta;

  Future<void> registrarVenta() async {
    if (clienteSeleccionado == null || detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona cliente y agrega al menos un detalle."),
        ),
      );
      return;
    }

    final venta = VentaRequest(
      idCliente: clienteSeleccionado!.idCliente!,
      fecha: DateTime.now().toIso8601String(),
      usuarioRegistro: "admin",
      detalles: detalles,
    );

    final ok = await VentaService.registrarVenta(venta);

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Venta registrada correctamente.")),
        );
      }
      setState(() {
        detalles.clear();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Error al registrar la venta.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      appBar: AppBar(
        title: const Text(
          "Registrar Venta",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 3,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: cargarDatos,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildCard(
                              title: "Cliente",
                              child: DropdownButtonFormField<Cliente>(
                                value: clienteSeleccionado,
                                decoration: const InputDecoration(
                                  labelText: "Selecciona cliente",
                                  border: OutlineInputBorder(),
                                ),
                                items: clientes
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.nombre),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (c) =>
                                    setState(() => clienteSeleccionado = c),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCard(
                              title: "Agregar producto",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<Producto>(
                                    value: productoSeleccionado,
                                    decoration: const InputDecoration(
                                      labelText: "Producto",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: productos
                                        .map(
                                          (p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(p.nombre),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (p) {
                                      setState(() {
                                        productoSeleccionado = p;
                                        filtrarUnidadesPorProducto();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<UnidadMedida>(
                                    value: unidadSeleccionada,
                                    decoration: const InputDecoration(
                                      labelText: "Unidad de medida",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: unidadesFiltradas
                                        .map(
                                          (u) => DropdownMenuItem(
                                            value: u,
                                            child: Text(
                                              "${u.nombre} (${u.abreviacion})",
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (u) =>
                                        setState(() => unidadSeleccionada = u),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _cantidadCtrl,
                                          decoration: const InputDecoration(
                                            labelText: "Cantidad",
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: agregarDetalle,
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      label: const Text("Agregar Detalle"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (detalles.isNotEmpty)
                              _buildCard(
                                title: "Detalles de la venta",
                                child: SizedBox(
                                  height: 300,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                                Colors.deepPurple.shade50,
                                              ),
                                          columnSpacing: 16,
                                          headingTextStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                          border: TableBorder.symmetric(
                                            inside: BorderSide(
                                              color: Colors.deepPurple
                                                  .withOpacity(0.1),
                                            ),
                                          ),
                                          columns: const [
                                            DataColumn(label: Text("Producto")),
                                            DataColumn(label: Text("Unidad")),
                                            DataColumn(label: Text("Cant.")),
                                            DataColumn(label: Text("Precio")),
                                            DataColumn(label: Text("Subtotal")),
                                            DataColumn(label: Text("Eliminar")),
                                          ],
                                          rows: List.generate(detalles.length, (
                                            i,
                                          ) {
                                            final d = detalles[i];
                                            final producto = productos
                                                .firstWhere(
                                                  (p) =>
                                                      p.idProducto ==
                                                      d.idProducto,
                                                  orElse: () => Producto(
                                                    idProducto: 0,
                                                    nombre: "Desconocido",
                                                    descripcion: "",
                                                    idCategoria: 0,
                                                    idMarca: 0,
                                                    idUnidadMedida: 0,
                                                  ),
                                                );
                                            final unidad = unidades.firstWhere(
                                              (u) =>
                                                  u.idUnidad ==
                                                  d.idUnidadMedida,
                                              orElse: () => UnidadMedida(
                                                idUnidad: 0,
                                                nombre: "-",
                                                abreviacion: "-",
                                                tipoUnidad: "-",
                                              ),
                                            );

                                            final precio =
                                                d.precioUnitario ?? 0.0;
                                            final subtotal =
                                                precio * d.cantidad;

                                            return DataRow(
                                              cells: [
                                                DataCell(Text(producto.nombre)),
                                                DataCell(
                                                  Text(unidad.abreviacion),
                                                ),
                                                DataCell(
                                                  Text(
                                                    d.cantidad.toStringAsFixed(
                                                      2,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    precio > 0
                                                        ? formatter.format(
                                                            precio,
                                                          )
                                                        : "—",
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    formatter.format(subtotal),
                                                  ),
                                                ),
                                                DataCell(
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons
                                                          .delete_forever_rounded,
                                                      color: Colors.redAccent,
                                                      size: 22,
                                                    ),
                                                    onPressed: () =>
                                                        eliminarDetalle(i),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Subtotal: ${formatter.format(subtotalSinMargen)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Total: ${formatter.format(subtotalConMargen)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: registrarVenta,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("Registrar Venta"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 30,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 6,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
