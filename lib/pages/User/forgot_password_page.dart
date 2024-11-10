import 'package:Artounsi/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late String? _email;
  late String? _code;
  final _emailcontroller = TextEditingController();
  bool _isVisible = false;

  GlobalKey<FormState> _emailFormKey =
  GlobalKey<FormState>(); // Separate key for email form field
  GlobalKey<FormState> _codeFormKey =
  GlobalKey<FormState>(); // Separate key for code form field

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailcontroller.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Check your email to reset your password"),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    super.dispose();
  }

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
                controller: _emailcontroller,
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
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (value!.isEmpty || !regex.hasMatch(value)) {
                    return "Email must have valid form";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),


          const SizedBox(height: 30),

          // Send Mail Button
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
                    passwordReset();
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
