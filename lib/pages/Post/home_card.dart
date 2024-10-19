import 'package:flutter/material.dart';
import 'details_page.dart';

class HomeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int likes;
  final int views;
  final List<Map<String, dynamic>> allPosts;
  final int index;

  const HomeCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.allPosts,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text('$likes'),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 16, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text('$views'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}