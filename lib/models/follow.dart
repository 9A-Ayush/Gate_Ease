import 'package:cloud_firestore/cloud_firestore.dart';

class Follow {
  final String id;
  final String followerId; // User who is following
  final String followerName;
  final String followerRole;
  final String followingId; // User being followed
  final String followingName;
  final String followingRole;
  final DateTime createdAt;

  Follow({
    required this.id,
    required this.followerId,
    required this.followerName,
    required this.followerRole,
    required this.followingId,
    required this.followingName,
    required this.followingRole,
    required this.createdAt,
  });

  factory Follow.fromMap(Map<String, dynamic> map, String id) => Follow(
    id: id,
    followerId: map['follower_id'] ?? '',
    followerName: map['follower_name'] ?? '',
    followerRole: map['follower_role'] ?? '',
    followingId: map['following_id'] ?? '',
    followingName: map['following_name'] ?? '',
    followingRole: map['following_role'] ?? '',
    createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory Follow.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Follow.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'follower_id': followerId,
    'follower_name': followerName,
    'follower_role': followerRole,
    'following_id': followingId,
    'following_name': followingName,
    'following_role': followingRole,
    'created_at': Timestamp.fromDate(createdAt),
  };

  Follow copyWith({
    String? id,
    String? followerId,
    String? followerName,
    String? followerRole,
    String? followingId,
    String? followingName,
    String? followingRole,
    DateTime? createdAt,
  }) => Follow(
    id: id ?? this.id,
    followerId: followerId ?? this.followerId,
    followerName: followerName ?? this.followerName,
    followerRole: followerRole ?? this.followerRole,
    followingId: followingId ?? this.followingId,
    followingName: followingName ?? this.followingName,
    followingRole: followingRole ?? this.followingRole,
    createdAt: createdAt ?? this.createdAt,
  );
}
