import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditArtworkPage.dart';

class DetailsPage extends StatefulWidget {
  final String artworkId;

  const DetailsPage({Key? key, required this.artworkId}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<DocumentSnapshot> _artworkFuture;

  @override
  void initState() {
    super.initState();
    _artworkFuture = FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get();
  }

  void _handleArtworkUpdated(Map<String, dynamic> updatedArtwork) {
    setState(() {
      _artworkFuture = FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artwork Details'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _artworkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Artwork not found'));
          }

          Map<String, dynamic> artwork = snapshot.data!.data() as Map<String, dynamic>;
          artwork['id'] = snapshot.data!.id;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  artwork['imageUrl'],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork['title'],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(artwork['description']),
                      SizedBox(height: 16),
                      Text('Software Used: ${artwork['softwareUsed']}'),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: (artwork['tags'] as List<dynamic>).map((tag) => Chip(label: Text(tag))).toList(),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditArtworkPage(
                                artwork: artwork,
                                onArtworkUpdated: _handleArtworkUpdated,
                              ),
                            ),
                          );
                        },
                        child: Text('Edit Artwork'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}