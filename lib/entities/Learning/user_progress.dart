// File: lib/entities/learning/user_progress.dart
class UserProgress {
  final String userId;
  final String courseId;
  final List<String> completedModules;
  final double overallProgress;

  UserProgress({
    required this.userId,
    required this.courseId,
    required this.completedModules,
    required this.overallProgress,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      completedModules: List<String>.from(map['completedModules'] ?? []),
      overallProgress: map['overallProgress']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completedModules': completedModules,
      'overallProgress': overallProgress,
    };
  }
}