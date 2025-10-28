class Usuario {
  int idUsuario;
  String nombre;
  String contrasena;
  DateTime fechaRegistro;
  List<String> roles;

  Usuario({
    this.idUsuario = 0,
    required this.nombre,
    required this.contrasena,
    DateTime? fechaRegistro,
    List<String>? roles,
  })  : fechaRegistro = fechaRegistro ?? DateTime.now(),
        roles = roles ?? [];

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'] ?? 0,
      nombre: json['nombre'] ?? '',
      contrasena: '', // no traemos el hash al cliente
      fechaRegistro: DateTime.parse(json['fechaRegistro'] ?? DateTime.now().toString()),
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "contraseña": contrasena,
      };
}
