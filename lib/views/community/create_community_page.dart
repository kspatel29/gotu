import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCommunityPage extends StatefulWidget {
  final String city;

  const CreateCommunityPage({Key? key, required this.city}) : super(key: key);

  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _submitCommunity() async {
    if (_formKey.currentState!.validate()) {
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Add community to Firestore with 'type' field set to 'created'
      await FirebaseFirestore.instance.collection('cities').doc(widget.city).collection('communities').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'authorId': userId, // Use current user's ID as authorId
        'type': 'created', // Mark this as a user-created community
        'createdAt': FieldValue.serverTimestamp(), // Timestamp of creation
      });

      // Clear form fields after submission
      _nameController.clear();
      _descriptionController.clear();

      // Show success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Community created successfully')));
      Navigator.pop(context); // Optionally, navigate back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Community in ${widget.city}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Community Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a community name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCommunity,
                child: Text('Create Community'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
