// File: lib/pages/Learning/courses_tab.dart
import 'package:flutter/material.dart';
import '../../services/learning_service.dart';
import '../../entities/learning/course.dart';
import 'course_card.dart';

class CoursesTab extends StatelessWidget {
  final LearningService _learningService = LearningService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: _learningService.getAllCoursesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No courses available'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Course course = snapshot.data![index];
            return CourseCard(course: course);
          },
        );
      },
    );
  }
}