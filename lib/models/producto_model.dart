class Producto {
  int idProducto;
  String nombre;
  String descripcion;
  int idCategoria;
  int idMarca;
  int idUnidadMedida;

  Producto({
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.idCategoria,
    required this.idMarca,
    required this.idUnidadMedida,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['idProducto'] ?? json['IdProducto'],
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      descripcion: json['descripcion'] ?? json['Descripcion'] ?? '',
      idCategoria: json['idCategoria'] ?? json['IdCategoria'],
      idMarca: json['idMarca'] ?? json['IdMarca'],
      idUnidadMedida: json['idUnidadMedida'] ?? json['IdUnidadMedida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdProducto': idProducto,
      'Nombre': nombre,
      'Descripcion': descripcion,
      'IdCategoria': idCategoria,
      'IdMarca': idMarca,
      'IdUnidadMedida': idUnidadMedida,
    };
  }
}