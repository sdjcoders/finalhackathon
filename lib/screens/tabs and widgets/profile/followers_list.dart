import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gonomad/features/auth/screen/profile_screen.dart';

class FollowerCount extends StatefulWidget {
  final String uid;

  const FollowerCount({Key? key, required this.uid}) : super(key: key);

  @override
  State<FollowerCount> createState() => _FollowerCountState();
}

class _FollowerCountState extends State<FollowerCount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Followers'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 9,
              sigmaY: 9,
            ), // Adjust the sigmaX and sigmaY values for blur intensity
            child: Container(
              color: Colors.white.withOpacity(0.7),
              // Adjust opacity as needed
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('User not found.'),
            );
          }

          // Fetch the following list of the user
          List<dynamic> following = snapshot.data!.get('followers') ?? [];

          if (following.isEmpty) {
            return Center(
              child: Text('No followers found.'),
            );
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(following[index])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                      ),
                      title: Text('Loading...'),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                      ),
                      title: Text('User not found'),
                    );
                  }
                  // User found, display the follower
                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          uid: snapshot.data!.id,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          userData['photoUrl'],
                        ),
                      ),
                      title: Text(
                        userData['username'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
