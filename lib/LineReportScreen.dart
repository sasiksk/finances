import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skfinance/Data/Databasehelper.dart';
import 'package:skfinance/Utilities/CustomDatePicker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:skfinance/Utilities/Reports/CusFullTrans/pdf_generator.dart';
import 'package:skfinance/finance_provider.dart';

class Linereportscreen extends ConsumerStatefulWidget {
  @override
  _LinereportscreenState createState() => _LinereportscreenState();
}

class _LinereportscreenState extends ConsumerState<Linereportscreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<Map<String, dynamic>> _entries = [];
  double _totalYouGave = 0.0;
  double _totalYouGot = 0.0;

  Future<void> _fetchEntries() async {
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(_startDateController.text);
      DateTime endDate =
          DateFormat('dd-MM-yyyy').parse(_endDateController.text);

      // Get the current line name
      final lineName = ref.read(currentLineNameProvider);

      // Fetch all LenId values for the given line name
      List<int> lenIds = await DatabaseHelper.getLenIdsByLineName(lineName!);

      // Fetch entries between dates and filter by LenId
      List<Map<String, dynamic>> entries =
          await CollectionDB.getEntriesBetweenDates(startDate, endDate);

      entries =
          entries.where((entry) => lenIds.contains(entry['LenId'])).toList();

      double totalYouGave = 0.0;
      double totalYouGot = 0.0;

      for (var entry in entries) {
        if (entry['CrAmt'] != null) {
          totalYouGave += entry['CrAmt'];
        }
        if (entry['DrAmt'] != null) {
          totalYouGot += entry['DrAmt'];
        }

        // Fetch PartyName for each entry
        String? partyName =
            await DatabaseHelper.getPartyNameByLenId(entry['LenId']);
        entry = {...entry, 'PartyName': partyName};
      }

      setState(() {
        _entries = entries;
        _totalYouGave = totalYouGave;
        _totalYouGot = totalYouGot;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Report'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomDatePicker(
                    controller: _startDateController,
                    labelText: 'START DATE',
                    hintText: 'Pick a start date',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomDatePicker(
                    controller: _endDateController,
                    labelText: 'END DATE',
                    hintText: 'Pick an end date',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchEntries,
              child: Text('Fetch Entries'),
            ),
            SizedBox(height: 16),

            // Net Balance Section
            Text(
              'Net Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 71, 2, 92),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL', style: TextStyle(color: Colors.grey)),
                      Text('${_entries.length} Entries',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('YOU GAVE', style: TextStyle(color: Colors.red)),
                      Text('₹ $_totalYouGave',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('YOU GOT', style: TextStyle(color: Colors.green)),
                      Text('₹ $_totalYouGot',
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),

            // Entries List
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  var entry = _entries[index];
                  var previousEntry = index > 0 ? _entries[index - 1] : null;
                  bool showDateHeader = previousEntry == null ||
                      entry['Date'] != previousEntry['Date'];

                  double totalCrAmt = 0.0;
                  double totalDrAmt = 0.0;

                  for (var e
                      in _entries.where((e) => e['Date'] == entry['Date'])) {
                    if (e['CrAmt'] != null) {
                      totalCrAmt += e['CrAmt'];
                    }
                    if (e['DrAmt'] != null) {
                      totalDrAmt += e['DrAmt'];
                    }
                  }

                  return FutureBuilder<String?>(
                    future: DatabaseHelper.getPartyNameByLenId(entry['LenId']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String partyName = snapshot.data ?? 'Unknown';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 219, 247, 169),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${DateFormat('dd-MM').format(DateFormat('dd-MM-yyyy').parse(entry['Date']))}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₹${totalCrAmt != 0.0 ? totalCrAmt : 0.0}',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      Text(
                                        '₹${totalDrAmt != 0.0 ? totalDrAmt : 0.0}',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        partyName.length >= 4
                                            ? partyName.substring(0, 4)
                                            : partyName,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        entry['CrAmt'] != 0.0
                                            ? '₹${entry['CrAmt']}'
                                            : '',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        entry['DrAmt'] != 0.0
                                            ? '₹${entry['DrAmt']}'
                                            : '',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            ),

            // Download Button
            /* Center(
              child: ElevatedButton.icon(
                onPressed: () => generatePdf(
                    _entries,
                    _totalYouGave,
                    _totalYouGot,
                    _startDateController.text,
                    _endDateController.text),
                icon: Icon(Icons.picture_as_pdf),
                label: Text('DOWNLOAD'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
