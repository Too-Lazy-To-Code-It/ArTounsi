import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProjectCreationPage extends StatefulWidget {
  @override
  _ProjectCreationPageState createState() => _ProjectCreationPageState();
}

class _ProjectCreationPageState extends State<ProjectCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _title = '';
  String _description = '';
  File? _mainImage;
  List<File> _additionalImages = [];
  String _projectLink = '';

  Future<void> _pickImage(ImageSource source, {bool isMain = false}) async {
    final XFile? pickedFile = await _getImage();
    if (pickedFile != null) {
      setState(() {
        if (isMain) {
          _mainImage = File(pickedFile.path);
        } else {
          _additionalImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<XFile?> _getImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  Future<String> _uploadImage(File image, String folder) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('Job_images/$folder/$fileName');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _saveJob() async {
    if (_formKey.currentState!.validate() && _mainImage != null) {
      _formKey.currentState!.save();

      try {
        // Upload main image
        String mainImageUrl = await _uploadImage(_mainImage!, 'main');

        // Upload additional images
        List<String> additionalImageUrls = [];
        for (File image in _additionalImages) {
          String url = await _uploadImage(image, 'additional');
          additionalImageUrls.add(url);
        }

        // Get current user ID
        String userId = _auth.currentUser?.uid ?? 'anonymous';

        // Save job data to Firestore
        await _firestore.collection('Jobs').add({
          'title': _title,
          'description': _description,
          'mainImageUrl': mainImageUrl,
          'additionalImageUrls': additionalImageUrls,
          'projectLink': _projectLink,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job created successfully')),
        );

        // Clear the form
        setState(() {
          _title = '';
          _description = '';
          _mainImage = null;
          _additionalImages = [];
          _projectLink = '';
          _formKey.currentState!.reset();
        });
      } catch (e) {
        print('Error saving job: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating job. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Job Title',
                errorStyle: TextStyle(color: Colors.red),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Job Description',
                errorStyle: TextStyle(color: Colors.red),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) {
                _description = value!;
              },
            ),
            SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hover Job Image',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(isMain: true),
                      child: Container(
                        height: MediaQuery.sizeOf(context).width * 0.6,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: _mainImage != null
                            ? Image.file(_mainImage!, fit: BoxFit.cover)
                            : Center(child: Text('Upload image')),
                      ),
                    ),
                    if (_mainImage == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Required main image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Images (Optional)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _additionalImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _additionalImages.length) {
                          return GestureDetector(
                            onTap: () => _showImageSourceDialog(),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Icon(Icons.add),
                            ),
                          );
                        }
                        return Image.file(_additionalImages[index],
                            fit: BoxFit.cover);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Job Link (Optional)',
                errorStyle: TextStyle(color: Colors.red),
              ),
              onSaved: (value) {
                _projectLink = value ?? '';
              },
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _saveJob,
              child: Text('Create Job'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog({bool isMain = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera, isMain: isMain);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery, isMain: isMain);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}