import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int likes;
  final int views;

  const DetailsPage({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By $author',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text('$likes likes'),
                      const SizedBox(width: 24),
                      Icon(Icons.visibility, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text('$views views'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a detailed description of the artwork. It can include information about the techniques used, the inspiration behind the piece, or any other relevant details about the creation process.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality for liking the artwork
                    },
                    child: const Text('Like this artwork'),
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