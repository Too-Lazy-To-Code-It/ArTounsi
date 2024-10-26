import 'package:flutter/material.dart';
import 'fullscreen_photo_view.dart';

class DetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  final int initialIndex;

  const DetailsPage({
    Key? key,
    required this.allPosts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
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
                GestureDetector(
                  onTap: () async {
                    final int? newIndex = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenPhotoView(
                          imageUrls: widget.allPosts.map((post) => post['imageUrl'] as String).toList(),
                          initialIndex: index,
                        ),
                      ),
                    );
                    if (newIndex != null && newIndex != index) {
                      _pageController.jumpToPage(newIndex);
                    }
                  },
                  child: Image.network(
                    post['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                ),
                Padding(
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
                        'By ${post['author']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${post['likes']} likes'),
                          const SizedBox(width: 24),
                          Icon(Icons.visibility, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${post['views']} views'),
                          const SizedBox(width: 24),
                          Icon(Icons.comment, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${post['comments'].length} comments'),
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
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTag(post['tag']),
                          // Add more tags here if available
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Software Used',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post['softwareUsed'] ?? 'Not specified',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildCommentsList(post['comments']),
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

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      child: Text(
        tag,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  Widget _buildCommentsList(List<Map<String, String>> comments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(comment['author']![0]),
          ),
          title: Text(comment['author']!),
          subtitle: Text(comment['content']!),
        );
      },
    );
  }
}