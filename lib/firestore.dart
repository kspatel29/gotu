import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:gotuappv1/map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreService{
  
  final CollectionReference reports = FirebaseFirestore.instance.collection('Reports');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final CollectionReference communities = FirebaseFirestore.instance.collection('communities');
  final CollectionReference reportsOnMap = FirebaseFirestore.instance.collection('mapReports');


  // Create User
  // Future<DocumentReference<Object?>> addUser(String? phoneNo, String? userName) async{
  //   return await user.add({
  //     'phoneNo': phoneNo,
  //     'userName': userName
  //   });
  // }
  // Future<bool> checkUserExists(String userId) async {
  //   try {
  //     DocumentSnapshot snapshot =
  //         await users.doc(userId).get();
  //     return snapshot.exists;
  //   } catch (e) {
  //     // Handle any errors that occur
  //     print('Error checking user existence: $e');
  //     return false;
  //   }
  // }



   Future<void> addUserToDatabase(User user, String? username, XFile? image) async {
    try {
        // Upload the image to Firebase Storage
        if (image != null) {
          File file = File(image.path);
          String fileName = 'image/profile/${user.uid}.jpg';
          Reference ref = FirebaseStorage.instance.ref().child(fileName);
          await ref.putFile(file);
          String imageUrl = await ref.getDownloadURL();

          // Store the image URL in Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'username': username,
            'phone': user.phoneNumber,
            'uid': user.uid,
            'lastActive': DateTime.now(),
            'ProfilePic': imageUrl,
            // Add any additional user data fields you want to store
          });
          print('User added to database successfully');
        } else {
          print('No image provided');
        }
    } catch (e) {
        // Handle any errors that occur
        print('Error adding user to database: $e');
    }
  }

  Future<void> extraInfo(String? reportID, User user, String? comment, XFile? image, XFile? video) async {
    if (image == null && video == null) {
      print('No image or video provided');
      return;
    }

    // Upload the image to Firebase Storage
    String imageUrl = '';
    if (image != null) {
      File file = File(image.path);
      String fileName = 'extraInfo/$reportID/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(file);
      imageUrl = await ref.getDownloadURL();
    }

    // Upload the video to Firebase Storage
    String videoUrl = '';
    if (video != null) {
      File videoFile = File(video.path);
      String videoFileName = 'extraInfo/$reportID/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      Reference videoRef = FirebaseStorage.instance.ref().child(videoFileName);
      await videoRef.putFile(videoFile);
      videoUrl = await videoRef.getDownloadURL();
    }

    // Store the image and video URLs in Firestore
    await FirebaseFirestore.instance.collection('Reports').doc(reportID).collection('extraInfo').doc(user.uid).set({
      'comment': comment,
      'imageURL': imageUrl,
      'videoURL': videoUrl,

      // Add any additional user data fields you want to store
    });
    print('User added to database successfully');
  }



  // Create
  Future<DocumentReference> addReport(User user, LatLng? locationCoord, String? reportLocation, String? reportType, String? reportDescription, String? randomUserInformation, int? upVote, int? downVote, XFile? image, XFile? video) async {
    // Upload the files to Firebase Storage
    String? imageURL;
    String? videoURL;

    if (image != null) {
    try {
      // Generate a random file name for the image
      String imageFileName = '${Random().nextInt(10000)}-${image.name}';

      // Upload the image file to Firebase Storage
      Reference imageRef = FirebaseStorage.instance.ref().child('reports/${user.uid}/$imageFileName');
      UploadTask imageUploadTask = imageRef.putFile(File(image.path));
      TaskSnapshot imageSnapshot = await imageUploadTask;

      // Get the download URL for the image
      imageURL = await imageSnapshot.ref.getDownloadURL();
    } catch (e) {
      print(e); // Handle error
    }
  }

  if (video != null) {
    try {
      // Generate a random file name for the video
      String videoFileName = '${Random().nextInt(10000)}-${video.name}';

      // Upload the video file to Firebase Storage
      Reference videoRef = FirebaseStorage.instance.ref().child('reports/${user.uid}/$videoFileName');
      UploadTask videoUploadTask = videoRef.putFile(File(video.path));
      TaskSnapshot videoSnapshot = await videoUploadTask;

      // Get the download URL for the video
      videoURL = await videoSnapshot.ref.getDownloadURL();
    } catch (e) {
      print(e); // Handle error
    }
  }


    // Add the report to Firestore, including the download URLs if files were uploaded
    return reports.add({
      'date': Timestamp.now(),
      'locationCoordinates': GeoPoint(locationCoord!.latitude, locationCoord.longitude),
      'Location': reportLocation,
      'reportType': reportType,
      'reportDescription': reportDescription,
      'extraInformation': randomUserInformation,
      'upVote': upVote,
      'usersthatUpvoted': null,
      'usersthatDownvoted': null,
      'downVote': downVote,
      'imageURL': imageURL, // Store the image URL in Firestore
      'videoURL': videoURL, // Store the video URL in Firestore
      'verified': false,
    });
  }

  Future<void> updateUserReportData(String docid, List<String?>? upVoteUsers, List<String?> downVoteUsers){
    return reports.doc(docid).update({
      'usersthatUpvoted': upVoteUsers,
      'usersthatDownvoted': downVoteUsers,
    });
  }

  Future<void> mapReport(GeoPoint? reportLocation, String? reportType){
    return reportsOnMap.add({
      'date': Timestamp.now(),
      'Location': reportLocation,
      'reportType': reportType,
    });
  }

  Stream<QuerySnapshot> getReportByTime(Timestamp startTime, Timestamp endTime) {
    
    return reports.where('date', isGreaterThanOrEqualTo: startTime, isLessThanOrEqualTo: endTime).snapshots();
  }

  // Read
  Stream<QuerySnapshot> getReport() {
    return reports.snapshots();
  }

  Stream<QuerySnapshot> getReportOnMap() {
    return reportsOnMap.snapshots();
  }

  Stream<QuerySnapshot> getCommunities() {
    return communities.snapshots();
  }

  //Update
  Future<void> updateReport(String docid, String? randomUserInformation, int? upVote, int? downVote) {
    return reports.doc(docid).update({
      'extraInformation': randomUserInformation,
      'upVote': upVote,
      'downVote': downVote
    });
  }

  

  Future<void> updateReportOnMap(String docid, GeoPoint? reportLocation, String? reportType) {
    return reportsOnMap.doc(docid).update({
      'date': Timestamp.now(),
      'Location': reportLocation,
      'reportType': reportType,
    });
  }

  //delete
  Future<void> deleteReport(String docid) {
    return reports.doc(docid).delete();
  }

  Future<void> deleteReportOnMap(String docid) {
    return reportsOnMap.doc(docid).delete();
  }
}