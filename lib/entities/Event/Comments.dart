class Comment {
  final String name;
  final String comment;

  Comment({
    required this.name,
    required this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'comment': comment,
    };
  }

  factory Comment.fromFirestore(Map<String, dynamic> data) {
    return Comment(
      name: data['name'],
      comment: data['comment'],
    );
  }
}
