import 'package:gotuappv1/model/messages.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart'; // Adjust the path according to your project structure
// import '../../models/message.dart'; // Adjust the path according to your project structure

class PrivateMessagesTab extends StatefulWidget {
  const PrivateMessagesTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrivateMessagesTabState createState() => _PrivateMessagesTabState();
}

class _PrivateMessagesTabState extends State<PrivateMessagesTab> {
  final TextEditingController _controller = TextEditingController();
  final FireService _firebaseService = FireService();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // Example sender and receiver IDs. Replace with actual IDs from your auth system.
      String senderId = "senderUID";
      String receiverId = "receiverUID";
      // _firebaseService.sendMessage(senderId, receiverId, _controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Example sender and receiver IDs
    String senderId = "senderUID";
    String receiverId = "receiverUID";
    return Scaffold(
      
    );

    // return Column(
    //   children: [
    //     Expanded(
    //       child: StreamBuilder<List<Message>>(
    //         stream: _firebaseService.getMessages(senderId, receiverId),
    //         builder: (context, snapshot) {
    //           if (snapshot.hasError) return Text('Error: ${snapshot.error}');
    //           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

    //           List<Message> messages = snapshot.data ?? [];
    //           return ListView.builder(
    //             itemCount: messages.length,
    //             itemBuilder: (context, index) {
    //               Message message = messages[index];
    //               return ListTile(
    //                 title: Text(message.text!),
    //                 subtitle: Text(message.senderId == senderId ? 'You' : 'Them'),
    //               );
    //             },
    //           );
    //         },
    //       ),
    //     ),
    //     Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Row(
    //         children: [
    //           Expanded(
    //             child: TextField(
    //               controller: _controller,
    //               decoration: const InputDecoration(hintText: 'Type a message...'),
    //             ),
    //           ),
    //           IconButton(
    //             icon: const Icon(Icons.send),
    //             onPressed: _sendMessage,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }
}
