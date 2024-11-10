import 'package:Artounsi/entities/Shop/Cart.dart';
import 'package:Artounsi/pages/MainScreen/main_screen.dart';
import 'package:Artounsi/pages/User/session.dart';
import 'package:Artounsi/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key:key);

  @override
  State<LoginPage> createState()=> _LoginPageState();
  }

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    late String? _email;
    late String? _password;
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    final Cart cart = Cart();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    Future Login() async {
     await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());

      if (_keyForm.currentState!.validate()) {
        _keyForm.currentState!.save();
        // Navigator.pushNamed(context, "/mainScreen");
       await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Session(),
          ),
        );
      }
    }

    @override
    void dispose(){
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Form(
        key: _keyForm,
        child: SafeArea(
          child: SingleChildScrollView(
            // Wrap the entire body with SingleChildScrollView
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
                      controller: _emailController,
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

                  const SizedBox(height: 10),

                  // password textfield
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                      ),
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
                        InkWell(
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, "/forgotPasswordPage");
                          },
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
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppTheme.primaryColor),
                      ),
                      child: const Text("Login"),
                      onPressed: () {                          Login();


                      },
                    ),
                  ),

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
        ),
      ),
    );
  }
}
