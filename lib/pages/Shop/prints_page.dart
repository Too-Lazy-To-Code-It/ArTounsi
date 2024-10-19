import 'package:flutter/material.dart';

class PrintsPage extends StatelessWidget {
  const PrintsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {'name': 'Landscape Print', 'price': 24.99},
      {'name': 'Portrait Print', 'price': 29.99},
      {'name': 'Abstract Print', 'price': 19.99},
      {'name': 'Sci-Fi Print', 'price': 34.99},
      {'name': 'Landscape Print', 'price': 24.99},
      {'name': 'Portrait Print', 'price': 29.99},
      {'name': 'Abstract Print', 'price': 19.99},
      {'name': 'Sci-Fi Print', 'price': 34.99},

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
        return Card(
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}