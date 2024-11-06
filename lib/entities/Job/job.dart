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

  // Create a Job instance from a Map with null checks
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] ?? '', // Default to empty string if null
      title: map['title'] ?? '', // Default to empty string if null
      description: map['description'] ?? '', // Default to empty string if null
      mainImagePath: map['mainImagePath'] ?? '', // Default to empty string if null
      additionalImagePaths: List<String>.from(map['additionalImagePaths'] ?? []),
      JobLink: map['JobLink'] ?? '', // Default to empty string if null
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
