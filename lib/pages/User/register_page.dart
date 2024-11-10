import 'dart:io';

import 'package:Artounsi/pages/User/login_page.dart';
import 'package:Artounsi/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _username;
  String? _email;
  String? _password;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password can't be empty";
    }
    if (value.length < 5) {
      return "Password must be at least 5 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least 1 uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }
    return null; // Password is valid
  }

  Future Register() async {
   try{ UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
    await addUsersDetails(_usernameController.text.trim(), _emailController.text.trim(), _passwordController.text.trim());
    if (userCredential.user != null && !userCredential.user!.emailVerified) {
      await userCredential.user!.sendEmailVerification();
      String message =
          "Check your mail for complete verification ! \n Welcome $_username to ArTounsi";

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Information"),
              content: Text(message),
            );
          });
    }
   } on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    showDialog(context: context,
      builder: (context){
        return AlertDialog(
          content : Text('Weak Password'),
        );
      },
    );
  } else if (e.code == 'email-already-in-use') {
    showDialog(context: context,
      builder: (context){
        return AlertDialog(
          content : Text('Email already in use'),
        );
      },
    );  }
  } catch (e) {
  print(e);
  }
  }

  addUsersDetails(String username, String email, String password) async{
    await FirebaseFirestore.instance.collection('users').add({
      'username': username,
      'email': email,
      'password': password
    });
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
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 150,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : const AssetImage('assets/images/img.png'),
              ),
            ),
            const SizedBox(height: 30),
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Email"),
                onSaved: (String? value) {
                  _email = value;
                },
                validator: (String? value) {
                  RegExp regex = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
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
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Password"),
                onSaved: (String? value) {
                  _password = value;
                },
                validator: _validatePassword,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("Register"),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await Register();

                    }
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  child: const Text("Cancel"),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                  ),
                  onPressed: () {
                    _formKey.currentState!.reset();
                    // Navigator.pop(context);
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 4),
                InkWell(
                  child: const Text(
                    'Login now',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  LoginPage()),
                    );                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
