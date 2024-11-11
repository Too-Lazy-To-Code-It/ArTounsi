// File: lib/pages/Learning/add_course_tab.dart
import 'package:flutter/material.dart';
import '../../services/Learning/learning_service.dart';
import '../../services/Learning//image_upload_service.dart';

class AddCourseTab extends StatefulWidget {
  @override
  _AddCourseTabState createState() => _AddCourseTabState();
}

class _AddCourseTabState extends State<AddCourseTab> {
  final _formKey = GlobalKey<FormState>();
  final LearningService _learningService = LearningService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  String title = '', description = '', imageUrl = '';
  List<String> modules = [''];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Course Title'),
              validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => title = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              onSaved: (value) => description = value!,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Upload Image'),
              onPressed: _uploadImage,
            ),
            if (imageUrl.isNotEmpty)
              Image.network(imageUrl, height: 100, width: 100, fit: BoxFit.cover),
            SizedBox(height: 16.0),
            Text('Modules:', style: Theme.of(context).textTheme.titleMedium),
            ...modules.asMap().entries.map((entry) {
              int idx = entry.key;
              String module = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Module ${idx + 1}'),
                      initialValue: module,
                      onChanged: (value) {
                        setState(() {
                          modules[idx] = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () {
                      setState(() {
                        modules.removeAt(idx);
                      });
                    },
                  ),
                ],
              );
            }).toList(),
            ElevatedButton(
              child: Text('Add Module'),
              onPressed: () {
                setState(() {
                  modules.add('');
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Add Course'),
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  void _uploadImage() async {
    String? uploadedImageUrl = await _imageUploadService.pickAndUploadImage();
    if (uploadedImageUrl != null) {
      setState(() {
        imageUrl = uploadedImageUrl;
      });
    } else {
      // Handle the case where image upload failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (imageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload an image for the course')),
        );
        return;
      }
      _addNewCourse();
    }
  }

  void _addNewCourse() async {
    try {
      await _learningService.addNewCourse(title, description, imageUrl, modules);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course added successfully')),
      );
      // Clear the form
      setState(() {
        title = '';
        description = '';
        imageUrl = '';
        modules = [''];
      });
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add course: $e')),
      );
    }
  }
}