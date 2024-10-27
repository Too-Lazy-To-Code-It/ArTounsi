import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/Event/Events.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(Event event) async {
    try {
      await _firestore.collection('events').add({
        'title': event.title,
        'imagePath': event.imageUrl,
        'date': event.date.toIso8601String(),
        'description': event.description,
      });
    } catch (e) {
      print("Error adding event: $e");
      throw e;
    }
  }
}
