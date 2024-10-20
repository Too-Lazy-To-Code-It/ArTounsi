import 'package:flutter/material.dart';

class BlogPostDetails extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  final int initialIndex;

  const BlogPostDetails({
    Key? key,
    required this.allPosts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _BlogPostDetailsState createState() => _BlogPostDetailsState();
}

class _BlogPostDetailsState extends State<BlogPostDetails> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allPosts[_currentIndex]['title']),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allPosts.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final post = widget.allPosts[index];
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  post['imageUrl'],
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.favorite,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text('${post['likes']} likes'),
                          const SizedBox(width: 16),
                          Icon(Icons.comment,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text('${post['comments']} comments'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Comments',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildCommentsList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentsList() {
    // This is a dummy list of comments. In a real app, you'd fetch this from an API or database.
    final List<Map<String, String>> comments = [
      {'author': 'Alice', 'content': 'Great article! Very insightful.'},
      {
        'author': 'Bob',
        'content': 'I learned a lot from this. Thanks for sharing!'
      },
      {
        'author': 'Charlie',
        'content': 'Interesting perspective. Id love to see more on this topic.'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          title: Text(comment['author']!),
          subtitle: Text(comment['content']!),
        );
      },
    );
  }
}
