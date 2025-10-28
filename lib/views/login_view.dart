import 'package:flutter/material.dart';
import 'dart:math';
import '../services/api_service.dart';
import 'home_view.dart';

class LoginPantallaPremiumAnimada extends StatefulWidget {
  const LoginPantallaPremiumAnimada({super.key});

  @override
  State<LoginPantallaPremiumAnimada> createState() =>
      _LoginPantallaPremiumAnimadaState();
}

class _LoginPantallaPremiumAnimadaState
    extends State<LoginPantallaPremiumAnimada>
    with SingleTickerProviderStateMixin {
  bool _mostrarPassword = false;
  bool _recordarUsuario = false;
  bool _isLoading = false;

  late AnimationController _controller;

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<_Burbuja> _burbujas = [
    _Burbuja(top: 50, left: 20, size: 50, color: const Color(0xFF4A148C)),
    _Burbuja(top: 130, left: 250, size: 70, color: const Color(0xFF6A1B9A)),
    _Burbuja(top: 200, left: 100, size: 40, color: const Color(0xFF7B1FA2)),
    _Burbuja(top: 80, left: 280, size: 30, color: const Color(0xFF8E24AA)),
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
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _movimiento(double valor) => sin(valor * 2 * pi);

  Future<void> _() async {
  String usuario = _usuarioController.text.trim();
  String password = _passwordController.text.trim();

  if (usuario.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Por favor, completa todos los campos")),
    );
    return;
  }

  setState(() => _isLoading = true);

  bool success = await ApiService.login(usuario, password);

  setState(() => _isLoading = false);

  if (success && mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeViewPremium()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Usuario o contraseña incorrectos."),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF120321)),
          Positioned(
            top: -50,
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
                      Color(0xFF6A1B9A)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          ..._burbujas.map((b) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final movimiento = _movimiento(_controller.value + b.offset);
                return Positioned(
                  top: b.top + movimiento * 15,
                  left: b.left + movimiento * 15,
                  child: _burbuja3D(b.size, b.color),
                );
              },
            );
          }),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "¡Bienvenido!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Ingresa tus datos para continuar",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  _campoTexto(
                    label: "Usuario",
                    icon: Icons.person,
                    obscure: false,
                    controller: _usuarioController,
                  ),
                  const SizedBox(height: 20),
                  _campoTexto(
                    label: "Contraseña",
                    icon: Icons.lock,
                    obscure: !_mostrarPassword,
                    togglePassword: () {
                      setState(() {
                        _mostrarPassword = !_mostrarPassword;
                      });
                    },
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _recordarUsuario,
                        onChanged: (v) {
                          setState(() {
                            _recordarUsuario = v ?? false;
                          });
                        },
                        activeColor: Colors.purpleAccent,
                      ),
                      const Text(
                        "Recordar usuario",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB47BC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "INGRESAR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 1.2),
                            ),
                    ),
                  ),
                ],
              ),
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
          colors: [color.withOpacity(0.9), color.withOpacity(0.4)],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(5, 5))
        ],
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required IconData icon,
    required bool obscure,
    VoidCallback? togglePassword,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: togglePassword != null
            ? IconButton(
                icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70),
                onPressed: togglePassword,
              )
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
      ),
    );
  }
}

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

class _Burbuja {
  double top;
  double left;
  double size;
  Color color;
  double offset;

  _Burbuja(
      {required this.top,
      required this.left,
      required this.size,
      required this.color})
      : offset = Random().nextDouble();
}
