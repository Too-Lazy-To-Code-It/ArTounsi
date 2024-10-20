import 'package:flutter/material.dart';
import '../../entities/Shop/Cart.dart';
import 'product_grid_page.dart';
import '../../entities/Shop/Product.dart';

class ShopPage extends StatefulWidget {
  final Cart cart;

  const ShopPage({Key? key, required this.cart}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildTabButton('Marketplace', 0),
                SizedBox(width: 16),
                _buildTabButton('Prints', 1),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                ProductGridPage(productType: ProductType.marketplace, cart: widget.cart),
                ProductGridPage(productType: ProductType.prints, cart: widget.cart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedIndex == index ? Theme.of(context).primaryColor : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}