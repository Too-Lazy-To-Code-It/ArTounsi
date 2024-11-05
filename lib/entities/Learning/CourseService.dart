import 'package:cloud_firestore/cloud_firestore.dart';
import 'courses.dart'; // Assuming you have a Course class defined

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a course
  Future<void> addCourse(Course course) async {
    await _firestore.collection('courses').add(course.toMap());
  }

  // Read all courses
  Stream<List<Course>> getCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Course.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update a course
  Future<void> updateCourse(Course course) async {
    await _firestore.collection('courses').doc(course.id).update(course.toMap());
  }

  // Delete a course
  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection('courses').doc(courseId).delete();
  }
}
