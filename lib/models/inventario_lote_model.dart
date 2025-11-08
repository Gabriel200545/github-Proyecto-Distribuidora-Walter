class InventarioLote {
  int idProducto;
  String nombreProducto;
  int idBodega;
  String nombreBodega;
  int idLote;
  String codigoLote;
  double stock;
  String abreviaturaUnidad;

  InventarioLote({
    required this.idProducto,
    required this.nombreProducto,
    required this.idBodega,
    required this.nombreBodega,
    required this.idLote,
    required this.codigoLote,
    required this.stock,
    required this.abreviaturaUnidad,
  });

  factory InventarioLote.fromJson(Map<String, dynamic> json) {
    return InventarioLote(
      idProducto: json['idProducto'] ?? json['IdProducto'] ?? 0,
      nombreProducto: json['nombreProducto'] ?? json['NombreProducto'] ?? '',
      idBodega: json['idBodega'] ?? json['IdBodega'] ?? 0,
      nombreBodega: json['nombreBodega'] ?? json['NombreBodega'] ?? '',
      idLote: json['idLote'] ?? json['IdLote'] ?? 0,
      codigoLote: json['codigoLote'] ?? json['CodigoLote'] ?? '',
      stock: (json['stock'] ?? json['Stock'] ?? 0).toDouble(),
      abreviaturaUnidad:
          json['abreviaturaUnidad'] ?? json['AbreviaturaUnidad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdProducto': idProducto,
      'NombreProducto': nombreProducto,
      'IdBodega': idBodega,
      'NombreBodega': nombreBodega,
      'IdLote': idLote,
      'CodigoLote': codigoLote,
      'Stock': stock,
      'AbreviaturaUnidad': abreviaturaUnidad,
    };
  }
}
