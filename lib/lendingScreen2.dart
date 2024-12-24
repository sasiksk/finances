import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skfinance/Data/Databasehelper.dart';

import 'package:skfinance/Utilities/AppBar.dart';
import 'package:skfinance/Utilities/CustomDatePicker.dart';
import 'package:skfinance/Utilities/CustomTextField.dart';
import 'package:skfinance/finance_provider.dart';
import 'package:intl/intl.dart';

class LendingCombinedDetailsScreen2 extends ConsumerWidget {
  LendingCombinedDetailsScreen2({
    super.key,
  });

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amtGivenController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _lentDateController = TextEditingController();
  final TextEditingController _dueDaysController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  void _updateLending(BuildContext context, String lineName, String partyName,
      int lentid) async {
    if (_formKey.currentState?.validate() == true) {
      try {
        final double amtGiven = double.parse(_amtGivenController.text);
        final double profit = double.parse(_profitController.text);

        final updatedValues = {
          'LenId': lentid,
          'amtgiven': amtGiven,
          'profit': profit,
          'Lentdate': _lentDateController.text,
          'duedays': int.parse(_dueDaysController.text),
          'amtcollected': 0.0,
          'status': 'active',
        };

        await dbLending.updateLending(
          lineName: lineName,
          partyName: partyName,
          lenId: lentid,
          updatedValues: updatedValues,
        );

        // Fetch existing values from the Line table
        final db = await DatabaseHelper.getDatabase();
        final List<Map<String, dynamic>> existingEntries = await db.query(
          'Line',
          where: 'LOWER(Linename) = ?',
          whereArgs: [lineName.toLowerCase()],
        );

        if (existingEntries.isNotEmpty) {
          final existingEntry = existingEntries.first;
          final double existingAmtGiven = existingEntry['Amtgiven'];
          final double existingProfit = existingEntry['Profit'];

          final double newAmtGiven = existingAmtGiven + amtGiven;

          final double newProfit = existingProfit + profit;

          // Update the Line table with new values
          await dbline.updateLineAmounts(
            lineName: lineName,
            amtGiven: newAmtGiven,
            profit: newProfit,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lending details updated successfully')),
        );

        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PartyDetailScreen()),
        );*/
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating lending details: $e')),
        );
      }
    }
  }

  void _calculateTotal() {
    final amtGiven = double.tryParse(_amtGivenController.text) ?? 0.0;
    final profit = double.tryParse(_profitController.text) ?? 0.0;
    final total = amtGiven + profit;
    _totalController.text = total.toString();
  }

  void _calculateDueDate() {
    if (_lentDateController.text.isNotEmpty &&
        _dueDaysController.text.isNotEmpty) {
      DateTime lentDate =
          DateFormat('dd-MM-yyyy').parse(_lentDateController.text);
      int dueDays = int.parse(_dueDaysController.text);
      DateTime dueDate = lentDate.add(Duration(days: dueDays));
      _dueDateController.text = DateFormat('dd-MM-yyyy').format(dueDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Call the calculation methods to update the total and due date

    final lineName = ref.watch(currentLineNameProvider);
    final partyName = ref.watch(currentPartyNameProvider);
    final lenId = ref.watch(lenIdProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Lending to - ${partyName ?? ''}",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Details Form Section
                const Text(
                  "Financial Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _amtGivenController,
                  decoration: const InputDecoration(
                    labelText: "Amount Given",
                    hintText: "Enter the amount given",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount given';
                    }
                    return null;
                  },
                  onChanged: (value) => _calculateTotal(),
                  onTap: () {
                    _amtGivenController.clear();
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _profitController,
                  decoration: const InputDecoration(
                    labelText: "Profit",
                    hintText: "Enter the profit",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the profit';
                    }
                    return null;
                  },
                  onChanged: (value) => _calculateTotal(),
                  onTap: () {
                    _profitController.clear();
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _totalController,
                  labelText: "Total",
                  hintText: "Enter the total",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        controller: _lentDateController,
                        labelText: "Lent Date",
                        hintText: "Pick a lent date",
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _dueDaysController,
                        decoration: const InputDecoration(
                          labelText: "Due Days",
                          hintText: "Enter the due days",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the due days';
                          }
                          return null;
                        },
                        onTap: () {
                          _dueDaysController.clear();
                        },
                        onChanged: (value) => _calculateDueDate(),
                        onFieldSubmitted: (value) => _calculateDueDate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _dueDateController,
                  labelText: "Due Date",
                  hintText: "Due date will be calculated",
                  readOnly: true,
                ),
                const SizedBox(height: 20),

                // Submit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          DatabaseHelper.getLenId(lineName!, partyName!)
                              .then((lenid) async {
                            if (lenid != null) {
                              final lenStatus =
                                  await dbLending.getStatusByLenId(lenid);
                              if (lenStatus == 'passive') {
                                _updateLending(
                                    context, lineName, partyName, lenid);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Form Submitted')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Error: Cannot lend amount to active state party')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error: LenId is null')),
                              );
                            }
                          });
                        }
                      },
                      child: const Text("Submit"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        _lentDateController.clear();
                        _dueDaysController.clear();
                        // Clear other controllers if needed
                      },
                      child: const Text("Reset"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
