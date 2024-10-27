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
  late TextEditingController _newTagController;
  File? _newArtImage;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.artwork['title']);
    _descriptionController = TextEditingController(text: widget.artwork['description']);
    _softwareController = TextEditingController(text: widget.artwork['softwareUsed']);
    _newTagController = TextEditingController();
    _selectedTags = List<String>.from(widget.artwork['tag'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _softwareController.dispose();
    _newTagController.dispose();
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

  void _addTag() {
    if (_newTagController.text.isNotEmpty) {
      setState(() {
        _selectedTags.add(_newTagController.text);
        _newTagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
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
      ),
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
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _softwareController,
                  decoration: InputDecoration(labelText: 'Software Used'),
                ),
                SizedBox(height: 16),
                Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _newTagController,
                        decoration: InputDecoration(labelText: 'Add new tag'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addTag,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Artwork Image', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _newArtImage != null
                        ? Image.file(_newArtImage!, fit: BoxFit.cover)
                        : Image.network(widget.artwork['imageUrl'], fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Update Artwork'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}