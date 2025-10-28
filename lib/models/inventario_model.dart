class Inventario {
  int idProducto;
  int idBodega;
  double stock;

  Inventario({
    required this.idProducto,
    required this.idBodega,
    required this.stock,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      idProducto: json['idProducto'] ?? json['IdProducto'],
      idBodega: json['idBodega'] ?? json['IdBodega'],
      stock: (json['stock'] ?? json['Stock'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdProducto': idProducto,
      'IdBodega': idBodega,
      'Stock': stock,
    };
  }
}