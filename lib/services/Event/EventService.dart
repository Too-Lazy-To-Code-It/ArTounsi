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
      final ref = _storage.ref().child(fileName);
      TaskSnapshot snapshot = await ref.putFile(image);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
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

  Future<List<Event>> getEvents() async {
    try {
      QuerySnapshot snapshot = await _db.collection('events').get();
      return snapshot.docs.map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

}
