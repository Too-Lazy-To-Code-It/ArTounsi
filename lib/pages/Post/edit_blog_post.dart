import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'blog_post.dart';

class EditBlogPost extends StatefulWidget {
  final BlogPost post;

  const EditBlogPost({super.key, required this.post});

  @override
  _EditBlogPostState createState() => _EditBlogPostState();
}

class _EditBlogPostState extends State<EditBlogPost> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _excerptController;
  late TextEditingController _contentController;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _excerptController = TextEditingController(text: widget.post.excerpt);
    _contentController = TextEditingController(text: widget.post.content);
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != widget.post.authorId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have permission to edit this post.')),
        );
        return;
      }

      String imageUrl = widget.post.imageUrl;

      if (_image != null) {
        // Delete old image
        if (widget.post.imageUrl.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(widget.post.imageUrl).delete();
          } catch (e) {
            print('Error deleting old image: $e');
          }
        }

        // Upload new image
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('blog_images/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Update blog post
      await FirebaseFirestore.instance.collection('blog_posts').doc(widget.post.id).update({
        'title': _titleController.text,
        'excerpt': _excerptController.text,
        'content': _contentController.text,
        'imageUrl': imageUrl,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Blog Post')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _excerptController,
                  decoration: const InputDecoration(labelText:  'Excerpt'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an excerpt';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _image == null
                    ? Image.network(widget.post.imageUrl)
                    : Image.file(_image!),
                ElevatedButton(
                  onPressed: getImage,
                  child: const Text('Change Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}