import 'dart:async';
import 'dart:io';

import 'package:gotuappv1/appPages.dart';
import 'package:gotuappv1/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Add this package to pick images from the gallery or camera

class UsernamePage extends StatefulWidget {
  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  bool _uploadProfilePicture = false;
  XFile? _image; // Add this variable to store the selected image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        backgroundColor: Colors.blue, // Add some color to the app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            if (_image != null) // Show the image if it is not null
              CircleAvatar(
                radius: 80,
                backgroundImage: FileImage(File(_image!.path)),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Upload Profile Picture'),
                Switch( // Use a switch instead of a checkbox for a better UI
                  value: _uploadProfilePicture,
                  onChanged: (value) {
                    setState(() {
                      _uploadProfilePicture = value;
                      if (value) {
                        _pickImage(); // Call this function to pick an image
                      } else {
                        _image = null; // Reset the image if the switch is turned off
                      }
                    });
                  },
                ),
              ],
            ),
            

            SizedBox(
              width: 300,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(), // Add some border to the text field
                ),
              ),
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveUsername(),
              child: Text('Save Username'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Add some color to the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Add some shape to the button
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // _requestLocationAccess();
                // termsNConditions();
                Navigator.pushNamed(context, 'home');
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Add some color to the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Add some shape to the button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUsername() async {
    final String username = _usernameController.text.trim();
    final User? user = FirebaseAuth.instance.currentUser;
    print('Saved Username');

    if (user != null) {
      try {
        await firestoreService.addUserToDatabase(user, username, _image); // Pass the image as an optional parameter to the firestore service
        
        // Optionally, you can show a success message or navigate to the next page here
      } catch (e) {
        print(e);
      }
    }
  }

  

  // void _selectCity() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select City'),
  //         content: TextField(
  //           decoration: InputDecoration(
  //             labelText: 'Search city',
  //             border: OutlineInputBorder(), // Add some border to the text field
  //           ),
  //           onChanged: (value) {
  //             // Handle city search
  //           },
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Confirm'),
  //             onPressed: () {
  //               // Handle city selection
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _pickImage() async {
    // This function will use the image picker package to pick an image from the gallery or camera
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery, // You can change this to ImageSource.camera if you want to use the camera
      maxWidth: 300, // You can adjust the image quality here
      maxHeight: 300,
    );
    setState(() {
      _image = image;
    });
  }
}
