import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skfinance/Data/Databasehelper.dart';
import 'package:skfinance/PartyDetailScreen.dart';
import 'package:skfinance/Sms.dart';
import 'package:skfinance/Utilities/CustomDatePicker.dart';
import 'package:skfinance/finance_provider.dart';
import 'package:intl/intl.dart';

// ...existing code...

class CollectionScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amtCollectedController = TextEditingController();
  final int? preloadedCid;
  final double? preloadedAmtCollected;

  CollectionScreen(
      {super.key,
      String? preloadedDate,
      this.preloadedAmtCollected,
      this.preloadedCid}) {
    if (preloadedDate != null) {
      _dateController.text = preloadedDate;
    } else {
      _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }
    if (preloadedAmtCollected != null) {
      _amtCollectedController.text = preloadedAmtCollected.toString();
    }
  }

  Future<void> _updateLendingData(int lenId, double collectedAmt) async {
    final lendingData = await dbLending.fetchLendingData(lenId);

    final double amtCollected = (lendingData['amtcollected']);
    final double amtgiven = (lendingData['amtgiven']) + (lendingData['profit']);

    final updatedValues = {
      'amtcollected': amtCollected + collectedAmt,
      'status':
          (amtgiven - collectedAmt - amtCollected) == 0 ? 'passive' : 'active',
    };

    await dbLending.updateDueAmt(
      lenId: lenId,
      updatedValues: updatedValues,
    );
  }

  Future<void> _updateAmtRecieved(String lineName, double collectedAmt) async {
    final amtRecieved = await dbline.fetchAmtRecieved(lineName);
    final updatedAmtRecieved = amtRecieved + collectedAmt;

    await dbline.updateLine(
      lineName: lineName,
      updatedValues: {'Amtrecieved': updatedAmtRecieved},
    );
  }

  Future<int> _getNextCid() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT MAX(cid) as maxCid FROM Collection');
    final maxCid = result.first['maxCid'] as int?;
    return (maxCid ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partyName = ref.watch(currentPartyNameProvider);
    final lenid = ref.watch(lenIdProvider);
    final lineName = ref.watch(currentLineNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(partyName ?? "Add Collection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDatePicker(
                controller: _dateController,
                labelText: "Date of Payment",
                hintText: "Pick the date of payment",
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amtCollectedController,
                decoration: const InputDecoration(
                  labelText: "Amount Collected",
                  hintText: "Enter the amount collected",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount collected';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        final date = _dateController.text;
                        final collectedAmt =
                            double.parse(_amtCollectedController.text);
                        final lenStatus =
                            await dbLending.getStatusByLenId(lenid!);
                        if (lenid != null && lineName != null) {
                          if (lenStatus == 'active' || preloadedCid != null) {
                            if (preloadedCid != null) {
                              // Fetch the current amtCollected and dueAmt from Lending table
                              final lendingData =
                                  await dbLending.fetchLendingData(lenid);

                              final double currentAmtCollected =
                                  lendingData['amtcollected'];
                              final double currentgivenamt =
                                  lendingData['amtgiven'] +
                                      (lendingData['profit']);

                              final int sms = lendingData['sms'];
                              final String pno = lendingData['PartyPhnone'];
                              // Calculate the new amtCollected and dueAmt
                              final double newAmtCollected =
                                  currentAmtCollected +
                                      collectedAmt -
                                      preloadedAmtCollected!;

                              if (currentgivenamt >= newAmtCollected) {
                                print(
                                    'NEW COLLECTED AMT EXCEEDING THE GIVEN AMT ');
                                final String status =
                                    currentgivenamt - newAmtCollected == 0
                                        ? 'passive'
                                        : 'active';
                                print(status);

                                final amtRecieved_Line =
                                    await dbline.fetchAmtRecieved(lineName);
                                final newamtrecived = amtRecieved_Line +
                                    collectedAmt -
                                    preloadedAmtCollected!;
                                await dbline.updateLine(
                                    lineName: lineName,
                                    updatedValues: {
                                      'Amtrecieved': newamtrecived
                                    });

                                await dbLending.updateLendingAmounts(
                                    lenId: lenid,
                                    newAmtCollected: newAmtCollected,
                                    status: status);

                                //newDueAmt: newDueAmt);
                                // Update existing record in Collection table
                                await CollectionDB.updateCollection(
                                  cid: preloadedCid!,
                                  lenId: lenid,
                                  date: date,
                                  crAmt: 0.0,
                                  drAmt: collectedAmt,
                                );
                              } else {
                                // filepath: /path/to/CollectionScreen.dart
                                Future.delayed(Duration.zero, () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Error"),
                                        content: const Text(
                                            'Amount exceeds original. Can\'t Update.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PartyDetailScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                              }
                              await sendSms(pno,
                                  'Your Paid= $currentAmtCollected, Balance=${currentgivenamt - currentAmtCollected}. Thank You. Selva Vinagaya Finance.');
                            }
                            // Insert new record
                            else {
                              final lendingData =
                                  await dbLending.fetchLendingData(lenid);

                              final double currentAmtCollected =
                                  lendingData['amtcollected'];
                              final double currentgivenamt =
                                  lendingData['amtgiven'] +
                                      (lendingData['profit']);
                              final int sms = lendingData['sms'];
                              final String pno = lendingData['PartyPhnone'];

                              // Calculate the new amtCollected and dueAmt
                              final double newAmtCollected =
                                  currentAmtCollected + collectedAmt;
                              final double bal =
                                  currentgivenamt - newAmtCollected;

                              if (currentgivenamt >= newAmtCollected) {
                                final cid = await _getNextCid();
                                await CollectionDB.insertCollection(
                                  cid: cid,
                                  lenId: lenid,
                                  date: date,
                                  crAmt: 0.0,
                                  drAmt: collectedAmt,
                                );

                                await _updateLendingData(lenid, collectedAmt);
                                await _updateAmtRecieved(
                                    lineName, collectedAmt);

                                if (sms == 1) {
                                  await sendSms(pno,
                                      'Your Paid= $collectedAmt, Balance=${currentgivenamt - collectedAmt}. Thank You. Selva Vinagaya Finance.');
                                }
                              } else {
                                Future.delayed(Duration.zero, () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Error"),
                                        content: const Text(
                                            'Amount exceeds original. Can\'t Update.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PartyDetailScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                              }
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Form Submitted')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PartyDetailScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Cannot lend amount to passive state party')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Error: LenId or LineName is null')),
                          );
                        }
                      }
                    },
                    child: Text(preloadedCid != null ? "Update" : "Submit"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (preloadedCid != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete Confirmation"),
                              content: const Text(
                                  "Are you sure you want to delete this entry?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await PartyDetailScreen.deleteEntry(
                                      context,
                                      preloadedCid!,
                                      lineName!,
                                      preloadedAmtCollected!,
                                      lenid!,
                                      partyName!,
                                    );
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PartyDetailScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(preloadedCid != null ? "Delete" : "Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ...existing code...

  /* Future<void> _sendSms(String phoneNumber, String message) async {
    List<String> recipients = [phoneNumber];

    try {
      String result = await sendSMS(
        message: message,
        recipients: recipients,
      );
      print(result);
    } catch (error) {
      print("Failed to send SMS: $error");
    }
  }*/

// ...existing code...
}
