import 'package:cloud_firestore/cloud_firestore.dart';

class Amenity {
  final String id;
  final String name;
  final String slotTime;
  final String bookedBy;
  final DateTime createdAt;

  Amenity({
    required this.id,
    required this.name,
    required this.slotTime,
    required this.bookedBy,
    required this.createdAt,
  });

  factory Amenity.fromMap(Map<String, dynamic> map, String id) => Amenity(
    id: id,
    name: map['name'] ?? '',
    slotTime: map['slot_time'] ?? '',
    bookedBy: map['booked_by'] ?? '',
    createdAt: (map['created_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'slot_time': slotTime,
    'booked_by': bookedBy,
    'created_at': createdAt,
  };
}