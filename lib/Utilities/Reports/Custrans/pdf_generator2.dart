import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';

class PdfEntry {
  final String lineName;
  final String partyName;
  final double amtGiven;
  final double profit;
  final double amtCollected;
  final double balanceAmt;

  PdfEntry({
    required this.lineName,
    required this.partyName,
    required this.amtGiven,
    required this.profit,
    required this.amtCollected,
    required this.balanceAmt,
  });
}

Future<void> generateNewPdf(
  List<PdfEntry> entries,
  double totalAmtGiven,
  double totalProfit,
  double totalAmtReceived,
  double totalExpense,
  String finname,
) async {
  // Sort entries by line name
  entries.sort((a, b) => a.lineName.compareTo(b.lineName));

  // Group entries by line name
  final groupedEntries = <String, List<PdfEntry>>{};
  for (var entry in entries) {
    if (!groupedEntries.containsKey(entry.lineName)) {
      groupedEntries[entry.lineName] = [];
    }
    groupedEntries[entry.lineName]!.add(entry);
  }

  final pdf = pw.Document();

  final ttf =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));

  final today = DateTime.now();
  final formattedDate = "${today.day}-${today.month}-${today.year}";

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
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
                      'Account Statement as on $formattedDate',
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
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Amt Given (-): \u20B9$totalAmtGiven',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 14,
                          color: PdfColors.red,
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Text(
                        'Profit: \u20B9$totalProfit',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 14,
                          color: PdfColors.green,
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Text(
                        'Total: \u20B9${totalAmtGiven + totalProfit}',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 14,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Amt Received (+): \u20B9$totalAmtReceived',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 14,
                          color: PdfColors.green,
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Text(
                        'Expense: \u20B9$totalExpense',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 14,
                          color: PdfColors.red,
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Text(
                        'Amt in Line: \u20B9${(totalAmtGiven + totalProfit) - totalAmtReceived - totalExpense}',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 14,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey, width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Line Name',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Party Name',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Amt Given + Profit',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Amt Collected',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Balance Amt',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
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
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              pdfEntry.partyName,
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '\u20B9${pdfEntry.amtGiven + pdfEntry.profit}',
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '\u20B9${pdfEntry.amtCollected}',
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '\u20B9${pdfEntry.balanceAmt}',
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ];
                }).toList(),
              ],
            ),
          ],
        );
      },
    ),
  );

  final output = await path_provider.getTemporaryDirectory();
  final file = File("${output.path}/account_statement.pdf");
  await file.writeAsBytes(await pdf.save());
  await OpenFile.open(file.path);
}
