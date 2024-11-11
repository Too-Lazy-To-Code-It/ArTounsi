import 'package:cloud_firestore/cloud_firestore.dart';

class Events {
  String id;
  String title;
  String imageUrl;
  DateTime date;
  String description;
  String location;
  String username; // Add the username field

  Events(this.id, this.title, this.imageUrl, this.date, this.description, this.location, this.username);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'date': date,
      'description': description,
      'location': location,
      'username': username, // Include the username here
    };
  }

  factory Events.fromMap(String id, Map<String, dynamic> map) {
    return Events(
      id,
      map['title'],
      map['imageUrl'],
      (map['date'] as Timestamp).toDate(),
      map['description'],
      map['location'],
      map['username'], // Add username to the factory method
    );
  }
}

