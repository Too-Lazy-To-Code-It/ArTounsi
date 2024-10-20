import 'package:flutter/material.dart';
import 'details_page.dart';

class HomeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int likes;
  final int views;
  final int comments;
  final String tag;
  final List<Map<String, dynamic>> allPosts;
  final int index;

  const HomeCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.comments,
    required this.tag,
    required this.allPosts,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(
                allPosts: allPosts,
                initialIndex: index,
              ),
            ),
          );
        },
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}