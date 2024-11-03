import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String author;
  final DateTime date;
  final String excerpt;
  final String content;
  final String imageUrl;

  BlogPost({
    required this.id,
    required this.title,
    required this.author,
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
      author: data['author'] ?? 'Unknown',
      date: (data['date'] as Timestamp).toDate(),
      excerpt: data['excerpt'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'date': Timestamp.fromDate(date),
      'excerpt': excerpt,
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}