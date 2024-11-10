// File: lib/pages/Learning/progress_card.dart
import 'package:flutter/material.dart';
import '../../services/learning_service.dart';
import '../../entities/learning/course.dart';
import '../../entities/learning/user_progress.dart';

class ProgressCard extends StatelessWidget {
  final UserProgress progress;
  final LearningService _learningService = LearningService();

  ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Course>(
      future: _learningService.getCourse(progress.courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        Course course = snapshot.data!;
        return Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Text(course.title),
                subtitle: Text('Overall Progress: ${(progress.overallProgress * 100).toStringAsFixed(2)}%'),
              ),
              LinearProgressIndicator(value: progress.overallProgress),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Completed Modules: ${progress.completedModules.length}/${course.modules.length}'),
              ),
              ...course.modules.map((module) => CheckboxListTile(
                title: Text(module),
                value: progress.completedModules.contains(module),
                onChanged: (bool? value) {
                  _updateModuleProgress(context, module, value ?? false);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  void _updateModuleProgress(BuildContext context, String module, bool completed) async {
    try {
      await _learningService.updateModuleProgress(progress, module, completed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progress updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: $e')),
      );
    }
  }
}