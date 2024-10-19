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
        'artistLogo': 'https://example.com/john_doe_logo.png',
        'categories': ['Digital', 'Abstract']
      },
      {
        'name': '3D Model Pack',
        'price': 49.99,
        'artist': 'Jane Smith',
        'artistLogo': 'https://example.com/jane_smith_logo.png',
        'categories': ['3D', 'Characters']
      },
      {
        'name': 'Texture Set',
        'price': 19.99,
        'artist': 'Bob Johnson',
        'artistLogo': 'https://example.com/bob_johnson_logo.png',
        'categories': ['Textures', 'Environment']
      },
      {
        'name': 'Character Design',
        'price': 39.99,
        'artist': 'Alice Brown',
        'artistLogo': 'https://example.com/alice_brown_logo.png',
        'categories': ['Character', 'Concept Art']
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
                builder: (context) => MarketplaceDetailPage(product: products[index]),
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
                        Icons.brush,
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
                        style: Theme.of(context).textTheme.subtitle1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${products[index]['price']}',
                        style: Theme.of(context).textTheme.subtitle2?.copyWith(
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
                              style: Theme.of(context).textTheme.caption,
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