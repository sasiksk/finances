import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart'; // Add this import
import 'package:http_parser/http_parser.dart';

import 'package:archive/archive_io.dart'; // Add this import

class General {
  final secureStorage = FlutterSecureStorage();

  Future<void> saveFileId(String fileId) async {
    await secureStorage.write(key: 'google_drive_file_id', value: fileId);
  }

  Future<String?> getFolderId(
      String folderName, Map<String, String> headers) async {
    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/drive/v3/files?q=name="$folderName" and mimeType="application/vnd.google-apps.folder" and trashed=false'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final files = responseBody['files'] as List<dynamic>;
      if (files.isNotEmpty) {
        return files.first['id'] as String;
      }
    } else {
      print('Failed to check folder existence: ${response.reasonPhrase}');
    }
    return null;
  }

  Future<String?> createFolder(
      String folderName, Map<String, String> headers) async {
    // Check if the folder already exists
    final existingFolderId = await getFolderId(folderName, headers);
    if (existingFolderId != null) {
      print('Folder already exists with ID: $existingFolderId');
      return existingFolderId;
    }

    // Create a new folder if it doesn't exist
    final response = await http.post(
      Uri.parse('https://www.googleapis.com/drive/v3/files'),
      headers: headers,
      body: json.encode({
        'name': folderName,
        'mimeType': 'application/vnd.google-apps.folder',
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['id'];
    } else {
      print('Failed to create folder: ${response.reasonPhrase}');
      return null;
    }
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

// ...existing code...

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
      headers['Content-Type'] = 'application/json';

      // Create folder
      final folderId = await createFolder('digivasool', headers);
      if (folderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create folder')),
        );
        return;
      }

      final file = File(dbPath);

      // Zip the database file
      final zipFilePath = '${file.parent.path}/database.zip';
      final zipFile = File(zipFilePath);
      final encoder = ZipFileEncoder();
      encoder.create(zipFilePath);
      encoder.addFile(file);
      encoder.close();

      final uploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
        ),
      );

      uploadRequest.headers.addAll(headers);
      uploadRequest.fields['name'] = zipFile.uri.pathSegments.last; // File name
      uploadRequest.fields['parents'] = folderId; // Set the parent folder

      // Determine the MIME type of the zip file
      final mimeType = lookupMimeType(zipFile.path) ?? 'application/zip';
      print('Determined MIME type: $mimeType');

      uploadRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await zipFile.readAsBytes(),
          filename: zipFile.uri.pathSegments.last,
          contentType:
              MediaType.parse(mimeType), // Set the correct content type
        ),
      );

      // Log the request details
      print('Uploading file: ${zipFile.uri.pathSegments.last}');
      print('Headers: $headers');
      print('Fields: ${uploadRequest.fields}');
      print('Files: ${uploadRequest.files}');

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
        final responseBody = await response.stream.bytesToString();
        print('Failed to upload file: ${response.reasonPhrase}');
        print('Response body: $responseBody');
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
        print('Database restored successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database restored successfully')),
        );
      } else {
        print('Failed to download file: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to download file: ${response.reasonPhrase}')),
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
