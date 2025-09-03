import 'package:cloud_firestore/cloud_firestore.dart';

class Like {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userRole;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.createdAt,
  });

  factory Like.fromMap(Map<String, dynamic> map, String id) => Like(
    id: id,
    postId: map['post_id'] ?? '',
    userId: map['user_id'] ?? '',
    userName: map['user_name'] ?? '',
    userRole: map['user_role'] ?? '',
    createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory Like.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Like.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'post_id': postId,
    'user_id': userId,
    'user_name': userName,
    'user_role': userRole,
    'created_at': Timestamp.fromDate(createdAt),
  };

  Like copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userRole,
    DateTime? createdAt,
  }) => Like(
    id: id ?? this.id,
    postId: postId ?? this.postId,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    userRole: userRole ?? this.userRole,
    createdAt: createdAt ?? this.createdAt,
  );
}
