import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'blog_post.dart';
import 'blog_post_details.dart';
import 'add_blog_post.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddBlogPost()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blog_posts')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No blog posts found.'));
          }

          List<BlogPost> blogPosts = snapshot.data!.docs.map((doc) {
            return BlogPost.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: blogPosts.length,
            itemBuilder: (context, index) {
              final post = blogPosts[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: post.imageUrl.isNotEmpty
                      ? Image.network(
                    post.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  )
                      : const Icon(Icons.image),
                  title: Text(post.title),
                  subtitle: Text(post.date.toString().split(' ')[0]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogPostDetails(post: post),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}