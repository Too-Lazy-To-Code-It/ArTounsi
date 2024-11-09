import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../entities/Shop/Product.dart';

class AddProductForm extends StatefulWidget {
  final VoidCallback? onProductAdded;

  const AddProductForm({super.key, this.onProductAdded});

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
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
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

  Future<String> _uploadImageToFirebase(File image) async {
    final String fileName = Uuid().v4();
    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('product_images/$fileName');
    final UploadTask uploadTask = firebaseStorageRef.putFile(image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String imageUrl = '';
        if (_image != null) {
          imageUrl = await _uploadImageToFirebase(_image!);
        }

        final newProduct = Product(
          id: '',
          name: _nameController.text,
          price: double.parse(_priceController.text),
          artist: _artistController.text,
          imageUrl: imageUrl,
          categories: _categoriesController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
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
        title: Text('Add Product'),
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
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a price' : null,
                ),
                TextFormField(
                  controller: _artistController,
                  decoration: InputDecoration(labelText: 'Artist'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an artist' : null,
                ),
                TextFormField(
                  controller: _categoriesController,
                  decoration: InputDecoration(
                      labelText: 'Categories (comma-separated)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter categories' : null,
                ),
                DropdownButtonFormField<ProductType>(
                  value: _productType,
                  items: ProductType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _productType = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Product Type'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _getImage,
                  child: Text('Pick Image'),
                ),
                if (_image != null) ...[
                  SizedBox(height: 16),
                  Image.file(_image!, height: 200),
                ],
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Add Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
