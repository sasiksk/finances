import 'package:flutter/material.dart';

import 'package:skfinance/Data/Databasehelper.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedTable;
  List<Map<String, dynamic>> _tableData = [];
  List<String> _tableNames = ['Line', 'Lending', 'Collection'];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadTableData(String tableName) async {
    final db = await DatabaseHelper.getDatabase();
    final data = await db.query(tableName);
    setState(() {
      _tableData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Table'),
              value: _selectedTable,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTable = newValue;
                  _loadTableData(newValue!);
                });
              },
              items: _tableNames.map((String tableName) {
                return DropdownMenuItem<String>(
                  value: tableName,
                  child: Text(tableName),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Start Date: ${_startDate.toLocal()}'.split(' ')[0]),
            Text('End Date: ${_endDate.toLocal()}'.split(' ')[0]),
            SizedBox(height: 20),
            Expanded(
              child: _tableData.isEmpty
                  ? Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: _tableData.isNotEmpty
                            ? _tableData.first.keys
                                .map((key) => DataColumn(label: Text(key)))
                                .toList()
                            : [],
                        rows: _tableData
                            .map((item) => DataRow(
                                  cells: item.values
                                      .map((value) =>
                                          DataCell(Text(value.toString())))
                                      .toList(),
                                ))
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
