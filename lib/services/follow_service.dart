import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/follow.dart';
import '../models/app_user.dart';
import 'logger_service.dart';

class FollowService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'follows';

  /// Follow a user
  static Future<void> followUser({
    required AppUser follower,
    required AppUser following,
  }) async {
    try {
      LoggerService.info('Following user: ${following.uid}', 'FOLLOW_SERVICE');

      // Check if already following
      final existingFollow = await _firestore.collection(_collection)
          .where('follower_id', isEqualTo: follower.uid)
          .where('following_id', isEqualTo: following.uid)
          .get();

      if (existingFollow.docs.isNotEmpty) {
        throw Exception('Already following this user');
      }

      // Create follow document
      final follow = Follow(
        id: '', // Will be set by Firestore
        followerId: follower.uid,
        followerName: follower.name,
        followerRole: follower.role,
        followingId: following.uid,
        followingName: following.name,
        followingRole: following.role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection(_collection).add(follow.toMap());

      LoggerService.info('User followed successfully: ${following.uid}', 'FOLLOW_SERVICE');
    } catch (e) {
      LoggerService.error('Error following user', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to follow user: $e');
    }
  }

  /// Unfollow a user
  static Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      LoggerService.info('Unfollowing user: $followingId', 'FOLLOW_SERVICE');

      // Find the follow document
      final followQuery = await _firestore.collection(_collection)
          .where('follower_id', isEqualTo: followerId)
          .where('following_id', isEqualTo: followingId)
          .get();

      if (followQuery.docs.isEmpty) {
        throw Exception('Follow relationship not found');
      }

      // Delete the follow document
      await followQuery.docs.first.reference.delete();

      LoggerService.info('User unfollowed successfully: $followingId', 'FOLLOW_SERVICE');
    } catch (e) {
      LoggerService.error('Error unfollowing user', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to unfollow user: $e');
    }
  }

  /// Check if user is following another user
  static Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final followQuery = await _firestore.collection(_collection)
          .where('follower_id', isEqualTo: followerId)
          .where('following_id', isEqualTo: followingId)
          .get();

      return followQuery.docs.isNotEmpty;
    } catch (e) {
      LoggerService.error('Error checking follow status', 'FOLLOW_SERVICE', e);
      return false;
    }
  }

  /// Get followers of a user
  static Stream<List<Follow>> getFollowers(String userId) {
    try {
      return _firestore.collection(_collection)
          .where('following_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Follow.fromFirestore(doc)).toList();
      });
    } catch (e) {
      LoggerService.error('Error getting followers', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to get followers: $e');
    }
  }

  /// Get users that a user is following
  static Stream<List<Follow>> getFollowing(String userId) {
    try {
      return _firestore.collection(_collection)
          .where('follower_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Follow.fromFirestore(doc)).toList();
      });
    } catch (e) {
      LoggerService.error('Error getting following', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to get following: $e');
    }
  }

  /// Get followers count for a user
  static Stream<int> getFollowersCount(String userId) {
    try {
      return _firestore.collection(_collection)
          .where('following_id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      LoggerService.error('Error getting followers count', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to get followers count: $e');
    }
  }

  /// Get following count for a user
  static Stream<int> getFollowingCount(String userId) {
    try {
      return _firestore.collection(_collection)
          .where('follower_id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      LoggerService.error('Error getting following count', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to get following count: $e');
    }
  }

  /// Toggle follow status
  static Future<bool> toggleFollow({
    required AppUser follower,
    required AppUser following,
  }) async {
    try {
      final isCurrentlyFollowing = await isFollowing(
        followerId: follower.uid,
        followingId: following.uid,
      );

      if (isCurrentlyFollowing) {
        await unfollowUser(
          followerId: follower.uid,
          followingId: following.uid,
        );
        return false; // Now unfollowing
      } else {
        await followUser(
          follower: follower,
          following: following,
        );
        return true; // Now following
      }
    } catch (e) {
      LoggerService.error('Error toggling follow', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to toggle follow: $e');
    }
  }

  /// Get suggested users to follow (users not currently followed)
  static Future<List<AppUser>> getSuggestedUsers({
    required String currentUserId,
    String? societyId,
    int limit = 10,
  }) async {
    try {
      // Get list of users currently being followed
      final followingQuery = await _firestore.collection(_collection)
          .where('follower_id', isEqualTo: currentUserId)
          .get();
      
      final followingIds = followingQuery.docs
          .map((doc) => doc.data()['following_id'] as String)
          .toList();
      
      // Add current user ID to exclude from suggestions
      followingIds.add(currentUserId);

      // Query users not in the following list
      Query usersQuery = _firestore.collection('users')
          .where('status', isEqualTo: 'active')
          .limit(limit * 2); // Get more to filter out followed users

      if (societyId != null && societyId.isNotEmpty) {
        usersQuery = usersQuery.where('society_id', isEqualTo: societyId);
      }

      final usersSnapshot = await usersQuery.get();
      
      final suggestedUsers = usersSnapshot.docs
          .where((doc) => !followingIds.contains(doc.id))
          .take(limit)
          .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return suggestedUsers;
    } catch (e) {
      LoggerService.error('Error getting suggested users', 'FOLLOW_SERVICE', e);
      throw Exception('Failed to get suggested users: $e');
    }
  }
}
