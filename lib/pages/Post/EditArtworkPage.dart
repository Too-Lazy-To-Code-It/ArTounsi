import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditArtworkPage extends StatefulWidget {
  final Map<String, dynamic> artwork;
  final Function(Map<String, dynamic>) onArtworkUpdated;

  const EditArtworkPage({
    Key? key,
    required this.artwork,
    required this.onArtworkUpdated,
  }) : super(key: key);

  @override
  _EditArtworkPageState createState() => _EditArtworkPageState();
}

class _EditArtworkPageState extends State<EditArtworkPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _softwareController;
  File? _newArtImage;
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.artwork['title']);
    _descriptionController = TextEditingController(text: widget.artwork['description']);
    _softwareController = TextEditingController(text: widget.artwork['softwareUsed']);
    _selectedTags = List<String>.from(widget.artwork['tag'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _softwareController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newArtImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadNewImage() async {
    if (_newArtImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = 'artworks/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = storageRef.child(fileName).putFile(_newArtImage!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? newImageUrl = await _uploadNewImage();

      try {
        Map<String, dynamic> updatedArtwork = {
          'id': widget.artwork['id'],
          'title': _titleController.text,
          'description': _descriptionController.text,
          'softwareUsed': _softwareController.text,
          'tag': _selectedTags,
          'imageUrl': newImageUrl ?? widget.artwork['imageUrl'],
        };

        await FirebaseFirestore.instance.collection('artworks').doc(widget.artwork['id']).update(updatedArtwork);

        widget.onArtworkUpdated(updatedArtwork);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork updated successfully')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update artwork: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Artwork'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 16),
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
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _softwareController,
                    label: 'Software Used',
                    icon: Icons.computer,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  _buildMultiSelectChips(),
                  SizedBox(height: 16),
                  _buildImagePicker(),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save, color: Colors.black),
                    label: const Text('Update Artwork', style: TextStyle(color: Colors.black)),
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
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[900],
        errorStyle: TextStyle(color: Colors.red[300]),
      ),
      style: TextStyle(color: Colors.white),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildMultiSelectChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
                  SizedBox(width: 4),
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
        Text(
          'Art Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[900],
            ),
            child: _newArtImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _newArtImage!,
                fit: BoxFit.cover,
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.artwork['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}