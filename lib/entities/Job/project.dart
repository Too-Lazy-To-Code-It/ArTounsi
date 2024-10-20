import 'dart:math';

class Project {
  String id;
  String title;
  String description;
  String mainImagePath;
  List<String> additionalImagePaths;
  String projectLink;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.mainImagePath,
    this.additionalImagePaths = const [],
    this.projectLink = '',
  });

  String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Convert a Project instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mainImagePath': mainImagePath,
      'additionalImagePaths': additionalImagePaths,
      'projectLink': projectLink,
    };
  }

  // Create a Project instance from a Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      mainImagePath: map['mainImagePath'],
      additionalImagePaths: List<String>.from(map['additionalImagePaths']),
      projectLink: map['projectLink'],
    );
  }

  // Create a copy of the Project with updated fields
  Project copyWith({
    String? title,
    String? description,
    String? mainImagePath,
    List<String>? additionalImagePaths,
    String? projectLink,
  }) {
    return Project(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mainImagePath: mainImagePath ?? this.mainImagePath,
      additionalImagePaths: additionalImagePaths ?? this.additionalImagePaths,
      projectLink: projectLink ?? this.projectLink,
    );
  }
}
