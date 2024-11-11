import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressedAdd;
  final VoidCallback onPressedSubtract;

  const CustomFloatingActionButton({
    Key? key,
    required this.onPressedAdd,
    required this.onPressedSubtract,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloatingActionButton(
            context: context,
            onPressed: onPressedAdd,
            icon: Icons.vertical_shades_closed_outlined,
            buttonColor: Colors.purple, // Custom color for the button
            iconColor: Colors.white, // Custom color for the icon
          ),
          SizedBox(height: 5),
          _buildFloatingActionButton(
            context: context,
            onPressed: onPressedSubtract,
            icon: Icons.horizontal_split_rounded,
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
