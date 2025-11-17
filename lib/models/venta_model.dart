// models/venta_model.dart
class DetalleVentaRequest {
  int idProducto;
  double cantidad;
  int idUnidadMedida;
  double precioCompra; // precio de compra obtenido desde compras (unidad base)
  double? precioUnitario; // precio mostrado (con margen y conversión)

  DetalleVentaRequest({
    required this.idProducto,
    required this.cantidad,
    required this.idUnidadMedida,
    required this.precioCompra,
    this.precioUnitario,
  });

  Map<String, dynamic> toJson() => {
    "idProducto": idProducto,
    "cantidad": cantidad,
    "idUnidadMedida": idUnidadMedida,
  };
}

class VentaRequest {
  int idCliente;
  String fecha;
  String usuarioRegistro;
  List<DetalleVentaRequest> detalles;

  VentaRequest({
    required this.idCliente,
    required this.fecha,
    required this.usuarioRegistro,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
    "idCliente": idCliente,
    "fecha": fecha,
    "usuarioRegistro": usuarioRegistro,
    "detalles": detalles.map((d) => d.toJson()).toList(),
  };
}
