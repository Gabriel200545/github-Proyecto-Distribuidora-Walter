import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/consultar_compra_model.dart';

Future<void> generarCompraPDF(Compra compra, String nombreProveedor) async {
  final pdf = pw.Document();

  final totalGeneral = compra.detalles.fold<double>(
    0,
    (sum, d) => sum + (d.cantidad * d.precioUnitario),
  );

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Distribuidora Walter',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple800,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Factura de Compra #${compra.idCompra}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Proveedor: $nombreProveedor'),
            pw.Text('Fecha: ${compra.fecha.toLocal().toString().split(" ")[0]}'),
            pw.Text('Usuario: ${compra.usuarioRegistro}'),
            pw.SizedBox(height: 20),

            // Tabla moderna con TableHelper
            pw.TableHelper.fromTextArray(
              headers: [
                'Producto',
                'Cantidad',
                'Unidad',
                'Precio Unitario',
                'Total'
              ],
              data: compra.detalles.map((d) {
                return [
                  d.nombreProducto,
                  d.cantidad.toString(),
                  d.abreviaturaUnidad,
                  d.precioUnitario.toStringAsFixed(2),
                  (d.cantidad * d.precioUnitario).toStringAsFixed(2),
                ];
              }).toList(),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.purple800),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 11),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total General: \$${totalGeneral.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
