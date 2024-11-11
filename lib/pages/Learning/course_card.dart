import 'package:flutter/material.dart';
import '../../entities/learning/course.dart';
import '../../services/Learning/learning_service.dart';
import 'course_details.dart';
import '../../services/Learning//image_upload_service.dart';

class CourseCard extends StatefulWidget {
  final Course course;

  CourseCard({required this.course});

  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  final LearningService _learningService = LearningService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  late Course _course;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    _checkEnrollmentStatus();
  }

  void _checkEnrollmentStatus() async {
    bool enrolled = await _learningService.isEnrolledInCourse(_course.id);
    setState(() {
      _isEnrolled = enrolled;
    });
  }

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
                    _course.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Instructor: ${_course.instructor}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _course.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_course.modules.length} modules',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      ElevatedButton(
                        child: Text(_isEnrolled ? 'Enrolled' : 'Enroll'),
                        onPressed: _isEnrolled ? null : () => _enrollInCourse(context),
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
            FutureBuilder<String>(
              future: _learningService.getCurrentUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasData && snapshot.data == _course.instructor) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpdateDialog(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteCourse(context),
                      ),
                    ],
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return _course.imageUrl.isNotEmpty
        ? Image.network(
      _course.imageUrl,
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
        builder: (_, controller) => CourseDetails(course: _course, scrollController: controller),
      ),
    );
  }

  void _enrollInCourse(BuildContext context) async {
    try {
      await _learningService.enrollInCourse(_course);
      setState(() {
        _isEnrolled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully enrolled in ${_course.title}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enroll: $e')),
      );
    }
  }

  void _showUpdateDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String updatedTitle = _course.title;
    String updatedDescription = _course.description;
    String updatedImageUrl = _course.imageUrl;
    List<String> updatedModules = List.from(_course.modules);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Update Course"),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: updatedTitle,
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                        onSaved: (value) => updatedTitle = value!,
                      ),
                      TextFormField(
                        initialValue: updatedDescription,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                        onSaved: (value) => updatedDescription = value!,
                      ),
                      ElevatedButton(
                        child: Text('Update Image'),
                        onPressed: () async {
                          String? newImageUrl = await _imageUploadService.pickAndUploadImage();
                          if (newImageUrl != null) {
                            setState(() {
                              updatedImageUrl = newImageUrl;
                            });
                          }
                        },
                      ),
                      if (updatedImageUrl.isNotEmpty)
                        Image.network(updatedImageUrl, height: 100, width: 100, fit: BoxFit.cover),
                      ElevatedButton(
                        child: Text('Update Course'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _learningService.updateCourse(_course.id, updatedTitle, updatedDescription, updatedImageUrl, updatedModules);
                            setState(() {
                              _course = Course(
                                id: _course.id,
                                title: updatedTitle,
                                description: updatedDescription,
                                imageUrl: updatedImageUrl,
                                modules: updatedModules,
                                instructor: _course.instructor,
                              );
                            });
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCourse(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Course"),
          content: Text("Are you sure you want to delete this course?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                _learningService.deleteCourse(_course.id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}