class Course {
  String id;
  String title;
  String type; // e.g., 'course', 'video', 'workshop'
  int progress;

  Course({
    required this.id,
    required this.title,
    required this.type,
    required this.progress,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'progress': progress,
    };
  }

  static Course fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      progress: map['progress'] as int,
    );
  }
}
