// views/venta_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../models/venta_model.dart';
import '../models/producto_model.dart';
import '../models/unidad_medida_model.dart';
import '../models/cliente_model.dart';
import '../models/conversion_model.dart';

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
  final factorVenta = 1.15; // 15% margen

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

  Future<double?> obtenerUltimoPrecioCompraDesdeCompras(int idProducto) async {
    try {
      final compras = await ConsultarCompraService.obtenerCompras();
      for (int i = compras.length - 1; i >= 0; i--) {
        final detalle = compras[i].detalles.firstWhereOrNull(
          (d) => d.idProducto == idProducto,
        );
        if (detalle != null) return detalle.precioUnitario;
      }
      return null;
    } catch (e) {
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
    for (final d in detalles) subtotal += (d.precioUnitario ?? 0) * d.cantidad;
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
      setState(() => detalles.clear());
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Registrar Venta",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        centerTitle: true,
        elevation: 3,
      ),
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: cargarDatos,
                      color: Colors.deepPurple,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildCard(
                              title: "Cliente",
                              child: DropdownButtonFormField<Cliente>(
                                value: clienteSeleccionado,
                                decoration: InputDecoration(
                                  labelText: "Selecciona cliente",
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  labelStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                dropdownColor: Colors.grey[900],
                                items: clientes
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c.nombre,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
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
                                    decoration: InputDecoration(
                                      labelText: "Producto",
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[900],
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    dropdownColor: Colors.grey[900],
                                    items: productos
                                        .map(
                                          (p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(
                                              p.nombre,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
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
                                    decoration: InputDecoration(
                                      labelText: "Unidad de medida",
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[900],
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    dropdownColor: Colors.grey[900],
                                    items: unidadesFiltradas
                                        .map(
                                          (u) => DropdownMenuItem(
                                            value: u,
                                            child: Text(
                                              "${u.nombre} (${u.abreviacion})",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (u) =>
                                        setState(() => unidadSeleccionada = u),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _cantidadCtrl,
                                    decoration: InputDecoration(
                                      labelText: "Cantidad",
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[900],
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
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
                                            20,
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
                                                Colors.deepPurple.shade900,
                                              ),
                                          headingTextStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          columnSpacing: 16,
                                          border: TableBorder(
                                            top: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2,
                                            ),
                                            left: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2,
                                            ),
                                            right: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2,
                                            ),
                                            horizontalInside: BorderSide(
                                              color: Colors.deepPurple
                                                  .withOpacity(0.2),
                                            ),
                                            verticalInside: BorderSide(
                                              color: Colors.deepPurple
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          columns: const [
                                            DataColumn(
                                              label: Text(
                                                "Producto",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Unidad",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Cant.",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Precio",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Subtotal",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Eliminar",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
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
                                                DataCell(
                                                  Text(
                                                    producto.nombre,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    unidad.abreviacion,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    d.cantidad.toStringAsFixed(
                                                      2,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
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
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    formatter.format(subtotal),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
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
                      color: Color(0xFF6A1B9A),
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
                              borderRadius: BorderRadius.circular(20),
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
      color: Colors.grey[850],
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
                color: Colors.white,
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
