import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Services/Shop/cart_provider.dart';
import '../Shop/cart_page.dart'; // Import the CartPage

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
                    backgroundImage:
                    AssetImage('assets/images/profile_picture.jpg'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ankara Methi',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    'ankara.methi@example.com',
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
            const Divider(),
            _buildDrawerItem(context, Icons.shopping_cart, 'Shop', 3,
                isCart: true),
            _buildDrawerItem(context, Icons.shopping_bag, 'Cart', 6,
                isCart: true, onTap: () => _navigateToCart(context)),
            _buildDrawerItem(context, Icons.event, 'Events', 4),
            const Divider(),
            _buildDrawerItem(context, Icons.person, 'Profile', 5),
            _buildDrawerItem(context, Icons.settings, 'Settings', -1),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, int index,
      {bool isCart = false, VoidCallback? onTap}) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        int itemCount = isCart ? cartProvider.cart.items.length : 0;

        return ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white),
              if (isCart && itemCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          onTap: onTap ?? () {
            if (index >= 0) {
              onItemTapped(index);
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
  }
}