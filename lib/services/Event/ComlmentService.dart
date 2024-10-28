import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/Event/Comments.dart';

class CommentService {
  final CollectionReference _commentCollection =
  FirebaseFirestore.instance.collection('comments');

  Future<DocumentReference> addComment(Comment comment) async {
    try {
      DocumentReference docRef = await _commentCollection.add(comment.toMap());
      return docRef;
    } catch (e) {
      print("Error adding comment: $e");
      rethrow;
    }
  }


  Future<List<Comment>> getComments() async {
    try {
      QuerySnapshot snapshot = await _commentCollection.get();
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  Stream<List<Comment>> listenToComments() {
    return _commentCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> deleteComment(DocumentReference commentRef) async {
    try {
      DocumentSnapshot doc = await commentRef.get();
      if (doc.exists) {
        await commentRef.delete();
      }
    } catch (e) {
      print("Error deleting comment: $e");
    }
  }
}
