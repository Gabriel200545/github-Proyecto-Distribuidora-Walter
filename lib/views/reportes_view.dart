import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/reportes_service.dart';
import '../models/reportes_model.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  late Future<TotalVentas> totalVentasFuture;
  late Future<GastoTotal> gastoTotalFuture;
  late Future<List<CrecimientoMensual>> crecimientoFuture;
  late Future<List<UnidadesVendidas>> unidadesVendidasFuture;
  late Future<List<CostoPromedio>> costoPromedioFuture;

  @override
  void initState() {
    super.initState();
    totalVentasFuture = ReportesService.getTotalVentas();
    gastoTotalFuture = ReportesService.getGastoTotal();
    crecimientoFuture = ReportesService.getCrecimientoMensual();
    unidadesVendidasFuture = ReportesService.getUnidadesVendidas();
    costoPromedioFuture = ReportesService.getCostoPromedio();
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

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
            // Tarjetas de métricas principales
            _buildMetricsCards(),
            SizedBox(height: cardSpacing * 2),

            // Crecimiento Mensual
            _buildSectionTitle('Crecimiento Mensual'),
            SizedBox(height: cardSpacing),
            _buildCrecimientoMensualChart(screenWidth),

            SizedBox(height: cardSpacing * 2),

            // Unidades Vendidas
            _buildSectionTitle('Unidades Vendidas'),
            SizedBox(height: cardSpacing),
            _buildUnidadesVendidasChart(screenWidth),

            SizedBox(height: cardSpacing * 2),

            // Costo Promedio
            _buildSectionTitle('Costo Promedio'),
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

  Widget _buildMetricsCards() {
    return isMobile
        ? Column(
            children: [
              _buildMetricCard(
                'Total Ventas',
                totalVentasFuture,
                (data) => '\$${data.total.toStringAsFixed(2)}',
                Colors.green,
                Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                'Gasto Total',
                gastoTotalFuture,
                (data) => '\$${data.total.toStringAsFixed(2)}',
                Colors.orange,
                Icons.trending_down,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Ventas',
                  totalVentasFuture,
                  (data) => '\$${data.total.toStringAsFixed(2)}',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Gasto Total',
                  gastoTotalFuture,
                  (data) => '\$${data.total.toStringAsFixed(2)}',
                  Colors.orange,
                  Icons.trending_down,
                ),
              ),
            ],
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
            final maxY = maxValue > 0 ? (maxValue * 1.2).toDouble() : 100.0;
            final minY = minValue < 0 ? (minValue * 1.2).toDouble() : 0.0;

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
                        interval: maxY > 50 ? 20 : 10,
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
                    horizontalInterval: maxY > 50 ? 20 : 10,
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
