import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Post/blog_page.dart';

class CustomSidebar extends StatefulWidget {
  final Function(int) onItemTapped;

  const CustomSidebar({
    super.key,
    required this.onItemTapped,
  });

  @override
  _CustomSidebarState createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  String? _userImage;
  Map<String, dynamic>? userData;

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print("inside fetchUserData");
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userData = querySnapshot.docs.first.data();
          _userImage = userData?['image'] ?? ''; // if no image, set empty string
        });
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _userImage == null || _userImage!.isEmpty
                      ? const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/img.png'),
                  )
                      : CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(_userImage!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['username'] ?? 'not username available',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    user.email ?? 'Unknown Email',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.home, 'Home', 0),
            _buildDrawerItem(context, Icons.work, 'Jobs', 1),
            _buildDrawerItem(context, Icons.school, 'Learning', 2),
            _buildDrawerItem(context, Icons.article, 'Blog', -1, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlogPage()),
              );
            }),
            const Divider(),
            _buildDrawerItem(context, Icons.shopping_cart, 'Shop', 3),
            _buildDrawerItem(context, Icons.event, 'Events', 4),
            const Divider(),
            _buildDrawerItem(context, Icons.person, 'Profile', 5),
            _buildDrawerItem(context, Icons.settings, 'Settings', -1),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, int index,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      onTap: onTap ??
              () {
            if (index >= 0) {
              widget.onItemTapped(index);
            }
            Navigator.pop(context);
          },
    );
  }
}