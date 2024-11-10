// File: lib/pages/Learning/course_card.dart
import 'package:flutter/material.dart';
import '../../entities/learning/course.dart';
import '../../services/learning_service.dart';
import 'course_details.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final LearningService _learningService = LearningService();

  CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCourseDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildImage(),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Instructor: ${course.instructor}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${course.modules.length} modules',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      ElevatedButton(
                        child: Text('Enroll'),
                        onPressed: () => _enrollInCourse(context),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return course.imageUrl.isNotEmpty
        ? Image.network(
      course.imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey[300],
          child: Icon(Icons.error, color: Colors.red),
        );
      },
    )
        : Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey[600]),
    );
  }

  void _showCourseDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => CourseDetails(course: course, scrollController: controller),
      ),
    );
  }

  void _enrollInCourse(BuildContext context) async {
    try {
      await _learningService.enrollInCourse(course);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully enrolled in ${course.title}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enroll: $e')),
      );
    }
  }
}