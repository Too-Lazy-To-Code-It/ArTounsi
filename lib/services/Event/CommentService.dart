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

  Future<List<Comment>> getCommentsForEvent(String eventId) async {
    try {
      QuerySnapshot snapshot =
      await _commentCollection.where('eventId', isEqualTo: eventId).get();
      return snapshot.docs.map((doc) {
        return Comment.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching comments for event: $e");
      return [];
    }
  }

  DocumentReference getCommentReference(String commentId) {
    return _commentCollection.doc(commentId);
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
