import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String? title;
  final String? description;
  final String? authorId; // Consider storing user details or just an ID
  final int? upvotes;
  final int? downvotes;
  final List<String>? mediaUrl; // Assuming URLs to media
  final int? commentCount;
  final Timestamp? timestamp;

  Post({
    required this.id,
    this.title,
    this.description,
    this.authorId,
    this.upvotes,
    this.downvotes,
    this.mediaUrl,
    this.commentCount,
    this.timestamp,
  });

  factory Post.fromMap(Map<String, dynamic> data, String id) {
  return Post(
    id: id,
    title: data['title'] ?? '',  // Provide a default empty string
    description: data['description'] ?? '',  // Provide a default empty string
    authorId: data['userId'] ?? '',  // Provide a default empty string
    upvotes: int.tryParse(data['upvotes'].toString()) ?? 0,
    downvotes: int.tryParse(data['downvotes'].toString()) ?? 0,
    mediaUrl: List<String>.from(data['mediaUrls'] ?? []),
    commentCount: data['commentCount'] ?? 0,
    timestamp: data['timestamp'] ?? Timestamp.now(),  // Ensure there's a sensible default or handle null separately
  );
}


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userId': authorId,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'mediaUrls': mediaUrl,
      'commentCount': commentCount,
      'timestamp': timestamp,
    };
  }
}
