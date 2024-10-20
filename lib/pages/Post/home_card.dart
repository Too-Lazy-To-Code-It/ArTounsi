import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class HomeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int likes;
  final int views;
  final int comments;
  final String tag;
  final List<Map<String, dynamic>> allPosts;
  final int index;

  const HomeCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.comments,
    required this.tag,
    required this.allPosts,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(
                allPosts: allPosts,
                initialIndex: index,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconWithText(Icons.favorite, likes.toString()),
                      _buildIconWithText(
                          Icons.remove_red_eye, views.toString()),
                      _buildIconWithText(Icons.comment, comments.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class DetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  final int initialIndex;

  const DetailsPage({
    Key? key,
    required this.allPosts,
    required this.initialIndex,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allPosts[_currentIndex]['title']),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullscreenPhotoView(imageUrl: post['imageUrl']),
                      ),
                    );
                  },
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      post['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${post['author']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIconWithText(
                              Icons.favorite, '${post['likes']} likes'),
                          _buildIconWithText(
                              Icons.remove_red_eye, '${post['views']} views'),
                          _buildIconWithText(
                              Icons.comment, '${post['comments']} comments'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a detailed description of the artwork. It can include information about the techniques used, the inspiration behind the piece, or any other relevant details about the creation process.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          post['tag'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildCommentsList(),
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

  Widget _buildIconWithText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _buildCommentsList() {
    // This is a dummy list of comments. In a real app, you'd fetch this from an API or database.
    final List<Map<String, String>> comments = [
      {
        'author': 'Alice',
        'content': 'Great artwork! I love the use of colors.'
      },
      {
        'author': 'Bob',
        'content': 'The composition is really interesting. Well done!'
      },
      {
        'author': 'Charlie',
        'content': 'This piece speaks to me on so many levels. Fantastic job!'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(comment['author']![0]),
          ),
          title: Text(comment['author']!),
          subtitle: Text(comment['content']!),
        );
      },
    );
  }
}

class FullscreenPhotoView extends StatelessWidget {
  final String imageUrl;

  const FullscreenPhotoView({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
