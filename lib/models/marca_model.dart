class Marca {
  int? idMarca;
  String nombre;

  Marca({this.idMarca, required this.nombre});

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(
      idMarca: json['idMarca'] ?? json['IdMarca'],
      nombre: json['nombre'] ?? json['Nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdMarca': idMarca,
      'Nombre': nombre,
    };
  }
}
