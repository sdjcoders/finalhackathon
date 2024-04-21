import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:tripsathihackathon/community%20post/controller/add_Cpost_controller.dart';
import 'package:tripsathihackathon/community%20post/screens/cpost_card.dart';
import 'package:tripsathihackathon/community/constants/error.dart';
import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';
import 'package:tripsathihackathon/community/drawer/drawers.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/widgets/post_card.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/search_screen.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<homepage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? uid;
  late StreamSubscription<User?> _userStreamSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userStreamSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        uid = user?.uid;
      });
    });
  }

  @override
  void dispose() {
    _userStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Tripsaathi',
              style: GoogleFonts.lobster(
                color: Colors.black,
                fontSize: 26.0,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            icon: const Icon(
              Icons.search_rounded,
              color: Color.fromARGB(255, 39, 36, 87),
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const homepage()),
              );
            },
            icon: const Icon(
              Icons.messenger_outline_rounded,
            ),
            color: Colors.black,
          ),
        ],
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 9,
              sigmaY: 9,
            ),
            child: Container(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'For You'),
            Tab(text: 'Following'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      drawer: const CommunityList(),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('datePublished', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final snap = snapshot.data!.docs[index].data();
                  return PostCard(snap: snap);
                },
                cacheExtent: MediaQuery.of(context).size.height * 8,
              );
            },
          ),
          _buildFollowingTab(),
          CommmunityFeedScreen()
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (uid == null) {
      return const SizedBox(); // Return an empty widget if uid is null
    }
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('User data not found.'));
        }
        List<dynamic> followingList = userSnapshot.data!.get('following') ?? [];
        if (followingList.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                // Handle the follow action
              },
              child: Text('Follow  Users'),
            ),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('uid', whereIn: followingList)
              .orderBy('datePublished', descending: true)
              .snapshots(),
          builder: (context, postSnapshot) {
            if (postSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: postSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = postSnapshot.data!.docs[index].data();
                return PostCard(snap: post);
              },
            );
          },
        );
      },
    );
  }
}

class CommmunityFeedScreen extends ConsumerWidget {
  const CommmunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(
        data: (communities) => ref.watch(userPostsProvider(communities)).when(
              data: (data) {
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = data[index];
                      return CPostCard(post: post);
                    });
              },
              error: (error, StackTrace) {
                if (kDebugMode) print(error);
                return ErrorText(error: error.toString());
              },
              loading: () => const Loader(),
            ),
        error: (error, StackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
