class LoteModel {
  int idLote;
  String codigo;
  int idProducto;
  String nombreProducto;
  DateTime? fechaFabricacion;
  DateTime? fechaCaducidad;
  int idProveedor;
  String nombreProveedor;
  String? observacion;

  LoteModel({
    required this.idLote,
    required this.codigo,
    required this.idProducto,
    required this.nombreProducto,
    this.fechaFabricacion,
    this.fechaCaducidad,
    required this.idProveedor,
    required this.nombreProveedor,
    this.observacion,
  });

  factory LoteModel.fromJson(Map<String, dynamic> json) {
    return LoteModel(
      idLote: json['idLote'] ?? json['IdLote'],
      codigo: json['codigo'] ?? json['Codigo'] ?? '',
      idProducto: json['idProducto'] ?? json['IdProducto'],
      nombreProducto: json['nombreProducto'] ?? json['NombreProducto'] ?? '',
      fechaFabricacion: json['fechaFabricacion'] != null
          ? DateTime.tryParse(json['fechaFabricacion'])
          : (json['FechaFabricacion'] != null
              ? DateTime.tryParse(json['FechaFabricacion'])
              : null),
      fechaCaducidad: json['fechaCaducidad'] != null
          ? DateTime.tryParse(json['fechaCaducidad'])
          : (json['FechaCaducidad'] != null
              ? DateTime.tryParse(json['FechaCaducidad'])
              : null),
      idProveedor: json['idProveedor'] ?? json['IdProveedor'],
      nombreProveedor:
          json['nombreProveedor'] ?? json['NombreProveedor'] ?? '',
      observacion: json['observacion'] ?? json['Observacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdLote': idLote,
      'Codigo': codigo,
      'IdProducto': idProducto,
      'NombreProducto': nombreProducto,
      'FechaFabricacion': fechaFabricacion?.toIso8601String(),
      'FechaCaducidad': fechaCaducidad?.toIso8601String(),
      'IdProveedor': idProveedor,
      'NombreProveedor': nombreProveedor,
      'Observacion': observacion,
    };
  }
}