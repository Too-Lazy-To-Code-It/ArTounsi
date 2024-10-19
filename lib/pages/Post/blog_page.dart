import 'package:flutter/material.dart';
import 'blog_post_details.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a dummy list of blog posts. In a real app, you'd fetch this from an API or database.
    final List<Map<String, dynamic>> blogPosts = [
      {
        'title': 'The Future of AI in Art',
        'author': 'Jane Doe',
        'date': '2023-05-15',
        'excerpt': 'Exploring how artificial intelligence is revolutionizing the art world...',
      },
      {
        'title': 'Top 10 Photography Tips for Beginners',
        'author': 'John Smith',
        'date': '2023-05-10',
        'excerpt': 'Essential tips to help you start your photography journey on the right foot...',
      },
      {
        'title': 'The Rise of Digital Sculpture',
        'author': 'Emily Johnson',
        'date': '2023-05-05',
        'excerpt': 'How digital tools are changing the landscape of sculptural art...',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
      ),
      body: ListView.builder(
        itemCount: blogPosts.length,
        itemBuilder: (context, index) {
          final post = blogPosts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                post['title'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('By ${post['author']} on ${post['date']}'),
                  const SizedBox(height: 4),
                  Text(
                    post['excerpt'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogPostDetails(post: post),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}