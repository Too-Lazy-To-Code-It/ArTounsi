import 'package:flutter/material.dart';
import '../Post/blog_page.dart';
import '../Post/blog_page.dart';

class CustomSidebar extends StatelessWidget {
  final Function(int) onItemTapped;

  const CustomSidebar({
    Key? key,
    required this.onItemTapped,
  }) : super(key: key);

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
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile_picture.jpg'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ankara Methi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    'ankara.methi@example.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.home, 'Home', 0),
            _buildDrawerItem(context, Icons.work, 'Jobs', 1),
            _buildDrawerItem(context, Icons.school, 'Learning', 2),
            const Divider(),
            _buildDrawerItem(context, Icons.shopping_cart, 'Shop', 3),
            _buildDrawerItem(context, Icons.event, 'Events', 4),
            _buildDrawerItem(context, Icons.article, 'Blog', -1, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlogPage()),
              );
            }),
            const Divider(),
            _buildDrawerItem(context, Icons.person, 'Profile', 5),
            _buildDrawerItem(context, Icons.settings, 'Settings', -1),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, int index, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      onTap: onTap ?? () {
        if (index >= 0) {
          onItemTapped(index);
        }
        Navigator.pop(context);
      },
    );
  }
}