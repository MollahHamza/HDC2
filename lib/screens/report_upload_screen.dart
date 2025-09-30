import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';


class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({super.key});

  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool isUploading = false;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => isUploading = true);
      final file = File(result.files.single.path!);
      final userId = _auth.currentUser!.uid;
      final fileName = result.files.single.name;

      try {
        // Upload file to Firebase Storage
        final ref = _storage.ref().child('reports/$userId/$fileName');
        await ref.putFile(file);

        // Get download URL
        final downloadUrl = await ref.getDownloadURL();

        // Save metadata in Firestore
        await _firestore.collection('reports').add({
          'patientId': userId,
          'fileName': fileName,
          'url': downloadUrl,
          'uploadedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report uploaded successfully!')),
        );
      } catch (e) {
        print('Error uploading report: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload report')),
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Reports')),
      body: Center(
        child: isUploading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _pickAndUploadFile,
                child: const Text('Select & Upload Report'),
              ),
      ),
    );
  }
}
