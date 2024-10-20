import 'package:Artounsi/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String? _email;
  String? _code;
  bool _isVisible = false;

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>(); // Separate key for email form field
  final GlobalKey<FormState> _codeFormKey = GlobalKey<FormState>();  // Separate key for code form field

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 30),
          const Icon(
            Icons.lock,
            size: 100,
          ),
          const SizedBox(height: 20),

          // Email Form
          Form(
            key: _emailFormKey,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
                onSaved: (String? value) {
                  _email = value;
                },
                validator: (String? value) {
                  RegExp regex = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
                  );
                  if (value!.isEmpty || !regex.hasMatch(value)) {
                    return "Email must have valid form";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),

          // Code Form (Initially Hidden)
          Visibility(
            visible: _isVisible, // Control visibility of the code input field
            child: Form(
              key: _codeFormKey,
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Code",
                  ),
                  onSaved: (String? value) {
                    _code = value;
                  },
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "The code can't be empty";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("Send Mail"),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                ),
                onPressed: () {
                  if (_emailFormKey.currentState!.validate()) {
                    _emailFormKey.currentState!.save();
                    setState(() {
                      _isVisible = true; // Show code input after email is valid
                    });
                  }
                },
              ),
              const SizedBox(width: 30),
              Visibility(
                visible: _isVisible, // Only show the "Enter Code" button if the code field is visible
                child: ElevatedButton(
                  child: const Text("Enter Code"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                  ),
                  onPressed: () {
                    if (_codeFormKey.currentState!.validate()) {
                      _codeFormKey.currentState!.save();
                      Navigator.pushNamed(context, "/confirmPasswordPage");
                    }
                  },
                ),
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
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}