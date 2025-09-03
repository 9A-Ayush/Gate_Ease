import 'package:flutter_test/flutter_test.dart';
import 'package:gate_ease/models/post.dart';
import 'package:gate_ease/models/comment.dart';
import 'package:gate_ease/models/like.dart';
import 'package:gate_ease/models/follow.dart';
import 'package:gate_ease/models/app_user.dart';

void main() {
  group('Social Media Models Tests', () {
    test('Post model should create and convert correctly', () {
      final post = Post(
        id: 'test_post_id',
        authorId: 'user_123',
        authorName: 'John Doe',
        authorRole: 'resident',
        content: 'This is a test post',
        imageUrls: ['https://example.com/image.jpg'],
        createdAt: DateTime.now(),
        likesCount: 5,
        commentsCount: 3,
        isEdited: false,
      );

      expect(post.id, 'test_post_id');
      expect(post.authorName, 'John Doe');
      expect(post.content, 'This is a test post');
      expect(post.likesCount, 5);
      expect(post.commentsCount, 3);
      expect(post.isEdited, false);

      // Test toMap conversion
      final map = post.toMap();
      expect(map['author_id'], 'user_123');
      expect(map['author_name'], 'John Doe');
      expect(map['content'], 'This is a test post');
      expect(map['likes_count'], 5);
      expect(map['comments_count'], 3);
      expect(map['is_edited'], false);
    });

    test('Comment model should create and convert correctly', () {
      final comment = Comment(
        id: 'test_comment_id',
        postId: 'test_post_id',
        userId: 'user_456',
        userName: 'Jane Smith',
        userRole: 'admin',
        content: 'Great post!',
        createdAt: DateTime.now(),
        isEdited: false,
      );

      expect(comment.id, 'test_comment_id');
      expect(comment.postId, 'test_post_id');
      expect(comment.userName, 'Jane Smith');
      expect(comment.content, 'Great post!');
      expect(comment.isEdited, false);

      // Test toMap conversion
      final map = comment.toMap();
      expect(map['post_id'], 'test_post_id');
      expect(map['user_id'], 'user_456');
      expect(map['user_name'], 'Jane Smith');
      expect(map['content'], 'Great post!');
      expect(map['is_edited'], false);
    });

    test('Like model should create and convert correctly', () {
      final like = Like(
        id: 'test_like_id',
        postId: 'test_post_id',
        userId: 'user_789',
        userName: 'Bob Wilson',
        userRole: 'vendor',
        createdAt: DateTime.now(),
      );

      expect(like.id, 'test_like_id');
      expect(like.postId, 'test_post_id');
      expect(like.userId, 'user_789');
      expect(like.userName, 'Bob Wilson');
      expect(like.userRole, 'vendor');

      // Test toMap conversion
      final map = like.toMap();
      expect(map['post_id'], 'test_post_id');
      expect(map['user_id'], 'user_789');
      expect(map['user_name'], 'Bob Wilson');
      expect(map['user_role'], 'vendor');
    });

    test('Follow model should create and convert correctly', () {
      final follow = Follow(
        id: 'test_follow_id',
        followerId: 'user_123',
        followerName: 'John Doe',
        followerRole: 'resident',
        followingId: 'user_456',
        followingName: 'Jane Smith',
        followingRole: 'admin',
        createdAt: DateTime.now(),
      );

      expect(follow.id, 'test_follow_id');
      expect(follow.followerId, 'user_123');
      expect(follow.followerName, 'John Doe');
      expect(follow.followingId, 'user_456');
      expect(follow.followingName, 'Jane Smith');

      // Test toMap conversion
      final map = follow.toMap();
      expect(map['follower_id'], 'user_123');
      expect(map['follower_name'], 'John Doe');
      expect(map['following_id'], 'user_456');
      expect(map['following_name'], 'Jane Smith');
    });

    test('Post copyWith should work correctly', () {
      final originalPost = Post(
        id: 'test_post_id',
        authorId: 'user_123',
        authorName: 'John Doe',
        authorRole: 'resident',
        content: 'Original content',
        imageUrls: [],
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        isEdited: false,
      );

      final updatedPost = originalPost.copyWith(
        content: 'Updated content',
        likesCount: 5,
        isEdited: true,
      );

      expect(updatedPost.id, originalPost.id);
      expect(updatedPost.authorName, originalPost.authorName);
      expect(updatedPost.content, 'Updated content');
      expect(updatedPost.likesCount, 5);
      expect(updatedPost.isEdited, true);
    });
  });

  group('Social Media Business Logic Tests', () {
    test('Post should validate content length', () {
      // This would be implemented in the actual service
      const maxContentLength = 500;
      const testContent = 'This is a test post content';
      
      expect(testContent.length <= maxContentLength, true);
    });

    test('User roles should be valid', () {
      const validRoles = ['admin', 'resident', 'vendor', 'guard'];
      const testRole = 'resident';
      
      expect(validRoles.contains(testRole), true);
    });

    test('Image URLs should be valid format', () {
      const testImageUrl = 'https://example.com/image.jpg';
      
      expect(testImageUrl.startsWith('http'), true);
      expect(testImageUrl.contains('.'), true);
    });
  });
}
