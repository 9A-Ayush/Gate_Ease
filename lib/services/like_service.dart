import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/like.dart';
import '../models/app_user.dart';
import 'post_service.dart';
import 'logger_service.dart';

class LikeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'likes';

  /// Like a post
  static Future<void> likePost({
    required String postId,
    required AppUser user,
  }) async {
    try {
      LoggerService.info('Liking post: $postId', 'LIKE_SERVICE');

      // Check if user already liked this post
      final existingLike = await _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: user.uid)
          .get();

      if (existingLike.docs.isNotEmpty) {
        throw Exception('Post already liked by user');
      }

      // Create like document
      final like = Like(
        id: '', // Will be set by Firestore
        postId: postId,
        userId: user.uid,
        userName: user.name,
        userRole: user.role,
        createdAt: DateTime.now(),
      );

      // Add like and increment post likes count in a batch
      final batch = _firestore.batch();
      
      final likeRef = _firestore.collection(_collection).doc();
      batch.set(likeRef, like.toMap());
      
      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {'likes_count': FieldValue.increment(1)});
      
      await batch.commit();

      LoggerService.info('Post liked successfully: $postId', 'LIKE_SERVICE');
    } catch (e) {
      LoggerService.error('Error liking post', 'LIKE_SERVICE', e);
      throw Exception('Failed to like post: $e');
    }
  }

  /// Unlike a post
  static Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    try {
      LoggerService.info('Unliking post: $postId', 'LIKE_SERVICE');

      // Find the like document
      final likeQuery = await _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: userId)
          .get();

      if (likeQuery.docs.isEmpty) {
        throw Exception('Like not found');
      }

      // Delete like and decrement post likes count in a batch
      final batch = _firestore.batch();
      
      batch.delete(likeQuery.docs.first.reference);
      
      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {'likes_count': FieldValue.increment(-1)});
      
      await batch.commit();

      LoggerService.info('Post unliked successfully: $postId', 'LIKE_SERVICE');
    } catch (e) {
      LoggerService.error('Error unliking post', 'LIKE_SERVICE', e);
      throw Exception('Failed to unlike post: $e');
    }
  }

  /// Check if user has liked a post
  static Future<bool> hasUserLikedPost({
    required String postId,
    required String userId,
  }) async {
    try {
      final likeQuery = await _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: userId)
          .get();

      return likeQuery.docs.isNotEmpty;
    } catch (e) {
      LoggerService.error('Error checking if user liked post', 'LIKE_SERVICE', e);
      return false;
    }
  }

  /// Get likes for a post
  static Stream<List<Like>> getPostLikes(String postId) {
    try {
      return _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Like.fromFirestore(doc)).toList();
      });
    } catch (e) {
      LoggerService.error('Error getting post likes', 'LIKE_SERVICE', e);
      throw Exception('Failed to get post likes: $e');
    }
  }

  /// Get likes count for a post
  static Stream<int> getPostLikesCount(String postId) {
    try {
      return _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      LoggerService.error('Error getting post likes count', 'LIKE_SERVICE', e);
      throw Exception('Failed to get post likes count: $e');
    }
  }

  /// Get posts liked by a user
  static Stream<List<Like>> getUserLikes(String userId) {
    try {
      return _firestore.collection(_collection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Like.fromFirestore(doc)).toList();
      });
    } catch (e) {
      LoggerService.error('Error getting user likes', 'LIKE_SERVICE', e);
      throw Exception('Failed to get user likes: $e');
    }
  }

  /// Toggle like status for a post
  static Future<bool> toggleLike({
    required String postId,
    required AppUser user,
  }) async {
    try {
      final hasLiked = await hasUserLikedPost(
        postId: postId,
        userId: user.uid,
      );

      if (hasLiked) {
        await unlikePost(postId: postId, userId: user.uid);
        return false; // Now unliked
      } else {
        await likePost(postId: postId, user: user);
        return true; // Now liked
      }
    } catch (e) {
      LoggerService.error('Error toggling like', 'LIKE_SERVICE', e);
      throw Exception('Failed to toggle like: $e');
    }
  }
}
