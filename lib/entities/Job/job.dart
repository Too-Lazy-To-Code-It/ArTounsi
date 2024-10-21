import 'dart:math';

class Job {
  String id;
  String title;
  String description;
  String mainImagePath;
  List<String> additionalImagePaths;
  String JobLink;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.mainImagePath,
    this.additionalImagePaths = const [],
    this.JobLink = '',
  });

  String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Convert a Job instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mainImagePath': mainImagePath,
      'additionalImagePaths': additionalImagePaths,
      'JobLink': JobLink,
    };
  }

  // Create a Job instance from a Map
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      mainImagePath: map['mainImagePath'],
      additionalImagePaths: List<String>.from(map['additionalImagePaths']),
      JobLink: map['JobLink'],
    );
  }

  // Create a copy of the Job with updated fields
  Job copyWith({
    String? title,
    String? description,
    String? mainImagePath,
    List<String>? additionalImagePaths,
    String? JobLink,
  }) {
    return Job(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mainImagePath: mainImagePath ?? this.mainImagePath,
      additionalImagePaths: additionalImagePaths ?? this.additionalImagePaths,
      JobLink: JobLink ?? this.JobLink,
    );
  }
}
