// prints_page.dart
import 'package:flutter/material.dart';
import 'prints_detail_page.dart';

class PrintsPage extends StatelessWidget {
  const PrintsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Landscape Print',
        'price': 24.99,
        'artist': 'Emma Wilson',
        'artistLogo': 'assets/images/Shop/1.jpg',
        'categories': ['Landscape', 'Nature'],
        'rating': 4.7,
        'reviewCount': 180,
      },
      {
        'name': 'Portrait Print',
        'price': 29.99,
        'artist': 'Michael Lee',
        'artistLogo': 'assets/images/Shop/2.jpg',
        'categories': ['Portrait', 'People'],
        'rating': 4.5,
        'reviewCount': 130,
      },
      {
        'name': 'Abstract Print',
        'price': 19.99,
        'artist': 'Sarah Johnson',
        'artistLogo': 'assets/images/Shop/3.jpg',
        'categories': ['Abstract', 'Modern'],
        'rating': 4.3,
        'reviewCount': 95,
      },
      {
        'name': 'Sci-Fi Print',
        'price': 34.99,
        'artist': 'David Chen',
        'artistLogo': 'assets/images/Shop/4.jpg',
        'categories': ['Sci-Fi', 'Fantasy'],
        'rating': 4.8,
        'reviewCount': 220,
      },
      {
        'name': 'Nature Print',
        'price': 24.99,
        'artist': 'Emma Wilson',
        'artistLogo': 'assets/images/Shop/5.jpg',
        'categories': ['Landscape', 'Nature'],
        'rating': 4.6,
        'reviewCount': 150,
      },
      {
        'name': 'Urban Print',
        'price': 29.99,
        'artist': 'Michael Lee',
        'artistLogo': 'assets/images/Shop/6.jpg',
        'categories': ['Urban', 'City'],
        'rating': 4.4,
        'reviewCount': 110,
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
                builder: (context) => PrintsDetailPage(product: products[index]),
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