import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
        tooltip: 'Menu',
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {},
          tooltip: 'Messages',
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 24,
      errorBuilder: (context, error, stackTrace) {
        // Return an empty container if the image fails to load
        return Container();
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}