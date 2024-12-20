import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String authorId;
  final String authorName;
  final DateTime date;
  final String excerpt;
  final String content;
  final String imageUrl;

  BlogPost({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.date,
    required this.excerpt,
    required this.content,
    required this.imageUrl,
  });

  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BlogPost(
      id: doc.id,
      title: data['title'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['author'] ?? 'Unknown',
      date: (data['createdAt'] as Timestamp).toDate(),
      excerpt: data['excerpt'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}