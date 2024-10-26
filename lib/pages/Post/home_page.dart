import 'package:flutter/material.dart';
import 'home_card.dart';
import 'add_art_page.dart';
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
  int _currentPage = 1;

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
          final data = doc.data() as Map<String, dynamic>;
          return {
            'imageUrl': data['imageUrl'],
            'title': data['title'],
            'description': data['description'] ?? 'No description available',
            'tag': List<String>.from(data['tag'] ?? []),
            'softwareUsed': data['softwareUsed'] ?? 'Unknown',  // softwareUsed as a string
            'author': data['author'] ?? 'Unknown Author',
            'likes': data['likes'] ?? 0,
            'views': data['views'] ?? 0,
            'comments': List<Map<String, String>>.from(data['comments'] ?? []), // comments as list of maps
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
                    imageUrl: post['imageUrl'],
                    title: post['title'],
                    author: post['author'],
                    likes: post['likes'],
                    views: post['views'],
                    comments: post['comments'].length,
                    tag: post['tag'],
                    allPosts: _posts,
                    index: index,
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