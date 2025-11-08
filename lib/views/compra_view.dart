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

class _CompraViewState extends State<CompraView>
    with SingleTickerProviderStateMixin {
  List<Proveedor> proveedores = [];
  List<Producto> productos = [];
  List<UnidadMedida> unidades = [];
  List<UnidadMedida> unidadesFiltradas = [];
  List<Bodega> bodegas = [];
  List<DetalleCompra> detalles = [];

  Proveedor? proveedorSeleccionado;
  bool proveedorVisible = true;
  bool mostrarFormulario = false;

  // Campos del formulario
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

  void guardarProducto() {
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

      // Ocultar formulario
      mostrarFormulario = false;

      // Limpiar formulario
      productoSeleccionado = null;
      unidadSeleccionada = null;
      bodegaSeleccionada = null;
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
        proveedorVisible = true;
        proveedorSeleccionado = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al registrar la compra.")),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String label, {
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: _inputDecoration(label).copyWith(
        suffixIcon: onTap != null
            ? const Icon(Icons.calendar_today, size: 18, color: Colors.white)
            : null,
      ),
      style: const TextStyle(color: Colors.white, fontSize: 12),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Registrar Compra",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 3,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Proveedor visible solo si proveedorVisible es true
                  if (proveedorVisible)
                    _buildCard(
                      title: "Proveedor",
                      child: DropdownButtonFormField<Proveedor>(
                        dropdownColor: const Color(0xFF1E1E1E),
                        value: proveedorSeleccionado,
                        decoration: _inputDecoration("Selecciona proveedor"),
                        items: proveedores
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.nombre,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (p) =>
                            setState(() => proveedorSeleccionado = p),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Formulario de producto
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: mostrarFormulario
                        ? _buildCard(
                            title: "Agregar Producto",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<Producto>(
                                  dropdownColor: const Color(0xFF1E1E1E),
                                  decoration: _inputDecoration("Producto"),
                                  value: productoSeleccionado,
                                  items: productos
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(
                                            p.nombre,
                                            style: const TextStyle(
                                              fontSize: 12,
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
                                const SizedBox(height: 6),
                                DropdownButtonFormField<UnidadMedida>(
                                  dropdownColor: const Color(0xFF1E1E1E),
                                  decoration: _inputDecoration(
                                    "Unidad de medida",
                                  ),
                                  value: unidadSeleccionada,
                                  items: unidadesFiltradas
                                      .map(
                                        (u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(
                                            "${u.nombre} (${u.abreviacion})",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (u) =>
                                      setState(() => unidadSeleccionada = u),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<Bodega>(
                                  dropdownColor: const Color(0xFF1E1E1E),
                                  decoration: _inputDecoration("Bodega"),
                                  value: bodegaSeleccionada,
                                  items: bodegas
                                      .map(
                                        (b) => DropdownMenuItem(
                                          value: b,
                                          child: Text(
                                            b.nombre,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (b) =>
                                      setState(() => bodegaSeleccionada = b),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _textField(
                                        _cantidadCtrl,
                                        "Cantidad",
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _textField(
                                        _precioCtrl,
                                        "Precio unitario",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _textField(
                                        _fechaFabCtrl,
                                        "Fecha fabricación",
                                        onTap: () =>
                                            seleccionarFecha(_fechaFabCtrl),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _textField(
                                        _fechaCadCtrl,
                                        "Fecha caducidad",
                                        onTap: () =>
                                            seleccionarFecha(_fechaCadCtrl),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: guardarProducto,
                                    icon: const Icon(
                                      Icons.save_outlined,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      "Guardar",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 8),

                  // Tabla de productos
                  detalles.isEmpty
                      ? const Center(
                          child: Text(
                            "No hay productos agregados",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              Colors.deepPurple.shade100,
                            ),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 12,
                            ),
                            dataRowColor: MaterialStateProperty.all(
                              Colors.grey.shade900,
                            ),
                            columnSpacing: 12,
                            border: TableBorder.symmetric(
                              inside: BorderSide(
                                color: Colors.deepPurple.withOpacity(0.3),
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
                                  DataCell(
                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      unidad.abreviacion,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      d.cantidad.toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatter.format(d.precioUnitario),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatter.format(
                                        d.cantidad * d.precioUnitario,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_forever_rounded,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      onPressed: () => eliminarDetalle(i),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                ],
              ),
            ),
          ),
          // Footer fijo
          Container(
            width: double.infinity,
            color: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: ${formatter.format(totalGeneral)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          mostrarFormulario = true;
                          proveedorVisible = false;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: const Text(
                        "Agregar producto",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: registrarCompra,
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text(
                        "Registrar Compra",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
