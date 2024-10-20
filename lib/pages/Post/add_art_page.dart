import 'package:flutter/material.dart';

class AddArtPage extends StatelessWidget {
  const AddArtPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Art'),
      ),
      body: const Center(
        child: Text('Add Art Page - Implement your form here'),
      ),
    );
  }
}