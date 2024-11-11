import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth for username
import '../../entities/Event/Events.dart';
import 'dart:io';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  Future<String> fetchUserData() async {
    print("inside fetchUserData");
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user is logged in');
        return 'Unknown';
      }
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        String username = userData?['username'] ?? 'Unknown';
        return username;
      } else {
        print('User document not found');
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'Unknown';
    }
  }

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

      String username = await fetchUserData();
      String imageUrl = await uploadImage(image);

      Events newEvent = Events('', event.title, imageUrl, event.date, event.description, event.location, username);

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

  // Function to modify an event in Firestore
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

      String username = await fetchUserData();  // Get the username

      final updatedData = {
        'title': updatedEvent.title,
        'imageUrl': imageUrl ?? '',
        'date': updatedEvent.date,
        'description': updatedEvent.description,
        'location': updatedEvent.location,
        'username': username,
      };

      await _db.collection('events').doc(eventId).update(updatedData);
    } catch (e) {
      print('Error modifying event: $e');
      throw Exception('Failed to modify event: $e');
    }
  }

  // Function to fetch all events from Firestore
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
