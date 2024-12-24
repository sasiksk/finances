import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class PdfEntry {
  final String partyName;
  final String date;
  final double drAmt;
  final double crAmt;

  PdfEntry({
    required this.partyName,
    required this.date,
    required this.drAmt,
    required this.crAmt,
  });
}

Future<void> generatePdf(
  List<PdfEntry> entries,
  double totalYouGave,
  double totalYouGot,
  String start,
  String end,
  WidgetRef ref,
  String finname,
) async {
  // Sort entries by date in descending order
  entries.sort((a, b) => b.date.compareTo(a.date));

  // Group entries by party name
  final groupedEntries = <String, List<PdfEntry>>{};
  for (var entry in entries) {
    if (!groupedEntries.containsKey(entry.partyName)) {
      groupedEntries[entry.partyName] = [];
    }
    groupedEntries[entry.partyName]!.add(entry);
  }

  final pdf = pw.Document();

  // Load custom font from assets
  final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(16),
      build: (pw.Context context) {
        return [
          // Finance Name and Account Statement
          pw.Container(
            color: PdfColors.blue,
            padding:
                const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    '$finname',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Account Statement ($start - $end)',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 16),

          // Summary Card
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Amt Given (-): \u20B9$totalYouGave',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                        color: PdfColors.red,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Amt Collected (+): \u20B9$totalYouGot',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                        color: PdfColors.green,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Net Balance: \u20B9${totalYouGave - totalYouGot} Cr',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Table Section
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              // Table Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Name',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        )),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Date',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        )),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Debit (-)',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        )),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Credit (+)',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        )),
                  ),
                ],
              ),
              // Table Rows
              ...groupedEntries.entries.expand((entry) {
                return [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          entry.key,
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(''),
                      ),
                    ],
                  ),
                  ...entry.value.map((pdfEntry) {
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.white,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            pdfEntry.date,
                            style: pw.TextStyle(font: ttf, fontSize: 10),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            pdfEntry.drAmt != 0.0
                                ? '\u20B9${pdfEntry.drAmt}'
                                : '',
                            style: pw.TextStyle(
                                font: ttf, fontSize: 10, color: PdfColors.red),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            pdfEntry.crAmt != 0.0
                                ? '\u20B9${pdfEntry.crAmt}'
                                : '',
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                                color: PdfColors.green),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ];
              }).toList(),
            ],
          ),
        ];
      },
    ),
  );

  final output = await path_provider.getTemporaryDirectory();
  final file = File("${output.path}/report.pdf");
  await file.writeAsBytes(await pdf.save());

  OpenFile.open(file.path);
}
