// File: lib/pages/Learning/progress_tab.dart
import 'package:flutter/material.dart';
import '../../services/learning_service.dart';
import '../../entities/learning/user_progress.dart';
import 'progress_card.dart';

class ProgressTab extends StatelessWidget {
  final LearningService _learningService = LearningService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserProgress>>(
      stream: _learningService.getUserProgressStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('You haven\'t enrolled in any courses yet'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            UserProgress progress = snapshot.data![index];
            return ProgressCard(progress: progress);
          },
        );
      },
    );
  }
}