// File: lib/pages/Learning/learning_page.dart
import 'package:flutter/material.dart';
import 'courses_tab.dart';
import 'progress_tab.dart';
import 'add_course_tab.dart';

class LearningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.school), text: 'Courses'),
              Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Add Course'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: TabBarView(
          children: [
            CoursesTab(),
            ProgressTab(),
            AddCourseTab(),
          ],
        ),
      ),
    );
  }
}