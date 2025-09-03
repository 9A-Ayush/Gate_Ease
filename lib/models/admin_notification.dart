import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'vendor_service', 'vendor_ad', 'complaint', 'visitor', etc.
  final String? relatedId; // ID of the related document
  final Map<String, dynamic>? metadata; // Additional data
  final DateTime createdAt;
  final bool isRead;
  final String priority; // 'low', 'medium', 'high', 'urgent'

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.metadata,
    required this.createdAt,
    this.isRead = false,
    this.priority = 'medium',
  });

  factory AdminNotification.fromMap(Map<String, dynamic> map, String id) {
    return AdminNotification(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      relatedId: map['relatedId'],
      metadata: map['metadata'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      priority: map['priority'] ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'priority': priority,
    };
  }

  AdminNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? relatedId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isRead,
    String? priority,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
    );
  }
}
