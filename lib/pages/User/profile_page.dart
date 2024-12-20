import 'package:Artounsi/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? _userImage;
  Map<String, dynamic>? userData;
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print("inside fetchUserData");
    try {
      // Query Firestore to get the user document by email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      print("querySnapshot ${querySnapshot}");

      print("querySnapshot.docs.isNotEmpty ${querySnapshot.docs.isNotEmpty}");
      print("querySnapshot.docs.first.data() ${querySnapshot.docs.first.data()}");

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userData = querySnapshot.docs.first.data();
          _userImage = userData?['image'] ?? ''; // if no image, set empty string
          print("userData ${userData}");

        });
      } else {
        // Handle the case where the user document was not found
        print('User document not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 30), // Add vertical padding
        children: [
          Center(
            child: _userImage == null || _userImage!.isEmpty
                ? const CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('assets/images/img.png'),
            )
                : CircleAvatar(
              radius: 100,
              backgroundImage: NetworkImage(_userImage!),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              Text(
                userData?['email'] ?? 'no email available',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              Text(
                userData?['username'] ?? 'no email username',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userData?['following']?.toString() ?? '0',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        'Following',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userData?['followers']?.toString() ?? '0',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        'Followers',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData?['summary'] ?? 'No summary available',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}