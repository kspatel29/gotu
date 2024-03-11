import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final int upvotes;
  final int downvotes;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      content: data['content'] ?? '',
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      timestamp: data['timestamp'],
    );
  }

  String? get cityName => null;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'timestamp': timestamp,
    };
  }
}
