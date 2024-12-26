import 'package:flutter/material.dart';
import 'package:skfinance/Data/Databasehelper.dart';
import 'BackupRestore.dart';

class BackupRestorePage extends StatefulWidget {
  @override
  _BackupRestorePageState createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final General _general = General();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup and Restore'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final dbPath = await DatabaseHelper.getDatabasePath();

                await _general.backupDatabaseToGoogleDrive(dbPath, context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Coming Soon...'),
                  ),
                );
              },
              child: Text('Backup'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Replace 'your_save_path' with the actual path where you want to save the restored file
                String savePath = await DatabaseHelper.getDatabasePath();
                await _general.restoreDatabaseFromGoogleDrive(
                    savePath, context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Coming Soon...'),
                  ),
                );
              },
              child: Text('Restore'),
            ),
          ],
        ),
      ),
    );
  }
}
