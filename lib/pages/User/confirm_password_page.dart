import 'package:Artounsi/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ConfirmPasswordPage extends StatefulWidget {
  const ConfirmPasswordPage({super.key});

  @override
  State<ConfirmPasswordPage> createState() => _ConfirmPasswordPageState();
}

class _ConfirmPasswordPageState extends State<ConfirmPasswordPage> {
  String? _password;
  String? _password_confirmed;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Function to validate password strength
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

  // Function to confirm that passwords match
  String? _validatePasswordConfirmed(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != _password) {
      return "Passwords do not match";
    }
    return null; // Password confirmation is valid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.key_rounded,
              size: 100,
            ),
            const SizedBox(height: 20),
            // Password field
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
                onChanged: (String? value) {
                  setState(() {
                    _password = value;
                  });
                },
                validator: _validatePassword, // Validate the password
              ),
            ),
            // Confirm password field
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Confirm Password",
                ),
                onSaved: (String? value) {
                  _password_confirmed = value;
                },
                validator:
                    _validatePasswordConfirmed, // Validate if passwords match
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("Confirm new password"),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pushNamed(context, "/loginPage");
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Link to Login Page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Or',
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
                    Navigator.pushNamed(context, "/loginPage");
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
