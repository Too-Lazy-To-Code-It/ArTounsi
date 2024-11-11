import 'package:cloud_firestore/cloud_firestore.dart';

class Events {
  String id;
  String title;
  String imageUrl;
  DateTime date;
  String description;
  String location; // New field for location

  Events(this.id, this.title, this.imageUrl, this.date, this.description, this.location);

  factory Events.fromMap(String id, Map<String, dynamic> map) {
    return Events(
      id,
      map['title'] ?? 'Untitled Event',
      map['imageUrl'] ?? '',
      map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      map['description'] ?? 'No description available',
      map['location'] ?? 'No location specified', // Add location with a default value
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'date': date,
      'description': description,
      'location': location, // Include location in the map
    };
  }
}
