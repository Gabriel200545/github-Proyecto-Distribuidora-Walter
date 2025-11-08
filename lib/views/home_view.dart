import 'package:distribuidora_app_new/views/asignar_rol_view.dart';
import 'package:distribuidora_app_new/views/compra_view.dart';
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
import 'bodega_view.dart'; // <-- Importamos la vista de Bodega

class HomeViewPremium extends StatefulWidget {
  const HomeViewPremium({super.key});

  @override
  State<HomeViewPremium> createState() => _HomeViewPremiumState();
}

class _HomeViewPremiumState extends State<HomeViewPremium>
    with SingleTickerProviderStateMixin {
  String _paginaActual = 'Reportes';
  String _menuSeleccionado = '';
  late AnimationController _controller;

  final Map<String, List<String>> menu = {
    'Mantenedor': ['Categoría', 'Marca', 'Producto', 'Unidad de Medida'],
    'Compras': ['Proveedor', 'Registrar Compra', 'Consultar Compra'],
    'Ventas': ['Clientes', 'Registrar Venta', 'Consultar Venta'],
    'Inventario': ['Lote', 'Inventario'],
    'Devolucion': ['Devolucion Compra', 'Devolucion Venta'],
    'Configuracion': [
      'Usuarios',
      'Asignar Roles',
      'Rol',
      'Bodega',
    ], // <-- Ya está
  };

  final Map<String, IconData> menuIcons = {
    'Mantenedor': Icons.build_circle_outlined,
    'Compras': Icons.shopping_bag_outlined,
    'Ventas': Icons.show_chart_outlined,
    'Inventario': Icons.inventory_2_outlined,
    'Devolucion': Icons.assignment_return_outlined,
    'Configuracion': Icons.settings_outlined,
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
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Distribuidora Walter',
                          style: const TextStyle(
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
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Text(
                            'Reportes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _tarjetaReporteMejorada(
                              'Ventas por Día',
                              '120 ventas',
                              Icons.show_chart,
                            ),
                            _tarjetaReporteMejorada(
                              'Inventario Crítico',
                              'Harina: 5 uds',
                              Icons.warning,
                            ),
                            _tarjetaReporteMejorada(
                              'Ingresos Mensuales',
                              '\$12,500',
                              Icons.monetization_on,
                            ),
                            _tarjetaReporteMejorada(
                              'Gastos Mensuales',
                              '\$5,200',
                              Icons.money_off,
                            ),
                            _tarjetaReporteMejorada(
                              'Clientes Activos',
                              '85',
                              Icons.people,
                            ),
                            _tarjetaReporteMejorada(
                              'Productos Disponibles',
                              '320',
                              Icons.shopping_cart,
                            ),
                            _tarjetaReporteMejorada(
                              'Devoluciones',
                              '3',
                              Icons.assignment_return,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(3, 0),
            ),
          ],
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Menu',
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
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? Colors.white.withOpacity(0.9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: seleccionado
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            menuIcons[entry.key],
                            color: seleccionado ? Colors.black : Colors.white,
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
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                splashColor: Colors.white24,
                                highlightColor: Colors.white10,
                                onTap: () {
                                  // Navegación
                                  if (subitem == 'Categoría') {
                                    Navigator.pushNamed(context, 'categoria');
                                  } else if (subitem == 'Marca') {
                                    Navigator.pushNamed(context, 'marca');
                                  } else if (subitem == 'Clientes') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ClienteView(),
                                      ),
                                    );
                                  } else if (subitem == 'Proveedor') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProveedorView(),
                                      ),
                                    );
                                  } else if (subitem == 'Usuarios') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UsuarioView(),
                                      ),
                                    );
                                  } else if (subitem == 'Asignar Roles') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AsignarRolView(),
                                      ),
                                    );
                                  } else if (subitem == 'Rol') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RolView(),
                                      ),
                                    );
                                  } else if (subitem == 'Bodega') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BodegaView(),
                                      ),
                                    );
                                  } else if (subitem == 'Producto') {
                                    // 🛒 Nuevo submenú Producto
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProductoView(),
                                      ),
                                    );
                                  } else if (subitem == 'Unidad de Medida') {
                                    // ⚖ Nuevo submenú Unidad de Medida
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UnidadMedidaView(),
                                      ),
                                    );
                                  } else if (subitem == 'Registrar Compra') {
                                    // ✅ Nuevo caso añadido
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CompraView(),
                                      ),
                                    );
                                  } else if (subitem == 'Inventario') {
                                    // ✅ Nuevo caso añadido
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InventarioLoteView(),
                                      ),
                                    );
                                  } else if (subitem == 'Lote') {
                                    // ✅ Nuevo caso añadido
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoteView(),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _paginaActual = subitem;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: Colors.white54,
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
          ],
        ),
      ),
    );
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

  Widget _tarjetaReporteMejorada(String titulo, String valor, IconData icono) {
    return Container(
      width: 160,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(color: Colors.white24, width: 1),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: Colors.white70, size: 28),
            const SizedBox(height: 6),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
