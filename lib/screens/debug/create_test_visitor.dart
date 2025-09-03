import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTestVisitorScreen extends StatefulWidget {
  const CreateTestVisitorScreen({super.key});

  @override
  State<CreateTestVisitorScreen> createState() =>
      _CreateTestVisitorScreenState();
}

class _CreateTestVisitorScreenState extends State<CreateTestVisitorScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _flatController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test Visitor'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Visitor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _flatController,
              decoration: const InputDecoration(
                labelText: 'Visiting Flat (e.g., 560)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createTestVisitor,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Test Visitor'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'This will create a test visitor with status "pending" that should appear in the resident\'s visitor management screen.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTestVisitor() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _flatController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('visitors').add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'visiting_flat': _flatController.text,
        'status': 'pending',
        'purpose': 'Test visit',
        'vehicle_type': 'None',
        'entry_time': FieldValue.serverTimestamp(),
        'logged_by': 'Test Guard',
        'photo_url': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test visitor created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _nameController.clear();
      _phoneController.clear();
      _flatController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating visitor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _flatController.dispose();
    super.dispose();
  }
}
