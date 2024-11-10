import 'package:Artounsi/pages/Job/FavorisService.dart';
import 'package:flutter/material.dart';

class FavorisPopup extends StatefulWidget {
  final String userId;

  const FavorisPopup({Key? key, required this.userId}) : super(key: key);

  @override
  _FavorisPopupState createState() => _FavorisPopupState();
}

class _FavorisPopupState extends State<FavorisPopup> {
  final FavorisService _favorisService = FavorisService();
  List<Map<String, dynamic>> _favoris = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  Future<void> _loadFavoris() async {
    try {
      final favoris = await _favorisService.getFavorisForUser(widget.userId);
      setState(() {
        _favoris = favoris;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favoris: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavoris(String favorisId) async {
    try {
      await _favorisService.removeFavoris(favorisId);
      setState(() {
        _favoris.removeWhere((favoris) => favoris['id'] == favorisId);
      });
    } catch (e) {
      print('Error removing favoris: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: <Widget>[
          Text(
            "Your Favorites",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 15),
          Flexible(
            fit: FlexFit.loose,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _favoris.isEmpty
                ? Center(child: Text("No favorites yet"))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: _favoris.length,
              itemBuilder: (context, index) {
                final favoris = _favoris[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                          child: Image.network(
                            favoris['url'],
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error, size: 50),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFavoris(favoris['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 15),
          TextButton(
            child: Text(
              "Close",
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}