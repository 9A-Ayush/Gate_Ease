import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String type; // text, image, video, audio, file
  final String text;
  final String? mediaUrl;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.text,
    this.mediaUrl,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) => Message(
    id: id,
    chatId: map['chat_id'] ?? '',
    senderId: map['sender_id'] ?? '',
    type: map['type'] ?? '',
    text: map['text'] ?? '',
    mediaUrl: map['mediaUrl'],
    timestamp: map['timestamp'] != null
        ? (map['timestamp'] as Timestamp).toDate()
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'chat_id': chatId,
    'sender_id': senderId,
    'type': type,
    'text': text,
    'mediaUrl': mediaUrl,
    'timestamp': FieldValue.serverTimestamp(),
  };
}