import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/learning/course.dart';
import '../entities/learning/user_progress.dart';

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
    try {
      DocumentSnapshot doc = await _firestore.collection('courses').doc(courseId).get();
      if (!doc.exists) {
        throw Exception("Course not found");
      }
      return Course.fromMap({'id': doc.id, ...doc.data() as Map<String, dynamic>});
    } catch (e) {
      print("Error getting course: $e");
      rethrow;
    }
  }

  Future<String> getCurrentUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return (userDoc.data() as Map<String, dynamic>)['username'] ?? user.email ?? 'Unknown User';
        } else {
          // If the user document doesn't exist, create it with a default username
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.email ?? 'User${user.uid.substring(0, 5)}',
            'email': user.email,
            // Add any other default user fields here
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

      // Refresh the stream
      _firestore.collection('courses').snapshots();
    } catch (e) {
      print("Error adding new course: $e");
      rethrow;
    }
  }

  Future<void> enrollInCourse(Course course) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('user_progress').add({
        'userId': _auth.currentUser?.uid,
        'courseId': course.id,
        'completedModules': [],
        'overallProgress': 0.0,
      });
      print("Enrolled in course: ${course.id}");
    } catch (e) {
      print("Error enrolling in course: $e");
      rethrow;
    }
  }

  Future<void> updateModuleProgress(UserProgress progress, String module, bool completed) async {
    try {
      await ensureAuthenticated();
      List<String> updatedModules = List.from(progress.completedModules);
      if (completed) {
        updatedModules.add(module);
      } else {
        updatedModules.remove(module);
      }

      double overallProgress = updatedModules.length / progress.completedModules.length;

      await _firestore.collection('user_progress').doc(progress.userId).update({
        'completedModules': updatedModules,
        'overallProgress': overallProgress,
      });
      print("Updated progress for course: ${progress.courseId}, module: $module");
    } catch (e) {
      print("Error updating module progress: $e");
      rethrow;
    }
  }
}