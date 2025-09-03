import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/cloudinary_service.dart';
import '../services/error_handler_service.dart';

class AddVisitorForm extends StatefulWidget {
  final String? defaultFlat; // For residents, this will be their flat number
  final String loggedBy; // 'admin', 'resident', or 'guard'
  final VoidCallback? onVisitorAdded;

  const AddVisitorForm({
    super.key,
    this.defaultFlat,
    required this.loggedBy,
    this.onVisitorAdded,
  });

  @override
  State<AddVisitorForm> createState() => _AddVisitorFormState();
}

class _AddVisitorFormState extends State<AddVisitorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _flatController = TextEditingController();
  final _purposeController = TextEditingController();
  
  String _selectedVehicleType = 'None';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _vehicleTypes = [
    'None',
    'Two Wheeler',
    'Four Wheeler',
    'Bicycle',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.defaultFlat != null) {
      _flatController.text = widget.defaultFlat!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _flatController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerService.handleError(
          context,
          e,
          customMessage: 'Failed to capture image. Please try again.',
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image to Cloudinary if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.uploadImage(
          _selectedImage!,
          folder: 'visitors',
        );
      }

      // Determine initial status based on who is adding the visitor
      String initialStatus;
      switch (widget.loggedBy) {
        case 'admin':
          initialStatus = 'approved'; // Admin can directly approve
          break;
        case 'resident':
          initialStatus = 'pending'; // Resident requests need approval
          break;
        case 'guard':
          initialStatus = 'pending'; // Guard entries need approval
          break;
        default:
          initialStatus = 'pending';
      }

      // Create visitor entry
      await FirebaseFirestore.instance.collection('visitors').add({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'visiting_flat': _flatController.text.trim().toUpperCase(),
        'purpose': _purposeController.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'photo_url': imageUrl,
        'entry_time': FieldValue.serverTimestamp(),
        'status': initialStatus,
        'logged_by': widget.loggedBy,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ErrorHandlerService.showSuccessSnackBar(
          context,
          'Visitor ${widget.loggedBy == 'admin' ? 'added and approved' : 'registered'} successfully!',
        );
        
        // Clear form
        _nameController.clear();
        _phoneController.clear();
        if (widget.defaultFlat == null) {
          _flatController.clear();
        }
        _purposeController.clear();
        setState(() {
          _selectedVehicleType = 'None';
          _selectedImage = null;
        });

        // Callback to parent
        widget.onVisitorAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerService.handleError(
          context,
          e,
          customMessage: 'Failed to register visitor. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Add New Visitor',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),

            // Visitor Photo
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : InkWell(
                      onTap: _pickImage,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to capture visitor photo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Retake Photo'),
              ),
            ],
            const SizedBox(height: 16),

            // Visitor Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Visitor Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter visitor name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Visiting Flat
            TextFormField(
              controller: _flatController,
              decoration: const InputDecoration(
                labelText: 'Visiting Flat *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
                hintText: 'e.g., A-101, B-205',
              ),
              enabled: widget.defaultFlat == null, // Disable for residents
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter flat number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Purpose of Visit
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose of Visit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'e.g., Personal visit, Delivery, Service',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Vehicle Type
            DropdownButtonFormField<String>(
              value: _selectedVehicleType,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: _vehicleTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleType = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.loggedBy == 'admin' 
                          ? 'Add & Approve Visitor'
                          : 'Register Visitor',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
