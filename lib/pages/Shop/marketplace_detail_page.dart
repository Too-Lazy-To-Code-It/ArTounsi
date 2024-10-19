import 'package:flutter/material.dart';
import 'fullscreen_image_view.dart';

class MarketplaceDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> allProducts;
  final int currentIndex;

  const MarketplaceDetailPage({
    Key? key,
    required this.product,
    required this.allProducts,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: allProducts.length,
        controller: PageController(initialPage: currentIndex),
        itemBuilder: (context, index) {
          final currentProduct = allProducts[index];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImageView(
                            imageUrls: allProducts
                                .map((p) => p['artistLogo'] as String)
                                .toList(),
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'productImage${currentProduct['name']}',
                      child: Image.asset(
                        currentProduct['artistLogo'],
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
                        currentProduct['name'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${currentProduct['price']}',
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
                            backgroundImage:
                                AssetImage(currentProduct['artistLogo']),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentProduct['artist'],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text(
                              ' ${currentProduct['rating']} (${currentProduct['reviewCount']} reviews)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Categories:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Wrap(
                        spacing: 8,
                        children: (currentProduct['categories'] as List<String>)
                            .map((category) => Chip(label: Text(category)))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildReviewItem(context, 'John Doe', 5,
                          'Great product! Highly recommended.'),
                      _buildReviewItem(context, 'Jane Smith', 4,
                          'Good quality, but a bit pricey.'),
                      _buildReviewItem(context, 'Mike Johnson', 5,
                          'Excellent service and fast delivery.'),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added to cart')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewItem(
      BuildContext context, String name, int rating, String comment) {
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
