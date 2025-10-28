class Compra {
  int idProveedor;
  String fecha;
  String usuarioRegistro;
  List<DetalleCompra> detalles;

  Compra({
    required this.idProveedor,
    required this.fecha,
    required this.usuarioRegistro,
    required this.detalles,
  });

  Map<String, dynamic> toJson() {
    return {
      "idProveedor": idProveedor,
      // Asegurar formato ISO completo
      "fecha": fecha.contains("T") ? fecha : "${fecha}T00:00:00",
      "usuarioRegistro": usuarioRegistro,
      "detalles": detalles.map((d) => d.toJson()).toList(),
    };
  }
}

class DetalleCompra {
  int idProducto;
  double cantidad;
  int idUnidadMedida;
  double precioUnitario;
  String codigoLote;
  String fechaFabricacion;
  String fechaCaducidad;
  int idBodega;

  DetalleCompra({
    required this.idProducto,
    required this.cantidad,
    required this.idUnidadMedida,
    required this.precioUnitario,
    required this.codigoLote,
    required this.fechaFabricacion,
    required this.fechaCaducidad,
    required this.idBodega,
  });

  Map<String, dynamic> toJson() {
    return {
      "idProducto": idProducto,
      "cantidad": cantidad,
      "idUnidadMedida": idUnidadMedida,
      "precioUnitario": precioUnitario,
      "codigoLote": codigoLote,
      // Asegurar formato ISO con hora
      "fechaFabricacion": fechaFabricacion.contains("T")
          ? fechaFabricacion
          : "${fechaFabricacion}T00:00:00",
      "fechaCaducidad": fechaCaducidad.contains("T")
          ? fechaCaducidad
          : "${fechaCaducidad}T00:00:00",
      "idBodega": idBodega,
    };
  }
}
