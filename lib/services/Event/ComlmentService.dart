// services/comment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/Event/Comments.dart';

class CommentService {
  final CollectionReference _commentCollection =
  FirebaseFirestore.instance.collection('comments');

  // Add a comment to Firestore
  Future<void> addComment(Comment comment) async {
    try {
      await _commentCollection.add(comment.toMap()); // Firestore will generate the ID
    } catch (e) {
      // Handle error
      print("Error adding comment: $e");
    }
  }

  // Get all comments from Firestore
  Future<List<Comment>> getComments() async {
    try {
      QuerySnapshot snapshot = await _commentCollection.get();
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Handle error
      print("Error fetching comments: $e");
      return [];
    }
  }

  // Listen for real-time updates to comments
  Stream<List<Comment>> listenToComments() {
    return _commentCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
