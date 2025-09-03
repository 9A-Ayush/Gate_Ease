import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHomeScreen extends StatefulWidget {
  const AddHomeScreen({super.key});

  @override
  State<AddHomeScreen> createState() => _AddHomeScreenState();
}

class _AddHomeScreenState extends State<AddHomeScreen> {
  String? selectedCountry;
  String? selectedCity;
  String? selectedSociety;
  String? selectedBuilding;
  String? flatNumber;

  // Mock data
  final Map<String, Map<String, Map<String, List<String>>>> data = {
    'India': {
      'Mumbai': {
        'Green Acres': ['A', 'B', 'C'],
        'Sunshine Residency': ['A', 'B'],
      },
      'Delhi': {
        'Palm Grove': ['A', 'B'],
      },
    },
    'UAE': {
      'Dubai': {
        'Palm Towers': ['A', 'B'],
      },
    },
    'USA': {
      'New York': {
        'Central Park Towers': ['A', 'B', 'C'],
      },
    },
  };

  List<String> get countries => data.keys.toList();
  List<String> get cities =>
      selectedCountry == null ? [] : data[selectedCountry!]!.keys.toList();
  List<String> get societies =>
      (selectedCountry == null || selectedCity == null)
          ? []
          : data[selectedCountry!]![selectedCity!]!.keys.toList();
  List<String> get buildings =>
      (selectedCountry == null ||
              selectedCity == null ||
              selectedSociety == null)
          ? []
          : data[selectedCountry!]![selectedCity!]![selectedSociety!]!;

  bool isLoading = false;

  Future<void> _submit() async {
    if ([
          selectedCountry,
          selectedCity,
          selectedSociety,
          selectedBuilding,
          flatNumber,
        ].contains(null) ||
        flatNumber!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => isLoading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'country': selectedCountry,
      'city': selectedCity,
      'society': selectedSociety,
      'building': selectedBuilding,
      'flat_no': flatNumber,
      'status': 'pending',
      'profileComplete': true,
    });
    setState(() => isLoading = false);
    Navigator.pushReplacementNamed(context, '/awaiting_approval');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Society')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedCountry,
              items:
                  countries
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    selectedCountry = val;
                    selectedCity = null;
                    selectedSociety = null;
                    selectedBuilding = null;
                  }),
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedCity,
              items:
                  cities
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    selectedCity = val;
                    selectedSociety = null;
                    selectedBuilding = null;
                  }),
              decoration: const InputDecoration(labelText: 'City'),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedSociety,
              items:
                  societies
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    selectedSociety = val;
                    selectedBuilding = null;
                  }),
              decoration: const InputDecoration(labelText: 'Society'),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedBuilding,
              items:
                  buildings
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
              onChanged: (val) => setState(() => selectedBuilding = val),
              decoration: const InputDecoration(labelText: 'Building'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Flat Number'),
              onChanged: (val) => flatNumber = val,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
          ],
        ),
      ),
    );
  }
}
