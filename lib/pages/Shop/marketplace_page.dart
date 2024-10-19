// marketplace_page.dart
import 'package:flutter/material.dart';
import 'marketplace_detail_page.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Digital Artwork 1',
        'price': 29.99,
        'artist': 'John Doe',
        'artistLogo': 'assets/images/Shop/1.jpg',
        'categories': ['Digital', 'Abstract'],
        'rating': 4.5,
        'reviewCount': 120,
      },
      {
        'name': '3D Model Pack',
        'price': 49.99,
        'artist': 'Jane Smith',
        'artistLogo': 'assets/images/Shop/2.jpg',
        'categories': ['3D', 'Characters'],
        'rating': 4.2,
        'reviewCount': 85,
      },
      {
        'name': 'Texture Set',
        'price': 19.99,
        'artist': 'Bob Johnson',
        'artistLogo': 'assets/images/Shop/3.jpg',
        'categories': ['Textures', 'Environment'],
        'rating': 4.8,
        'reviewCount': 200,
      },
      {
        'name': 'Character Design',
        'price': 39.99,
        'artist': 'Alice Brown',
        'artistLogo': 'assets/images/Shop/4.jpg',
        'categories': ['Character', 'Concept Art'],
        'rating': 4.6,
        'reviewCount': 150,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketplaceDetailPage(
                  product: products[index],
                  allProducts: products,
                  currentIndex: index,
                ),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: DecorationImage(
                        image: AssetImage(products[index]['artistLogo']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        products[index]['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${products[index]['price']}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(
                            ' ${products[index]['rating']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.comment, size: 16, color: Colors.grey),
                          Text(
                            ' ${products[index]['reviewCount']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}