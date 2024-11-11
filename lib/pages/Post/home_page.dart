import 'package:flutter/material.dart';

import 'home_card.dart';
import 'add_art_page.dart';
import 'details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Implement pagination if needed
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _navigateToAddArtPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddArtPage()),
    );
  }

  bool _artworkMatchesSearch(Map<String, dynamic> artwork, String query) {
    if (query.isEmpty) return true;
    query = query.toLowerCase();
    return artwork['title'].toString().toLowerCase().contains(query) ||
        artwork['description'].toString().toLowerCase().contains(query) ||
        (artwork['tags'] as List<dynamic>).any((tag) => tag.toString().toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Art Gallery'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search artworks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                List<Map<String, dynamic>> posts = snapshot.data!.docs
                    .map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'id': doc.id,
                    'imageUrl': data['imageUrl'] as String? ?? '',
                    'title': data['title'] as String? ?? 'Untitled',
                    'description': data['description'] as String? ?? 'No description available',
                    'tags': List<String>.from(data['tags'] ?? []),
                    'softwareUsed': data['softwareUsed'] as String? ?? 'Unknown',
                    'author': data['author'] as String? ?? 'Unknown Author',
                    'likes': data['likes'] as int? ?? 0,
                    'views': data['views'] as int? ?? 0,
                    'comments': List<Map<String, dynamic>>.from(data['comments'] ?? []),
                  };
                })
                    .where((post) => _artworkMatchesSearch(post, _searchQuery))
                    .toList();

                return posts.isEmpty
                    ? const Center(child: Text('No artworks found'))
                    : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return HomeCard(
                      id: post['id'],
                      imageUrl: post['imageUrl'],
                      title: post['title'],
                      author: post['author'],
                      likes: post['likes'],
                      views: post['views'],
                      comments: post['comments'].length,
                      tag: List<String>.from(post['tags']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              artworkId: post['id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddArtPage,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}