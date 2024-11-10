import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String author;
  final int likes;
  final int views;
  final int comments;
  final List<String> tag;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.comments,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          FirebaseFirestore.instance.collection('artworks').doc(id).update({
            'views': FieldValue.increment(1),
          });
          onTap();
        },
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}