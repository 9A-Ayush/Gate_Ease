import 'package:cloud_firestore/cloud_firestore.dart';

class Call {
  final String id;
  final List<String> participants;
  final String channelName;
  final String type; // voice, video
  final DateTime timestamp;

  Call({
    required this.id,
    required this.participants,
    required this.channelName,
    required this.type,
    required this.timestamp,
  });

  factory Call.fromMap(Map<String, dynamic> map, String id) => Call(
    id: id,
    participants: List<String>.from(map['participants'] ?? []),
    channelName: map['channel_name'] ?? '',
    type: map['type'] ?? '',
    timestamp: (map['timestamp'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'participants': participants,
    'channel_name': channelName,
    'type': type,
    'timestamp': timestamp,
  };
}