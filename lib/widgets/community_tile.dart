import 'package:gotuappv1/model/community.dart';
import 'package:flutter/material.dart';

class ExpandableCommunityTile extends StatefulWidget {
  final Community community;
  final VoidCallback onJoin;

  const ExpandableCommunityTile({
    Key? key,
    required this.community,
    required this.onJoin,
  }) : super(key: key);

  @override
  _ExpandableCommunityTileState createState() => _ExpandableCommunityTileState();
}

class _ExpandableCommunityTileState extends State<ExpandableCommunityTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.community.name),
      subtitle: _isExpanded ? Text(widget.community.description) : null,
      trailing: ElevatedButton(
        onPressed: widget.onJoin,
        child: const Text('Join'),
      ),
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
    );
  }
}
