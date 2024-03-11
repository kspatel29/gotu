import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gotuappv1/model/community.dart';
import 'package:gotuappv1/services/firebase_service.dart';
import 'package:gotuappv1/views/community/community_posts_page.dart';
import 'package:gotuappv1/views/community/create_community_page.dart';
import 'package:gotuappv1/views/community/join_community_page.dart';

class CommunitiesTab extends StatefulWidget {
  const CommunitiesTab({Key? key}) : super(key: key);

  @override
  _CommunitiesTabState createState() => _CommunitiesTabState();
}

class _CommunitiesTabState extends State<CommunitiesTab> {
  final FireService _fireService = FireService();
  String? selectedCity;
  List<String> cities = [
    'Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton',
    'Ottawa', 'Winnipeg', 'Quebec City', 'Hamilton', 'Kitchener',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCity ?? "Select a City"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _selectCityDialog,
          ),
        ],
      ),
      body: selectedCity == null
          ? const Center(child: Text("Please select a city to see its communities."))
          : _buildCommunitySections(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'comTabFAB',
        onPressed: () => _showFABMenu(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _selectCityDialog() async {
    final String? city = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(cities[index]),
                onTap: () {
                  Navigator.pop(context, cities[index]);
                },
              );
            },
          ),
        );
      },
    );

    if (city != null) {
      setState(() {
        selectedCity = city;
      });
    }
  }

  Widget _buildCommunitySections() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Spotlight Communities"),
          _buildCommunitiesList("spotlight"),
          const SizedBox(height: 16),
          _buildSectionTitle("Joined Communities"),
          _buildCommunitiesList("joined"),
          const SizedBox(height: 16),
          _buildSectionTitle("Your Communities"),
          _buildCommunitiesList("created"),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCommunitiesList(String listType) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    Stream<List<Community>> stream = Stream.empty();
    if (listType == "spotlight") {
      stream = _fireService.getSpotlightCommunities(selectedCity!);
    } else if (listType == "created") {
      stream = _fireService.getCreatedCommunities(selectedCity!, userId!);
    } else if (listType == "joined") {
      stream = _fireService.getJoinedCommunities(userId!);
    }

  return StreamBuilder<List<Community>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("No communities found.", style: Theme.of(context).textTheme.subtitle1),
        );
      }
      List<Widget> communityWidgets = [];
      for (var community in snapshot.data!) {
        Widget listTile = ListTile(
          title: Text(community.name),
          subtitle: Text(community.description),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityPostsPage(communityId: community.id, cityName: selectedCity!),
            ),
          ),
        );
        // Wrap with Dismissible only for "joined" communities
        if (listType == "joined" && community.authorId != "admin") { // Assuming authorId "admin" is used for spotlight communities
          listTile = Dismissible(
            key: Key(community.id),
            background: Container(color: Colors.red),
            direction: DismissDirection.endToStart, // Swipe from right to left
            onDismissed: (direction) async {
              await _fireService.leaveCommunity(community.id, selectedCity!, userId!);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You've left the community.")));
            },
            child: listTile,
          );
        }
        communityWidgets.add(listTile);
      }
      return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: communityWidgets,
      );
    },
  );
}


  void _showFABMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Join a Community'),
              onTap: () => _navigateToJoinCommunity(),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create a Community'),
              onTap: () => _navigateToCreateCommunity(),
            ),
          ],
        );
      },
    );
  }

  void _navigateToJoinCommunity() {
    if (selectedCity != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => JoinCommunityPage(city: selectedCity!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a city first.")));
    }
  }

  void _navigateToCreateCommunity() {
    if (selectedCity != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateCommunityPage(city: selectedCity!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a city first.")));
    }
  }
}
