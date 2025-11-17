import 'package:distribuidora_app_new/views/asignar_rol_view.dart';
import 'package:distribuidora_app_new/views/compra_view.dart';
import 'package:distribuidora_app_new/views/consultar_compra_view.dart';
import 'package:distribuidora_app_new/views/consultar_venta_view.dart';
import 'package:distribuidora_app_new/views/devolucion_compra_view.dart';
import 'package:distribuidora_app_new/views/devolucion_venta_view.dart';
import 'package:distribuidora_app_new/views/inventario_lote_view.dart';
import 'package:distribuidora_app_new/views/inventario_view.dart';
import 'package:distribuidora_app_new/views/lote_view.dart';
import 'package:distribuidora_app_new/views/producto_view.dart';
import 'package:distribuidora_app_new/views/unidad_de_medida_view.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'cliente_view.dart';
import 'proveedor_view.dart';
import 'usuario_view.dart';
import 'rol_view.dart';
import 'bodega_view.dart';
import 'reportes_view.dart';
import 'venta_view.dart';

class HomeViewPremium extends StatefulWidget {
  const HomeViewPremium({super.key});

  @override
  State<HomeViewPremium> createState() => _HomeViewPremiumState();
}

class _HomeViewPremiumState extends State<HomeViewPremium>
    with SingleTickerProviderStateMixin {
  String _menuSeleccionado = '';
  late AnimationController _controller;

  final Map<String, List<String>> menu = {
    'Mantenedor': ['Categoría', 'Marca', 'Producto', 'Unidad de Medida'],
    'Compras': ['Proveedor', 'Registrar Compra', 'Consultar Compra'],
    'Ventas': ['Clientes', 'Registrar Venta', 'Consultar Venta'],
    'Inventario': ['Lote', 'Inventario'],
    'Devolucion': ['Devolucion Compra', 'Devolucion Venta'],
    'Configuracion': ['Usuarios', 'Asignar Roles', 'Rol', 'Bodega'],
    'Reportes': ['Diagramas'],
  };

  final Map<String, IconData> menuIcons = {
    'Mantenedor': Icons.build_circle_outlined,
    'Compras': Icons.shopping_bag_outlined,
    'Ventas': Icons.show_chart_outlined,
    'Inventario': Icons.inventory_2_outlined,
    'Devolucion': Icons.assignment_return_outlined,
    'Configuracion': Icons.settings_outlined,
    'Reportes': Icons.pie_chart_outline,
  };

  final List<_Burbuja> _burbujas = List.generate(
    12,
    (index) => _Burbuja(
      topFactor: 0.05 + Random().nextDouble() * 0.9,
      leftFactor: 0.05 + Random().nextDouble() * 0.9,
      size: 25 + Random().nextDouble() * 60,
      color: [
        const Color(0xFF6A1B9A),
        const Color(0xFF8E24AA),
        const Color(0xFF4A148C),
        const Color(0xFF9C27B0),
      ][Random().nextInt(4)],
    ),
  );

  final Map<String, bool> _expansionState = {};
  final Color colorPrincipal = const Color(0xFF6A1B9A);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (var key in menu.keys) {
      _expansionState[key] = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _movimiento(double valor) => sin(valor * 2 * pi);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      drawer: _menuLateral(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF120321), Color(0xFF1A033D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ..._burbujas.map((b) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final movimiento = _movimiento(_controller.value + b.offset);
                return Align(
                  alignment: Alignment(
                    -1 + b.leftFactor * 2,
                    -1 + b.topFactor * 2,
                  ),
                  child: Transform.translate(
                    offset: Offset(movimiento * 20, movimiento * 20),
                    child: _burbuja3D(b.size, b.color),
                  ),
                );
              },
            );
          }),
          Column(
            children: [
              Container(
                width: double.infinity,
                height: statusBarHeight + 90,
                color: colorPrincipal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: EdgeInsets.only(top: statusBarHeight),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 34,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Distribuidora Walter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Drawer _menuLateral() {
    final ancho = MediaQuery.of(context).size.width * 0.7;

    return Drawer(
      width: ancho,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorPrincipal.withOpacity(0.95), colorPrincipal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Menú',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...menu.entries.map((entry) {
              final bool seleccionado = _menuSeleccionado == entry.key;

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expansionState[entry.key] =
                            !(_expansionState[entry.key] ?? false);
                        _menuSeleccionado = _expansionState[entry.key]!
                            ? entry.key
                            : '';
                        _expansionState.forEach((k, v) {
                          if (k != entry.key) _expansionState[k] = false;
                        });
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? Colors.white.withOpacity(0.9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            menuIcons[entry.key],
                            color: seleccionado ? Colors.black : Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: seleccionado
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Icon(
                            _expansionState[entry.key]!
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: seleccionado ? Colors.black : Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild: Column(
                      children: entry.value
                          .map(
                            (subitem) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                splashColor: Colors.white24,
                                highlightColor: Colors.white10,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _navegarSubmenu(subitem);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 10,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          subitem,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    crossFadeState: _expansionState[entry.key]!
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            // 🔴 CERRAR SESIÓN
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  bool? confirmar = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmar'),
                        content: const Text('¿Desea cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sí'),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirmar == true) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/',
                    ); // Volver al login
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarSubmenu(String subitem) {
    switch (subitem) {
      case 'Categoría':
        Navigator.pushNamed(context, 'categoria');
        break;
      case 'Marca':
        Navigator.pushNamed(context, 'marca');
        break;
      case 'Clientes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClienteView()),
        );
        break;
      case 'Proveedor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProveedorView()),
        );
        break;
      case 'Usuarios':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsuarioView()),
        );
        break;
      case 'Asignar Roles':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AsignarRolView()),
        );
        break;
      case 'Rol':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RolView()),
        );
        break;
      case 'Bodega':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BodegaView()),
        );
        break;
      case 'Producto':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductoView()),
        );
        break;
      case 'Unidad de Medida':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UnidadMedidaView()),
        );
        break;
      case 'Registrar Compra':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompraView()),
        );
        break;
      case 'Consultar Compra':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConsultarCompraView()),
        );
        break;
      case 'Registrar Venta':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VentaView()),
        );
        break;
      case 'Consultar Venta':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConsultarVentaView()),
        );
        break;
      case 'Lote':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoteView()),
        );
        break;
      case 'Inventario':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InventarioView()),
        );
        break;
      case 'Devolucion Compra':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DevolucionCompraView()),
        );
        break;
      case 'Devolucion Venta':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DevolucionVentaView()),
        );
        break;
      case 'Diagramas':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportesView()),
        );
        break;
    }
  }

  Widget _burbuja3D(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
    );
  }
}

class _Burbuja {
  double topFactor;
  double leftFactor;
  double size;
  Color color;
  double offset;

  _Burbuja({
    required this.topFactor,
    required this.leftFactor,
    required this.size,
    required this.color,
  }) : offset = Random().nextDouble();
}
