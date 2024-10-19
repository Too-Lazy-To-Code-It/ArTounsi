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
        'categories': ['Landscape', 'Nature']
      },
      {
        'name': 'Portrait Print',
        'price': 29.99,
        'artist': 'Michael Lee',
        'artistLogo': 'assets/images/Shop/2.jpg',
        'categories': ['Portrait', 'People']
      },
      {
        'name': 'Abstract Print',
        'price': 19.99,
        'artist': 'Sarah Johnson',
        'artistLogo': 'assets/images/Shop/3.jpg',
        'categories': ['Abstract', 'Modern']
      },
      {
        'name': 'Sci-Fi Print',
        'price': 34.99,
        'artist': 'David Chen',
        'artistLogo': 'assets/images/Shop/4.jpg',
        'categories': ['Sci-Fi', 'Fantasy']
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        products[index]['name'],
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
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
                          CircleAvatar(
                            radius: 10,
                            backgroundImage: NetworkImage(products[index]['artistLogo']),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              products[index]['artist'],
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: (products[index]['categories'] as List<String>)
                            .map((category) => Chip(
                          label: Text(category, style: TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                            .toList(),
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