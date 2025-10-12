import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../models/expense.dart';

class StorageService {
  // -------- CSV --------
  Future<void> exportToCSV(List<Expense> expenses) async {
    final rows = <List<dynamic>>[
      ['Judul', 'Deskripsi', 'Kategori', 'Jumlah', 'Tanggal']
    ];
    for (final e in expenses) {
      rows.add([e.title, e.description, e.category, e.total, e.formattedDate]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(utf8.encode(csv));

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: 'data_pengeluaran',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/data_pengeluaran.csv');
      await file.writeAsBytes(bytes);
    }
  }

  // -------- PDF --------
  Future<void> exportToPDF(List<Expense> expenses) async {
    final pdf = pw.Document();
    final total = expenses.fold<double>(0, (s, e) => s + e.total);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Center(
            child: pw.Text('Laporan Pengeluaran',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total: Rp ${total.toStringAsFixed(0)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Judul', 'Kategori', 'Jumlah', 'Tanggal'],
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            headerStyle:
                pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 10),
            data: expenses
                .map((e) => [e.title, e.category, e.formattedTotal, e.formattedDate])
                .toList(),
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Dicetak: ${DateTime.now()}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: 'laporan_pengeluaran',
        bytes: Uint8List.fromList(bytes),
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/laporan_pengeluaran.pdf');
      await file.writeAsBytes(bytes);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    }
  }

  Future<void> previewPDF(List<Expense> expenses) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (_) => pw.Center(child: pw.Text('Preview Laporan'))));
    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }
}
