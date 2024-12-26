import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skfinance/Data/Databasehelper.dart';

class RestorePage extends StatefulWidget {
  @override
  _RestorePageState createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage> {
  bool _isLoading = false;

  Future<void> restoreDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request storage permissions
      if (await Permission.storage.request().isGranted &&
          await Permission.manageExternalStorage.request().isGranted) {
        // Open file picker to select the database file
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any, // Allow all file types
        );

        if (result != null && result.files.single.path != null) {
          // Get the selected file
          File selectedFile = File(result.files.single.path!);

          // Validate the file extension
          if (selectedFile.path.endsWith('.db')) {
            // Proceed with restoring the database
            // Define the target database path
            String dbPath = await DatabaseHelper.getDatabasePath();

// Delete the existing file if it exists

            File dbFile = File(dbPath);

// Copy the selected file to the app's database directory, overwriting the existing file
            await selectedFile.copy(dbPath);

            print(selectedFile.path);
            print(dbPath);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Database restored successfully!')),
            );
          } else {
            // Notify the user about the invalid file type
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Invalid file type. Please select a .db file.')),
            );
          }
        } else {
          // User canceled the picker
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No file selected.')),
          );
        }
      } else {
        // Permissions not granted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permissions not granted.')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring database: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restore Database'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: restoreDatabase,
                child: Text('Restore Database'),
              ),
      ),
    );
  }
}
