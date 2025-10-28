class Categoria {
  int? id;
  String nombre;

  Categoria({this.id, required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['idCategoria'] ?? json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'idCategoria': id,
      'nombre': nombre,
    };
  }
}
