import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/consultar_venta_model.dart';

Future<void> generarFacturaPDF(Venta venta, String nombreCliente) async {
  final pdf = pw.Document();

  final totalGeneral = venta.detalles.fold<double>(
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
                  color: PdfColors.purple700,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Factura de Venta #${venta.idVenta}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text('Cliente: $nombreCliente'),
            pw.Text('Fecha: ${venta.fecha.toLocal().toString().split(" ")[0]}'),
            pw.Text('Usuario: ${venta.usuarioRegistro}'),
            pw.SizedBox(height: 20),

            // Tabla de detalles
            pw.Table.fromTextArray(
              headers: [
                'Producto',
                'Cantidad',
                'Unidad',
                'Precio Unitario',
                'Total'
              ],
              data: venta.detalles.map((d) {
                return [
                  d.nombreProducto,
                  d.cantidad.toString(),
                  d.abreviaturaUnidad,
                  d.precioUnitario.toStringAsFixed(2),
                  (d.cantidad * d.precioUnitario).toStringAsFixed(2),
                ];
              }).toList(),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.purple700,
              ),
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
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
