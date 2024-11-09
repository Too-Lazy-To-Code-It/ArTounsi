import 'package:flutter/material.dart';

class Inscpire extends StatelessWidget {
  final VoidCallback APIcall;

  const Inscpire({
    Key? key,
    required this.APIcall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloatingActionButton(
            context: context,
            onPressed: APIcall,
            icon: Icons.search,
            buttonColor: Colors.purple, // Custom color for the button
            iconColor: Colors.white, // Custom color for the icon
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required Color buttonColor, // Custom color for the button
    required Color iconColor, // Custom color for the icon
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40, // Adjust size if needed
        height: 40, // Adjust size if needed
        decoration: BoxDecoration(
          color: buttonColor, // Apply the custom button color
          shape: BoxShape.circle, // Keep it circular
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor, // Apply the custom icon color
          ),
        ),
      ),
    );
  }
}
