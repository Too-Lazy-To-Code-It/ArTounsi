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

  Future<String> addEvent(Event event, File image) async {
    try {
      String imageUrl = await uploadImage(image);
      Event newEvent = Event(event.title, imageUrl, event.date, event.description);
      DocumentReference docRef = await _db.collection('events').add(newEvent.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding event: $e');
      throw Exception('Failed to add event: $e');
    }
  }

  Future<void> deleteEvent(DocumentReference eventRef) async {
    try {
      DocumentSnapshot doc = await eventRef.get();
      if (doc.exists) {
        String imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'];

        if (imageUrl.isNotEmpty) {
          String fileName = imageUrl.split('%2F').last.split('?').first;
          await _storage.ref().child('events/$fileName').delete();
        }

        // Delete the event from Firestore
        await eventRef.delete();
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<void> modifyEvent(DocumentReference eventRef, Event updatedEvent, {File? newImage}) async {
    try {
      // Check if a new image is provided
      String? imageUrl;
      if (newImage != null) {
        imageUrl = await uploadImage(newImage);
      } else {
        // If no new image, retrieve the existing image URL
        DocumentSnapshot doc = await eventRef.get();
        if (doc.exists) {
          imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'];
        }
      }

      // Prepare the updated event data
      final updatedData = {
        'title': updatedEvent.title,
        'imageUrl': imageUrl ?? '', // Use existing image if not updated
        'date': updatedEvent.date,
        'description': updatedEvent.description,
      };

      // Update the event in Firestore
      await eventRef.update(updatedData);
    } catch (e) {
      print('Error modifying event: $e');
      throw Exception('Failed to modify event: $e');
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
