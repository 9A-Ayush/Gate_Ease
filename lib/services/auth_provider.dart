import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  User? firebaseUser;
  AppUser? appUser;
  bool isLoading = true;

  AuthProvider() {
    AuthService().authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    firebaseUser = user;
    if (user != null) {
      appUser = await AuthService().getAppUser();
    } else {
      appUser = null;
    }
    isLoading = false;
    notifyListeners();
  }

  bool get isLoggedIn => firebaseUser != null;
  String? get role => appUser?.role;
  bool get isProfileComplete => appUser?.profileComplete ?? false;

  Future<void> signOut() async {
    await AuthService().signOut();
  }

  // Logout with navigation - clears navigation stack
  Future<void> signOutAndNavigateToLogin(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (context.mounted) {
        // Clear the entire navigation stack and go to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> loadUser() async {
    if (firebaseUser != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser!.uid)
                .get();

        if (userDoc.exists) {
          appUser = AppUser.fromMap(userDoc.data()!, firebaseUser!.uid);
        } else {
          // User document doesn't exist in Firestore - this shouldn't happen
          // but if it does, clear the user data
          appUser = null;
          debugPrint(
            'Warning: Firebase user exists but no Firestore document found',
          );
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading user: $e');
        // Don't clear appUser on network errors - keep existing data
        // Only clear if it's a critical error
        if (e.toString().contains('permission-denied') ||
            e.toString().contains('not-found')) {
          appUser = null;
        }
        notifyListeners();
      }
    } else {
      // No Firebase user - clear app user data
      appUser = null;
      notifyListeners();
    }
  }

  // Refresh user data - useful for app resume
  Future<void> refreshUser() async {
    if (firebaseUser != null) {
      await loadUser();
    }
  }
}
