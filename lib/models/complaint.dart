import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Complaint {
  final String id;
  final String raisedBy;
  final String raisedByName;
  final String flatNo;
  final String category;
  final String description;
  final String? imageUrl;
  final String status; // Open, In Progress, Resolved
  final DateTime createdAt;
  final DateTime? updatedAt;

  Complaint({
    required this.id,
    required this.raisedBy,
    required this.raisedByName,
    required this.flatNo,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Complaint.fromMap(Map<String, dynamic> map, String id) => Complaint(
    id: id,
    raisedBy: map['raised_by'] ?? '',
    raisedByName: map['raised_by_name'] ?? '',
    flatNo: map['flat_no'] ?? '',
    category: map['category'] ?? '',
    description: map['description'] ?? '',
    imageUrl: map['image_url'],
    status: map['status'] ?? 'Open',
    createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
  );

  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Complaint.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'raised_by': raisedBy,
    'raised_by_name': raisedByName,
    'flat_no': flatNo,
    'category': category,
    'description': description,
    'image_url': imageUrl,
    'status': status,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };

  // Helper method to get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFFFF9800); // Orange
      case 'in progress':
      case 'in_progress':
        return const Color(0xFF2196F3); // Blue
      case 'resolved':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Helper method to get status icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.report_problem;
      case 'in progress':
      case 'in_progress':
        return Icons.work;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}
