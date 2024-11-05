import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  String imageUrl;
  DateTime date;
  String description;

  Event(this.id, this.title, this.imageUrl, this.date, this.description);

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id,
      map['title'] ?? 'Untitled Event',
      map['imageUrl'] ?? '',
      map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      map['description'] ?? 'No description available',
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
