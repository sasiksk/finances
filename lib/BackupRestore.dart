import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class General {
  final secureStorage = FlutterSecureStorage();

  Future<void> saveFileId(String fileId) async {
    await secureStorage.write(key: 'google_drive_file_id', value: fileId);
  }

  Future<String?> getFileId() async {
    return await secureStorage.read(key: 'google_drive_file_id');
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  Future<GoogleSignInAccount?> signIn(BuildContext context) async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during sign-in: $e')),
      );
      return null;
    }
  }

  Future<void> backupDatabaseToGoogleDrive(
      String dbPath, BuildContext context) async {
    try {
      final account = await signIn(context);
      if (account == null) {
        print('Sign-in failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed')),
        );
        return;
      }

      final headers = await account.authHeaders;
      final file = File(dbPath);

      final uploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'),
      );

      uploadRequest.headers.addAll(headers);
      uploadRequest.fields['name'] = file.uri.pathSegments.last; // File name
      uploadRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.uri.pathSegments.last,
        ),
      );

      final response = await uploadRequest.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        final fileId = responseData['id'];
        print('File uploaded successfully with ID: $fileId');

        // Save the fileId dynamically
        await saveFileId(fileId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('File uploaded successfully with ID: $fileId')),
        );
      } else {
        print('Failed to upload file: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload file: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      print('Error during backup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during backup: $e')),
      );
    }
  }

  Future<void> restoreDatabaseFromGoogleDrive(
      String savePath, BuildContext context) async {
    try {
      final account = await signIn(context);
      if (account == null) {
        print('Sign-in failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed')),
        );
        return;
      }

      final fileId = await getFileId();
      if (fileId == null) {
        print('No file ID found. Backup the database first.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No file ID found. Backup the database first.')),
        );
        return;
      }

      final headers = await account.authHeaders;

      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        print('Database restored successfully to: $savePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Database restored successfully to: $savePath')),
        );
      } else {
        print('Failed to restore file: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to restore file: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      print('Error during restore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during restore: $e')),
      );
    }
  }
}
