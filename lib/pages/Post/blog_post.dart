import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class BlogPost {
  final String id;
  final String title;
  final DateTime date;
  final String content;
  final String imageUrl;
  final String author;

  BlogPost({
    required this.id,
    required this.title,
    required this.date,
    required this.content,
    required this.imageUrl,
    this.author = 'Unknown',
  });

  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BlogPost(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      author: data['author'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
    };
  }
}