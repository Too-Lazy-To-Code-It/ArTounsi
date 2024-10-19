import 'package:flutter/material.dart';

class BlogPostDetails extends StatelessWidget {
  final Map<String, dynamic> post;

  const BlogPostDetails({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['title'],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By ${post['author']} on ${post['date']}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'This is the full content of the blog post. In a real application, this would be a longer text with paragraphs, possibly including formatting, images, and other rich content.\n\n'
                  'For now, we\'ll use this placeholder text to simulate a full blog post. You can replace this with actual content when integrating with a backend or CMS.\n\n'
                  '${post['excerpt']}\n\n'
                  'The rest of the blog post would continue here, discussing the topic in more detail, providing examples, and drawing conclusions.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}