import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/Shop/Product.dart';
import '../../entities/Shop/Cart.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final Cart cart;

  const ProductDetailPage({
    Key? key,
    required this.productId,
    required this.cart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Product not found'));
          }

          final product = Product.fromFirestore(snapshot.data!);

          // Build your product detail UI here using the 'product' object
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Image.network(
                  product.imagePath,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      Text('Artist: ${product.artist}'),
                      SizedBox(height: 8),
                      Text('Rating: ${product.rating}'),
                      SizedBox(height: 8),
                      Text('Reviews: ${product.reviewCount}'),
                      SizedBox(height: 16),
                      Text('Categories: ${product.categories.join(", ")}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add to cart logic here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to cart')),
          );
        },
        child: Icon(Icons.add_shopping_cart),
      ),
    );
  }
}