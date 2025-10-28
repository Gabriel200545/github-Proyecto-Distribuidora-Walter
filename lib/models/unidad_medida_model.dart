class UnidadMedida {
  int idUnidad;
  String nombre;
  String abreviacion;
  String tipoUnidad;

  UnidadMedida({
    required this.idUnidad,
    required this.nombre,
    required this.abreviacion,
    required this.tipoUnidad,
  });

  factory UnidadMedida.fromJson(Map<String, dynamic> json) {
    return UnidadMedida(
      idUnidad: json['idUnidad'] ?? json['IdUnidad'],
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      abreviacion: json['abreviacion'] ?? json['Abreviacion'] ?? '',
      tipoUnidad: json['tipoUnidad'] ?? json['TipoUnidad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdUnidad': idUnidad,
      'Nombre': nombre,
      'Abreviacion': abreviacion,
      'TipoUnidad': tipoUnidad,
    };
  }
}