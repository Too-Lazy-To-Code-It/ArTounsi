import 'package:Artounsi/entities/Shop/Cart.dart';
import 'package:Artounsi/pages/MainScreen/main_screen.dart';
import 'package:Artounsi/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Cart cart = Cart();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArTounsi',
      theme: AppTheme.darkTheme, // Use the custom light theme
      darkTheme: AppTheme.darkTheme, // Use the custom dark theme
      themeMode: ThemeMode.system, // Or ThemeMode.light or ThemeMode.dark
      home: MainScreen(cart: cart),
    );
  }
}