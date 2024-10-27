import 'package:flutter/material.dart';
import 'home_card.dart';
import 'add_art_page.dart';

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
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulating an API call to fetch more posts
      await Future.delayed(const Duration(seconds: 2));

      final List<String> tags = [
        'Art',
        'Photography',
        'Digital',
        'Sculpture',
        'Painting'
      ];
      final List<Map<String, dynamic>> newPosts = List.generate(
        10,
        (index) => {
          'imageUrl':
              'https://picsum.photos/seed/${_currentPage * 10 + index}/400/400',
          'title': 'Artwork ${_currentPage * 10 + index}',
          'author': 'Artist ${_currentPage * 10 + index}',
          'likes': (_currentPage * 10 + index) * 10,
          'views': (_currentPage * 10 + index) * 100,
          'comments': [
            {'author': 'User1', 'content': 'Great work!'},
            {'author': 'User2', 'content': 'I love the colors!'},
          ],
          'tag': tags[(_currentPage * 10 + index) % tags.length],
        },
      );

      setState(() {
        _posts.addAll(newPosts);
        _currentPage++;
        _isLoading = false;
      });
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