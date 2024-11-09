import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../entities/Shop/Product.dart';
import '../../entities/Shop/Cart.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final Cart cart;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.cart,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Product> _productFuture;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _artistController;
  late TextEditingController _categoriesController;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProduct();
  }

  Future<Product> _fetchProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('Product')
        .doc(widget.productId)
        .get();
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    return Product.fromFirestore(doc);
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _updateProduct(Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection('Product')
          .doc(product.id)
          .update(product.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully')),
      );
      setState(() {
        _productFuture = Future.value(product);
        _isEditing = false;
      });
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    }
  }

  Future<void> _deleteProduct(String productId, String imageUrl) async {
    try {
      // Delete the product document from Firestore
      await  FirebaseFirestore.instance
          .collection('Product')
          .doc(productId)
          .delete();

      // Delete the image from Firebase Storage
      if (imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
      Navigator.of(context).pop(); // Return to previous page
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Product not found'));
          }

          final product = snapshot.data!;

          if (_isEditing) {
            _nameController = TextEditingController(text: product.name);
            _priceController = TextEditingController(text: product.price.toString());
            _artistController = TextEditingController(text: product.artist);
            _categoriesController = TextEditingController(text: product.categories.join(', '));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Icon(Icons.error);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isEditing
                          ? TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Product Name'),
                      )
                          : Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      _isEditing
                          ? TextField(
                        controller: _priceController,
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                      )
                          : Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      _isEditing
                          ? TextField(
                        controller: _artistController,
                        decoration: InputDecoration(labelText: 'Artist'),
                      )
                          : Text(
                        'Artist: ${product.artist}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      _isEditing
                          ? TextField(
                        controller: _categoriesController,
                        decoration: InputDecoration(labelText: 'Categories (comma-separated)'),
                      )
                          : Text(
                        'Categories: ${product.categories.join(", ")}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text(' ${product.rating} (${product.reviewCount} reviews)'),
                        ],
                      ),
                      SizedBox(height: 24),
                      if (!_isEditing)
                        ElevatedButton(
                          onPressed: () {
                            widget.cart.addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} added to cart')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text('Add to Cart'),
                        ),
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: () {
                            final updatedProduct = Product(
                              id: product.id,
                              name: _nameController.text,
                              price: double.tryParse(_priceController.text) ?? product.price,
                              artist: _artistController.text,
                              imageUrl: product.imageUrl,
                              categories: _categoriesController.text.split(',').map((e) => e.trim()).toList(),
                              rating: product.rating,
                              reviewCount: product.reviewCount,
                              type: product.type,
                            );
                            _updateProduct(updatedProduct);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text('Save Changes'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _productFuture.then((product) {
                  _deleteProduct(widget.productId, product.imageUrl);
                });
              },
            ),
          ],
        );
      },
    );
  }
}