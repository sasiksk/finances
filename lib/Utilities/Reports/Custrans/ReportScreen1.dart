import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skfinance/Data/Databasehelper.dart';
import 'package:skfinance/Utilities/Reports/Custrans/pdf_generator2.dart';
import 'package:skfinance/finance_provider.dart';

class ReportScreen1 extends ConsumerWidget {
  const ReportScreen1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeName = ref.watch(financeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Wise Report'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Fetch data from the database
            Map<String, double> totals = await dbline.allLineDetails();

            List<PdfEntry> entries = await dbLending.fetchLendingEntries();
            double totalAmtGiven = totals['totalAmtGiven'] ?? 0.0;
            double totalProfit = totals['totalProfit'] ?? 0.0;
            double totalAmtReceived = totals['totalAmtRecieved'] ?? 0.0;
            double totalExpense = await fetchTotalExpense();

            await generateNewPdf(entries, totalAmtGiven, totalProfit,
                totalAmtReceived, totalExpense, financeName);
          },
          child: Text('Generate PDF'),
        ),
      ),
    );
  }

  Future<double> fetchTotalExpense() async {
    // Implement your logic to fetch total expense from the database
    // Example:
    return 0.0;
  }
}
