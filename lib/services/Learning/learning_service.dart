import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../entities/learning/course.dart';
import '../../entities/learning/user_progress.dart';

class LearningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> ensureAuthenticated() async {
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
        print("Signed in anonymously");
      } catch (e) {
        print("Error signing in anonymously: $e");
        throw e;
      }
    }
  }

  Stream<List<UserProgress>> getUserProgressStream() {
    return _firestore
        .collection('user_progress')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      print("Received ${snapshot.docs.length} user progress documents");
      return snapshot.docs
          .map((doc) => UserProgress.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<Course>> getAllCoursesStream() {
    print("Starting getAllCoursesStream");
    return _firestore.collection('courses').snapshots().map((snapshot) {
      print("Received snapshot with ${snapshot.docs.length} documents");
      return snapshot.docs.map((doc) {
        print("Processing document: ${doc.id}");
        return Course.fromMap({'id': doc.id, ...doc.data() as Map<String, dynamic>});
      }).toList();
    });
  }

  Future<Course> getCourse(String courseId) async {
    var courseData = await _firestore.collection('courses').doc(courseId).get();
    return Course.fromMap(courseData.data()!);
  }

  Future<String> getCurrentUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return (userDoc.data() as Map<String, dynamic>)['username'] ?? user.email ?? 'Unknown User';
        } else {
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.email ?? 'User${user.uid.substring(0, 5)}',
            'email': user.email,
          });
          return user.email ?? 'User${user.uid.substring(0, 5)}';
        }
      } catch (e) {
        print("Error fetching or creating user document: $e");
        return user.email ?? 'Unknown User';
      }
    }
    return 'Unknown User';
  }

  Future<void> addNewCourse(String title, String description, String imageUrl, List<String> modules) async {
    try {
      await ensureAuthenticated();
      String instructor = await getCurrentUsername();
      DocumentReference docRef = await _firestore.collection('courses').add({
        'title': title,
        'description': description,
        'instructor': instructor,
        'imageUrl': imageUrl,
        'modules': modules,
      });
      print("Added new course with ID: ${docRef.id}");
      _firestore.collection('courses').snapshots();
    } catch (e) {
      print("Error adding new course: $e");
      rethrow;
    }
  }

  Future<void> enrollInCourse(Course course) async {
    await ensureAuthenticated();
    String userId = _auth.currentUser!.uid;

    bool isEnrolled = await isEnrolledInCourse(course.id);

    if (isEnrolled) {
      throw Exception('You are already enrolled in this course');
    }

    UserProgress userProgress = UserProgress(
      userId: userId,
      courseId: course.id,
      completedModules: [],
      overallProgress: 0.0,
    );

    await _firestore.collection('user_progress').add(userProgress.toMap());
    print("Enrolled in course: ${course.title}");
  }

  Future<void> updateModuleProgress(UserProgress progress, String module, bool completed) async {
    try {
      await ensureAuthenticated();
      String userId = _auth.currentUser!.uid;

      QuerySnapshot progressDocs = await _firestore
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: progress.courseId)
          .get();

      if (progressDocs.docs.isEmpty) {
        throw Exception('User progress not found');
      }

      DocumentReference progressRef = progressDocs.docs.first.reference;

      List<String> updatedModules = List.from(progress.completedModules);
      if (completed) {
        updatedModules.add(module);
      } else {
        updatedModules.remove(module);
      }

      DocumentSnapshot courseDoc = await _firestore.collection('courses').doc(progress.courseId).get();
      int totalModules = (courseDoc.data() as Map<String, dynamic>)['modules'].length;

      double newOverallProgress = updatedModules.length / totalModules;

      await progressRef.update({
        'completedModules': updatedModules,
        'overallProgress': newOverallProgress,
      });

      // Update the progress object
      progress.updateProgress(
        updatedModules: updatedModules,
        updatedProgress: newOverallProgress,
      );

      print("Updated progress for course: ${progress.courseId}, module: $module");
    } catch (e) {
      print("Error updating module progress: $e");
      rethrow;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await ensureAuthenticated();
      DocumentSnapshot courseDoc = await _firestore.collection('courses').doc(courseId).get();

      if (!courseDoc.exists) throw Exception("Course not found");

      String instructor = courseDoc['instructor'];
      String currentUser = await getCurrentUsername();

      if (instructor != currentUser) {
        throw Exception("Only the course instructor can delete this course");
      }

      await _firestore.collection('courses').doc(courseId).delete();
      print("Course deleted successfully: $courseId");

    } catch (e) {
      print("Error deleting course: $e");
      rethrow;
    }
  }

  Future<void> updateCourse(String courseId, String title, String description, String imageUrl, List<String> modules) async {
    try {
      await ensureAuthenticated();
      DocumentSnapshot courseDoc = await _firestore.collection('courses').doc(courseId).get();

      if (!courseDoc.exists) throw Exception("Course not found");

      String instructor = courseDoc['instructor'];
      String currentUser = await getCurrentUsername();

      if (instructor != currentUser) {
        throw Exception("Only the course instructor can update this course");
      }

      await _firestore.collection('courses').doc(courseId).update({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'modules': modules,
      });
      print("Course updated successfully: $courseId");

    } catch (e) {
      print("Error updating course: $e");
      rethrow;
    }
  }

  Future<bool> isEnrolledInCourse(String courseId) async {
    await ensureAuthenticated();
    String userId = _auth.currentUser!.uid;

    QuerySnapshot progressDocs = await _firestore
        .collection('user_progress')
        .where('userId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .get();

    return progressDocs.docs.isNotEmpty;
  }
}