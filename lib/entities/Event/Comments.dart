class Comment {
  final String name;
  final String comment;
  final String eventId; // New property

  Comment({
    required this.name,
    required this.comment,
    required this.eventId, // Include eventId in the constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'comment': comment,
      'eventId': eventId, // Include eventId in the map
    };
  }

  factory Comment.fromFirestore(Map<String, dynamic> data) {
    return Comment(
      name: data['name'],
      comment: data['comment'],
      eventId: data['eventId'], // Extract eventId from data
    );
  }
}
