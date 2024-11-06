import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';
import 'package:Artounsi/entities/Job/Job.dart';

class JobService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {
    try {
      String fileName = 'jobs/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      TaskSnapshot snapshot = await ref.putFile(image);
      await Future.delayed(Duration(seconds: 1));
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> addJob(Job job, File mainImage, {List<File>? additionalImages}) async {
    try {
      String mainImageUrl = await uploadImage(mainImage);
      List<String> additionalImageUrls = [];
      if (additionalImages != null) {
        for (File image in additionalImages) {
          String imageUrl = await uploadImage(image);
          additionalImageUrls.add(imageUrl);
        }
      }

      Job newJob = Job(
        id: '',
        title: job.title,
        description: job.description,
        mainImagePath: mainImageUrl,
        additionalImagePaths: additionalImageUrls,
        JobLink: job.JobLink,
      );

      DocumentReference docRef = await _db.collection('jobs').add(newJob.toMap());
      newJob.id = docRef.id;
      await _db.collection('jobs').doc(docRef.id).update({'id': newJob.id});
      return newJob.id;
    } catch (e) {
      print('Error adding job: $e');
      throw Exception('Failed to add job: $e');
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      DocumentSnapshot doc = await _db.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String mainImagePath = data['mainImagePath'];
        List<String> additionalImagePaths = List<String>.from(data['additionalImagePaths']);

        await _storage.refFromURL(mainImagePath).delete();
        for (String imagePath in additionalImagePaths) {
          await _storage.refFromURL(imagePath).delete();
        }

        await _db.collection('jobs').doc(jobId).delete();
      } else {
        throw Exception('Job not found');
      }
    } catch (e) {
      print('Error deleting job: $e');
      throw Exception('Failed to delete job: $e');
    }
  }

  Future<void> modifyJob(String jobId, Job updatedJob, {File? newMainImage, List<File>? newAdditionalImages}) async {
    try {
      String? mainImageUrl;
      if (newMainImage != null) {
        mainImageUrl = await uploadImage(newMainImage);
      } else {
        DocumentSnapshot doc = await _db.collection('jobs').doc(jobId).get();
        if (doc.exists) {
          mainImageUrl = (doc.data() as Map<String, dynamic>)['mainImagePath'];
        }
      }

      List<String> additionalImageUrls = [];
      if (newAdditionalImages != null && newAdditionalImages.isNotEmpty) {
        for (File image in newAdditionalImages) {
          additionalImageUrls.add(await uploadImage(image));
        }
      } else {
        DocumentSnapshot doc = await _db.collection('jobs').doc(jobId).get();
        if (doc.exists) {
          additionalImageUrls = List<String>.from((doc.data() as Map<String, dynamic>)['additionalImagePaths']);
        }
      }

      final updatedData = {
        'title': updatedJob.title,
        'description': updatedJob.description,
        'mainImagePath': mainImageUrl ?? '',
        'additionalImagePaths': additionalImageUrls,
        'JobLink': updatedJob.JobLink,
      };

      await _db.collection('jobs').doc(jobId).update(updatedData);
    } catch (e) {
      print('Error modifying job: $e');
      throw Exception('Failed to modify job: $e');
    }
  }

  Future<List<Job>> getJobs() async {
    try {
      QuerySnapshot snapshot = await _db.collection('jobs').get();
      return snapshot.docs.map((doc) {
        print(doc.data()); // Debugging log
        return Job.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching jobs: $e');
      throw Exception('Failed to fetch jobs: $e');
    }
  }
}

