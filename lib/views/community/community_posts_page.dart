import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gotuappv1/model/post.dart';
import 'package:gotuappv1/services/firebase_service.dart';
import 'package:gotuappv1/views/community/create_post_page.dart';
import 'package:gotuappv1/views/community/post_detail_page.dart';

class CommunityPostsPage extends StatefulWidget {
  final String communityId;
  final String cityName;

  const CommunityPostsPage({Key? key, required this.communityId, required this.cityName}) : super(key: key);

  @override
  _CommunityPostsPageState createState() => _CommunityPostsPageState();
}

class _CommunityPostsPageState extends State<CommunityPostsPage> {
  final FireService _firebaseService = FireService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts in ${widget.cityName} Community'),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firebaseService.getPosts(widget.cityName, widget.communityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text("No posts found.");
          }

          List<Post> posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              Post post = posts[index];
              return ListTile(
                title: Text(post.title ?? "No Title"),
                subtitle: Text(post.description ?? "No Description"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(
                        communityId: widget.communityId,
                        postId: post.id,
                        cityName: widget.cityName,
                        post: post,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreatePostPage(communityId: widget.communityId, cityName: widget.cityName)),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Post',
      ),
    );
  }
}
