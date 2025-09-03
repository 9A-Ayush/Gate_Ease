import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/cloudinary_service.dart';

class GuardVisitorLogScreen extends StatefulWidget {
  const GuardVisitorLogScreen({super.key});

  @override
  State<GuardVisitorLogScreen> createState() => _GuardVisitorLogScreenState();
}

class _GuardVisitorLogScreenState extends State<GuardVisitorLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _purposeController = TextEditingController();
  final _flatController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  String _selectedVehicleType = 'None';

  final List<String> _vehicleTypes = [
    'None',
    'Car',
    'Bike',
    'Bicycle',
    'Auto',
    'Taxi',
  ];
  final List<String> _purposes = [
    'Personal Visit',
    'Delivery',
    'Service/Repair',
    'Medical',
    'Business',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Log Visitor Entry'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 48,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Visitor Entry Form',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in visitor details for entry log',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Visitor Photo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visitor Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child:
                              _selectedImage != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to capture',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Visitor Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visitor Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Visitor Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty == true
                                  ? 'Please enter name'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (value) =>
                              value?.isEmpty == true
                                  ? 'Please enter phone number'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Visiting Flat
                    TextFormField(
                      controller: _flatController,
                      decoration: const InputDecoration(
                        labelText: 'Visiting Flat *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                        hintText: 'e.g., A-101',
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty == true
                                  ? 'Please enter flat number'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Purpose
                    DropdownButtonFormField<String>(
                      initialValue:
                          _purposeController.text.isEmpty
                              ? null
                              : _purposeController.text,
                      decoration: const InputDecoration(
                        labelText: 'Purpose of Visit *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                      items:
                          _purposes.map((purpose) {
                            return DropdownMenuItem(
                              value: purpose,
                              child: Text(purpose),
                            );
                          }).toList(),
                      onChanged:
                          (value) => _purposeController.text = value ?? '',
                      validator:
                          (value) =>
                              value == null ? 'Please select purpose' : null,
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Type
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      items:
                          _vehicleTypes.map((vehicle) {
                            return DropdownMenuItem(
                              value: vehicle,
                              child: Text(vehicle),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => _selectedVehicleType = value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitVisitorEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'LOG VISITOR ENTRY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitVisitorEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload image to Cloudinary if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.uploadImage(
          _selectedImage!,
          folder: 'visitors',
        );
      }

      // Create visitor entry
      await FirebaseFirestore.instance.collection('visitors').add({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'visiting_flat': _flatController.text.trim().toUpperCase(),
        'purpose': _purposeController.text,
        'vehicle_type': _selectedVehicleType,
        'photo_url': imageUrl,
        'entry_time': FieldValue.serverTimestamp(),
        'status': 'pending',
        'logged_by': 'guard',
      });

      // Clear form
      _nameController.clear();
      _phoneController.clear();
      _flatController.clear();
      _purposeController.clear();
      setState(() {
        _selectedImage = null;
        _selectedVehicleType = 'None';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visitor entry logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging visitor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    _flatController.dispose();
    super.dispose();
  }
}
