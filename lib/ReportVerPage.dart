import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:gotuappv1/firestore.dart';
import 'package:gotuappv1/map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ReportVerPage extends StatefulWidget {
  const ReportVerPage({super.key});
  
  get reportId => null;
  
  Object? get userId => null;

  @override
  State<ReportVerPage> createState() => _ReportVerPageState();
}

class _ReportVerPageState extends State<ReportVerPage> with SingleTickerProviderStateMixin{
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  
  bool isUserUpvoted = false;
  bool isUserDownvoted = false;
  bool hasUpvoted = false;
  bool hasDownvoted = false;

  Future<void> checkUserVoteStatus(String docID, bool vote, upvoteUsers, downvoteUsers) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    print(userId);

    bool isUserUpvoted = false;
    bool isUserDownvoted = false;

    try {
        // DocumentReference reportRef = FirebaseFirestore.instance.collection('Reports').doc(docID);
        // DocumentSnapshot reportSnapshot = await reportRef.get();
        // Map<String, dynamic>? reportData = reportSnapshot.data() as Map<String, dynamic>?;
        // List<dynamic>? upvoteUsers = reportData?['usersthatUpvoted']?.cast<dynamic>() ?? [];
        // List<dynamic>? downvoteUsers = reportData?['usersthatDownvoted']?.cast<dynamic>() ?? [];
        
        print('Upvote Users: $upvoteUsers');
        print('Downvote Users: $downvoteUsers');
        print(docID);
        isUserUpvoted = upvoteUsers!.contains(userId);
        isUserDownvoted = downvoteUsers!.contains(userId);

        if (!isUserUpvoted && !isUserDownvoted && !vote) {
          upvoteUsers.add(userId);
          await firestoreService.updateUserReportData(docID, upvoteUsers, downvoteUsers);
        }

        if (!isUserUpvoted && !isUserDownvoted && vote) {
          downvoteUsers.add(userId);
          await firestoreService.updateUserReportData(docID, upvoteUsers, downvoteUsers);
        }

        if(isUserUpvoted && !isUserDownvoted && vote){
          upvoteUsers.remove(userId);
          downvoteUsers.add(userId);
          await firestoreService.updateUserReportData(docID, upvoteUsers, downvoteUsers);
        }
        if(!isUserUpvoted && isUserDownvoted && !vote){
          upvoteUsers.add(userId);
          downvoteUsers.remove(userId);
          await firestoreService.updateUserReportData(docID, upvoteUsers, downvoteUsers);
        }
        if(isUserUpvoted && !isUserDownvoted && !vote){
          upvoteUsers.remove(userId);
          // downvoteUsers.remove(userId);
          await firestoreService.updateUserReportData(docID, upvoteUsers, downvoteUsers);
        }
        if(!isUserUpvoted && isUserDownvoted && vote){
          // upvoteUsers.add(userId);
          downvoteUsers.remove(userId);
          await firestoreService.updateUserReportData(docID, upvoteUsers, downvoteUsers);
        }

        // Assuming this function is part of a StatefulWidget
        setState(() {
          hasUpvoted = isUserUpvoted;
          hasDownvoted = isUserDownvoted;
        });
    } catch (error) {
        print('Error retrieving vote status: $error');
        // Consider showing a user-friendly error message or handling specific error types
    }
    }



  TabController? _tabController;
  bool isExpanded = false;

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length:  3, vsync:this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
  var upVote = 0;
  var downVote = 0;

  void OpenExtraInfo({String? docid}) {

  final User? user = FirebaseAuth.instance.currentUser;
  File? image;
  File? video;

  XFile? _image;
  XFile? _video;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          // Add a title to the dialog
          title: Text('Add a comment'),
          // Add some padding and scrollability to the content
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    maxLines: 5,
                    controller: textController,
                    decoration: InputDecoration(hintText: 'Enter your comment'),
                  ),
                  SizedBox(height: 20),
                  if (image != null) Image.file(image!),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Icon(Icons.image),
                        onPressed: () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? pickedImage =
                              await _picker.pickImage(source: ImageSource.gallery);

                          if (pickedImage != null) {
                            setState(() {
                              image = File(pickedImage.path);
                              _image = pickedImage;
                            });
                          }
                        },
                      ),
                      if (image != null) Icon(Icons.check),
                      SizedBox(width: 5),
                      TextButton(
                        child: Icon(Icons.camera_alt_rounded),
                        onPressed: () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? pickedVideo = await _picker.pickVideo(
                            source: ImageSource.gallery,
                            maxDuration: Duration(seconds: 45),
                          );

                          if (pickedVideo != null) {
                            setState(() {
                              video = File(pickedVideo.path);
                              _video = pickedVideo;
                            });
                          }
                        },
                      ),
                      if (video != null) Icon(Icons.check),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Add a cancel button to the dialog
            TextButton(
              onPressed: () {
                // Clear the text and files
                textController.clear();
                _image = null;
                _video = null;
                image = null;
                video = null;
                // Close the dialog
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await firestoreService.extraInfo(
                  docid,
                  user!,
                  textController.text,
                  _image,
                  _video,
                );
                _image = null;
                _video = null;
                image = null;
                video = null;

                textController.clear();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    ),
  );

  } 




  Future<String> getPlacePrediction(LatLng coordinates) async {
    final apiKey = 'AIzaSyC0Cb--NlC6ieCNt8jSQImz5bN1JhmvOsY'; // Replace with your Google Cloud API key
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coordinates.latitude},${coordinates.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final results = decodedResponse['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        final firstResult = results.first;
        final formattedAddress = firstResult['formatted_address'] as String;
        return formattedAddress;
      }
    }
    return '';
  }

  void userUpVote(String? docid, String? extraInfo, int? reportDownVote){
    upVote++;
    firestoreService.updateReport(docid!, extraInfo, upVote, reportDownVote);
  }
  void userDownVote(String? docid, String? extraInfo, int? reportUpVote){
    downVote++;
    firestoreService.updateReport(docid!, extraInfo, reportUpVote, downVote);
  }

  
  
  @override
  Widget build(BuildContext context) {
    final oneHourAgo = Timestamp.now().toDate().subtract(Duration(hours: 1));
    final oneHourAgoTimestamp = Timestamp.fromDate(oneHourAgo);
    return DefaultTabController(
      length:  3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Reports", style: TextStyle(color: Colors.white),),
          
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            tabs: const [
              Tab(child: Text(
                "Recent",
                style: TextStyle(color: Color.fromARGB(255, 184, 217, 245)),
              ),),
              Tab(child: Text(
                "This Month",
                style: TextStyle(color: Color.fromARGB(255, 197, 226, 251)),
              ),),
              Tab(child: Text(
                "All Time",
                style: TextStyle(color: Color.fromARGB(255, 184, 215, 241)),
              ),),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildReportList(startTime: oneHourAgoTimestamp, endTime: Timestamp.now()), // Recent
            _buildReportList(startTime: _thisMonthStart(), endTime: Timestamp.now()), // This Month
            _buildReportList(startTime: _allTimeStart(), endTime: Timestamp.now()), // All Time
          ],
        ),
        backgroundColor: HexColor('#03045E'),
      ),
    );
  }

   Widget _buildReportList({required Timestamp startTime, required Timestamp endTime}) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getReportByTime(startTime,endTime),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List reportList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: reportList.length,       
              itemBuilder: (context, index) {
                DocumentSnapshot document = reportList[index];
                String docID = document.id;

                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String? reportType = data['reportType'];
                String? reportDescription = data['reportDescription'];
                Timestamp? ReportedTime = data['date'];  
                DateTime now = DateTime.now();
                DateTime reportedDateTime = ReportedTime!.toDate();

                Duration difference = now.difference(reportedDateTime);
                int differenceInDays = difference.inDays;
                String dateString;

                if (differenceInDays == 0) {
                  dateString = 'Today';
                } else if (differenceInDays == 1) {
                  dateString = 'Yesterday';
                } else {
                  dateString = '${differenceInDays}d';
                }



                String? extraInfo = data['extraInformation'];
                int? reportUpVote = data['upVote'];
                int? reportDownVote = data['downVote'];
                List<String?> upVoteUsers = data['usersthatUpvoted']?.cast<String>()?? [];
                List<String?> downVoteUsers = data['usersthatDownvoted']?.cast<String>()?? [];
                String? reportImage = data['imageURL'];
                String? reportVideo = data['videoURL'];
                bool? verified = data['verified'];
                String? reportedLocation = data['Location'];
                GeoPoint? reportedLocationLat = data['locationCoordinates'];

                


                reportUpVote = upVoteUsers.length;
                reportDownVote = downVoteUsers.length;

                
                return SizedBox(
                  height: isExpanded ? null : 150,
                  width: 100,
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    color: HexColor('#0077B6'),
                    elevation: 20,
                    child: InkWell(
                      onTap: toggleExpansion,
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Text(
                                
                                  reportType!,
                                  style: TextStyle(color:HexColor('90e0ef'),fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 10),
                                if(verified != null && verified)
                                  Icon(Icons.verified,color: HexColor('90e0ef'),size: 30,),
                                if(verified == null || !verified)
                                 Icon(Icons.watch_later,color: HexColor('#09295c'),size: 30,),
                                SizedBox(width: 10),
                                if (reportedLocationLat != null)
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to the reported location on the map
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => MapSample(latitude: reportedLocationLat.latitude, longitude: reportedLocationLat.longitude)),
                                      );
                                    },
                                    child: Icon(Icons.location_on_rounded),
                                  ),
                              ],
                            ),
                            subtitle: Text(dateString,style: TextStyle(color:Colors.black),),
                          ),
                          if (isExpanded)
                            Column(
                              children: [
                                if (reportedLocation != null)
                                  Text("$reportedLocation"),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    reportDescription!,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                if (reportImage != null) // Check if the image URL is not null
                                  Container(
                                    width: 400, // Set the desired width
                                    height: 300, // Set the desired height
                                    child: Image.network(reportImage as String),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Text("$reportUpVote"),
                                        IconButton(
                                          onPressed: () { 
                                            checkUserVoteStatus(docID, false, upVoteUsers, downVoteUsers);
                                            isUserUpvoted = true;
                                          },
                                          icon: Icon(Icons.thumb_up),
                                        ),
                                        Text("$reportDownVote"),
                                        IconButton(
                                          onPressed: () { 
                                            checkUserVoteStatus(docID, true, upVoteUsers, downVoteUsers);
                                            isUserDownvoted = true;
                                          },
                                          icon: Icon(Icons.thumb_down),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () {
                                          OpenExtraInfo(docid: docID);
                                        },
                                        icon: Icon(Icons.add_box),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                
                                // Add more widgets here to show images or other details when expanded
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }     
              
            );

          } else {
            return const Text("No notes");
          }
        }
    );
    

  }
   Timestamp _thisMonthStart() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month);
    return Timestamp.fromDate(startOfMonth);
  }

  Timestamp _allTimeStart() {
    // This is a conceptual example. Adjust according to your needs.
    return Timestamp.fromDate(DateTime(2000,  1)); // Start from a specific year
  }

}




