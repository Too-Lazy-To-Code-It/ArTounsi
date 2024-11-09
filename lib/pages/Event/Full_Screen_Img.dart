import 'package:flutter/material.dart';

class FullscreenImage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  FullscreenImage({required this.imageUrls, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(imageUrls[initialIndex]),
          ),
        ),
      ),
    );
  }
}
