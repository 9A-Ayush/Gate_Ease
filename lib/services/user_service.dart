import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import 'logger_service.dart';

class UserService {
  static const String _collection = 'users';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user by ID
  static Future<AppUser?> getUserById(String userId) async {
    try {
      LoggerService.info('Fetching user by ID: $userId', 'USER_SERVICE');

      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (doc.exists) {
        final user = AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        LoggerService.info('User found', 'USER_SERVICE');
        return user;
      } else {
        LoggerService.info('User not found', 'USER_SERVICE');
        return null;
      }
    } catch (e) {
      LoggerService.error('Error fetching user by ID', 'USER_SERVICE', e);
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Get user by email
  static Future<AppUser?> getUserByEmail(String email) async {
    try {
      LoggerService.info('Fetching user by email: $email', 'USER_SERVICE');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final user = AppUser.fromMap(doc.data(), doc.id);
        LoggerService.info('User found by email', 'USER_SERVICE');
        return user;
      } else {
        LoggerService.info('User not found by email', 'USER_SERVICE');
        return null;
      }
    } catch (e) {
      LoggerService.error('Error fetching user by email', 'USER_SERVICE', e);
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Update user information
  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      LoggerService.info('Updating user: $userId', 'USER_SERVICE');

      await _firestore.collection(_collection).doc(userId).update(data);

      LoggerService.info('User updated successfully', 'USER_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating user', 'USER_SERVICE', e);
      throw Exception('Failed to update user: $e');
    }
  }

  /// Get all residents (for admin)
  static Future<List<AppUser>> getAllResidents() async {
    try {
      LoggerService.info('Fetching all residents', 'USER_SERVICE');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: 'resident')
          .get();

      final users = querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();

      LoggerService.info('Fetched ${users.length} residents', 'USER_SERVICE');
      return users;
    } catch (e) {
      LoggerService.error('Error fetching residents', 'USER_SERVICE', e);
      throw Exception('Failed to fetch residents: $e');
    }
  }
}
