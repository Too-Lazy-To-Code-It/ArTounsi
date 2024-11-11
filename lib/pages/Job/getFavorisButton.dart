import 'package:Artounsi/pages/Job/FavorisPopup.dart';
import 'package:flutter/material.dart';

class GetFavoris extends StatelessWidget {
  final String userId;

  const GetFavoris({
    Key? key,
    required this.userId,
  }) : super(key: key);

  void _showFavorisPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FavorisPopup(userId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      bottom: 65,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloatingActionButton(
            context: context,
            onPressed: () => _showFavorisPopup(context),
            icon: Icons.favorite_rounded,
            buttonColor: Colors.purple,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required Color buttonColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: buttonColor,
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
            color: iconColor,
          ),
        ),
      ),
    );
  }
}