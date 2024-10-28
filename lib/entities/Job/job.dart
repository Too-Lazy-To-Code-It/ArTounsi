import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String mainImagePath;
  final List<String> additionalImagePaths;
  final String jobLink;
  final String idUser;  // New field

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.mainImagePath,
    required this.additionalImagePaths,
    required this.jobLink,
    required this.idUser,  // New field
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'mainImagePath': mainImagePath,
      'additionalImagePaths': additionalImagePaths,
      'jobLink': jobLink,
      'id_user': idUser,  // New field
    };
  }

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      mainImagePath: data['mainImagePath'] ?? '',
      additionalImagePaths: List<String>.from(data['additionalImagePaths'] ?? []),
      jobLink: data['jobLink'] ?? '',
      idUser: data['id_user'] ?? '',  // New field
    );
  }
}

class JobService {
  final CollectionReference jobCollection = FirebaseFirestore.instance.collection('Job');

  Future<void> addJob(Job job) {
    return jobCollection.add(job.toMap());
  }

  Stream<List<Job>> getJobs() {
    return jobCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    });
  }

  Future<Job?> getJobById(String id) async {
    DocumentSnapshot doc = await jobCollection.doc(id).get();
    return doc.exists ? Job.fromFirestore(doc) : null;
  }

  Future<void> updateJob(Job job) {
    return jobCollection.doc(job.id).update(job.toMap());
  }

  Future<void> deleteJob(String id) {
    return jobCollection.doc(id).delete();
  }

  // New method to get jobs by user ID
  Stream<List<Job>> getJobsByUser(String userId) {
    return jobCollection
        .where('id_user', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    });
  }
}