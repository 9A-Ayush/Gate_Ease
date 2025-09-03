import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {
  final String id;
  final String vendorId;
  final String bannerUrl;
  final String status;
  final int duration;
  final DateTime startDate;
  final DateTime endDate;

  Ad({
    required this.id,
    required this.vendorId,
    required this.bannerUrl,
    required this.status,
    required this.duration,
    required this.startDate,
    required this.endDate,
  });

  factory Ad.fromMap(Map<String, dynamic> map, String id) => Ad(
    id: id,
    vendorId: map['vendor_id'] ?? '',
    bannerUrl: map['banner_url'] ?? '',
    status: map['status'] ?? '',
    duration: map['duration'] ?? 0,
    startDate: (map['start_date'] as Timestamp).toDate(),
    endDate: (map['end_date'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'vendor_id': vendorId,
    'banner_url': bannerUrl,
    'status': status,
    'duration': duration,
    'start_date': startDate,
    'end_date': endDate,
  };
}