import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String title;
  String imageUrl;
  DateTime date;
  String description;

  Event(this.title, this.imageUrl, this.date, this.description);

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      map['title'] ?? 'Untitled Event', // Default title if null
      map['imageUrl'] ?? '',            // Empty string if no image URL
      // Check if date is a Timestamp or a String
      map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      map['description'] ?? 'No description available', // Default description
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'date': date,
      'description': description,
    };
  }
}
