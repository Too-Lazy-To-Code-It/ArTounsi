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
  final List<Map<String, dynamic>> _posts = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMorePosts();
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
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('artworks')
            .get();

        List<Map<String, dynamic>> newPosts = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            'imageUrl': data['imageUrl'] as String? ?? '',
            'title': data['title'] as String? ?? 'Untitled',
            'description': data['description'] as String? ?? 'No description available',
            'tag': List<String>.from(data['tag'] ?? []),
            'softwareUsed': data['softwareUsed'] as String? ?? 'Unknown',
            'author': data['author'] as String? ?? 'Unknown Author',
            'likes': data['likes'] as int? ?? 0,
            'views': data['views'] as int? ?? 0,
            'comments': List<Map<String, dynamic>>.from(data['comments'] ?? []),
          };
        }).toList();

        setState(() {
          _posts.addAll(newPosts);
          _isLoading = false;
        });
      } catch (error) {
        print("Error fetching posts: $error");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddArtPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddArtPage()),
    );
  }

  void _onArtworkDeleted(String artworkId) {
    setState(() {
      _posts.removeWhere((post) => post['id'] == artworkId);
    });
  }

  void _onArtworkUpdated(Map<String, dynamic> updatedArtwork) {
    setState(() {
      int index = _posts.indexWhere((post) => post['id'] == updatedArtwork['id']);
      if (index != -1) {
        _posts[index] = updatedArtwork;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                  if (index >= _posts.length) {
                    return null;
                  }
                  final post = _posts[index];
                  return HomeCard(
                    imageUrl: post['imageUrl'] ?? '',
                    title: post['title'] ?? 'Untitled',
                    author: post['author'] ?? 'Unknown',
                    likes: post['likes'] ?? 0,
                    views: post['views'] ?? 0,
                    comments: (post['comments'] as List?)?.length ?? 0,
                    tag: List<String>.from(post['tag'] ?? []),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(
                            allPosts: _posts,
                            initialIndex: index,
                            onArtworkDeleted: _onArtworkDeleted,
                            onArtworkUpdated: _onArtworkUpdated,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddArtPage,
        child: const Icon(Icons.add),

      ),
    );
  }
}