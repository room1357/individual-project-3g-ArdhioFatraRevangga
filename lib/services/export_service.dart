import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/expense.dart';

class ExportService {
  /// Export ke CSV
  Future<void> exportCSV(List<Expense> expenses) async {
    List<List<dynamic>> rows = [
      ["Title", "Amount", "Category", "Date"],
    ];
    for (var e in expenses) {
      rows.add([e.title, e.amount, e.category, e.date.toIso8601String()]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final Uint8List bytes = Uint8List.fromList(csv.codeUnits);

    await FileSaver.instance.saveFile(
      name: "expenses",
      bytes: bytes,
      ext: "csv",
      mimeType: MimeType.csv,
    );
  }

  /// Export ke PDF
  Future<void> exportPDF(List<Expense> expenses) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Table.fromTextArray(
            headers: ["Title", "Amount", "Category", "Date"],
            data: expenses.map((e) {
              return [
                e.title,
                e.amount.toString(),
                e.category,
                e.date.toIso8601String()
              ];
            }).toList(),
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    await FileSaver.instance.saveFile(
      name: "expenses",
      bytes: bytes,
      ext: "pdf",
      mimeType: MimeType.pdf,
    );
  }
}
