import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrugStoreScreen extends StatefulWidget {
  const DrugStoreScreen({super.key});

  @override
  State<DrugStoreScreen> createState() => _DrugStoreScreenState();
}

class _DrugStoreScreenState extends State<DrugStoreScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _orderDrug(String drugName) async {
    final userId = _auth.currentUser!.uid;

    try {
      await _firestore.collection('orders').add({
        'patientId': userId,
        'drugName': drugName,
        'orderedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // You can later update status when processed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ordered $drugName successfully!')),
      );
    } catch (e) {
      print('Error ordering drug: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Drug Store')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('drugs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No drugs available'));
          }

          final drugs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: drugs.length,
            itemBuilder: (context, index) {
              final drug = drugs[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(drug['name']),
                  subtitle: Text('Price: \$${drug['price']}'),
                  trailing: ElevatedButton(
                    onPressed: () => _orderDrug(drug['name']),
                    child: const Text('Order'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
