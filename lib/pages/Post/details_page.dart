import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _editingCommentId;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _artworkStream = FirebaseFirestore.instance
        .collection('artworks')
        .doc(widget.artworkId)
        .snapshots();
    currentUser = FirebaseAuth.instance.currentUser;
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
          title: const Text('Delete Artwork', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this artwork?',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
          const SnackBar(content: Text('Artwork deleted successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete artwork: $e')),
        );
      }
    }
  }

  void _likeArtwork(String artworkId) async {
    if (currentUser == null) return;

    final artworkRef = FirebaseFirestore.instance.collection('artworks').doc(artworkId);
    final userLikesRef = FirebaseFirestore.instance.collection('user_likes').doc(currentUser!.uid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final artworkSnapshot = await transaction.get(artworkRef);
      final userLikesSnapshot = await transaction.get(userLikesRef);

      if (!artworkSnapshot.exists) {
        throw Exception("Artwork does not exist!");
      }

      List<String> likedArtworks = [];
      if (userLikesSnapshot.exists) {
        likedArtworks = List<String>.from(userLikesSnapshot.data()?['liked_artworks'] ?? []);
      }

      if (likedArtworks.contains(artworkId)) {
        // User has already liked this artwork, so remove the like
        likedArtworks.remove(artworkId);
        transaction.update(artworkRef, {'likes': FieldValue.increment(-1)});
      } else {
        // User hasn't liked this artwork yet, so add the like
        likedArtworks.add(artworkId);
        transaction.update(artworkRef, {'likes': FieldValue.increment(1)});
      }

      transaction.set(userLikesRef, {'liked_artworks': likedArtworks}, SetOptions(merge: true));
    }).then((_) {
      // Transaction successful
      setState(() {}); // Trigger a rebuild to update the UI
    }).catchError((error) {
      print("Error updating like: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like. Please try again.')),
      );
    });
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty && currentUser != null) {
      FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
        'comments': FieldValue.arrayUnion([
          {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': _commentController.text,
            'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
            'authorId': currentUser!.uid,
            'authorName': currentUser!.displayName ?? 'Anonymous',
          }
        ]),
      }).then((_) {
        setState(() {
          _commentController.clear();
        });
      }).catchError((error) {
        print('Error adding comment: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment. Please try again.')),
        );
      });
    }
  }

  void _editComment(Map<String, dynamic> comment) {
    setState(() {
      _editingCommentId = comment['id'];
      _editCommentController.text = comment['text'];
    });
  }

  void _saveEditedComment(String commentId) {
    if (_editCommentController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get().then((doc) {
        List<dynamic> comments = List.from(doc.data()!['comments'] ?? []);
        int index = comments.indexWhere((c) => c['id'] == commentId);
        if (index != -1) {
          comments[index]['text'] = _editCommentController.text;
          FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
            'comments': comments,
          }).then((_) {
            setState(() {
              _editingCommentId = null;
              _editCommentController.clear();
            });
          }).catchError((error) {
            print('Error updating comment: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update comment. Please try again.')),
            );
          });
        }
      });
    }
  }

  void _deleteComment(String commentId) {
    FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get().then((doc) {
      List<dynamic> comments = List.from(doc.data()!['comments'] ?? []);
      comments.removeWhere((c) => c['id'] == commentId);
      FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).update({
        'comments': comments,
      }).then((_) {
        setState(() {});
      }).catchError((error) {
        print('Error deleting comment: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment. Please try again.')),
        );
      });
    });
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Artwork not found')),
          );
        }

        Map<String, dynamic> artwork = snapshot.data!.data() as Map<String, dynamic>;
        artwork['id'] = snapshot.data!.id;

        List<dynamic> comments = List.from(artwork['comments'] ?? []);
        bool isOwner = currentUser?.uid == artwork['authorId'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Artwork Details'),
            backgroundColor: Colors.black,
            actions: isOwner ? [
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
            ] : null,
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
                      const SizedBox(height: 8),
                      Text(
                        'By ${artwork['authorName'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _likeArtwork(artwork['id']),
                            child: Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                          ),
                          const SizedBox(width: 8),
                          Text('${artwork['likes'] ?? 0} likes', style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 24),
                          Icon(Icons.visibility, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${artwork['views'] ?? 0} views', style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 24),
                          Icon(Icons.comment, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('${comments.length} comments', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artwork['description'] ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: (artwork['tags'] as List<dynamic>? ?? [])
                            .map((tag) => _buildTag(tag.toString()))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Software Used',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artwork['softwareUsed'] ?? 'Not specified',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index] as Map<String, dynamic>;
                          final bool isCommentOwner = currentUser?.uid == comment['authorId'];
                          return ListTile(
                            title: _editingCommentId == comment['id']
                                ? TextField(
                              controller: _editCommentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _saveEditedComment(comment['id']),
                                ),
                              ),
                            )
                                : Text(
                              comment['text'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${comment['authorName']} - ${DateTime.fromMillisecondsSinceEpoch(comment['timestamp']).toString()}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: isCommentOwner
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => _editComment(comment),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _deleteComment(comment['id']),
                                ),
                              ],
                            )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: const TextStyle(color: Colors.white54),
                                enabledBorder: const UnderlineInputBorder(
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