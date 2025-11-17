class Inventario {
  int idProducto;
  int idBodega;
  String nombreProducto;
  String nombreBodega;
  double stock;
  String abreviaturaUnidad;

  Inventario({
    required this.idProducto,
    required this.idBodega,
    required this.nombreProducto,
    required this.nombreBodega,
    required this.stock,
    required this.abreviaturaUnidad,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      idProducto: json['idProducto'] ?? json['IdProducto'],
      idBodega: json['idBodega'] ?? json['IdBodega'],
      nombreProducto: json['nombreProducto'] ?? '',
      nombreBodega: json['nombreBodega'] ?? '',
      stock: (json['stock'] ?? json['Stock'] ?? 0).toDouble(),
      abreviaturaUnidad: json['abreviaturaUnidad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdProducto': idProducto,
      'IdBodega': idBodega,
      'nombreProducto': nombreProducto,
      'nombreBodega': nombreBodega,
      'Stock': stock,
      'abreviaturaUnidad': abreviaturaUnidad,
    };
  }
}
