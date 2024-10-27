import 'package:flutter/material.dart';
import 'home_card.dart';
import 'add_art_page.dart';
import 'details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Implement pagination if needed
    }
  }

  void _navigateToAddArtPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddArtPage()),
    );
    // No need to manually refresh, StreamBuilder will handle updates
  }

  void _onArtworkDeleted(String artworkId) {
    // Deletion will be handled by StreamBuilder automatically
  }

  void _onArtworkUpdated(Map<String, dynamic> updatedArtwork) {
    // Updates will be handled by StreamBuilder automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artworks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> posts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'imageUrl': data['imageUrl'] as String? ?? '',
              'title': data['title'] as String? ?? 'Untitled',
              'description': data['description'] as String? ?? 'No description available',
              'tag': List<String>.from(data['tags'] ?? []),
              'softwareUsed': data['softwareUsed'] as String? ?? 'Unknown',
              'author': data['author'] as String? ?? 'Unknown Author',
              'likes': data['likes'] as int? ?? 0,
              'views': data['views'] as int? ?? 0,
              'comments': List<Map<String, dynamic>>.from(data['comments'] ?? []),
            };
          }).toList();

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index >= posts.length) {
                        return null;
                      }
                      final post = posts[index];
                      return HomeCard(
                        imageUrl: post['imageUrl'],
                        title: post['title'],
                        author: post['author'],
                        likes: post['likes'],
                        views: post['views'],
                        comments: (post['comments'] as List).length,
                        tag: post['tag'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                allPosts: posts,
                                initialIndex: index,
                                onArtworkDeleted: _onArtworkDeleted,
                                onArtworkUpdated: _onArtworkUpdated,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddArtPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}