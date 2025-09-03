import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../route_helper.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String role;
  const ProfileCompletionScreen({super.key, required this.role});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final extraInfoController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    extraInfoController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (extraInfoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the required information'),
        ),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      // Get current user ID from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await AuthService().completeProfile(currentUser.uid, {
        'extraInfo': extraInfoController.text.trim(),
      });

      if (!mounted) return;

      // Route user based on their role
      switch (widget.role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin_home');
          break;
        case 'guard':
          Navigator.pushReplacementNamed(context, '/guard_home');
          break;
        case 'vendor':
          Navigator.pushReplacementNamed(context, '/vendor_home');
          break;
        default:
          RouteHelper.navigateToLogin(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile completion failed: $e')));
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  String _getRoleSpecificHint() {
    switch (widget.role) {
      case 'guard':
        return 'Enter your assigned area and shift details';
      case 'vendor':
        return 'Enter your business details and service area';
      case 'admin':
        return 'Enter additional admin information';
      default:
        return 'Enter additional information';
    }
  }

  String _getRoleSpecificLabel() {
    switch (widget.role) {
      case 'guard':
        return 'Area & Shift Details';
      case 'vendor':
        return 'Business Details';
      case 'admin':
        return 'Admin Information';
      default:
        return 'Additional Information';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Complete Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Welcome Section
              Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Additional info for ${widget.role.capitalize()}',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Role-specific information
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: extraInfoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _getRoleSpecificHint(),
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Save & Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const Spacer(),
              // Help Text
              const Text(
                'This information helps us provide\nyou with better service',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
