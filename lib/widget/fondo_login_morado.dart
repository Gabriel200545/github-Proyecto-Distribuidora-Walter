import 'package:flutter/material.dart';

class FondoLoginMorado extends StatelessWidget {
  const FondoLoginMorado({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo base (negro morado)
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1C),
          ),
        ),

        // Burbuja morada fuerte inferior izquierda
        Positioned(
          left: -120,
          bottom: -120,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFF6A1B9A),
                  Color(0xFF1C1C1C),
                ],
                center: Alignment.topLeft,
                radius: 1.0,
              ),
            ),
          ),
        ),

        // Burbuja morado medio superior derecha
        Positioned(
          right: -100,
          top: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFF6A1B9A),
                ],
                center: Alignment.bottomRight,
                radius: 1.0,
              ),
            ),
          ),
        ),

        // Burbuja lilac (clara) arriba izquierda
        Positioned(
          top: 100,
          left: 60,
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFBA68C8),
                  Color(0xFF9C27B0),
                ],
                center: Alignment.topLeft,
                radius: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(4, 4),
                ),
              ],
            ),
          ),
        ),

        // Burbuja morado claro central izquierda
        Positioned(
          left: 40,
          bottom: 220,
          child: Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFD1C4E9),
                  Color(0xFFBA68C8),
                ],
                radius: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 15,
                  offset: Offset(5, 5),
                ),
              ],
            ),
          ),
        ),

        // Burbuja morado intermedio derecha
        Positioned(
          right: 80,
          bottom: 280,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFE1BEE7),
                  Color(0xFFD1C4E9),
                ],
                radius: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
