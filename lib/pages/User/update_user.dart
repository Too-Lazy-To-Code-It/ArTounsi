import 'dart:io';
import 'package:Artounsi/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UpdateUser extends StatefulWidget {
  const UpdateUser({super.key});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  String? _username;
  String? _summary;
  bool? _fullTime;
  bool? _freelance;
  String? _userId;
  String? _userImage;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  final user = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic>? userData;
  late final SharedPreferences prefs;

  // Controllers for the form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _usernameController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    print("inside fetchUserData");
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userData = querySnapshot.docs.first.data();
          _usernameController.text = userData?['username'] ?? '';
          _summaryController.text = userData?['summary'] ?? '';
          _freelance = userData?['freelance'] ?? false;
          _fullTime = userData?['fulltime'] ?? false;
          _fullTime = userData?['fulltime'] ?? false;
          _userImage = userData?['image'] ?? '';
          _userId = querySnapshot.docs.first.id;
          print("User ID: $_userId");
        });
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload the image to Firebase Storage
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name
        firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('user_images/$fileName');

        // Upload the file
        firebase_storage.UploadTask uploadTask = storageReference.putFile(_imageFile!);
        await uploadTask;

        // Get the download URL
        String downloadURL = await storageReference.getDownloadURL();

        // Update Firestore with the image URL
        await updateUserImage(downloadURL);

        print("Image uploaded successfully: $downloadURL");
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> updateUserImage(String imageUrl) async {
    print("inside updaloadUserImage");
    print("_userId $_userId");
    if (_userId != null) {
      try {
        print("inside updaloadUserImage 5");
        final userDoc = FirebaseFirestore.instance.collection('users').doc(_userId);
        await userDoc.update({
          'image': imageUrl,  // Store the image URL in Firestore
        });

        print("User image URL updated successfully");
        // Optionally show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated successfully!")),
        );
      } catch (e) {
        print("Error updating user image: $e");
        // Optionally show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile image")),
        );
      }
    }
  }


  Future<void> updateUserData() async {
    if(_userId != null)
      {
        try {
          print("user ID is not null : $_userId");

          final userDoc = FirebaseFirestore.instance.collection('users').doc(_userId);

          await userDoc.update({
            'username': _usernameController.text,
            'summary': _summaryController.text,
            'fulltime': _fullTime ?? false,
            'freelance': _freelance ?? false,
          });

          print("User data updated successfully");
          // Optionally show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
        } catch (e) {
          print("Error updating user data: $e");
          // Optionally show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update profile")),
          );
        }
      }
    else
      {
        print("_userId is null");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update personal information"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 200,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_userImage != null && _userImage!.isNotEmpty)
                      ? NetworkImage(_userImage!)  // Use NetworkImage for URLs
                      : const AssetImage('assets/images/img.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Username"),
                  onSaved: (String? value) {
                    _username = value;
                  },
                  validator: (String? value) {
                    if (value!.isEmpty || value.length < 5) {
                      return "The username must have at least 5 characters";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  controller: _summaryController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Summary"),
                  onSaved: (String? value) {
                    _summary = value;
                  },
                ),
              ),
              // Add this code right after the ElevatedButton widget
              Container(
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Full-time employment"),
                        Switch(
                          value: _fullTime ?? false,
                          onChanged: (bool value) {
                            setState(() {
                              _fullTime = value;
                              _freelance = !value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Freelance"),
                        Switch(
                          value: _freelance ?? false,
                          onChanged: (bool value) {
                            setState(() {
                              _freelance = value;
                              _fullTime = !value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                  ),
                  child: const Text("Update"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      updateUserData();
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}