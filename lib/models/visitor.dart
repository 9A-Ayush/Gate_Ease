import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String id;
  final String name;
  final String visitingFlat;
  final String phone;
  final String? photoUrl;
  final String status;
  final DateTime entryTime;

  Visitor({
    required this.id,
    required this.name,
    required this.visitingFlat,
    required this.phone,
    this.photoUrl,
    required this.status,
    required this.entryTime,
  });

  factory Visitor.fromMap(Map<String, dynamic> map, String id) => Visitor(
    id: id,
    name: map['name'] ?? '',
    visitingFlat: map['visiting_flat'] ?? '',
    phone: map['phone'] ?? '',
    photoUrl: map['photo_url'],
    status: map['status'] ?? '',
    entryTime: (map['entry_time'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'visiting_flat': visitingFlat,
    'phone': phone,
    'photo_url': photoUrl,
    'status': status,
    'entry_time': entryTime,
  };
}