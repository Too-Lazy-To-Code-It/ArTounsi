import 'package:flutter/material.dart';
import 'blog_post_details.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> blogPosts = [
      {
        'title': 'The Future of AI in Art',
        'author': 'Jane Doe',
        'date': '2023-05-15',
        'excerpt':
            'Exploring how artificial intelligence is revolutionizing the art world...',
        'imageUrl': 'https://picsum.photos/seed/ai_art/400/300',
        'likes': 156,
        'comments': 23,
      },
      {
        'title': 'Top 10 Photography Tips for Beginners',
        'author': 'John Smith',
        'date': '2023-05-10',
        'excerpt':
            'Essential tips to help you start your photography journey on the right foot...',
        'imageUrl': 'https://picsum.photos/seed/photo_tips/400/300',
        'likes': 89,
        'comments': 15,
      },
      {
        'title': 'The Rise of Digital Sculpture',
        'author': 'Emily Johnson',
        'date': '2023-05-05',
        'excerpt':
            'How digital tools are changing the landscape of sculptural art...',
        'imageUrl': 'https://picsum.photos/seed/digital_sculpture/400/300',
        'likes': 112,
        'comments': 18,
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlogPostDetails(
                    allPosts: blogPosts,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    post['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['title'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text('By ${post['author']} on ${post['date']}'),
                        const SizedBox(height: 4),
                        Text(
                          post['excerpt'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.favorite,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 16),
                            const SizedBox(width: 4),
                            Text('${post['likes']}'),
                            const SizedBox(width: 16),
                            Icon(Icons.comment,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 16),
                            const SizedBox(width: 4),
                            Text('${post['comments']}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
