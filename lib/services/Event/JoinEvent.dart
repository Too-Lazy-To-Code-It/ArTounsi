import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class joinevent {
  Future<bool> checkIfUserJoined(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No current user');
        return false;
      }
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('User document not found');
        return false;
      }
      final userData = querySnapshot.docs.first.data();
      final eventSnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
      if (eventSnapshot.exists) {
        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        final joinedMembers = List.from(eventData['joinedMembers'] ?? []);
        bool isUserAlreadyJoined = joinedMembers.any((member) => member['username'] == userData['username']);
        return isUserAlreadyJoined;
      }
      return false;
    } catch (e) {
      print('Error checking if user joined event: $e');
      return false;
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No current user');
        return;
      }
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('User document not found');
        return;
      }
      final userData = querySnapshot.docs.first.data();
      final currentDate = DateTime.now().toIso8601String();
      final eventSnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
      if (eventSnapshot.exists) {
        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        final joinedMembers = List.from(eventData['joinedMembers'] ?? []);
        bool isUserAlreadyJoined = joinedMembers.any((member) => member['username'] == userData['username']);
        if (isUserAlreadyJoined) {
          print('User has already joined the event');
          return;
        }
      }
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'joinedMembers': FieldValue.arrayUnion([
          {
            'username': userData['username'],
            'joinedAt': currentDate,
          }
        ]),
      });

      print('User joined the event successfully');
    } catch (e) {
      print('Error joining event: $e');
    }
  }
}
