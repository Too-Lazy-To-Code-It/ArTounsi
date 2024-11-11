import 'package:Artounsi/pages/User/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../entities/Shop/Cart.dart';
import '../MainScreen/main_screen.dart';

class Session extends StatelessWidget {
   Session({super.key});

  final Cart cart = Cart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges() ,
        builder : (context, snapshot){
          if(snapshot.hasData){
            return  MainScreen();
          }else{
            return LoginPage();
          }
        }
      )
    );
  }
}
