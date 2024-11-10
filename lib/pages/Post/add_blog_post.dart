import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'blog_post.dart';

class AddBlogPost extends StatefulWidget {
  const AddBlogPost({super.key});

  @override
  _AddBlogPostState createState() => _AddBlogPostState();
}

class _AddBlogPostState extends State<AddBlogPost> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _excerptController = TextEditingController();
  final _contentController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to post.')),
        );
        return;
      }

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('blog_images/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      BlogPost newPost = BlogPost(
        id: '',
        title: _titleController.text,
        authorId: currentUser.uid,
        authorName: currentUser.displayName ?? 'Anonymous',
        date: DateTime.now(),
        excerpt: _excerptController.text,
        content: _contentController.text,
        imageUrl: imageUrl,
      );

      await FirebaseFirestore.instance.collection('blog_posts').add(newPost.toMap());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Blog Post')),
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
                  decoration: const InputDecoration(labelText: 'Excerpt'),
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
                    ? const Text('No image selected.')
                    : Image.file(_image!),
                ElevatedButton(
                  onPressed: getImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}