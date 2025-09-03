import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugDataScreen extends StatelessWidget {
  const DebugDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Data'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.pushNamed(context, '/create_test_visitor'),
                child: const Text('Create Test Visitor'),
              ),
            ),
            const SizedBox(height: 24),
            // Current User Info
            const Text(
              'Current User Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UID: ${FirebaseAuth.instance.currentUser?.uid}'),
                      Text('Name: ${userData?['name'] ?? 'N/A'}'),
                      Text('Role: ${userData?['role'] ?? 'N/A'}'),
                      Text('Flat No: "${userData?['flat_no'] ?? 'N/A'}"'),
                      Text('Status: ${userData?['status'] ?? 'N/A'}'),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // All Users
            const Text(
              'All Users:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return Column(
                  children:
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${data['name'] ?? 'N/A'}'),
                              Text('Role: ${data['role'] ?? 'N/A'}'),
                              Text('Flat No: "${data['flat_no'] ?? 'N/A'}"'),
                              Text('Status: ${data['status'] ?? 'N/A'}'),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // All Visitors
            const Text(
              'All Visitors:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('visitors')
                      .orderBy('entry_time', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                if (snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('No visitors found'),
                  );
                }

                return Column(
                  children:
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${data['name'] ?? 'N/A'}'),
                              Text(
                                'Visiting Flat: "${data['visiting_flat'] ?? 'N/A'}"',
                              ),
                              Text('Phone: ${data['phone'] ?? 'N/A'}'),
                              Text('Status: ${data['status'] ?? 'N/A'}'),
                              Text('Logged By: ${data['logged_by'] ?? 'N/A'}'),
                              if (data['entry_time'] != null)
                                Text(
                                  'Entry Time: ${(data['entry_time'] as Timestamp).toDate()}',
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
