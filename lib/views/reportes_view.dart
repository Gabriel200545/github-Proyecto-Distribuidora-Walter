import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/reportes_service.dart';
import '../models/reportes_model.dart';
import '../services/categoria_service.dart';
import '../services/marca_service.dart';
import '../services/proveedor_service.dart';
import '../models/categoria_model.dart';
import '../models/marca_model.dart';
import '../models/proveedor_model.dart';
import 'package:intl/intl.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  // Estados para TotalVentas
  DateTime? _totalVentasFechaInicio;
  DateTime? _totalVentasFechaFin;
  int? _totalVentasAnio;
  int? _totalVentasMes;
  late Future<TotalVentas> totalVentasFuture;

  // Estados para GastoTotal
  DateTime? _gastoTotalFechaInicio;
  DateTime? _gastoTotalFechaFin;
  int? _gastoTotalAnio;
  int? _gastoTotalMes;
  int? _gastoTotalProveedorId;
  late Future<GastoTotal> gastoTotalFuture;
  late Future<List<Proveedor>> proveedoresFuture;

  // Estados para CrecimientoMensual
  int? _crecimientoAnio;
  int? _crecimientoMesInicio;
  int? _crecimientoMesFin;
  String? _crecimientoPeriodo; // 'mensual' o 'trimestral'
  late Future<List<CrecimientoMensual>> crecimientoFuture;

  // Estados para UnidadesVendidas
  DateTime? _unidadesFechaInicio;
  DateTime? _unidadesFechaFin;
  int? _unidadesCategoriaId;
  int? _unidadesMarcaId;
  int? _unidadesTop;
  late Future<List<UnidadesVendidas>> unidadesVendidasFuture;
  late Future<List<Categoria>> categoriasFuture;
  late Future<List<Marca>> marcasFuture;

  // Estados para CostoPromedio
  int? _costoCategoriaId;
  int? _costoProveedorId;
  DateTime? _costoFechaInicio;
  DateTime? _costoFechaFin;
  int? _costoTop;
  late Future<List<CostoPromedio>> costoPromedioFuture;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    setState(() {
      totalVentasFuture = ReportesService.getTotalVentas();
      gastoTotalFuture = ReportesService.getGastoTotal();
      crecimientoFuture = ReportesService.getCrecimientoMensual();
      unidadesVendidasFuture = ReportesService.getUnidadesVendidas();
      costoPromedioFuture = ReportesService.getCostoPromedio();
      proveedoresFuture = ProveedorService.getProveedores();
      categoriasFuture = CategoriaService.getCategorias();
      marcasFuture = MarcaService.getMarcas();
    });
  }

  void _updateTotalVentas() {
    setState(() {
      totalVentasFuture = ReportesService.getTotalVentas(
        fechaInicio: _totalVentasFechaInicio,
        fechaFin: _totalVentasFechaFin,
        anio: _totalVentasAnio,
        mes: _totalVentasMes,
      );
    });
  }

  void _updateGastoTotal() {
    setState(() {
      gastoTotalFuture = ReportesService.getGastoTotal(
        fechaInicio: _gastoTotalFechaInicio,
        fechaFin: _gastoTotalFechaFin,
        anio: _gastoTotalAnio,
        mes: _gastoTotalMes,
        proveedorId: _gastoTotalProveedorId,
      );
    });
  }

  void _updateCrecimientoMensual() {
    setState(() {
      crecimientoFuture = ReportesService.getCrecimientoMensual(
        anio: _crecimientoAnio,
        mesInicio: _crecimientoMesInicio,
        mesFin: _crecimientoMesFin,
        periodo: _crecimientoPeriodo,
      );
    });
  }

  void _updateUnidadesVendidas() {
    setState(() {
      unidadesVendidasFuture = ReportesService.getUnidadesVendidas(
        fechaInicio: _unidadesFechaInicio,
        fechaFin: _unidadesFechaFin,
        categoriaId: _unidadesCategoriaId,
        marcaId: _unidadesMarcaId,
        top: _unidadesTop,
      );
    });
  }

  void _updateCostoPromedio() {
    setState(() {
      costoPromedioFuture = ReportesService.getCostoPromedio(
        categoriaId: _costoCategoriaId,
        proveedorId: _costoProveedorId,
        fechaInicio: _costoFechaInicio,
        fechaFin: _costoFechaFin,
        top: _costoTop,
      );
    });
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  // Calcula el intervalo apropiado para el eje Y basado en el rango
  double _calculateInterval(double range) {
    if (range <= 0) return 10.0;
    if (range <= 50) return 10.0;
    if (range <= 100) return 20.0;
    if (range <= 200) return 50.0;
    if (range <= 500) return 100.0;
    if (range <= 1000) return 200.0;
    return 500.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = isMobile
        ? 16.0
        : isTablet
        ? 24.0
        : 32.0;
    final cardSpacing = isMobile ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Reportes Distribuidora',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Ventas con filtros
            _buildSectionTitle('Total Ventas'),
            SizedBox(height: cardSpacing),
            _buildTotalVentasFilters(),
            SizedBox(height: cardSpacing),
            _buildMetricCard(
              'Total Ventas',
              totalVentasFuture,
              (data) => '\$${data.total.toStringAsFixed(2)}',
              Colors.green,
              Icons.trending_up,
            ),

            SizedBox(height: cardSpacing * 2),

            // Gasto Total con filtros
            _buildSectionTitle('Gasto Total'),
            SizedBox(height: cardSpacing),
            _buildGastoTotalFilters(),
            SizedBox(height: cardSpacing),
            _buildMetricCard(
              'Gasto Total',
              gastoTotalFuture,
              (data) => '\$${data.total.toStringAsFixed(2)}',
              Colors.orange,
              Icons.trending_down,
            ),

            SizedBox(height: cardSpacing * 2),

            // Crecimiento Mensual con filtros
            _buildSectionTitle('Crecimiento Mensual'),
            SizedBox(height: cardSpacing),
            _buildCrecimientoMensualFilters(),
            SizedBox(height: cardSpacing),
            _buildCrecimientoMensualChart(screenWidth),

            SizedBox(height: cardSpacing * 2),

            // Unidades Vendidas con filtros
            _buildSectionTitle('Unidades Vendidas'),
            SizedBox(height: cardSpacing),
            _buildUnidadesVendidasFilters(),
            SizedBox(height: cardSpacing),
            _buildUnidadesVendidasChart(screenWidth),

            SizedBox(height: cardSpacing * 2),

            // Costo Promedio con filtros
            _buildSectionTitle('Costo Promedio'),
            SizedBox(height: cardSpacing),
            _buildCostoPromedioFilters(),
            SizedBox(height: cardSpacing),
            _buildCostoPromedioChart(screenWidth),

            SizedBox(height: cardSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // Filtros para TotalVentas
  Widget _buildTotalVentasFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildDatePicker(
            label: 'Fecha Inicio',
            value: _totalVentasFechaInicio,
            onChanged: (date) {
              setState(() => _totalVentasFechaInicio = date);
              _updateTotalVentas();
            },
            onClear: () {
              setState(() => _totalVentasFechaInicio = null);
              _updateTotalVentas();
            },
          ),
          _buildDatePicker(
            label: 'Fecha Fin',
            value: _totalVentasFechaFin,
            onChanged: (date) {
              setState(() => _totalVentasFechaFin = date);
              _updateTotalVentas();
            },
            onClear: () {
              setState(() => _totalVentasFechaFin = null);
              _updateTotalVentas();
            },
          ),
          _buildYearPicker(
            label: 'Año',
            value: _totalVentasAnio,
            onChanged: (year) {
              setState(() => _totalVentasAnio = year);
              _updateTotalVentas();
            },
            onClear: () {
              setState(() => _totalVentasAnio = null);
              _updateTotalVentas();
            },
          ),
          _buildMonthPicker(
            label: 'Mes',
            value: _totalVentasMes,
            onChanged: (month) {
              setState(() => _totalVentasMes = month);
              _updateTotalVentas();
            },
            onClear: () {
              setState(() => _totalVentasMes = null);
              _updateTotalVentas();
            },
          ),
        ],
      ),
    );
  }

  // Filtros para GastoTotal
  Widget _buildGastoTotalFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildDatePicker(
            label: 'Fecha Inicio',
            value: _gastoTotalFechaInicio,
            onChanged: (date) {
              setState(() => _gastoTotalFechaInicio = date);
              _updateGastoTotal();
            },
            onClear: () {
              setState(() => _gastoTotalFechaInicio = null);
              _updateGastoTotal();
            },
          ),
          _buildDatePicker(
            label: 'Fecha Fin',
            value: _gastoTotalFechaFin,
            onChanged: (date) {
              setState(() => _gastoTotalFechaFin = date);
              _updateGastoTotal();
            },
            onClear: () {
              setState(() => _gastoTotalFechaFin = null);
              _updateGastoTotal();
            },
          ),
          _buildYearPicker(
            label: 'Año',
            value: _gastoTotalAnio,
            onChanged: (year) {
              setState(() => _gastoTotalAnio = year);
              _updateGastoTotal();
            },
            onClear: () {
              setState(() => _gastoTotalAnio = null);
              _updateGastoTotal();
            },
          ),
          _buildMonthPicker(
            label: 'Mes',
            value: _gastoTotalMes,
            onChanged: (month) {
              setState(() => _gastoTotalMes = month);
              _updateGastoTotal();
            },
            onClear: () {
              setState(() => _gastoTotalMes = null);
              _updateGastoTotal();
            },
          ),
          _buildProveedorDropdown(
            value: _gastoTotalProveedorId,
            onChanged: (id) {
              setState(() => _gastoTotalProveedorId = id);
              _updateGastoTotal();
            },
            onClear: () {
              setState(() => _gastoTotalProveedorId = null);
              _updateGastoTotal();
            },
          ),
        ],
      ),
    );
  }

  // Filtros para CrecimientoMensual
  Widget _buildCrecimientoMensualFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildYearPicker(
            label: 'Año',
            value: _crecimientoAnio,
            onChanged: (year) {
              setState(() => _crecimientoAnio = year);
              _updateCrecimientoMensual();
            },
            onClear: () {
              setState(() => _crecimientoAnio = null);
              _updateCrecimientoMensual();
            },
          ),
          _buildMonthPicker(
            label: 'Mes Inicio',
            value: _crecimientoMesInicio,
            onChanged: (month) {
              setState(() => _crecimientoMesInicio = month);
              _updateCrecimientoMensual();
            },
            onClear: () {
              setState(() => _crecimientoMesInicio = null);
              _updateCrecimientoMensual();
            },
          ),
          _buildMonthPicker(
            label: 'Mes Fin',
            value: _crecimientoMesFin,
            onChanged: (month) {
              setState(() => _crecimientoMesFin = month);
              _updateCrecimientoMensual();
            },
            onClear: () {
              setState(() => _crecimientoMesFin = null);
              _updateCrecimientoMensual();
            },
          ),
          _buildPeriodoDropdown(
            value: _crecimientoPeriodo,
            onChanged: (periodo) {
              setState(() => _crecimientoPeriodo = periodo);
              _updateCrecimientoMensual();
            },
            onClear: () {
              setState(() => _crecimientoPeriodo = null);
              _updateCrecimientoMensual();
            },
          ),
        ],
      ),
    );
  }

  // Filtros para UnidadesVendidas
  Widget _buildUnidadesVendidasFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildDatePicker(
            label: 'Fecha Inicio',
            value: _unidadesFechaInicio,
            onChanged: (date) {
              setState(() => _unidadesFechaInicio = date);
              _updateUnidadesVendidas();
            },
            onClear: () {
              setState(() => _unidadesFechaInicio = null);
              _updateUnidadesVendidas();
            },
          ),
          _buildDatePicker(
            label: 'Fecha Fin',
            value: _unidadesFechaFin,
            onChanged: (date) {
              setState(() => _unidadesFechaFin = date);
              _updateUnidadesVendidas();
            },
            onClear: () {
              setState(() => _unidadesFechaFin = null);
              _updateUnidadesVendidas();
            },
          ),
          _buildCategoriaDropdown(
            value: _unidadesCategoriaId,
            onChanged: (id) {
              setState(() => _unidadesCategoriaId = id);
              _updateUnidadesVendidas();
            },
            onClear: () {
              setState(() => _unidadesCategoriaId = null);
              _updateUnidadesVendidas();
            },
          ),
          _buildMarcaDropdown(
            value: _unidadesMarcaId,
            onChanged: (id) {
              setState(() => _unidadesMarcaId = id);
              _updateUnidadesVendidas();
            },
            onClear: () {
              setState(() => _unidadesMarcaId = null);
              _updateUnidadesVendidas();
            },
          ),
          _buildTopXInput(
            value: _unidadesTop,
            onChanged: (top) {
              setState(() => _unidadesTop = top);
              _updateUnidadesVendidas();
            },
            onClear: () {
              setState(() => _unidadesTop = null);
              _updateUnidadesVendidas();
            },
          ),
        ],
      ),
    );
  }

  // Filtros para CostoPromedio
  Widget _buildCostoPromedioFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildCategoriaDropdown(
            value: _costoCategoriaId,
            onChanged: (id) {
              setState(() => _costoCategoriaId = id);
              _updateCostoPromedio();
            },
            onClear: () {
              setState(() => _costoCategoriaId = null);
              _updateCostoPromedio();
            },
          ),
          _buildProveedorDropdown(
            value: _costoProveedorId,
            onChanged: (id) {
              setState(() => _costoProveedorId = id);
              _updateCostoPromedio();
            },
            onClear: () {
              setState(() => _costoProveedorId = null);
              _updateCostoPromedio();
            },
          ),
          _buildDatePicker(
            label: 'Fecha Inicio',
            value: _costoFechaInicio,
            onChanged: (date) {
              setState(() => _costoFechaInicio = date);
              _updateCostoPromedio();
            },
            onClear: () {
              setState(() => _costoFechaInicio = null);
              _updateCostoPromedio();
            },
          ),
          _buildDatePicker(
            label: 'Fecha Fin',
            value: _costoFechaFin,
            onChanged: (date) {
              setState(() => _costoFechaFin = date);
              _updateCostoPromedio();
            },
            onClear: () {
              setState(() => _costoFechaFin = null);
              _updateCostoPromedio();
            },
          ),
          _buildTopXInput(
            value: _costoTop,
            onChanged: (top) {
              setState(() => _costoTop = top);
              _updateCostoPromedio();
            },
            onClear: () {
              setState(() => _costoTop = null);
              _updateCostoPromedio();
            },
          ),
        ],
      ),
    );
  }

  // Widgets de filtros reutilizables
  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
    required VoidCallback onClear,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF6A1B9A),
                        onPrimary: Colors.white,
                        surface: Color(0xFF1E1E1E),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) onChanged(date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value != null
                          ? DateFormat('yyyy-MM-dd').format(value)
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        color: value != null ? Colors.white : Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (value != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.white70),
                      onPressed: onClear,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearPicker({
    required String label,
    required int? value,
    required Function(int?) onChanged,
    required VoidCallback onClear,
  }) {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (i) => currentYear - i);

    return SizedBox(
      width: isMobile ? double.infinity : 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Todos', style: TextStyle(color: Colors.white54)),
                  ),
                  ...years.map((year) => DropdownMenuItem<int?>(
                    value: year,
                    child: Text(year.toString()),
                  )),
                ],
                onChanged: (val) {
                  if (val == null) {
                    onClear();
                  } else {
                    onChanged(val);
                  }
                },
                hint: const Text('Seleccionar', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker({
    required String label,
    required int? value,
    required Function(int?) onChanged,
    required VoidCallback onClear,
  }) {
    final months = [
      {'value': 1, 'name': 'Enero'},
      {'value': 2, 'name': 'Febrero'},
      {'value': 3, 'name': 'Marzo'},
      {'value': 4, 'name': 'Abril'},
      {'value': 5, 'name': 'Mayo'},
      {'value': 6, 'name': 'Junio'},
      {'value': 7, 'name': 'Julio'},
      {'value': 8, 'name': 'Agosto'},
      {'value': 9, 'name': 'Septiembre'},
      {'value': 10, 'name': 'Octubre'},
      {'value': 11, 'name': 'Noviembre'},
      {'value': 12, 'name': 'Diciembre'},
    ];

    return SizedBox(
      width: isMobile ? double.infinity : 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Todos', style: TextStyle(color: Colors.white54)),
                  ),
                  ...months.map((m) => DropdownMenuItem<int?>(
                    value: m['value'] as int,
                    child: Text(m['name'] as String),
                  )),
                ],
                onChanged: (val) {
                  if (val == null) {
                    onClear();
                  } else {
                    onChanged(val);
                  }
                },
                hint: const Text('Seleccionar', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorDropdown({
    required int? value,
    required Function(int?) onChanged,
    required VoidCallback onClear,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proveedor',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FutureBuilder<List<Proveedor>>(
            future: proveedoresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              final proveedores = snapshot.data ?? [];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todos', style: TextStyle(color: Colors.white54)),
                      ),
                      ...proveedores.map((p) => DropdownMenuItem<int?>(
                        value: p.idProveedor,
                        child: Text(p.nombre),
                      )),
                    ],
                    onChanged: (val) {
                      if (val == null) {
                        onClear();
                      } else {
                        onChanged(val);
                      }
                    },
                    hint: const Text('Seleccionar', style: TextStyle(color: Colors.white54)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaDropdown({
    required int? value,
    required Function(int?) onChanged,
    required VoidCallback onClear,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categoría',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FutureBuilder<List<Categoria>>(
            future: categoriasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              final categorias = snapshot.data ?? [];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todos', style: TextStyle(color: Colors.white54)),
                      ),
                      ...categorias.map((c) => DropdownMenuItem<int?>(
                        value: c.id,
                        child: Text(c.nombre),
                      )),
                    ],
                    onChanged: (val) {
                      if (val == null) {
                        onClear();
                      } else {
                        onChanged(val);
                      }
                    },
                    hint: const Text('Seleccionar', style: TextStyle(color: Colors.white54)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMarcaDropdown({
    required int? value,
    required Function(int?) onChanged,
    required VoidCallback onClear,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Marca',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FutureBuilder<List<Marca>>(
            future: marcasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              final marcas = snapshot.data ?? [];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todos', style: TextStyle(color: Colors.white54)),
                      ),
                      ...marcas.map((m) => DropdownMenuItem<int?>(
                        value: m.idMarca,
                        child: Text(m.nombre),
                      )),
                    ],
                    onChanged: (val) {
                      if (val == null) {
                        onClear();
                      } else {
                        onChanged(val);
                      }
                    },
                    hint: const Text('Seleccionar', style: TextStyle(color: Colors.white54)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodoDropdown({
    required String? value,
    required Function(String?) onChanged,
    required VoidCallback onClear,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Período',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos', style: TextStyle(color: Colors.white54)),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'mensual',
                    child: Text('Mensual'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'trimestral',
                    child: Text('Trimestral'),
                  ),
                ],
                onChanged: (val) {
                  if (val == null) {
                    onClear();
                  } else {
                    onChanged(val);
                  }
                },
                hint: const Text('Seleccionar', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopXInput({
    required int? value,
    required Function(int?) onChanged,
    required VoidCallback onClear,
  }) {
    final controller = TextEditingController(
      text: value != null ? value.toString() : '',
    );

    return SizedBox(
      width: isMobile ? double.infinity : 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top X',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
              ),
              hintText: 'Ej: 10',
              hintStyle: const TextStyle(color: Colors.white54),
              suffixIcon: value != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.white70),
                      onPressed: () {
                        controller.clear();
                        onClear();
                      },
                    )
                  : null,
            ),
            onChanged: (text) {
              final top = int.tryParse(text);
              onChanged(top);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard<T>(
    String title,
    Future<T> future,
    String Function(T) valueBuilder,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            );
          } else if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar',
                  style: TextStyle(color: Colors.red.shade300, fontSize: 12),
                ),
              ],
            );
          } else if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  valueBuilder(snapshot.data as T),
                  style: TextStyle(
                    color: color,
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          } else {
            return Text(
              'Sin datos',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            );
          }
        },
      ),
    );
  }

  Widget _buildCrecimientoMensualChart(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: FutureBuilder<List<CrecimientoMensual>>(
        future: crecimientoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: isMobile ? 250 : 300,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: isMobile ? 250 : 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar datos',
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            final maxValue = data
                .map((e) => e.porcentaje)
                .reduce((a, b) => a > b ? a : b);
            final minValue = data
                .map((e) => e.porcentaje)
                .reduce((a, b) => a < b ? a : b);
            
            // Calcular rango más inteligente
            final range = maxValue - minValue;
            double maxY;
            double minY;
            
            if (range == 0) {
              // Si todos los valores son iguales (un solo punto o mismo valor)
              final center = maxValue;
              maxY = center + 20.0;
              minY = center - 20.0;
            } else {
              // Agregar margen del 15% del rango, con límites razonables
              final margin = range * 0.15;
              maxY = maxValue + margin;
              minY = minValue - margin;
              
              // Asegurar que el rango mínimo sea visible
              if (maxY - minY < 20) {
                final center = (maxValue + minValue) / 2;
                maxY = center + 20.0;
                minY = center - 20.0;
              }
            }
            
            // Redondear a múltiplos de 10 para mejor visualización
            maxY = (maxY / 10).ceil() * 10.0;
            minY = (minY / 10).floor() * 10.0;

            return SizedBox(
              height: isMobile
                  ? 250
                  : isTablet
                  ? 300
                  : 350,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 30 : 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                data[index].mes.length > 6
                                    ? data[index].mes.substring(0, 6)
                                    : data[index].mes,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isMobile ? 10 : 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 40 : 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 10 : 12,
                            ),
                          );
                        },
                        interval: _calculateInterval(maxY - minY),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.porcentaje);
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: Colors.blue,
                      barWidth: isMobile ? 3 : 4,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: isMobile ? 4 : 5,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(maxY - minY),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return SizedBox(
              height: isMobile ? 250 : 300,
              child: Center(
                child: Text(
                  'Sin datos de crecimiento',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUnidadesVendidasChart(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: FutureBuilder<List<UnidadesVendidas>>(
        future: unidadesVendidasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: isMobile ? 300 : 350,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: isMobile ? 300 : 350,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar datos',
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            final maxY =
                data.map((e) => e.unidades).reduce((a, b) => a > b ? a : b) *
                1.2;

            // Calcular ancho necesario
            final barWidth = isMobile
                ? 40.0
                : isTablet
                ? 50.0
                : 60.0;
            final spacing = isMobile ? 8.0 : 12.0;
            final totalWidth = (data.length * (barWidth + spacing)) + 80;
            final needsScroll = totalWidth > screenWidth - 32;

            return SizedBox(
              height: isMobile ? 300 : 350,
              child: needsScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: totalWidth,
                        child: _buildBarChart(
                          data,
                          maxY,
                          barWidth,
                          Colors.green,
                          (item) => item.unidades,
                        ),
                      ),
                    )
                  : _buildBarChart(
                      data,
                      maxY,
                      barWidth,
                      Colors.green,
                      (item) => item.unidades,
                    ),
            );
          } else {
            return SizedBox(
              height: isMobile ? 300 : 350,
              child: Center(
                child: Text(
                  'Sin datos de unidades vendidas',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCostoPromedioChart(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: FutureBuilder<List<CostoPromedio>>(
        future: costoPromedioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: isMobile ? 300 : 350,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: isMobile ? 300 : 350,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar datos',
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            final maxY =
                data.map((e) => e.costo).reduce((a, b) => a > b ? a : b) * 1.2;

            // Calcular ancho necesario
            final barWidth = isMobile
                ? 40.0
                : isTablet
                ? 50.0
                : 60.0;
            final spacing = isMobile ? 8.0 : 12.0;
            final totalWidth = (data.length * (barWidth + spacing)) + 80;
            final needsScroll = totalWidth > screenWidth - 32;

            return SizedBox(
              height: isMobile ? 300 : 350,
              child: needsScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: totalWidth,
                        child: _buildBarChart(
                          data,
                          maxY,
                          barWidth,
                          Colors.orange,
                          (item) => item.costo,
                        ),
                      ),
                    )
                  : _buildBarChart(
                      data,
                      maxY,
                      barWidth,
                      Colors.orange,
                      (item) => item.costo,
                    ),
            );
          } else {
            return SizedBox(
              height: isMobile ? 300 : 350,
              child: Center(
                child: Text(
                  'Sin datos de costo promedio',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBarChart<T>(
    List<T> data,
    double maxY,
    double barWidth,
    Color color,
    double Function(T) valueGetter,
  ) {
    String getProductName(T item) {
      if (item is UnidadesVendidas) return item.producto;
      if (item is CostoPromedio) return item.producto;
      return '';
    }

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isMobile ? 50 : 60,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final productName = getProductName(data[index]);
                  // Truncar nombres largos
                  final displayName = productName.length > 8
                      ? '${productName.substring(0, 8)}...'
                      : productName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: RotatedBox(
                      quarterTurns: isMobile ? 1 : 0,
                      child: Text(
                        displayName,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 9 : 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isMobile ? 50 : 60,
              getTitlesWidget: (value, meta) {
                // Formatear números grandes
                String formatValue(double val) {
                  if (val >= 1000) {
                    return '${(val / 1000).toStringAsFixed(1)}K';
                  }
                  return val.toInt().toString();
                }

                return Text(
                  formatValue(value),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 10 : 12,
                  ),
                );
              },
              interval: maxY > 100 ? maxY / 5 : maxY / 4,
            ),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: valueGetter(item),
                color: color,
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 100 ? maxY / 5 : maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => color.withOpacity(0.9),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = data[groupIndex];
              final value = valueGetter(item);
              final productName = getProductName(item);
              return BarTooltipItem(
                '$productName\n${value.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
