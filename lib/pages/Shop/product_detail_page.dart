import 'package:flutter/material.dart';
import '../../entities/Shop/Product.dart';
import '../../entities/Shop/Cart.dart';
import 'fullscreen_image_view.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final List<Product> allProducts;
  final int currentIndex;
  final Cart cart;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.allProducts,
    required this.currentIndex,
    required this.cart,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
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
      body: PageView.builder(
        itemCount: widget.allProducts.length,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final Product currentProduct = widget.allProducts[index];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: () async {
                      final int? newIndex = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImageView(
                            imageUrls: widget.allProducts.map((p) => p.imagePath).toList(),
                            initialIndex: _currentIndex,
                          ),
                        ),
                      );
                      if (newIndex != null && newIndex != _currentIndex) {
                        setState(() {
                          _currentIndex = newIndex;
                          _pageController.jumpToPage(newIndex);
                        });
                      }
                    },
                    child: Hero(
                      tag: 'productImage${currentProduct.id}',
                      child: Image.asset(
                        currentProduct.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentProduct.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${currentProduct.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(currentProduct.imagePath),
                          ),
                          const SizedBox(width: 8),
                          Text(

                            currentProduct.artist,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text(' ${currentProduct.rating} (${currentProduct.reviewCount} reviews)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Categories:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Wrap(
                        spacing: 8,
                        children: currentProduct.categories
                            .map((category) => Chip(label: Text(category)))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildReviewItem(context, 'John Doe', 5, 'Great product! Highly recommended.'),
                      _buildReviewItem(context, 'Jane Smith', 4, 'Good quality, but a bit pricey.'),
                      _buildReviewItem(context, 'Mike Johnson', 5, 'Excellent service and fast delivery.'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: Text('Add to Cart'),
          onPressed: () {
            widget.cart.addItem(widget.allProducts[_currentIndex]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added to cart')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, String name, int rating, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment),
        ],
      ),
    );
  }
}