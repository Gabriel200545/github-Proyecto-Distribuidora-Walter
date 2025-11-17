import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversion_model.dart';

class ConversionService {
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/Conversion";

  static Future<List<ConversionModel>> getConversiones() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));

      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);

        return data.map((item) => ConversionModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print("Error cargando conversiones: $e");
      return [];
    }
  }
}
