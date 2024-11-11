import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/Shop/Product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _artistController;
  late TextEditingController _categoriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _artistController = TextEditingController(text: widget.product.artist);
    _categoriesController = TextEditingController(text: widget.product.categories.join(', '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _artistController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _artistController,
              decoration: InputDecoration(labelText: 'Artist'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _categoriesController,
              decoration: InputDecoration(labelText: 'Categories (comma-separated)'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProduct() async {
    try {
      await FirebaseFirestore.instance.collection('Product').doc(widget.product.id).update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'artist': _artistController.text,
        'categories': _categoriesController.text.split(',').map((e) => e.trim()).toList(),
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully')),
      );
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product')),
      );
    }
  }
}