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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Distribuidora')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Ventas
            FutureBuilder<TotalVentas>(
              future: totalVentasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(
                    'Total Ventas: \$${snapshot.data!.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return const Text('Sin datos de ventas');
                }
              },
            ),
            const SizedBox(height: 16),

            // Gasto Total
            FutureBuilder<GastoTotal>(
              future: gastoTotalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(
                    'Gasto Total: \$${snapshot.data!.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return const Text('Sin datos de gasto');
                }
              },
            ),
            const SizedBox(height: 24),

            // Crecimiento Mensual
            const Text(
              'Crecimiento Mensual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<CrecimientoMensual>>(
              future: crecimientoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final data = snapshot.data!;
                  return Container(
                    height: 220,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY:
                            data
                                .map((e) => e.porcentaje)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < data.length) {
                                  return Text(
                                    data[index].mes,
                                    style: const TextStyle(fontSize: 12),
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
                              interval: 10,
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: data.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                e.value.porcentaje.toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.blue,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  );
                } else {
                  return const Text('Sin datos de crecimiento');
                }
              },
            ),
            const SizedBox(height: 24),

            // Unidades Vendidas
            const Text(
              'Unidades Vendidas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<UnidadesVendidas>>(
              future: unidadesVendidasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final data = snapshot.data!;
                  final maxY =
                      data
                          .map((e) => e.unidades)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: data.length * 60.0, // Ancho mayor por barra
                      height: 280,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: BarChart(
                        BarChartData(
                          maxY: maxY.toDouble(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < data.length) {
                                    return RotatedBox(
                                      quarterTurns: 1,
                                      child: Text(
                                        data[index].producto,
                                        style: const TextStyle(fontSize: 12),
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
                                interval: 10,
                              ),
                            ),
                          ),
                          barGroups: data.asMap().entries.map((entry) {
                            final index = entry.key;
                            final e = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: e.unidades.toDouble(),
                                  color: Colors.green,
                                  width: 18,
                                ),
                              ],
                            );
                          }).toList(),
                          gridData: FlGridData(show: true),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Text('Sin datos de unidades vendidas');
                }
              },
            ),
            const SizedBox(height: 24),

            // Costo Promedio
            const Text(
              'Costo Promedio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<CostoPromedio>>(
              future: costoPromedioFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final data = snapshot.data!;
                  final maxY =
                      data.map((e) => e.costo).reduce((a, b) => a > b ? a : b) *
                      1.2;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: data.length * 60.0,
                      height: 280,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: BarChart(
                        BarChartData(
                          maxY: maxY.toDouble(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < data.length) {
                                    return RotatedBox(
                                      quarterTurns: 1,
                                      child: Text(
                                        data[index].producto,
                                        style: const TextStyle(fontSize: 12),
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
                                interval: 10,
                              ),
                            ),
                          ),
                          barGroups: data.asMap().entries.map((entry) {
                            final index = entry.key;
                            final e = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: e.costo.toDouble(),
                                  color: Colors.orange,
                                  width: 18,
                                ),
                              ],
                            );
                          }).toList(),
                          gridData: FlGridData(show: true),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Text('Sin datos de costo promedio');
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
