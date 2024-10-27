import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditArtworkPage.dart';
import 'fullscreen_photo_view.dart';

class DetailsPage extends StatefulWidget {
  final String artworkId;

  const DetailsPage({Key? key, required this.artworkId}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<DocumentSnapshot> _artworkFuture;

  @override
  void initState() {
    super.initState();
    _artworkFuture = FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get();
  }

  void _handleArtworkUpdated(Map<String, dynamic> updatedArtwork) {
    setState(() {
      _artworkFuture = FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get();
    });
  }

  Future<void> _deleteArtwork(String artworkId) async {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _artworkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading...')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text('Not Found')),
            body: Center(child: Text('Artwork not found')),
          );
        }

        Map<String, dynamic> artwork = snapshot.data!.data() as Map<String, dynamic>;
        artwork['id'] = snapshot.data!.id;

        return Scaffold(
          appBar: AppBar(
            title: Text('Artwork Details'),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditArtworkPage(
                        artwork: artwork,
                        onArtworkUpdated: _handleArtworkUpdated,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                onPressed: () => _deleteArtwork(artwork['id']),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenPhotoView(
                          imageUrls: [artwork['imageUrl']],
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    artwork['imageUrl'],
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork['title'] ?? 'Untitled',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'By ${artwork['author'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                          SizedBox(width: 8),
                          Text('${artwork['likes'] ?? 0} likes', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 24),
                          Icon(Icons.visibility, color: Theme.of(context).colorScheme.secondary),
                          SizedBox(width: 8),
                          Text('${artwork['views'] ?? 0} views', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 24),
                          Icon(Icons.comment, color: Theme.of(context).colorScheme.secondary),
                          SizedBox(width: 8),
                          Text('${(artwork['comments'] as List?)?.length ?? 0} comments', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        artwork['description'] ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: (artwork['tags'] as List<dynamic>? ?? []).map((tag) => _buildTag(tag.toString())).toList(),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Software Used',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        artwork['softwareUsed'] ?? 'Not specified',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      _buildCommentsList(artwork['comments'] as List<dynamic>? ?? []),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          title: Text(comment['author'] ?? 'Unknown', style: TextStyle(color: Colors.white)),
          subtitle: Text(comment['content'] ?? '', style: TextStyle(color: Colors.white)),
        );
      },
    );
  }
}