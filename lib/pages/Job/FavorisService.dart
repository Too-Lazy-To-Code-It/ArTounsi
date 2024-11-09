import 'package:cloud_firestore/cloud_firestore.dart';

class FavorisService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> addFavoris(String userId, String url) async {
    try {
      DocumentReference docRef = await _db.collection('favoris').add({
        'ref_user': userId,
        'url': url,
      });

      await _db.collection('favoris').doc(docRef.id).update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Error adding favoris: $e');
      throw Exception('Failed to add favoris: $e');
    }
  }

  Future<void> removeFavoris(String favorisId) async {
    try {
      await _db.collection('favoris').doc(favorisId).delete();
    } catch (e) {
      print('Error removing favoris: $e');
      throw Exception('Failed to remove favoris: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavorisForUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _db.collection('favoris')
          .where('ref_user', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching favoris: $e');
      throw Exception('Failed to fetch favoris: $e');
    }
  }

  Future<bool> isFavoris(String userId, String url) async {
    try {
      QuerySnapshot snapshot = await _db.collection('favoris')
          .where('ref_user', isEqualTo: userId)
          .where('url', isEqualTo: url)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking favoris: $e');
      throw Exception('Failed to check favoris: $e');
    }
  }

  Future<void> toggleFavoris(String userId, String url) async {
    try {
      QuerySnapshot snapshot = await _db.collection('favoris')
          .where('ref_user', isEqualTo: userId)
          .where('url', isEqualTo: url)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Favoris exists, remove it
        await removeFavoris(snapshot.docs.first.id);
      } else {
        // Favoris doesn't exist, add it
        await addFavoris(userId, url);
      }
    } catch (e) {
      print('Error toggling favoris: $e');
      throw Exception('Failed to toggle favoris: $e');
    }
  }
}