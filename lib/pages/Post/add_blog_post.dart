import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'blog_post.dart';

class AddBlogPost extends StatefulWidget {
  @override
  _AddBlogPostState createState() => _AddBlogPostState();
}

class _AddBlogPostState extends State<AddBlogPost> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
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
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('blog_images/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      BlogPost newPost = BlogPost(
        id: '',
        title: _titleController.text,
        date: DateTime.now(),
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
      appBar: AppBar(title: Text('Add Blog Post')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  validator: (value) => value!.isEmpty ? 'Please enter content' : null,
                ),
                SizedBox(height: 20),
                _image == null
                    ? Text('No image selected.')
                    : Image.file(_image!),
                ElevatedButton(
                  onPressed: getImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}