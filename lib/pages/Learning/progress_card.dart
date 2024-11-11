import 'package:flutter/material.dart';
import '../../services/Learning/learning_service.dart';
import '../../entities/learning/course.dart';
import '../../entities/learning/user_progress.dart';

class ProgressCard extends StatefulWidget {
  final UserProgress progress;

  ProgressCard({required this.progress});

  @override
  _ProgressCardState createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  final LearningService _learningService = LearningService();
  late UserProgress _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Course>(
      future: _learningService.getCourse(_progress.courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        Course course = snapshot.data!;

        return Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Text(course.title),
                subtitle: Text('Overall Progress: ${(_progress.overallProgress * 100).toStringAsFixed(2)}%'),
              ),
              LinearProgressIndicator(value: _progress.overallProgress),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Completed Modules: ${_progress.completedModules.length}/${course.modules.length}'),
              ),
              ...course.modules.map((module) => CheckboxListTile(
                title: Text(module),
                value: _progress.completedModules.contains(module),
                onChanged: (bool? value) {
                  _updateModuleProgress(context, module, value ?? false, course);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  void _updateModuleProgress(BuildContext context, String module, bool completed, Course course) async {
    try {
      List<String> updatedModules = List.from(_progress.completedModules);
      if (completed) {
        updatedModules.add(module);
      } else {
        updatedModules.remove(module);
      }

      double updatedProgress = updatedModules.length / course.modules.length;

      await _learningService.updateModuleProgress(_progress, module, completed);

      setState(() {
        _progress.updateProgress(
          updatedModules: updatedModules,
          updatedProgress: updatedProgress,
        );
      });

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