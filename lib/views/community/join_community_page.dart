import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gotuappv1/model/community.dart';
import 'package:gotuappv1/services/firebase_service.dart';

class JoinCommunityPage extends StatefulWidget {
  final String city;

  JoinCommunityPage({Key? key, required this.city}) : super(key: key);

  @override
  _JoinCommunityPageState createState() => _JoinCommunityPageState();
}

class _JoinCommunityPageState extends State<JoinCommunityPage> {
  final FireService _firebaseService = FireService();
  late Future<List<Community>> _futureJoinableCommunities;

  @override
  void initState() {
    super.initState();
    _futureJoinableCommunities = _fetchJoinableCommunities();
  }

  Future<List<Community>> _fetchJoinableCommunities() async {
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  return await _firebaseService.getJoinableCommunities(widget.city, _currentUserId).first;
}


  void _joinCommunity(String communityId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 15),
                Text("Joining Community..."),
              ],
            ),
          ),
        );
      },
    );

    String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firebaseService.joinCommunity(communityId, widget.city, _currentUserId);
      Navigator.pop(context); // Close the dialog
      setState(() {
        _futureJoinableCommunities = _fetchJoinableCommunities(); // Refresh without casting
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully joined the community')));
    } catch (error) {
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to join the community: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join a Community in ${widget.city}")),
      body: FutureBuilder<List<Community>>(
        future: _futureJoinableCommunities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching communities: ${snapshot.error}"));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No communities available to join."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var community = snapshot.data![index];
                return ListTile(
                  title: Text(community.name),
                  subtitle: Text(community.description),
                  trailing: ElevatedButton(
                    onPressed: () => _joinCommunity(community.id),
                    child: const Text('Join'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
