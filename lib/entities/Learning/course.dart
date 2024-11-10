// File: lib/entities/learning/course.dart
class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String imageUrl;
  final List<String> modules;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.imageUrl,
    required this.modules,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructor: map['instructor'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      modules: List<String>.from(map['modules'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'imageUrl': imageUrl,
      'modules': modules,
    };
  }
  @override
  String toString() {
    return 'Course{id: $id, title: $title, instructor: $instructor}';
  }
}