import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditArtworkPage extends StatefulWidget {
  final Map<String, dynamic> artwork;
  final Function(Map<String, dynamic>) onArtworkUpdated;

  const EditArtworkPage({
    super.key,
    required this.artwork,
    required this.onArtworkUpdated,
  });

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
    _selectedTags = List<String>.from(widget.artwork['tags'] ?? []);
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
          'title': _titleController.text,
          'description': _descriptionController.text,
          'softwareUsed': _softwareController.text,
          'tags': _selectedTags,
        };

        if (newImageUrl != null) {
          updatedArtwork['imageUrl'] = newImageUrl;
        }

        await FirebaseFirestore.instance
            .collection('artworks')
            .doc(widget.artwork['id'])
            .update(updatedArtwork);

        // Update the local state
        Map<String, dynamic> fullUpdatedArtwork = Map<String, dynamic>.from(widget.artwork)..addAll(updatedArtwork);
        widget.onArtworkUpdated(fullUpdatedArtwork);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artwork updated successfully')),
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
        title: const Text('Edit Artwork'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _softwareController,
                  decoration: InputDecoration(
                    labelText: 'Software Used',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text('Tags', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tagOptions.map((tag) {
                    return FilterChip(
                      label: Text(tag['name']),
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Pick Image', style: TextStyle(color: Colors.black)),
                ),
                if (_newArtImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Image.file(_newArtImage!, height: 200, width: 200),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Update Artwork', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}