import 'package:Artounsi/pages/Post/home_page.dart';
import 'package:Artounsi/pages/User/login_page.dart';
import 'package:Artounsi/pages/User/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'pages/MainScreen/main_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ArTounsi());
}

class ArTounsi extends StatelessWidget {
  const ArTounsi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArTounsi',
      theme: AppTheme.darkTheme,
      home: LoginPage(),
      routes: {
        "/loginPage": (BuildContext context) => LoginPage(),
        "/registerPage": (BuildContext context) => RegisterPage(),
        "/mainScreen": (BuildContext context) => MainScreen(),
      },
    );
  }
}