class Comment {
  final String id;
  final String name;
  final String comment;
  final String eventId;

  Comment({
    required this.id,
    required this.name,
    required this.comment,
    required this.eventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'comment': comment,
      'eventId': eventId,
    };
  }

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment(
      id: id, // Extract id from parameters
      name: data['name'],
      comment: data['comment'],
      eventId: data['eventId'],
    );
  }
}
