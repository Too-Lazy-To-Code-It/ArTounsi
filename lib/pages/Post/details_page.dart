import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fullscreen_photo_view.dart';
import 'EditArtworkPage.dart';

class DetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  final int initialIndex;
  final Function(String) onArtworkDeleted;
  final Function(Map<String, dynamic>) onArtworkUpdated;

  const DetailsPage({
    Key? key,
    required this.allPosts,
    required this.initialIndex,
    required this.onArtworkDeleted,
    required this.onArtworkUpdated,
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

  Future<void> _deleteArtwork() async {
    final post = widget.allPosts[_currentIndex];
    final artworkId = post['id'];

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Artwork'),
          content: Text('Are you sure you want to delete this artwork?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('artworks').doc(artworkId).delete();
        widget.onArtworkDeleted(artworkId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork deleted successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete artwork: $e')),
        );
      }
    }
  }

  void _editArtwork() {
    final post = widget.allPosts[_currentIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditArtworkPage(
          artwork: post,
          onArtworkUpdated: (updatedArtwork) {
            setState(() {
              widget.allPosts[_currentIndex] = updatedArtwork;
            });
            widget.onArtworkUpdated(updatedArtwork);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allPosts[_currentIndex]['title'] ?? 'Artwork Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editArtwork,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteArtwork,
          ),
        ],
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
                          imageUrls: widget.allPosts.map((post) => post['imageUrl'] as String? ?? '').toList(),
                          initialIndex: index,
                        ),
                      ),
                    );
                    if (newIndex != null && newIndex != index) {
                      _pageController.jumpToPage(newIndex);
                    }
                  },
                  child: Image.network(
                    post['imageUrl'] ?? '',
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
                        post['title'] ?? 'Untitled',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${post['author'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${post['likes'] ?? 0} likes'),
                          const SizedBox(width: 24),
                          Icon(Icons.visibility, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${post['views'] ?? 0} views'),
                          const SizedBox(width: 24),
                          Icon(Icons.comment, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${(post['comments'] as List?)?.length ?? 0} comments'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post['description'] ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildTags(post['tag'] as List<dynamic>? ?? []),
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
                      _buildCommentsList(post['comments'] as List<dynamic>? ?? []),
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

  Widget _buildTags(List<dynamic> tags) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) => _buildTag(tag.toString())).toList(),
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

  Widget _buildCommentsList(List<dynamic> comments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index] as Map<String, dynamic>? ?? {};
        return ListTile(
          leading: CircleAvatar(
            child: Text(comment['author']?[0] ?? ''),
          ),
          title: Text(comment['author'] ?? 'Unknown'),
          subtitle: Text(comment['content'] ?? ''),
        );
      },
    );
  }
}