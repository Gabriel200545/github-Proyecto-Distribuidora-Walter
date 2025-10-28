class Bodega {
  int idBodega;
  String nombre;
  String ubicacion;

  Bodega({
    this.idBodega = 0,
    required this.nombre,
    required this.ubicacion,
  });

  factory Bodega.fromJson(Map<String, dynamic> json) {
    return Bodega(
      idBodega: json['idBodega'] ?? json['IdBodega'] ?? 0,
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      ubicacion: json['ubicacion'] ?? json['Ubicacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'idBodega': idBodega,
        'nombre': nombre,
        'ubicacion': ubicacion,
      };
}
