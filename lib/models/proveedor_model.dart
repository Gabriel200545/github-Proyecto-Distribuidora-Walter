// proveedor_model.dart
class Proveedor {
  int? idProveedor;
  String nombre;
  String contacto;
  String telefono;
  String correo;

  Proveedor({
    this.idProveedor,
    required this.nombre,
    required this.contacto,
    required this.telefono,
    required this.correo,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      idProveedor: json['idProveedor'] ?? json['IdProveedor'],
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      contacto: json['contacto'] ?? json['Contacto'] ?? '',
      telefono: json['telefono'] ?? json['Telefono'] ?? '',
      correo: json['correo'] ?? json['Correo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdProveedor': idProveedor,
      'Nombre': nombre,
      'Contacto': contacto,
      'Telefono': telefono,
      'Correo': correo,
    };
  }
}
