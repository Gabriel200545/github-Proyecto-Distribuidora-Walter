import 'dart:math';
import 'package:flutter/material.dart';
import '../views/home_view.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<_Burbuja> _burbujas = [
    _Burbuja(top: 40, left: 30, size: 50, color: const Color(0xFF4A148C)),
    _Burbuja(top: 120, left: 260, size: 70, color: const Color(0xFF6A1B9A)),
    _Burbuja(top: 180, left: 100, size: 40, color: const Color(0xFF7B1FA2)),
    _Burbuja(top: 90, left: 290, size: 30, color: const Color(0xFF8E24AA)),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _movimiento(double valor) => sin(valor * 2 * pi);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF120321)),
          Positioned(
            top: -60,
            left: -30,
            right: -30,
            child: ClipPath(
              clipper: _OndaSuperiorAvanzada(),
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFAB47BC),
                      Color(0xFF8E24AA),
                      Color(0xFF6A1B9A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          // Burbujas animadas
          ..._burbujas.map((b) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final movimiento = _movimiento(_controller.value + b.offset);
                return Positioned(
                  top: b.top + movimiento * 15,
                  left: b.left + movimiento * 10,
                  child: _burbuja3D(b.size, b.color),
                );
              },
            );
          }),

          // Contenido principal
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_rounded, color: Colors.white, size: 100),
                const SizedBox(height: 20),
                const Text(
                  "Distribuidora App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Bienvenido al panel principal",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB47BC),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeViewPremium()),
                    );
                  },
                  child: const Text(
                    "Ir al Inicio",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.4),
          ],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
        ],
      ),
    );
  }
}

// Clase para definir las burbujas
class _Burbuja {
  final double top;
  final double left;
  final double size;
  final Color color;
  final double offset;

  _Burbuja({
    required this.top,
    required this.left,
    required this.size,
    required this.color,
  }) : offset = Random().nextDouble();
}

// Onda superior animada (igual que el login)
class _OndaSuperiorAvanzada extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.cubicTo(size.width * 0.15, size.height, size.width * 0.35,
        size.height - 80, size.width * 0.5, size.height - 40);
    path.cubicTo(size.width * 0.65, size.height, size.width * 0.85,
        size.height - 80, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
