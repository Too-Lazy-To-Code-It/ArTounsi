import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _imageUrls = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadMoreImages();
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
      _loadMoreImages();
    }
  }

  Future<void> _loadMoreImages() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulating an API call to fetch more images
      await Future.delayed(const Duration(seconds: 2));

      final List<String> newImages = List.generate(
        10,
            (index) => 'https://picsum.photos/seed/${_currentPage * 10 + index}/400/400',
      );

      setState(() {
        _imageUrls.addAll(newImages);
        _currentPage++;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                if (index >= _imageUrls.length) {
                  return null;
                }
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    _imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
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
    );
  }
}