import 'dart:io';
import 'package:Artounsi/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({super.key});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  String? _username;
  String? _email;
  String? _summary;
  bool _receiveNotifications = true;
  bool _enableDarkMode = false;
  bool _showOnlineStatus = true;


  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Default values
  final String _defaultUsername = "Ankara Methi";
  final String _defaultEmail = "ankara.methi@exemple.com";
  final String _defaultSummary = "Ankara Methi has not yet provided a summary";

  @override
  void initState() {
    super.initState();
    // Initialize default values
    _username = _defaultUsername;
    _email = _defaultEmail;
    _summary = _defaultSummary;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
                      : const AssetImage('assets/images/profile_picture.jpg'),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  initialValue: _username,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Username"),
                  onSaved: (String? value) {
                    _username = value;
                  },
                  validator: (String? value) {
                    if (value!.isEmpty || value.length < 5) {
                      return "Le username must have at least 5 characters";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  initialValue: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Email"),
                  onSaved: (String? value) {
                    _email = value;
                  },
                  validator: (String? value) {
                    RegExp regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                    if (value!.isEmpty || !regex.hasMatch(value)) {
                      return "Email must have valid form";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  initialValue: _summary,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Summary"),
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
                          value: _receiveNotifications,
                          onChanged: (bool value) {
                            setState(() {
                              _receiveNotifications = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Contract"),
                        Switch(
                          value: _enableDarkMode,
                          onChanged: (bool value) {
                            setState(() {
                              _enableDarkMode = value;
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
                          value: _showOnlineStatus,
                          onChanged: (bool value) {
                            setState(() {
                              _showOnlineStatus = value;
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
                    backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                  ),
                  child: const Text("Update"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
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