// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tripsathihackathon/community/screens/add_mods.dart';
import 'package:tripsathihackathon/community/screens/edit_community.dart';
import 'package:tripsathihackathon/models/community_model.dart';

class ModToolsScreen extends StatelessWidget {
  final Community community;
  const ModToolsScreen({
    Key? key,
    required this.community,
  }) : super(key: key);

  void navigateToEditTools(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditCommunityScreen(name: community.name)),
    );
  }

  void navigateToModTools(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddModScreen(name: community.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mod Tools'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text('Add Moderators'),
            onTap: () {
              navigateToModTools(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Community'),
            onTap: () {
              navigateToEditTools(context);
            },
          ),
        ],
      ),
    );
  }
}
