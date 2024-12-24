// filepath: /J:/SASIKUMAR/skfinance/lib/Backuppage.dart
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'Data/Databasehelper.dart';

class DownloadDBScreen extends StatelessWidget {
  Future<void> downloadDBFile(BuildContext context) async {
    try {
      final dbPath = await DatabaseHelper.getDatabasePath();
      final dbFile = File(dbPath);
      if (await Permission.storage.request().isGranted &&
          await Permission.manageExternalStorage.request().isGranted) {
        // Get the database path
      }

      // Complete path
      String savePath = '$dbPath';

      // Copy the database file to the selected directory
      //await dbFile.copy(savePath);

      // Notify user

      // Share the file
      await Share.shareFiles([savePath], text: 'Download DB file');
    } catch (e) {
      debugPrint('Error creating backup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating backup: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Download Database File')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => downloadDBFile(context),
          child: Text('Download DB File'),
        ),
      ),
    );
  }
}
