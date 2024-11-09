import 'package:Artounsi/pages/Job/FavorisService.dart';
import 'package:flutter/material.dart';

class Inscpire extends StatelessWidget {
  //final VoidCallback APIcall;
  final String imageUrl;
  const Inscpire({
    Key? key,
   // required this.APIcall,
    required this.imageUrl,
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
            //onPressed: APIcall,
            onPressed: () => _showInspirePopup(context),
            icon: Icons.search,
            buttonColor: Colors.purple, // Custom color for the button
            iconColor: Colors.white, // Custom color for the icon
          ),
        ],
      ),
    );
  }

  void _showInspirePopup(BuildContext context) async {
    // Call the API to get the image URL
    // APIcall();

    // For this example, we'll use a placeholder URL

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedImageDialog(imageUrl: imageUrl);
      },
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




class AnimatedImageDialog extends StatefulWidget {
  final String imageUrl;

  const AnimatedImageDialog({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _AnimatedImageDialogState createState() => _AnimatedImageDialogState();
}

class _AnimatedImageDialogState extends State<AnimatedImageDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final FavorisService _favorisService = FavorisService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeDialog() {
    _controller.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Icon(Icons.error, color: Colors.red, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: _closeDialog,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Inspiring Image",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enjoy this beautiful image from our collection.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.favorite, color: Colors.white),
                          label: Text("Add to Favorites"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            // Add your favorite functionality here
                            // here we change the session user
                            _favorisService.addFavoris("userId", widget.imageUrl);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Added to favorites!")),
                            );
                            _closeDialog();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}