class Cliente {
  int? idCliente;
  String nombre;
  String direccion;
  String telefono;
  String correo;

  Cliente({
    this.idCliente,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.correo,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['idCliente'] ?? json['IdCliente'],
      nombre: json['nombre'] ?? json['Nombre'],
      direccion: json['direccion'] ?? json['Direccion'],
      telefono: json['telefono'] ?? json['Telefono'],
      correo: json['correo'] ?? json['Correo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdCliente': idCliente,
      'Nombre': nombre,
      'Direccion': direccion,
      'Telefono': telefono,
      'Correo': correo,
    };
  }
}
