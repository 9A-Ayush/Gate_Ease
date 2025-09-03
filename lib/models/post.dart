import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole; // admin, vendor, resident, guard
  final String? authorProfileImageUrl;
  final String content;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool isEdited;
  final String? societyId; // Optional: to filter posts by society

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorProfileImageUrl,
    required this.content,
    required this.imageUrls,
    required this.videoUrls,
    required this.createdAt,
    this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.isEdited,
    this.societyId,
  });

  factory Post.fromMap(Map<String, dynamic> map, String id) => Post(
    id: id,
    authorId: map['author_id'] ?? '',
    authorName: map['author_name'] ?? '',
    authorRole: map['author_role'] ?? '',
    authorProfileImageUrl: map['author_profile_image_url'],
    content: map['content'] ?? '',
    imageUrls: List<String>.from(map['image_urls'] ?? []),
    videoUrls: List<String>.from(map['video_urls'] ?? []),
    createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    likesCount: map['likes_count'] ?? 0,
    commentsCount: map['comments_count'] ?? 0,
    isEdited: map['is_edited'] ?? false,
    societyId: map['society_id'],
  );

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'author_id': authorId,
    'author_name': authorName,
    'author_role': authorRole,
    'author_profile_image_url': authorProfileImageUrl,
    'content': content,
    'image_urls': imageUrls,
    'video_urls': videoUrls,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'likes_count': likesCount,
    'comments_count': commentsCount,
    'is_edited': isEdited,
    'society_id': societyId,
  };

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? authorProfileImageUrl,
    String? content,
    List<String>? imageUrls,
    List<String>? videoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    bool? isEdited,
    String? societyId,
  }) => Post(
    id: id ?? this.id,
    authorId: authorId ?? this.authorId,
    authorName: authorName ?? this.authorName,
    authorRole: authorRole ?? this.authorRole,
    authorProfileImageUrl: authorProfileImageUrl ?? this.authorProfileImageUrl,
    content: content ?? this.content,
    imageUrls: imageUrls ?? this.imageUrls,
    videoUrls: videoUrls ?? this.videoUrls,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    likesCount: likesCount ?? this.likesCount,
    commentsCount: commentsCount ?? this.commentsCount,
    isEdited: isEdited ?? this.isEdited,
    societyId: societyId ?? this.societyId,
  );
}
