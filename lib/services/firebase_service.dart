import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gotuappv1/model/community.dart';
import 'package:gotuappv1/model/post.dart';
import 'package:gotuappv1/model/comment.dart';

class FireService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;




  // Community

  Stream<List<Community>> getCommunitiesByCity(String city) {
    return _db.collection('cities').doc(city).collection('communities').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Community.fromMap(doc.data(), doc.id)).toList());
  }

  // Add a new community and automatically add the creator as a member
  Future<void> addCommunity(String cityName, String communityName, String description) async {
    var communityRef = await _db.collection('cities').doc(cityName).collection('communities').add({
      'name': communityName,
      'description': description,
      'authorId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add the creator as a member of the community
    if (userId != null) {
      communityRef.collection('members').doc(userId).set({'joinedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> leaveCommunity(String communityId, String city, String userId) async {
    await _db.runTransaction((transaction) async {
      DocumentReference communityRef = _db.collection('cities').doc(city).collection('communities').doc(communityId);
      DocumentReference userCommunityRef = _db.collection('users').doc(userId).collection('joined_communities').doc(communityId);

      // Remove the user from the community's 'members' subcollection
      transaction.delete(communityRef.collection('members').doc(userId));

      // Remove the community from the user's 'joined_communities' collection
      transaction.delete(userCommunityRef);
    }).catchError((error) {
      print("Failed to leave community: $error");
      throw Exception('Failed to leave community');
    });
  }




  // Method to fetch spotlight communities
  Stream<List<Community>> getSpotlightCommunities(String cityName) {
  return _db.collection('cities').doc(cityName).collection('communities')
    .where('authorId', isEqualTo: 'admin')
    .snapshots()
    .map((snapshot) => snapshot.docs
    .map((doc) => Community.fromMap(doc.data(), doc.id))
    .toList());
}


  // Method to fetch communities the user has created
  Stream<List<Community>> getCreatedCommunities(String city, String userId) {
  return _db.collection('cities').doc(city).collection('communities')
      .where('authorId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Community.fromMap(doc.data(), doc.id))
          .toList());
}


  // Fetch communities excluding those the user has joined and spotlight communities
  Stream<List<Community>> getJoinableCommunities(String city, String userId) {
    return _db.collection('cities').doc(city).collection('communities').snapshots().asyncMap((snapshot) async {
      // Fetch joined community IDs for filtering
      var joinedSnapshot = await _db.collection('users').doc(userId).collection('joinedCommunities').get();
      var joinedCommunityIds = joinedSnapshot.docs.map((doc) => doc.id).toSet();

      // Filter out communities already joined and spotlight communities
      var filteredCommunities = snapshot.docs.where((doc) => 
        !joinedCommunityIds.contains(doc.id) && doc.data()['authorId'] != 'admin'
      ).map((doc) => Community.fromMap(doc.data(), doc.id)).toList();

      return filteredCommunities;
    });
  }






  Stream<List<Community>> getJoinedCommunities(String userId) async* {
  var joinedSnapshot = await _db.collection('users').doc(userId).collection('joinedCommunities').snapshots();
  await for (var snapshot in joinedSnapshot) {
    List<Community> communities = [];
    for (var doc in snapshot.docs) {
      var cityId = doc.data()['cityId'];
      var communityId = doc.id; // Assuming the doc id is the communityId
      var communitySnapshot = await _db.collection('cities').doc(cityId).collection('communities').doc(communityId).get();
      var community = Community.fromMap(communitySnapshot.data()!, communityId);
      communities.add(community);
    }
    yield communities; // This yields a stream of community lists as they are fetched.
  }
}




  Stream<List<Community>> getCommunitiesByCityAndAuthorId(String city, String authorId) {
    return _db.collection('cities').doc(city).collection('communities').where('authorId', isEqualTo: authorId).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Community.fromMap(doc.data(), doc.id)).toList());
  }

  // Join a community
  // Join a community
  Future<void> joinCommunity(String communityId, String city, String userId) async {
    DocumentReference communityRef = _db.collection('cities').doc(city).collection('communities').doc(communityId);
    
    // Add the user as a member of the community in the 'members' subcollection
    await communityRef.collection('members').doc(userId).set({
      'userId': userId,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Optionally, if you're also keeping track of joined communities under the user's document,
    // ensure to update that as well
    await _db.collection('users').doc(userId).collection('joined_communities').doc(communityId).set({
      'communityId': communityId,
      'city': city,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }



  Future<Set<String>> getUserJoinedCommunityIds(String userId) async {
    final querySnapshot = await _db.collectionGroup('members')
      .where('userId', isEqualTo: userId)
      .get();

    return querySnapshot.docs.map((doc) => doc.reference.parent.parent!.id).toSet();
  }


  // Posts

  Stream<List<Post>> getPosts(String cityName, String communityId) {
    return _db.collection('cities').doc(cityName).collection('communities').doc(communityId).collection('posts').orderBy('timestamp', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Post.fromMap(doc.data(), doc.id)).toList());
  }

  Future<Post> getPostDetails(String cityName, String communityId, String postId) async {
    var snapshot = await _db.collection('cities').doc(cityName).collection('communities').doc(communityId).collection('posts').doc(postId).get();
    return Post.fromMap(snapshot.data()!, snapshot.id);
  }

  Future<void> addPost(String cityName, String communityId, Post post) async {
    await _db.collection('cities').doc(cityName).collection('communities').doc(communityId).collection('posts').add(post.toMap());
  }



  // Comments

  Stream<List<Comment>> getComments(String cityName, String communityId, String postId) {
    return _db.collection('cities').doc(cityName).collection('communities').doc(communityId).collection('posts').doc(postId).collection('comments').orderBy('timestamp', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Comment.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addComment({required String cityName, required String communityId, required String postId, required Comment comment}) async {
    await _db.collection('cities').doc(cityName).collection('communities').doc(communityId).collection('posts').doc(postId).collection('comments').add(comment.toMap());
  }

  

}
