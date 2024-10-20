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
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  // Navigate to cart page
                },
              ),
              if (widget.cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${widget.cart.itemCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    // Implement filter functionality
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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