// prints_detail_page.dart
import 'package:flutter/material.dart';

class PrintsDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const PrintsDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                product['artistLogo'],
                fit: BoxFit.cover,
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
                    product['name'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height:  8),
                  Text(
                    '\$${product['price']}',
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
                        backgroundImage: AssetImage(product['artistLogo']),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product['artist'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Text(' ${product['rating']} (${product['reviewCount']} reviews)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categories:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: (product['categories'] as List<String>)
                        .map((category) => Chip(label: Text(category)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available Sizes:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: ['Small', 'Medium', 'Large']
                        .map((size) => ChoiceChip(
                      label: Text(size),
                      selected: false,
                      onSelected: (bool selected) {
                        // Implement size selection logic
                      },
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildReviewItem(context, 'Alice Brown', 5, 'Beautiful print! Looks great on my wall.'),
                  _buildReviewItem(context, 'Bob Wilson', 4, 'Good quality print, but colors are slightly different from the image.'),
                  _buildReviewItem(context, 'Carol Davis', 5, 'Excellent packaging and fast shipping.'),
                ],
              ),
            ),
          ),
        ],
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