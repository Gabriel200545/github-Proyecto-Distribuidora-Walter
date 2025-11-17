class Compra {
  final int idCompra;
  final int idProveedor;
  final DateTime fecha;
  final double total;
  final String usuarioRegistro;
  final List<DetalleCompra> detalles;

  Compra({
    required this.idCompra,
    required this.idProveedor,
    required this.fecha,
    required this.total,
    required this.usuarioRegistro,
    required this.detalles,
  });

  factory Compra.fromJson(Map<String, dynamic> json) {
    return Compra(
      idCompra: json['idCompra'],
      idProveedor: json['idProveedor'],
      fecha: DateTime.parse(json['fecha']),
      total: (json['total'] ?? 0).toDouble(),
      usuarioRegistro: json['usuarioRegistro'] ?? '',
      detalles: (json['detalles'] as List)
          .map((e) => DetalleCompra.fromJson(e))
          .toList(),
    );
  }
}

class DetalleCompra {
  final int idDetalleCompra;
  final int idProducto;
  final String nombreProducto;
  final int idBodega;
  final int idLote;
  final double cantidad;
  final int idUnidadMedida;
  final String abreviaturaUnidad;
  final double precioUnitario;

  DetalleCompra({
    required this.idDetalleCompra,
    required this.idProducto,
    required this.nombreProducto,
    required this.idBodega,
    required this.idLote,
    required this.cantidad,
    required this.idUnidadMedida,
    required this.abreviaturaUnidad,
    required this.precioUnitario,
  });

  factory DetalleCompra.fromJson(Map<String, dynamic> json) {
    return DetalleCompra(
      idDetalleCompra: json['idDetalleCompra'],
      idProducto: json['idProducto'],
      nombreProducto: json['nombreProducto'] ?? '',
      idBodega: json['idBodega'],
      idLote: json['idLote'],
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      idUnidadMedida: json['idUnidadMedida'],
      abreviaturaUnidad: json['abreviaturaUnidad'] ?? '',
      precioUnitario: (json['precioUnitario'] ?? 0).toDouble(),
    );
  }
}
