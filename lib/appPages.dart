import 'package:gotuappv1/ProfilePage.dart';
import 'package:gotuappv1/ReportVerPage.dart';
import 'package:gotuappv1/chatPage.dart';
import 'package:gotuappv1/views/huddle_page/huddle_page.dart';

import 'package:gotuappv1/map.dart';
import 'package:gotuappv1/videoPage.dart';
import 'package:gotuappv1/views/huddle_page/huddle_page.dart';
import 'package:flutter/material.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    MapSample(),
    HuddlePage(),
    ReportVerPage(),
    ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                onTabTapped(0);
              },
            ),
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                onTabTapped(1);
              },
            ),
            SizedBox(width: 100), // This is to leave space for the floating action button
            IconButton(
              icon: Icon(Icons.verified),
              onPressed: () {
                onTabTapped(2);
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: (){
                onTabTapped(3);
              },
            ), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.emergency),
        backgroundColor: Colors.blue,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.bug_report),
                      title: Text('Report'),
                      onTap: () {
                        // Add your report functionality here
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.local_police),
                      title: Text('Call 911'),
                      onTap: () {
                        // Add your report functionality here
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.crisis_alert),
                      title: Text('Alert All your friends'),
                      onTap: () {
                        // Add your report functionality here
                      },
                    ),
                    // Add more ListTiles for other options in the bottom sheet
                  ],
                  
                ),
                
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

