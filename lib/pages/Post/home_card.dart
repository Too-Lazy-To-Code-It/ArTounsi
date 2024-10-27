import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int likes;
  final int views;
  final int comments;
  final List<String> tag;
  final VoidCallback onTap;

  const HomeCard({
    Key? key,
    required this.imageUrl,

    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.comments,
    required this.tag,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}