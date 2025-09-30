import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewReportsScreen extends StatelessWidget {
  const ViewReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Reports')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('reports').orderBy('uploadedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(child: Text('No reports uploaded'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text(report['fileName']),
                subtitle: Text('Patient ID: ${report['patientId']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    final url = report['url'];
                    // Open in browser or PDF viewer
                    // You can use url_launcher package
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
