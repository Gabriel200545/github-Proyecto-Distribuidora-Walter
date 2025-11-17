import 'package:distribuidora_app_new/views/asignar_rol_view.dart';
import 'package:distribuidora_app_new/views/bodega_view.dart';
import 'package:distribuidora_app_new/views/categoria_view.dart';
import 'package:distribuidora_app_new/views/cliente_view.dart';
import 'package:distribuidora_app_new/views/compra_view.dart';
import 'package:distribuidora_app_new/views/consultar_compra_view.dart';
import 'package:distribuidora_app_new/views/consultar_venta_view.dart';
import 'package:distribuidora_app_new/views/devolucion_compra_view.dart';
import 'package:distribuidora_app_new/views/devolucion_venta_view.dart';
import 'package:distribuidora_app_new/views/inventario_lote_view.dart';
import 'package:distribuidora_app_new/views/inventario_view.dart';
import 'package:distribuidora_app_new/views/lote_view.dart';
import 'package:distribuidora_app_new/views/producto_view.dart';
import 'package:distribuidora_app_new/views/rol_view.dart';
import 'package:distribuidora_app_new/views/unidad_de_medida_view.dart';
import 'package:distribuidora_app_new/views/usuario_view.dart';
import 'package:distribuidora_app_new/views/venta_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/marca_view.dart';
import 'views/proveedor_view.dart';
import 'views/reportes_view.dart'; // <-- Importamos Reportes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Distribuidora Walter',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      home: const LoginPantallaPremiumAnimada(),
      routes: {
        'home': (_) => const HomeViewPremium(),
        'categoria': (_) => const CategoriaView(),
        'marca': (_) => const MarcaView(),
        'cliente': (context) => ClienteView(),
        'proveedor': (context) => ProveedorView(),
        'usuario': (context) => UsuarioView(),
        'rol': (context) => RolView(),
        'asignarRol': (context) => AsignarRolView(),
        'bodega': (context) => BodegaView(),
        'producto': (_) => const ProductoView(),
        'unidadMedida': (_) => const UnidadMedidaView(),
        'compra': (_) => const CompraView(),
        'lote': (_) => const LoteView(),
        'inventario': (_) => const InventarioView(),
        'reportes': (_) => const ReportesView(),
        'consultarVenta': (_) => const ConsultarVentaView(),
        'consultarCompra': (_) => const ConsultarCompraView(),
        'venta': (_) => VentaView(),
        'devolucioncompra': (_) => DevolucionCompraView(),
        'devolucionVenta': (_) => DevolucionVentaView(),
      },
    );
  }
}
