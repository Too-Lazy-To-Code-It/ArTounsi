import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddArtPage extends StatefulWidget {
  const AddArtPage({super.key});

  @override
  _AddArtPageState createState() => _AddArtPageState();
}

class _AddArtPageState extends State<AddArtPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _softwareController = TextEditingController();
  File? _mainArtImage;
  List<String> _selectedTags = [];

  final List<Map<String, dynamic>> _tagOptions = [
    {'name': 'Game Art', 'icon': Icons.games},
    {'name': 'Anime Art', 'icon': Icons.animation},
    {'name': 'Character Art', 'icon': Icons.person},
    {'name': 'Landscape Art', 'icon': Icons.landscape},
    {'name': 'Abstract Art', 'icon': Icons.brush},
    {'name': 'Portrait Art', 'icon': Icons.face},
    {'name': 'Concept Art', 'icon': Icons.lightbulb},
    {'name': 'Digital Painting', 'icon': Icons.palette},
    {'name': '3D Art', 'icon': Icons.view_in_ar},
    {'name': 'Pixel Art', 'icon': Icons.grid_on},
    {'name': 'Fan Art', 'icon': Icons.favorite},
    {'name': 'Illustration', 'icon': Icons.image},
  ];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _mainArtImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Artwork'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Art Title',
                    icon: Icons.title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Art Description',
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildMultiSelectChips(),
                  const SizedBox(height: 16.0),
                  _buildTextField(
                    controller: _softwareController,
                    label: 'Software Used',
                    icon: Icons.computer,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),
                  _buildImagePicker(),
                  const SizedBox(height: 24.0),
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text('Add Artwork', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[900],
        errorStyle: TextStyle(color: Colors.red[300]),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildMultiSelectChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Art Categories',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _tagOptions.map((tag) {
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tag['icon'], size: 18, color: _selectedTags.contains(tag['name']) ? Colors.black : Theme.of(context).primaryColor),
                  const SizedBox(width: 4),
                  Text(tag['name']),
                ],
              ),
              selected: _selectedTags.contains(tag['name']),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag['name']);
                  } else {
                    _selectedTags.remove(tag['name']);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.black,
              backgroundColor: Colors.grey[800],
              labelStyle: TextStyle(
                color: _selectedTags.contains(tag['name']) ? Colors.black : Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
        if (_selectedTags.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select at least one category',
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Art Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[900],
            ),
            child: _mainArtImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _mainArtImage!,
                fit: BoxFit.cover,
              ),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 50, color: Colors.white70),
                SizedBox(height: 8),
                Text(
                  'Tap to upload image',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        if (_mainArtImage == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Required main image',
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Choose Image Source', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera, color: Colors.white70),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _mainArtImage != null && _selectedTags.isNotEmpty) {
      _formKey.currentState!.save();

      try {
        // Upload the image to Firebase Storage and get the URL
        String imageUrl = await _uploadImage(_mainArtImage!);

        // Create a document in Firestore
        await FirebaseFirestore.instance.collection('artworks').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'softwareUsed': _softwareController.text,
          'tags': _selectedTags, // Changed from 'tag' to 'tags'
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Art added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Reset form
        _titleController.clear();
        _descriptionController.clear();
        _softwareController.clear();
        setState(() {
          _mainArtImage = null;
          _selectedTags = [];
        });
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields, select at least one category, and select an image'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = 'artworks/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = storageRef.child(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _softwareController.dispose();
    super.dispose();
  }
}