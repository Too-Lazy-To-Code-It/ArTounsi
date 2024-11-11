// File: lib/pages/Learning/courses_tab.dart
import 'package:flutter/material.dart';
import '../../services/Learning/learning_service.dart';
import '../../entities/learning/course.dart';
import 'course_card.dart';

class CoursesTab extends StatefulWidget {
  @override
  _CoursesTabState createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  final LearningService _learningService = LearningService();
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search courses...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Course>>(
            stream: _learningService.getAllCoursesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No courses available'));
              }

              List<Course> filteredCourses = snapshot.data!.where((course) =>
              course.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                  course.description.toLowerCase().contains(_searchTerm.toLowerCase())
              ).toList();

              if (filteredCourses.isEmpty) {
                return Center(child: Text('No courses match your search'));
              }

              return ListView.builder(
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  Course course = filteredCourses[index];
                  return CourseCard(course: course);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}