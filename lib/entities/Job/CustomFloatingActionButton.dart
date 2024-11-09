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
      left: 20,
      bottom: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloatingActionButton(
            context: context,
            onPressed: onPressedAdd,
            icon: Icons.add,
          ),
          SizedBox(height: 5),
          _buildFloatingActionButton(
            context: context,
            onPressed: onPressedSubtract,
            icon: Icons.remove,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
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
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
