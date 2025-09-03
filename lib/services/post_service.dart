import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../models/app_user.dart';
import 'cloudinary_service.dart';
import 'logger_service.dart';

class PostService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'posts';

  /// Create a new post
  static Future<String> createPost({
    required String content,
    required AppUser author,
    List<File>? images,
    List<File>? videos,
  }) async {
    try {
      LoggerService.info('Creating new post', 'POST_SERVICE');

      // Upload images to Cloudinary if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        for (File image in images) {
          final url = await CloudinaryService.uploadImage(
            image,
            folder: 'social_posts',
          );
          if (url != null) imageUrls.add(url);
        }
      }

      // Upload videos to Cloudinary if provided
      List<String> videoUrls = [];
      if (videos != null && videos.isNotEmpty) {
        for (File video in videos) {
          final url = await CloudinaryService.uploadVideo(
            video,
            folder: 'social_videos',
          );
          if (url != null) videoUrls.add(url);
        }
      }

      // Create post document
      final post = Post(
        id: '', // Will be set by Firestore
        authorId: author.uid,
        authorName: author.name,
        authorRole: author.role,
        authorProfileImageUrl: author.profileImageUrl,
        content: content,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        isEdited: false,
        societyId: author.societyId.isNotEmpty ? author.societyId : null,
      );

      final docRef = await _firestore.collection(_collection).add(post.toMap());
      
      LoggerService.info('Post created successfully: ${docRef.id}', 'POST_SERVICE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating post', 'POST_SERVICE', e);
      throw Exception('Failed to create post: $e');
    }
  }

  /// Get posts for feed (all posts or filtered by society)
  static Stream<List<Post>> getFeedPosts({String? societyId, int limit = 20}) {
    try {
      Query query = _firestore.collection(_collection)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (societyId != null && societyId.isNotEmpty) {
        query = query.where('society_id', isEqualTo: societyId);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
      });
    } catch (e) {
      LoggerService.error('Error getting feed posts', 'POST_SERVICE', e);
      throw Exception('Failed to get feed posts: $e');
    }
  }

  /// Get posts by a specific user
  static Stream<List<Post>> getUserPosts(String userId) {
    try {
      return _firestore.collection(_collection)
          .where('author_id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        var posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
        // Sort in memory instead of using orderBy to avoid index requirement
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return posts;
      });
    } catch (e) {
      LoggerService.error('Error getting user posts', 'POST_SERVICE', e);
      throw Exception('Failed to get user posts: $e');
    }
  }

  /// Get a single post by ID
  static Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(postId).get();
      if (doc.exists) {
        return Post.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting post by ID', 'POST_SERVICE', e);
      throw Exception('Failed to get post: $e');
    }
  }

  /// Update a post (only content can be updated)
  static Future<void> updatePost(String postId, String newContent) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Check if user owns the post
      final post = await getPostById(postId);
      if (post == null) throw Exception('Post not found');
      if (post.authorId != user.uid) throw Exception('Not authorized to update this post');

      await _firestore.collection(_collection).doc(postId).update({
        'content': newContent,
        'updated_at': Timestamp.fromDate(DateTime.now()),
        'is_edited': true,
      });

      LoggerService.info('Post updated successfully: $postId', 'POST_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating post', 'POST_SERVICE', e);
      throw Exception('Failed to update post: $e');
    }
  }

  /// Delete a post
  static Future<void> deletePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Check if user owns the post
      final post = await getPostById(postId);
      if (post == null) throw Exception('Post not found');
      if (post.authorId != user.uid) throw Exception('Not authorized to delete this post');

      // Delete the post document
      await _firestore.collection(_collection).doc(postId).delete();

      // Delete associated likes and comments
      await _deleteLikesForPost(postId);
      await _deleteCommentsForPost(postId);

      LoggerService.info('Post deleted successfully: $postId', 'POST_SERVICE');
    } catch (e) {
      LoggerService.error('Error deleting post', 'POST_SERVICE', e);
      throw Exception('Failed to delete post: $e');
    }
  }

  /// Helper method to delete likes for a post
  static Future<void> _deleteLikesForPost(String postId) async {
    final likesQuery = await _firestore.collection('likes')
        .where('post_id', isEqualTo: postId)
        .get();
    
    for (var doc in likesQuery.docs) {
      await doc.reference.delete();
    }
  }

  /// Helper method to delete comments for a post
  static Future<void> _deleteCommentsForPost(String postId) async {
    final commentsQuery = await _firestore.collection('comments')
        .where('post_id', isEqualTo: postId)
        .get();
    
    for (var doc in commentsQuery.docs) {
      await doc.reference.delete();
    }
  }

  /// Increment likes count
  static Future<void> incrementLikesCount(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'likes_count': FieldValue.increment(1),
      });
    } catch (e) {
      LoggerService.error('Error incrementing likes count', 'POST_SERVICE', e);
      throw Exception('Failed to increment likes count: $e');
    }
  }

  /// Decrement likes count
  static Future<void> decrementLikesCount(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'likes_count': FieldValue.increment(-1),
      });
    } catch (e) {
      LoggerService.error('Error decrementing likes count', 'POST_SERVICE', e);
      throw Exception('Failed to decrement likes count: $e');
    }
  }

  /// Increment comments count
  static Future<void> incrementCommentsCount(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'comments_count': FieldValue.increment(1),
      });
    } catch (e) {
      LoggerService.error('Error incrementing comments count', 'POST_SERVICE', e);
      throw Exception('Failed to increment comments count: $e');
    }
  }

  /// Decrement comments count
  static Future<void> decrementCommentsCount(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'comments_count': FieldValue.increment(-1),
      });
    } catch (e) {
      LoggerService.error('Error decrementing comments count', 'POST_SERVICE', e);
      throw Exception('Failed to decrement comments count: $e');
    }
  }
}
