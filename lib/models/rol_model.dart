class Rol {
  int idRol;
  String nombre;

  Rol({required this.idRol, required this.nombre});

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['idRol'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRol': idRol,
      'nombre': nombre,
    };
  }
}
