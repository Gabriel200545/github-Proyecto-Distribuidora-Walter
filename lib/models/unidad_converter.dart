import 'conversion_model.dart';

class UnidadConverter {
  final List<ConversionModel> conversiones;

  UnidadConverter(this.conversiones);

  double convertir({
    required int unidadDesde,
    required int unidadHasta,
    required double cantidad,
  }) {
    if (unidadDesde == unidadHasta) return cantidad;

    final conversion = conversiones.firstWhere(
      (c) => c.idUnidadDesde == unidadDesde && c.idUnidadHasta == unidadHasta,
      orElse: () => ConversionModel(
        idConversion: 0,
        idUnidadDesde: 0,
        idUnidadHasta: 0,
        factor: 0,
      ),
    );

    if (conversion.factor == 0) {
      print("⚠ No existe conversión definida entre unidades.");
      return cantidad;
    }

    return cantidad * conversion.factor;
  }
}
