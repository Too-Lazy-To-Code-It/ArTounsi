import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../entities/Event/Events.dart';
import 'dart:io';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {
    try {
      String fileName = 'events/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> addEvent(Event event, File image) async {
    try {
      String imageUrl = await uploadImage(image);
      Event newEvent = Event(event.title, imageUrl, event.date, event.description);
      await _db.collection('events').add(newEvent.toMap());
    } catch (e) {
      print('Error adding event: $e');
      throw Exception('Failed to add event: $e');
    }
  }


  /*Future<List<Event>> getEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) {
        return Event(
          doc['title'] ?? '',
          doc['imageUrl'] ?? '',
          (doc['date'] as Timestamp).toDate(),
          doc['description'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }*/
}
