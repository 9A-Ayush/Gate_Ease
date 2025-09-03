import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'cloudinary_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user profile
  Future<AppUser?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!, user.uid);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile information
  Future<void> updateProfile({
    String? name,
    String? about,
    String? phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (about != null) updateData['about'] = about;
      if (phone != null) updateData['phone'] = phone;

      if (updateData.isNotEmpty) {
        await _db.collection('users').doc(user.uid).update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload and update profile image
  Future<String?> updateProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(
        imageFile,
        folder: 'profile_images',
      );

      if (imageUrl != null) {
        // Update user document with new image URL
        await _db.collection('users').doc(user.uid).update({
          'profileImageUrl': imageUrl,
        });
        return imageUrl;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  /// Remove profile image
  Future<void> removeProfileImage() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Get current profile to check if there's an existing image
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile?.profileImageUrl != null) {
        // Extract public ID and delete from Cloudinary
        final publicId = CloudinaryService.getPublicIdFromUrl(
          currentProfile!.profileImageUrl!,
        );
        if (publicId != null) {
          await CloudinaryService.deleteImage(publicId);
        }
      }

      // Remove image URL from user document
      await _db.collection('users').doc(user.uid).update({
        'profileImageUrl': null,
      });
    } catch (e) {
      throw Exception('Failed to remove profile image: $e');
    }
  }

  /// Update multiple profile fields at once
  Future<void> updateCompleteProfile({
    String? name,
    String? about,
    String? phone,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (about != null) updateData['about'] = about;
      if (phone != null) updateData['phone'] = phone;

      // Handle profile image upload if provided
      if (profileImage != null) {
        final imageUrl = await CloudinaryService.uploadImage(
          profileImage,
          folder: 'profile_images',
        );
        if (imageUrl != null) {
          updateData['profileImageUrl'] = imageUrl;
        }
      }

      if (updateData.isNotEmpty) {
        await _db.collection('users').doc(user.uid).update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update complete profile: $e');
    }
  }

  /// Get user's login email (from Firebase Auth)
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Check if user can edit certain fields based on their role
  bool canEditField(String field, String userRole) {
    switch (field) {
      case 'email':
        return false; // Email cannot be edited through profile
      case 'role':
        return false; // Role cannot be edited by user
      case 'status':
        return false; // Status is managed by admin
      case 'flatNo':
      case 'societyId':
        return userRole == 'resident'; // Only residents can edit these
      default:
        return true; // Name, about, phone, profile image can be edited by all
    }
  }
}
