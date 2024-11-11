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

  Future<String> addEvent(Events event, File image) async {
    try {
      String imageUrl = await uploadImage(image);
      Events newEvent = Events('', event.title, imageUrl, event.date, event.description, event.location);
      DocumentReference docRef = await _db.collection('events').add(newEvent.toMap());
      newEvent.id = docRef.id;
      await _db.collection('events').doc(docRef.id).update({'id': newEvent.id});
      return newEvent.id;
    } catch (e) {
      print('Error adding event: $e');
      throw Exception('Failed to add event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      DocumentSnapshot doc = await _db.collection('events').doc(eventId).get();
      if (doc.exists) {
        String imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'];

        if (imageUrl.isNotEmpty) {
          String fileName = imageUrl.split('%2F').last.split('?').first;
          await _storage.ref().child('events/$fileName').delete();
        }

        await _db.collection('events').doc(eventId).delete();
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<void> modifyEvent(String eventId, Events updatedEvent, {File? newImage}) async {
    try {
      String? imageUrl;
      if (newImage != null) {
        imageUrl = await uploadImage(newImage);
      } else {
        DocumentSnapshot doc = await _db.collection('events').doc(eventId).get();
        if (doc.exists) {
          imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'] as String?;
        }
      }

      final updatedData = {
        'title': updatedEvent.title,
        'imageUrl': imageUrl ?? '',
        'date': updatedEvent.date,
        'description': updatedEvent.description,
        'location': updatedEvent.location,
      };

      await _db.collection('events').doc(eventId).update(updatedData);
    } catch (e) {
      print('Error modifying event: $e');
      throw Exception('Failed to modify event: $e');
    }
  }

  Future<List<Events>> getEvents() async {
    try {
      QuerySnapshot snapshot = await _db.collection('events').get();
      return snapshot.docs.map((doc) => Events.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }
}
