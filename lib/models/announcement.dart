import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map, String id) => Announcement(
    id: id,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    createdAt: (map['created_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'created_at': createdAt,
  };
}