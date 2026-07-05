import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Shared PDF text extraction used by both the keyword engine and the
/// AI engine, so parsing logic lives in exactly one place.
class PdfService {
  static Future<String> extractText(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final buffer = StringBuffer();

    for (int i = 0; i < document.pages.count; i++) {
      buffer.writeln(
        extractor.extractText(startPageIndex: i, endPageIndex: i),
      );
    }
    document.dispose();
    return buffer.toString();
  }
}
