import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gotuappv1/model/comment.dart';
import 'package:gotuappv1/model/post.dart';
import 'package:gotuappv1/services/firebase_service.dart';

class PostDetailPage extends StatefulWidget {
  final String communityId;
  final String postId;
  final String cityName;
  final Post post;

  const PostDetailPage({
    Key? key,
    required this.communityId,
    required this.postId,
    required this.cityName,
    required this.post,
  }) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final FireService _firebaseService = FireService();
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title ?? "Post Details")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostSection(widget.post),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<Comment>>(
              stream: _firebaseService.getComments(widget.cityName, widget.communityId, widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No comments found."),
                  );
                }
                List<Comment> comments = snapshot.data!;
                return _buildCommentsSection(comments);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommentDialog,
        tooltip: 'Add Comment',
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildPostSection(Post post) {
  return Card(
    margin: EdgeInsets.all(10),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title ?? "No Title",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(post.description ?? "No Description"),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Upvote Button
              IconButton(
                icon: Icon(Icons.arrow_upward_outlined),
                onPressed: () {
                  // Implement upvote functionality
                },
              ),
              Text("${post.upvotes ?? 0}"),
              // Downvote Button
              IconButton(
                icon: Icon(Icons.arrow_downward_outlined),
                onPressed: () {
                  // Implement downvote functionality
                },
              ),
              Text("${post.downvotes ?? 0}"),
              Text("Comments: ${post.commentCount ?? 0}")
            ],
          ),
          
        ],
      ),
    ),
  );
}

void _showAddCommentDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: _commentController,
          decoration: InputDecoration(hintText: "Type your comment here"),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () async {
              if (_commentController.text.isNotEmpty) {
                // Call method to add comment
                _addComment();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}


void _addComment() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    // Handle user not logged in
    return;
  }

  // Fetch username from Firestore
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final username = userDoc.data()?['username'] as String? ?? 'Anonymous'; // Fallback to 'Anonymous'

  final newComment = Comment(
    id: '', // ID will be auto-generated by Firestore when adding the comment
    userId: userId,
    username: username,
    content: _commentController.text,
    upvotes: 0,
    downvotes: 0,
    timestamp: Timestamp.now(),
  );

  try {
    await FirebaseFirestore.instance
      .collection('cities')
      .doc(widget.cityName)
      .collection('communities')
      .doc(widget.communityId)
      .collection('posts')
      .doc(widget.postId)
      .collection('comments')
      .add(newComment.toMap());

    // Clear the text field and close the dialog
    _commentController.clear();
  } catch (e) {
    // Handle errors, e.g., show a Snackbar
  }
}

Widget _buildCommentsSection(List<Comment> comments) {
  return ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: comments.length,
    separatorBuilder: (context, index) => const Divider(),
    itemBuilder: (context, index) {
      final comment = comments[index];
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns the avatar to the top of the row
          children: [
            // Profile Picture
            const Padding(
              padding: EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
            // Comment Content and Voting Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.username, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(comment.content),
                  // Align votes to the right and below the content
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_upward, size: 20),
                          onPressed: () => _updateCommentVote(comment.id, true),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text("${comment.upvotes}", style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4), // Space between upvote and downvote
                        IconButton(
                          icon: const Icon(Icons.arrow_downward, size: 20),
                          onPressed: () => _updateCommentVote(comment.id, false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0), // Adjust the padding value as needed
                          child: Text("${comment.downvotes}", style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}





void _updateCommentVote(String commentId, bool isUpvote) async {
  // Reference to the specific comment document in Firestore
  var commentRef = FirebaseFirestore.instance
    .collection('cities').doc(widget.cityName)
    .collection('communities').doc(widget.communityId)
    .collection('posts').doc(widget.postId)
    .collection('comments').doc(commentId);

  FirebaseFirestore.instance.runTransaction((transaction) async {
    var commentSnapshot = await transaction.get(commentRef);
    if (commentSnapshot.exists) {
      var commentData = commentSnapshot.data();
      int upvotes = commentData?['upvotes'] ?? 0;
      int downvotes = commentData?['downvotes'] ?? 0;

      if (isUpvote) {
        transaction.update(commentRef, {'upvotes': upvotes + 1});
      } else {
        transaction.update(commentRef, {'downvotes': downvotes + 1});
      }
    }
  }).then((_) {
    // Optionally, refresh the state if necessary to reflect the update
    setState(() {});
  }).catchError((error) {
    // Handle any errors here
    print("Error updating comment vote: $error");
  });
}




}
