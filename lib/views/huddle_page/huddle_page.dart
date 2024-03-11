import 'package:flutter/material.dart';
import './communities_tab.dart'; // Update these imports based on your file structure
import './private_messages_tab.dart'; // Update these imports based on your file structure

class HuddlePage extends StatelessWidget {
  const HuddlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // The number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Huddle'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Communities'),
              Tab(text: 'Private Messaging'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CommunitiesTab(),
            PrivateMessagesTab(),
          ],
        ),
      ),
    );
  }
}
