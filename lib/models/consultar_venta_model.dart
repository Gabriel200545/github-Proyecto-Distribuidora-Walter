class DetalleVenta {
  final int idProducto;
  final String nombreProducto;
  final int idBodega;
  final int idLote;
  final double cantidad;
  final String abreviaturaUnidad;
  final double precioUnitario;

  DetalleVenta({
    required this.idProducto,
    required this.nombreProducto,
    required this.idBodega,
    required this.idLote,
    required this.cantidad,
    required this.abreviaturaUnidad,
    required this.precioUnitario,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      idProducto: json['idProducto'],
      nombreProducto: json['nombreProducto'] ?? '',
      idBodega: json['idBodega'],
      idLote: json['idLote'],
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      abreviaturaUnidad: json['abreviaturaUnidad'] ?? '',
      precioUnitario: (json['precioUnitario'] ?? 0).toDouble(),
    );
  }
}

class Venta {
  final int idVenta;
  final int idCliente;
  final String usuarioRegistro;
  final DateTime fecha;
  final List<DetalleVenta> detalles;

  Venta({
    required this.idVenta,
    required this.idCliente,
    required this.usuarioRegistro,
    required this.fecha,
    required this.detalles,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    var detallesJson = json['detalles'] as List? ?? [];
    return Venta(
      idVenta: json['idVenta'],
      idCliente: json['idCliente'],
      usuarioRegistro: json['usuarioRegistro'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      detalles: detallesJson.map((d) => DetalleVenta.fromJson(d)).toList(),
    );
  }
}
