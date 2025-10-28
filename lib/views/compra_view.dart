import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/compra_model.dart';
import '../models/producto_model.dart';
import '../models/proveedor_model.dart';
import '../models/unidad_medida_model.dart';
import '../models/bodega_model.dart';
import '../services/compra_service.dart';
import '../services/producto_service.dart';
import '../services/proveedor_service.dart';
import '../services/unidad_de_medida_service.dart';
import '../services/bodega_service.dart';

class CompraView extends StatefulWidget {
  const CompraView({super.key});

  @override
  State<CompraView> createState() => _CompraViewState();
}

class _CompraViewState extends State<CompraView> {
  List<Proveedor> proveedores = [];
  List<Producto> productos = [];
  List<UnidadMedida> unidades = [];
  List<UnidadMedida> unidadesFiltradas = [];
  List<Bodega> bodegas = [];
  List<DetalleCompra> detalles = [];

  Proveedor? proveedorSeleccionado;
  Producto? productoSeleccionado;
  UnidadMedida? unidadSeleccionada;
  Bodega? bodegaSeleccionada;

  final _cantidadCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _fechaFabCtrl = TextEditingController();
  final _fechaCadCtrl = TextEditingController();

  double get totalGeneral =>
      detalles.fold(0, (sum, d) => sum + (d.cantidad * d.precioUnitario));

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    proveedores = await ProveedorService.getProveedores();
    productos = await ProductoService.getProductos();
    unidades = await UnidadMedidaService.getUnidades();
    bodegas = await BodegaService.getBodegas();
    setState(() {});
  }

  void filtrarUnidadesPorProducto() {
    if (productoSeleccionado == null) {
      unidadesFiltradas = unidades;
    } else {
      unidadesFiltradas = unidades
          .where((u) => u.idUnidad == productoSeleccionado!.idUnidadMedida)
          .toList();
    }
    unidadSeleccionada = unidadesFiltradas.isNotEmpty
        ? unidadesFiltradas.first
        : null;
  }

  Future<void> seleccionarFecha(TextEditingController controller) async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
    );
    if (fechaSeleccionada != null) {
      controller.text = DateFormat(
        'yyyy-MM-ddTHH:mm:ss',
      ).format(fechaSeleccionada);
    }
  }

  void agregarDetalle() {
    if (productoSeleccionado == null ||
        unidadSeleccionada == null ||
        bodegaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona producto, unidad y bodega.")),
      );
      return;
    }

    final cantidad = double.tryParse(_cantidadCtrl.text) ?? 0;
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    if (cantidad <= 0 || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cantidad y precio deben ser > 0.")),
      );
      return;
    }

    final lote = "L${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";

    final detalle = DetalleCompra(
      idProducto: productoSeleccionado!.idProducto,
      cantidad: cantidad,
      idUnidadMedida: unidadSeleccionada!.idUnidad,
      precioUnitario: precio,
      codigoLote: lote,
      fechaFabricacion: _fechaFabCtrl.text,
      fechaCaducidad: _fechaCadCtrl.text,
      idBodega: bodegaSeleccionada!.idBodega,
    );

    setState(() {
      detalles.add(detalle);
      _cantidadCtrl.clear();
      _precioCtrl.clear();
      _fechaFabCtrl.clear();
      _fechaCadCtrl.clear();
    });
  }

  void eliminarDetalle(int index) {
    setState(() {
      detalles.removeAt(index);
    });
  }

  Future<void> registrarCompra() async {
    if (proveedorSeleccionado == null || detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona proveedor y agrega al menos un detalle."),
        ),
      );
      return;
    }

    final compra = Compra(
      idProveedor: proveedorSeleccionado!.idProveedor!,
      fecha: DateTime.now().toIso8601String(),
      usuarioRegistro: "admin",
      detalles: detalles,
    );

    final ok = await CompraService.registrarCompra(compra);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Compra registrada correctamente.")),
      );
      setState(() {
        detalles.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al registrar la compra.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      appBar: AppBar(
        title: const Text(
          "Registrar Compra",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 3,
      ),
      body: SafeArea(
        child: Column(
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
                        title: "Proveedor",
                        child: DropdownButtonFormField<Proveedor>(
                          initialValue: proveedorSeleccionado,
                          decoration: const InputDecoration(
                            labelText: "Selecciona proveedor",
                            border: OutlineInputBorder(),
                          ),
                          items: proveedores
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.nombre),
                                ),
                              )
                              .toList(),
                          onChanged: (p) =>
                              setState(() => proveedorSeleccionado = p),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildCard(
                        title: "Agregar producto",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<Producto>(
                              initialValue: productoSeleccionado,
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
                              initialValue: unidadSeleccionada,
                              decoration: const InputDecoration(
                                labelText: "Unidad de medida",
                                border: OutlineInputBorder(),
                              ),
                              items: unidadesFiltradas
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        "${u.nombre} (${u.abreviacion}) - ${u.tipoUnidad}",
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (u) =>
                                  setState(() => unidadSeleccionada = u),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Bodega>(
                              initialValue: bodegaSeleccionada,
                              decoration: const InputDecoration(
                                labelText: "Bodega",
                                border: OutlineInputBorder(),
                              ),
                              items: bodegas
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b.nombre),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (b) =>
                                  setState(() => bodegaSeleccionada = b),
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
                                Expanded(
                                  child: TextField(
                                    controller: _precioCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "Precio unitario",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _fechaFabCtrl,
                                    readOnly: true,
                                    onTap: () =>
                                        seleccionarFecha(_fechaFabCtrl),
                                    decoration: const InputDecoration(
                                      labelText: "Fecha fabricación",
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _fechaCadCtrl,
                                    readOnly: true,
                                    onTap: () =>
                                        seleccionarFecha(_fechaCadCtrl),
                                    decoration: const InputDecoration(
                                      labelText: "Fecha caducidad",
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: agregarDetalle,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text("Agregar Detalle"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🧾 Tabla con scroll interno
                      if (detalles.isNotEmpty)
                        _buildCard(
                          title: "Detalles de la compra",
                          child: SizedBox(
                            height: 300,
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.deepPurple.shade50,
                                    ),
                                    columnSpacing: 16,
                                    headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                    border: TableBorder.symmetric(
                                      inside: BorderSide(
                                        color: Colors.deepPurple.withOpacity(
                                          0.1,
                                        ),
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
                                    rows: List.generate(detalles.length, (i) {
                                      final d = detalles[i];
                                      final producto = productos.firstWhere(
                                        (p) => p.idProducto == d.idProducto,
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
                                        (u) => u.idUnidad == d.idUnidadMedida,
                                        orElse: () => UnidadMedida(
                                          idUnidad: 0,
                                          nombre: "Desconocida",
                                          abreviacion: "-",
                                          tipoUnidad: "-",
                                        ),
                                      );
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(producto.nombre)),
                                          DataCell(Text(unidad.abreviacion)),
                                          DataCell(
                                            Text(d.cantidad.toStringAsFixed(2)),
                                          ),
                                          DataCell(
                                            Text(
                                              formatter.format(
                                                d.precioUnitario,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatter.format(
                                                d.cantidad * d.precioUnitario,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_forever_rounded,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Total: ${formatter.format(totalGeneral)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: registrarCompra,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Registrar Compra"),
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
