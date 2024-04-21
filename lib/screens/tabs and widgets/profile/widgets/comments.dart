import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsathihackathon/models/usermodel.dart';
import 'package:tripsathihackathon/providers/firebase_storage.dart';
import 'package:tripsathihackathon/providers/user_provider.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/widgets/comments_card.dart';

class CommentsScreen extends StatefulWidget {
  final snap;
  const CommentsScreen({super.key, required this.snap});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _commentcontroller = TextEditingController();
    final User? user = Provider.of<UserProvider>(context).getUser;
    @override
    void dispose() {
      super.dispose();
      _commentcontroller;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data as dynamic).docs.length,
            itemBuilder: (context, index) {
              return CommentCard(
                snap: (snapshot.data! as dynamic).docs[index].data(),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user?.photoUrl ?? ''),
              radius: 21,
            ),

            // Textfield for adding comments
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 18.0, right: 8, bottom: 10),
                  child: TextField(
                    controller: _commentcontroller,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () async {
                  await FirestoreMethods().postComment(
                    widget.snap['postId'],
                    _commentcontroller.text,
                    user!.uid,
                    user.username,
                    user.photoUrl,
                  );

                  setState(() {
                    _commentcontroller.clear();
                  });
                },
                icon: const Icon(
                  Icons.send_rounded,
                  size: 40,
                )),
          ]),
        ),
      ),
    );
  }
}
