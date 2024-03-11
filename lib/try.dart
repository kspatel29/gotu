// import 'package:gotuappv1/firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_places_flutter/model/place_details.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class SendData extends StatefulWidget {
//   const SendData({super.key});

//   @override
//   State<SendData> createState() => _SendDataState();
// }

// class _SendDataState extends State<SendData> {
//   final db = FirebaseFirestore.instance;

//   final FirestoreService firestoreService = FirestoreService();
//   final TextEditingController textController = TextEditingController();

//   void openNoteBox({String? docid}){
//     showDialog(context:context , builder:(context)=>AlertDialog(
//       content:TextField(
//         controller: textController,
//       ),
//       actions: [
//         ElevatedButton(onPressed: () {
//           // firestoreService.addReport(textController.text);

//           textController.clear();

//           Navigator.pop(context);
//         }, child: Text("add"))
//       ],
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: ElevatedButton(
//         child: Text('Submit'),
//         onPressed: () {
//           openNoteBox();
//           }
        
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         // stream: firestoreService.getNotes(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             List notesList = snapshot.data!.docs;
//             return ListView.builder(
//             itemCount: notesList.length,       
//             itemBuilder: (context, index) {
//               DocumentSnapshot document = notesList[index];
//               String docID = document.id;

//               Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//               String noteText = data['note'];
//               return ListTile(
//                 title: Text(noteText),
//                 trailing: IconButton(onPressed: () {
//                   openNoteBox(docid: docID);
//                 }, icon: Icon(Icons.safety_check)),
//               );
//             },
//             );
//           } else {
//             return const Text("No notes");
//           }
//         }
//             )
//     );
//         }
// }  