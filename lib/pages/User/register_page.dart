import 'package:Artounsi/theme/app_theme.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _username;
  String? _email;
  String? _password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      return "Password must contain at least 1 number";
    }
    return null; // Password is valid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 30),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Image.asset("assets/images/logo.png", width: 460, height: 215)),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: TextFormField(
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
                obscureText: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Password"),
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
                    backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      String message = "Register Successful ! \n Welcome $_username to ArTounsi";

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Information"),
                              content: Text(message),
                            );
                          });
                    }
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  child: const Text("Cancel"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor),
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}