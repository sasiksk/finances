import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skfinance/Data/Databasehelper.dart';

import 'package:skfinance/PartyDetailScreen.dart';
import 'package:skfinance/Utilities/AppBar.dart';
import 'package:skfinance/Utilities/EmptyDetailsCard.dart';
import 'package:skfinance/Utilities/FloatingActionButtonWithText.dart';

import 'package:skfinance/Utilities/PartyScreen.dart';
import 'package:skfinance/Utilities/drawer.dart';
import 'finance_provider.dart';

class LineDetailScreen extends ConsumerStatefulWidget {
  const LineDetailScreen({super.key});

  @override
  _LineDetailScreenState createState() => _LineDetailScreenState();
}

class _LineDetailScreenState extends ConsumerState<LineDetailScreen> {
  List<String> partyNames = [];
  ValueNotifier<List<String>> filteredPartyNamesNotifier = ValueNotifier([]);
  Map<String, Map<String, double>> partyDetailsMap = {};

  @override
  void initState() {
    super.initState();
    loadPartyNames();
  }

  void loadPartyNames() async {
    final lineName = ref.read(currentLineNameProvider);
    if (lineName != null) {
      final names = await dbLending.getPartyNames(lineName);
      final details = await Future.wait(
          names.map((name) => dbLending.getPartyDetailss(lineName, name)));

      setState(() {
        partyNames = names;
        filteredPartyNamesNotifier.value = names;
        for (int i = 0; i < names.length; i++) {
          partyDetailsMap[names[i]] = details[i];
        }
      });
    }
  }

  void handleLineSelected(String partyName) async {
    final lineName = ref.read(currentLineNameProvider);
    ref.read(currentPartyNameProvider.notifier).state = partyName;

    final lenId = await DatabaseHelper.getLenId(lineName!, partyName);
    ref.read(lenIdProvider.notifier).state = lenId;

    final String? stat = await DatabaseHelper.getStatus(lenId!);
    if (stat != null) {
      ref.read(lenStatusProvider.notifier).updateLenStatus(stat);
    }

    ref.read(lenIdProvider.notifier).state = lenId;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PartyDetailScreen()),
    ).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final lineName = ref.watch(currentLineNameProvider);

    if (lineName == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      drawer: buildDrawer(context),
      appBar: CustomAppBar(
        title: lineName!,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadPartyNames,
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, double>>(
            future: dbLending.getLineSums(lineName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data found.'));
              } else {
                final data = snapshot.data!;

                return EmptyCard(
                  screenHeight: MediaQuery.of(context).size.height * 1.25,
                  screenWidth: MediaQuery.of(context).size.width,
                  title: 'Line Details',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Given: ₹${data['totalAmtGiven']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Profit: ₹${data['totalProfit']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collected: ₹${data['totalAmtCollected']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Expense: ₹${data['totalexpense']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Amt in Line: ₹${(data['totalAmtGiven']! + data['totalProfit']! - data['totalAmtCollected']! - data['totalexpense']!).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 50,
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: GoogleFonts.tinos().fontFamily,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search Party',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  filteredPartyNamesNotifier.value = partyNames
                      .where((partyName) =>
                          partyName.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Party Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.tinos().fontFamily,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount                              ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.tinos().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: filteredPartyNamesNotifier,
              builder: (context, filteredPartyNames, _) {
                return ListView.separated(
                  itemCount: filteredPartyNames.length,
                  itemBuilder: (context, index) {
                    final partyName = filteredPartyNames[index];
                    final details = partyDetailsMap[partyName] ?? {};
                    final amtGiven = details['amtgiven'] ?? 0.0;
                    final profit = details['profit'] ?? 0.0;
                    final amtCollected = details['amtcollected'] ?? 0.0;
                    final calculatedValue = amtGiven + profit - amtCollected;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueGrey.shade700,
                              Colors.blueGrey.shade500,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                partyName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.tinos().fontFamily,
                                ),
                              ),
                              Text(
                                'Bal: ₹${calculatedValue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.tinos().fontFamily,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => handleLineSelected(partyName),
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) async {
                              if (value == 'Update') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PartyScreen(
                                      partyName: partyName,
                                      // Pass other necessary details if needed
                                    ),
                                  ),
                                );
                              } else if (value == 'Delete') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                          'Are you sure you want to delete this party and related collections?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Dismiss the dialog
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () async {
                                            Navigator.of(context)
                                                .pop(); // Dismiss the dialog
                                            final lenId =
                                                await DatabaseHelper.getLenId(
                                                    lineName!, partyName);
                                            if (lenId != null) {
                                              await dbLending
                                                  .deleteLendingAndCollections(
                                                      lenId, lineName);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Party and related collections deleted successfully'),
                                                ),
                                              );
                                              // Optionally, refresh the list or navigate back
                                              loadPartyNames(); // Refresh the list after deletion
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {'Update', 'Delete'}.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const FloatingActionButtonWithText(
        label: 'Add Party',
        navigateTo: PartyScreen(),
        icon: Icons.add,
      ),
    );
  }
}
