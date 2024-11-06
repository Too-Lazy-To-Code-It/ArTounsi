import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'EditArtworkPage.dart';
import 'fullscreen_photo_view.dart';

class DetailsPage extends StatefulWidget {
  final String artworkId;

  const DetailsPage({Key? key, required this.artworkId}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Stream<DocumentSnapshot> _artworkStream;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _artworkStream = FirebaseFirestore.instance
        .collection('artworks')
        .doc(widget.artworkId)
        .snapshots();
  }

  void _handleArtworkUpdated(Map<String, dynamic> updatedArtwork) {
    setState(() {});
  }

  Future<void> _deleteArtwork(String artworkId, String imageUrl) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Delete Artwork', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete this artwork?',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('artworks').doc(artworkId).delete();

        if (imageUrl.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(imageUrl).delete();
          } catch (e) {
            print('Error deleting image from storage: $e');
          }
        }

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

  void _likeArtwork() {
    FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
      'likes': FieldValue.increment(1),
    });
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
        'comments': FieldValue.arrayUnion([
          {
            'text': _commentController.text,
            'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
            'id': DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
          }
        ]),
      }).then((_) {
        setState(() {
          _commentController.clear();
        });
      }).catchError((error) {
        print('Error adding comment: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment. Please try again.')),
        );
      });
    }
  }

  void _editComment(Map<String, dynamic> comment) {
    if (comment['text'] == null) return;

    _editCommentController.text = comment['text'].toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Edit Comment', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _editCommentController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Edit your comment",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                if (_editCommentController.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get().then((doc) {
                    List<dynamic> comments = List.from(doc.data()!['comments'] ?? []);
                    int index = comments.indexWhere((c) => c['id'] == comment['id']);
                    if (index != -1) {
                      comments[index]['text'] = _editCommentController.text;
                      FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
                        'comments': comments,
                      }).then((_) {
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        print('Error updating comment: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update comment. Please try again.')),
                        );
                      });
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(Map<String, dynamic> comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Delete Comment', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete this comment?',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get().then((doc) {
                  List<dynamic> comments = List.from(doc.data()!['comments'] ?? []);
                  comments.removeWhere((c) => c['id'] == comment['id']);
                  FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
                    'comments': comments,
                  }).then((_) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print('Error deleting comment: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete comment. Please try again.')),
                    );
                  });
                });
              },
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _artworkStream,
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

        List<dynamic> comments = List.from(artwork['comments'] ?? []);

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
                onPressed: () => _deleteArtwork(artwork['id'], artwork['imageUrl']),
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
                          GestureDetector(
                            onTap: _likeArtwork,
                            child: Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                          ),
                          SizedBox(width: 8),
                          Text('${artwork['likes'] ?? 0} likes', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 24),
                          Icon(Icons.visibility, color: Theme.of(context).colorScheme.secondary),
                          SizedBox(width: 8),
                          Text('${artwork['views'] ?? 0} views', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 24),
                          Icon(Icons.comment, color: Theme.of(context).colorScheme.secondary),
                          SizedBox(width: 8),
                          Text('${comments.length} comments', style: TextStyle(color: Colors.white)),
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
                        children: (artwork['tags'] as List<dynamic>? ?? [])
                            .map((tag) => _buildTag(tag.toString()))
                            .toList(),
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index] as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                              comment['text']?.toString() ?? '',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              comment['timestamp'] != null
                                  ? DateTime.fromMillisecondsSinceEpoch(comment['timestamp']).toString()
                                  : 'Unknown time',
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => _editComment(comment),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _deleteComment(comment),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(color: Colors.white54),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white54),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                            onPressed: _addComment,
                          ),
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
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editCommentController.dispose();
    super.dispose();
  }
}