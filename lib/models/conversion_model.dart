class ConversionModel {
  final int idConversion;
  final int idUnidadDesde;
  final int idUnidadHasta;
  final double factor;

  ConversionModel({
    required this.idConversion,
    required this.idUnidadDesde,
    required this.idUnidadHasta,
    required this.factor,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    return ConversionModel(
      idConversion: json['idConversion'],
      idUnidadDesde: json['idUnidadDesde'],
      idUnidadHasta: json['idUnidadHasta'],
      factor: (json['factor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'idConversion': idConversion,
    'idUnidadDesde': idUnidadDesde,
    'idUnidadHasta': idUnidadHasta,
    'factor': factor,
  };
}
