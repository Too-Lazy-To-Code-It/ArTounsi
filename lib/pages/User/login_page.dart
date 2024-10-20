import 'package:Artounsi/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    late String? _username;
    late String? _password;
    final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Form(
        key: _keyForm,
        child : SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // logo
              Image.asset(
                'assets/images/logo.png',
                width: 300, // Set the size of the image
                height: 300,
              ),

              // welcome back, you've been missed!
              Text(
                'Welcome back you\'ve been missed!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Username"),
                  onSaved: (String? value) {
                    _username = value;
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Username can't be empty";
                    } else if (value.length < 5) {
                      return "Username can't have less than 5 characters";
                    } else {
                      return null;
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // password textfield
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Password"),
                  onSaved: (String? value) {
                    _password = value;
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Password can't be empty";
                    } else {
                      return null;
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // sign in button

              Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColor),
                    ),
                    child: const Text("Login"),
                    onPressed: () {
                      if (_keyForm.currentState!.validate()) {
                        _keyForm.currentState!.save();

                        Navigator.pushNamed(context, "/mainScreen");
                      }
                    },
                  )),

              const SizedBox(height: 50),

              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/registerPage");
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      )
    );
  }
}