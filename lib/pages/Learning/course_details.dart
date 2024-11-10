// File: lib/pages/Learning/course_details.dart
import 'package:flutter/material.dart';
import '../../entities/learning/course.dart';

class CourseDetails extends StatelessWidget {
  final Course course;
  final ScrollController scrollController;

  CourseDetails({required this.course, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        controller: scrollController,
        children: [
          Text(course.title, style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 8.0),
          Text('Instructor: ${course.instructor}', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 16.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              course.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16.0),
          Text('Description', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8.0),
          Text(course.description, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 24.0),
          Text('Modules', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8.0),
          ...course.modules.asMap().entries.map((entry) {
            int idx = entry.key;
            String module = entry.value;
            return ListTile(
              leading: CircleAvatar(
                child: Text('${idx + 1}'),
              ),
              title: Text(module),
            );
          }).toList(),
        ],
      ),
    );
  }
}