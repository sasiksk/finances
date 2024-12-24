import 'package:flutter/material.dart';

import 'package:skfinance/Data/Databasehelper.dart';
import 'package:skfinance/Utilities/CustomTextField.dart';
import 'package:skfinance/home_screen.dart';

class LineScreen extends StatefulWidget {
  final Map<String, dynamic>? entry; // Add this line

  const LineScreen({super.key, this.entry}); // Update the constructor

  @override
  _LineScreenState createState() => _LineScreenState();
}

class _LineScreenState extends State<LineScreen> {
  final TextEditingController _lineNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _lineNameController.text = widget.entry!['Linename'];
    }
  }

  @override
  void dispose() {
    _lineNameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _lineNameController.clear();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        if (widget.entry != null) {
          // Update existing entry in Line table
          await dbline.updateLine(
            lineName: widget.entry!['Linename'],
            updatedValues: {
              'Linename': _lineNameController.text,
            },
          );
          await dbline.updateLineNameInLending(
            oldLineName: widget.entry!['Linename'],
            newLineName: _lineNameController.text,
          );
          // Update LineName in Lending table

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Line entry updated successfully')),
          );
        } else {
          // Insert new entry
          await dbline.insertLine(
            _lineNameController.text,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Line entry added successfully')),
          );
        }
        _resetForm();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Line',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _lineNameController,
                labelText: 'Enter Line Name',
                hintText: 'Enter Line Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Line Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.entry != null ? 'Update' : 'Submit'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetForm,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
