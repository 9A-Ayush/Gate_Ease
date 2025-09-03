import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment.dart';
import '../models/app_user.dart';
import 'post_service.dart';
import 'logger_service.dart';

class CommentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'comments';

  /// Add a comment to a post
  static Future<String> addComment({
    required String postId,
    required String content,
    required AppUser user,
  }) async {
    try {
      LoggerService.info('Adding comment to post: $postId', 'COMMENT_SERVICE');

      // Create comment document
      final comment = Comment(
        id: '', // Will be set by Firestore
        postId: postId,
        userId: user.uid,
        userName: user.name,
        userRole: user.role,
        userProfileImageUrl: user.profileImageUrl,
        content: content,
        createdAt: DateTime.now(),
        isEdited: false,
      );

      // Add comment and increment post comments count in a batch
      final batch = _firestore.batch();

      final commentRef = _firestore.collection(_collection).doc();
      final commentData = comment.toMap();
      LoggerService.info('Creating comment with data: $commentData', 'COMMENT_SERVICE');

      batch.set(commentRef, commentData);

      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {'comments_count': FieldValue.increment(1)});

      await batch.commit();

      LoggerService.info('Comment added successfully: ${commentRef.id}', 'COMMENT_SERVICE');
      return commentRef.id;
    } catch (e) {
      LoggerService.error('Error adding comment', 'COMMENT_SERVICE', e);
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Update a comment
  static Future<void> updateComment({
    required String commentId,
    required String newContent,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Check if user owns the comment
      final commentDoc = await _firestore.collection(_collection).doc(commentId).get();
      if (!commentDoc.exists) throw Exception('Comment not found');
      
      final comment = Comment.fromFirestore(commentDoc);
      if (comment.userId != user.uid) throw Exception('Not authorized to update this comment');

      await _firestore.collection(_collection).doc(commentId).update({
        'content': newContent,
        'updated_at': Timestamp.fromDate(DateTime.now()),
        'is_edited': true,
      });

      LoggerService.info('Comment updated successfully: $commentId', 'COMMENT_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating comment', 'COMMENT_SERVICE', e);
      throw Exception('Failed to update comment: $e');
    }
  }

  /// Delete a comment
  static Future<void> deleteComment(String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Get comment to check ownership and get post ID
      final commentDoc = await _firestore.collection(_collection).doc(commentId).get();
      if (!commentDoc.exists) throw Exception('Comment not found');
      
      final comment = Comment.fromFirestore(commentDoc);
      if (comment.userId != user.uid) throw Exception('Not authorized to delete this comment');

      // Delete comment and decrement post comments count in a batch
      final batch = _firestore.batch();
      
      batch.delete(commentDoc.reference);
      
      final postRef = _firestore.collection('posts').doc(comment.postId);
      batch.update(postRef, {'comments_count': FieldValue.increment(-1)});
      
      await batch.commit();

      LoggerService.info('Comment deleted successfully: $commentId', 'COMMENT_SERVICE');
    } catch (e) {
      LoggerService.error('Error deleting comment', 'COMMENT_SERVICE', e);
      throw Exception('Failed to delete comment: $e');
    }
  }

  /// Get comments for a post
  static Stream<List<Comment>> getPostComments(String postId) {
    try {
      LoggerService.info('Getting comments for post: $postId', 'COMMENT_SERVICE');
      return _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .snapshots()
          .map((snapshot) {
        LoggerService.info('Found ${snapshot.docs.length} comments for post: $postId', 'COMMENT_SERVICE');
        var comments = snapshot.docs.map((doc) {
          LoggerService.info('Comment doc: ${doc.id} - ${doc.data()}', 'COMMENT_SERVICE');
          return Comment.fromFirestore(doc);
        }).toList();

        // Sort in memory instead of using orderBy to avoid index requirement
        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return comments;
      });
    } catch (e) {
      LoggerService.error('Error getting post comments', 'COMMENT_SERVICE', e);
      throw Exception('Failed to get post comments: $e');
    }
  }

  /// Get comments count for a post
  static Stream<int> getPostCommentsCount(String postId) {
    try {
      return _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      LoggerService.error('Error getting post comments count', 'COMMENT_SERVICE', e);
      throw Exception('Failed to get post comments count: $e');
    }
  }

  /// Get comments by a user
  static Stream<List<Comment>> getUserComments(String userId) {
    try {
      return _firestore.collection(_collection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
      });
    } catch (e) {
      LoggerService.error('Error getting user comments', 'COMMENT_SERVICE', e);
      throw Exception('Failed to get user comments: $e');
    }
  }

  /// Get a single comment by ID
  static Future<Comment?> getCommentById(String commentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(commentId).get();
      if (doc.exists) {
        return Comment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting comment by ID', 'COMMENT_SERVICE', e);
      throw Exception('Failed to get comment: $e');
    }
  }

  /// Get recent comments for a post (limited number)
  static Stream<List<Comment>> getRecentPostComments(String postId, {int limit = 3}) {
    try {
      return _firestore.collection(_collection)
          .where('post_id', isEqualTo: postId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
      });
    } catch (e) {
      LoggerService.error('Error getting recent post comments', 'COMMENT_SERVICE', e);
      throw Exception('Failed to get recent post comments: $e');
    }
  }
}
