import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/vendor_service.dart';
import '../../services/notification_service.dart';
import '../../models/vendor_ad.dart';

class VendorCreateAdScreen extends StatefulWidget {
  const VendorCreateAdScreen({super.key});

  @override
  State<VendorCreateAdScreen> createState() => _VendorCreateAdScreenState();
}

class _VendorCreateAdScreenState extends State<VendorCreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final VendorBusinessService _vendorService = VendorBusinessService();
  final ImagePicker _imagePicker = ImagePicker();

  int _selectedDuration = AdDuration.oneWeek;
  File? _selectedBanner;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Create Ad Campaign'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image Section
              _buildBannerSection(),
              const SizedBox(height: 24),

              // Ad Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Ad Title *',
                  hintText: 'e.g., Professional Plumbing Services',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe your promotional offer...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Duration Selection
              const Text(
                'Campaign Duration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Column(
                children:
                    AdDuration.allDurations.map((duration) {
                      final price = AdDuration.getPrice(duration);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<int>(
                          value: duration,
                          groupValue: _selectedDuration,
                          onChanged: (value) {
                            setState(() {
                              _selectedDuration = value!;
                            });
                          },
                          title: Text(
                            AdDuration.getDisplayName(duration),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '₹${price.toStringAsFixed(0)} - ${_getDurationDescription(duration)}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          activeColor: const Color(0xFFFF9800),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Pricing Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Campaign Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Duration',
                      AdDuration.getDisplayName(_selectedDuration),
                    ),
                    _buildInfoRow(
                      'Cost',
                      '₹${AdDuration.getPrice(_selectedDuration).toStringAsFixed(0)}',
                    ),
                    _buildInfoRow('Status', 'Pending admin approval'),
                    const SizedBox(height: 8),
                    Text(
                      'Your ad will be reviewed by admin before going live. You will be notified once approved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Create Ad Campaign',
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

  Widget _buildBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banner Image',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a high-quality banner image for your ad (recommended: 1200x600px)',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _pickBanner,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              color: Colors.grey.shade50,
            ),
            child:
                _selectedBanner != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedBanner!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to upload banner image',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'JPG, PNG up to 5MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
          ),
        ),

        if (_selectedBanner != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _selectedBanner = null),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getDurationDescription(int duration) {
    switch (duration) {
      case 1:
        return 'Perfect for flash sales';
      case 7:
        return 'Great for weekly promotions';
      case 30:
        return 'Best value for brand awareness';
      default:
        return 'Custom duration';
    }
  }

  Future<void> _pickBanner() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedBanner = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createAd() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBanner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a banner image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.appUser!;

      final now = DateTime.now();
      final endDate = now.add(Duration(days: _selectedDuration));

      final ad = VendorAd(
        id: '',
        vendorId: user.uid,
        vendorName: user.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        bannerUrl: '', // Will be set by service
        status: 'pending',
        duration: _selectedDuration,
        amount: AdDuration.getPrice(_selectedDuration),
        startDate: now,
        endDate: endDate,
        createdAt: now,
        views: 0,
        clicks: 0,
      );

      final adId = await _vendorService.createAd(ad, _selectedBanner!);

      // Notify admins about new ad campaign
      await NotificationService.notifyNewVendorAd(
        vendorName: user.name,
        adTitle: ad.title,
        adId: adId,
        duration: AdDuration.getDisplayName(_selectedDuration),
        amount: ad.amount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ad campaign created successfully! Awaiting admin approval.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ad: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
