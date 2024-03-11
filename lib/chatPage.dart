import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void addMessageToFirebase(ChatMessage message) {
  final databaseReference = FirebaseDatabase.instance.reference();
  final messageReference = databaseReference.child('messages').push();
  messageReference.set({
    'sender': message.sender,
    'text': message.text,
    'timestamp': message.timestamp,
    'upvoteCount': message.upvoteCount,
    'downvoteCount': message.downvoteCount,
  });
}

void updateMessageCountsInFirebase(String messageId, int upvoteCount, int downvoteCount) {
  final databaseReference = FirebaseDatabase.instance.reference();
  final messageReference = databaseReference.child('messages').child(messageId);
  messageReference.update({
    'upvoteCount': upvoteCount,
    'downvoteCount': downvoteCount,
  });
}

class chatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<chatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void replyToMessage(int index) {
    final message = _messages[index];
    if (message.reply == null) {
      setState(() {
        message.reply = TextEditingController();
      });
    } else {
      final replyText = message.reply!.text;
      if (replyText.isNotEmpty) {
        setState(() {
          _messages.insert(
            index + 1,
            ChatMessage(
              sender: "You",
              text: replyText,
              timestamp: DateTime.now().toString(),
              reply: null,
              upvoteCount: 0,
              downvoteCount: 0,
            ),
          );
          message.reply!.clear();
          message.reply = null;
        });
      }
    }
}

  void onUpvoteButtonPressed(int index) {
  setState(() {
    _messages[index].upvoteCount++;
  });
}

void onDownvoteButtonPressed(int index) {
  setState(() {
    _messages[index].downvoteCount++;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reddit Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message.sender),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.text),
                      if (message.reply != null)
                        TextField(
                          controller: message.reply!,
                          decoration: InputDecoration(hintText: 'Type a reply'),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () {
                              onUpvoteButtonPressed(index);
                            },
                          ),
                          Text('${message.upvoteCount}'),
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () {
                              onDownvoteButtonPressed(index);
                            },
                          ),
                          Text('${message.downvoteCount}'),
                          IconButton(
                            icon: Icon(Icons.reply),
                            onPressed: () {
                              replyToMessage(index);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(message.timestamp),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        _messages.add(
                          ChatMessage(
                            sender: 'You',
                            text: _messageController.text,
                            timestamp: DateTime.now().toString(), reply: null,
                          ),
                        );
                        _messageController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class ChatMessage {
  final String sender;
  final String text;
  final String timestamp;
  TextEditingController? reply;
  int upvoteCount;
  int downvoteCount;

  ChatMessage({required this.sender, 
  required this.text, 
  required this.timestamp, 
  required this.reply,
  this.upvoteCount = 0,
  this.downvoteCount = 0,
  });
}