import 'package:gotuappv1/model/post.dart';
import 'package:gotuappv1/views/community/post_detail_page.dart';
import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title!, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(post.description!),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(icon: Icon(Icons.thumb_up), onPressed: () {}),
                Text("${post.upvotes}"),
                SizedBox(width: 8),
                IconButton(icon: Icon(Icons.thumb_down), onPressed: () {}),
                Text("${post.downvotes}"),
                Spacer(),
                IconButton(icon: Icon(Icons.comment), onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailPage(post: post, communityId: '', postId: '', cityName: '',)));
                }),
                Text("${post.commentCount}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
