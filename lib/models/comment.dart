import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userRole;
  final String? userProfileImageUrl;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.userProfileImageUrl,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.isEdited,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) => Comment(
    id: id,
    postId: map['post_id'] ?? '',
    userId: map['user_id'] ?? '',
    userName: map['user_name'] ?? '',
    userRole: map['user_role'] ?? '',
    userProfileImageUrl: map['user_profile_image_url'],
    content: map['content'] ?? '',
    createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    isEdited: map['is_edited'] ?? false,
  );

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'post_id': postId,
    'user_id': userId,
    'user_name': userName,
    'user_role': userRole,
    'user_profile_image_url': userProfileImageUrl,
    'content': content,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'is_edited': isEdited,
  };

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userRole,
    String? userProfileImageUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
  }) => Comment(
    id: id ?? this.id,
    postId: postId ?? this.postId,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    userRole: userRole ?? this.userRole,
    userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isEdited: isEdited ?? this.isEdited,
  );
}
