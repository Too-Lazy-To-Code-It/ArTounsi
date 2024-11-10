import 'package:Artounsi/pages/MainScreen/main_screen.dart';
import 'package:Artounsi/pages/User/Avatar.dart';
import 'package:Artounsi/pages/User/confirm_password_page.dart';
import 'package:Artounsi/pages/User/forgot_password_page.dart';
import 'package:Artounsi/pages/User/login_page.dart';
import 'package:Artounsi/pages/User/profile_page.dart';
import 'package:Artounsi/pages/User/register_page.dart';
import 'package:Artounsi/pages/User/session.dart';
import 'package:Artounsi/pages/User/update_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'entities/Shop/Cart.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final prefs =  SharedPreferences.getInstance();
  final Cart cart = Cart();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArTounsi',
      theme: AppTheme.darkTheme, // Use the custom light theme
      darkTheme: AppTheme.darkTheme, // Use the custom dark theme
      themeMode: ThemeMode.system, // Or ThemeMode.light or ThemeMode.dark
      debugShowCheckedModeBanner: false,
      home: Session(),
      routes: {
        "/loginPage": (BuildContext context) => LoginPage(),
        "/registerPage": (BuildContext context) => RegisterPage(),
         "/mainScreen": (BuildContext context) => MainScreen(cart: cart,),
        "/forgotPasswordPage": (BuildContext context) => ForgotPasswordPage(),
        "/confirmPasswordPage": (BuildContext context) => ConfirmPasswordPage(),
        "/userPage": (BuildContext context) => UserPage(),
        "/updateUser": (BuildContext context) => UpdateUser(),
      },
    );
  }
}
