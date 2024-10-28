import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../entities/Shop/Product.dart';

class AddProductForm extends StatefulWidget {
  final VoidCallback? onProductAdded;

  const AddProductForm({Key? key, this.onProductAdded}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _artistController = TextEditingController();
  final _categoriesController = TextEditingController();
  ProductType _productType = ProductType.marketplace;
  File? _image;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _artistController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String imageUrl = '';
        if (_image != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('product_images/${DateTime.now().toIso8601String()}.jpg');

          // Upload the file
          await storageRef.putFile(_image!).whenComplete(() async {
            // Get the download URL
            imageUrl = await storageRef.getDownloadURL();
          }).catchError((error) {
            print('Error uploading image: $error');
            throw error; // Rethrow the error to be caught in the outer catch block
          });
        }

        final newProduct = Product(
          id: '',
          name: _nameController.text,
          price: double.parse(_priceController.text),
          artist: _artistController.text,
          imagePath: imageUrl,
          categories: _categoriesController.text.split(',').map((e) => e.trim()).toList(),
          rating: 0,
          reviewCount: 0,
          type: _productType,
        );

        await FirebaseFirestore.instance
            .collection('Product')
            .add(newProduct.toFirestore());

        print('Product added successfully');
        widget.onProductAdded?.call();
        Navigator.of(context).pop();
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _artistController,
                  decoration: InputDecoration(
                    labelText: 'Artist',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter an artist' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _categoriesController,
                  decoration: InputDecoration(
                    labelText: 'Categories (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter categories' : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<ProductType>(
                  value: _productType,
                  items: ProductType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _productType = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Product Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _getImage,
                  icon: Icon(Icons.image),
                  label: Text('Select Image'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                SizedBox(height: 16),
                if (_image != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}