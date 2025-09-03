import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_provider.dart' as my_auth;
import '../../route_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<my_auth.AuthProvider>(
      context,
      listen: false,
    );

    try {
      // Wait for Firebase Auth to initialize and check current user
      await Future.delayed(const Duration(milliseconds: 500));
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        // No user logged in - go to login screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // User is logged in - load their profile data with retry logic
      bool userLoaded = false;
      int retryCount = 0;
      const maxRetries = 3;

      while (!userLoaded && retryCount < maxRetries) {
        try {
          await authProvider.loadUser();
          userLoaded = true;
        } catch (e) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount));
          } else {
            // If we can't load user data after retries, still proceed
            // The user is authenticated with Firebase
            debugPrint(
              'Failed to load user data after $maxRetries attempts: $e',
            );
          }
        }
      }

      if (!mounted) return;

      // Route user based on their profile data
      RouteHelper.routeUser(
        context,
        authProvider.role ?? '',
        authProvider.isProfileComplete,
        status: authProvider.appUser?.status,
      );
    } catch (e) {
      debugPrint('Auth state check failed: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.home, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              // App Name
              const Text(
                'GateEase',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Smart Society Management',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),
              // Loading Indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Loading...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
