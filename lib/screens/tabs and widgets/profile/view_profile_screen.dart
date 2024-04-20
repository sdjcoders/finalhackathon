import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsathihackathon/auth/authmethods.dart';
import 'package:tripsathihackathon/community%20post/controller/add_Cpost_controller.dart';
import 'package:tripsathihackathon/community%20post/screens/cpost_card.dart';
import 'package:tripsathihackathon/community%20post/screens/edit_profile_screen.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';
import 'package:tripsathihackathon/models/community_model.dart';
import 'package:tripsathihackathon/models/cpost_model.dart';
import 'package:tripsathihackathon/providers/firebase_storage.dart';
import 'package:tripsathihackathon/screens/onboard_buttons.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/about_us.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/followers_list.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/following_list.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/settings_screen.dart';
import 'package:tripsathihackathon/utils/utils.dart';
// Adjust the import path as needed

import 'package:tuple/tuple.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  var userData = {};
  var postLen = 0;
  int followers = 0;
  int following = 0;
  int score = 0;
  bool isFollowing = false;
  bool isLoading = false;
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getData();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getData() async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      isLoading = true;
    });

    try {
      var userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);

      // Add a snapshot listener to the user document
      userDocRef.snapshots().listen((userSnap) {
        if (!mounted) return; // Check if the widget is still mounted
        if (userSnap.exists) {
          setState(() {
            // Update user data
            userData = userSnap.data()!;
            followers = userData['followers'].length;
            following = userData['following'].length;
            score = userData['score'];
            isFollowing = userData['followers'].contains(
              FirebaseAuth.instance.currentUser!.uid,
            );
          });
        }
      });

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        postLen = postSnap.docs.length;
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              color: Color.fromARGB(255, 15, 139, 108),
                            ),
                            FirebaseAuth.instance.currentUser!.uid == widget.uid
                                ? Positioned(
                                    top: 10,
                                    right: 12,
                                    child: Material(
                                      elevation: 4,
                                      shape: CircleBorder(),
                                      clipBehavior: Clip.antiAlias,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.menu,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          _showBottomDrawer(context);
                                        },
                                      ),
                                    ),
                                  )
                                : Positioned(
                                    top: 10,
                                    right: 12,
                                    child: Material(
                                      elevation: 4,
                                      shape: CircleBorder(),
                                      clipBehavior: Clip.antiAlias,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.menu,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          _showBottomDrawerUser(context);
                                        },
                                      ),
                                    ),
                                  ),
                            Positioned(
                              top: 150,
                              left: MediaQuery.of(context).size.width / 2 - 50,
                              child: Hero(
                                tag:
                                    'profile_picture_${userData['uid']}', // Unique tag for the hero animation
                                child: Transform.translate(
                                  offset: Offset(0, -50),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 6, // Thickness of the border
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        userData['photoUrl'],
                                      ),
                                      radius: 55,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 70,
                                  ),
                                  Center(
                                    child: Text(
                                      userData['username'],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    // mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    //  crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          child: buildStateRow(
                                            Icon(Icons.image_sharp),
                                            postLen,
                                          )),
                                      GestureDetector(
                                        child: buildStateRow(
                                          Icon(Icons.person),
                                          followers,
                                        ),
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FollowerCount(
                                                        uid: widget.uid))),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          child: buildStateRow(
                                            Icon(Icons.person_add_alt_1),
                                            following,
                                          ),
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowingCount(
                                                        uid: widget.uid,
                                                      ))),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FirebaseAuth.instance.currentUser!.uid ==
                                              widget.uid
                                          ? SizedBox()
                                          : isFollowing
                                              ? FollowButton(
                                                  text: 'Disconnect',
                                                  backgroundColor: Colors.grey,
                                                  borderColor: Colors.black,
                                                  textColor: Colors.black,
                                                  function: () async {
                                                    await FirestoreMethods()
                                                        .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );
                                                    setState(() {
                                                      isFollowing = false;
                                                      followers--;
                                                    });
                                                  },
                                                )
                                              : FollowButton(
                                                  text: 'Connect',
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 15, 139, 108),
                                                  borderColor: Colors.grey,
                                                  textColor: Colors.white,
                                                  function: () async {
                                                    await FirestoreMethods()
                                                        .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );

                                                    setState(() {
                                                      isFollowing = true;
                                                      followers++;
                                                    });
                                                  },
                                                ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Container(
                        //   alignment: Alignment.centerLeft,
                        //   padding: const EdgeInsets.only(top: 15.0),
                        //   child: Text(
                        //     userData['username'],
                        //     style: const TextStyle(
                        //       fontWeight: FontWeight.bold,
                        //       fontSize: 18,
                        //     ),
                        //   ),
                        // ),
                        // Container(
                        //   alignment: Alignment.centerLeft,
                        //   padding: const EdgeInsets.only(top: 1.0),
                        //   child: Text(
                        //     userData['bio'],
                        //   ),
                        // ),
                        // Container(
                        //   alignment: Alignment.centerLeft,
                        //   padding: const EdgeInsets.only(top: 1.0),
                        //   child: Text('score = $score'),
                        // ),
                      ],
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                          _tabController.animateTo(0);
                        },
                        style: ButtonStyle(
                          backgroundColor: _selectedIndex == 0
                              ? MaterialStateProperty.all(
                                  Color.fromARGB(255, 226, 161, 8))
                              : MaterialStateProperty.all(
                                  Color.fromARGB(255, 102, 106, 104)),
                        ),
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color: _selectedIndex == 0
                                ? Colors.white
                                : Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                          _tabController.animateTo(1);
                        },
                        style: ButtonStyle(
                          backgroundColor: _selectedIndex == 1
                              ? MaterialStateProperty.all(
                                  Color.fromARGB(255, 226, 161, 8))
                              : MaterialStateProperty.all(
                                  Color.fromARGB(255, 102, 106, 104)),
                        ),
                        child: Text(
                          'Community',
                          style: TextStyle(
                            color: _selectedIndex == 1
                                ? Colors.white
                                : Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                          _tabController.animateTo(2);
                        },
                        style: ButtonStyle(
                          backgroundColor: _selectedIndex == 2
                              ? MaterialStateProperty.all(
                                  Color.fromARGB(255, 226, 161, 8))
                              : MaterialStateProperty.all(
                                  Color.fromARGB(255, 102, 106, 104)),
                        ),
                        child: Text(
                          'About',
                          style: TextStyle(
                            color: _selectedIndex == 2
                                ? Colors.white
                                : Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex =
                                3; // Change to the index of the "Trips" tab
                          });
                          _tabController.animateTo(3);
                        },
                        style: ButtonStyle(
                          backgroundColor: _selectedIndex == 3
                              ? MaterialStateProperty.all(
                                  Color.fromARGB(255, 226, 161, 8))
                              : MaterialStateProperty.all(
                                  Color.fromARGB(255, 102, 106, 104)),
                        ),
                        child: Text(
                          'Trips',
                          style: TextStyle(
                            color: _selectedIndex == 3
                                ? Colors.white
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        buildPostTab(),
                        Communitypostscreen(
                          uid: userData['uid'],
                        ),
                        buildaboutus(),
                        TripsTab(
                          uid: userData['uid'],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget buildPostTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          itemCount: (snapshot.data! as dynamic).docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 1.5,
              childAspectRatio: 1),
          itemBuilder: (context, index) {
            DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(url: snap['postUrl']),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: snap['postUrl'],
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }

  Widget buildaboutus() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(255, 218, 208, 208)
                  .withOpacity(0.5), // Adjust the opacity as needed
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: buildStatColumn(postLen, "posts"),
            ),
          ),

          SizedBox(
              height: 20), // Add spacing between the row and column sections

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: 150, // Adjust the height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 222, 217, 217)
                          .withOpacity(0.5), // Adjust the opacity as needed
                    ),
                    child: buildStatColumn(followers, "followers"),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowerCount(uid: widget.uid),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8), // Add spacing between follower and following
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: 150, // Adjust the height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 210, 205, 205)
                          .withOpacity(0.5), // Adjust the opacity as needed
                    ),
                    child: buildStatColumn(following, "following"),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowingCount(uid: widget.uid),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
              height: 20), // Add spacing between the row and column sections

          Column(
            children: [
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 210, 205, 205)
                      .withOpacity(0.5), // Adjust the opacity as needed
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Username: ${userData['username']}',
                      style: const TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 210, 205, 205)
                      .withOpacity(0.5), // Adjust the opacity as needed
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bio: ${userData['bio']}',
                      style: const TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 210, 205, 205)
                      .withOpacity(0.5), // Adjust the opacity as needed
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addtrips() {}

  void _showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Container(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.monetization_on), // Changed the icon
                  title: Text('Expense Tracker'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom drawer
                    //   Navigator.push(
                    //  context,
                    //   MaterialPageRoute(
                    //       builder: (context) =>
                    //           Expenses()), // Navigate to Expenses screen
                    // );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Edit Profile'),
                  onTap: () {
                    // Navigate to Settings screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(uid: widget.uid),
                        ));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    // Navigate to Settings screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About Us'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsScreen()),
                    );
                    // Navigate to About Us screen
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Sign out'),
                  onTap: () async {
                    await AuthMethods().signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BackgroundVideo()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBottomDrawerUser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Container(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.share), // Changed the icon
                  title: Text('Share this profile'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom drawer
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) =>
                    //           Expenses()), // Navigate to Expenses screen
                    // );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block User'),
                  onTap: () {
                    // Navigate to Settings screen
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) =>
                    //           EditProfileScreen(uid: widget.uid),
                    //     ));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.report),
                  title: Text('Report User'),
                  onTap: () {
                    // Navigate to Settings screen
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SettingsScreen()),
                    // );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Column buildStatColumn(int num, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(num.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
      Container(
        margin: const EdgeInsets.only(top: 3),
        child: Text(label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            )),
      ),
    ],
  );
}

Row buildStateRow(
  Icon icon,
  int num,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(num.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          )),
      icon
    ],
  );
}

// Your existing methods

class FullScreenImage extends StatelessWidget {
  final String url;

  const FullScreenImage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.withOpacity(0.2),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class Communitypostscreen extends ConsumerStatefulWidget {
  final String uid;

  const Communitypostscreen({
    required this.uid,
  });

  @override
  ConsumerState<Communitypostscreen> createState() =>
      _CommunitypostscreenState();
}

class _CommunitypostscreenState extends ConsumerState<Communitypostscreen> {
  late String currentUserUid;
  late List<Community> userCommunities;
  late String? selectedCommunity;

  @override
  void initState() {
    super.initState();
    currentUserUid = widget.uid;
    userCommunities = [];
    selectedCommunity = null;
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(userCommunitiesProvider).when(
          data: (List<Community> communities) {
            userCommunities = communities;
            if (userCommunities.isEmpty) {
              return Center(
                child: Text("You haven't joined any communities."),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Your Communities",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: userCommunities.length,
                    itemBuilder: (BuildContext context, int index) {
                      final community = userCommunities[index];
                      return ListTile(
                        title: Text(community.name),
                        onTap: () {
                          setState(() {
                            selectedCommunity = community.name;
                          });
                        },
                      );
                    },
                  ),
                ),
                if (selectedCommunity != null)
                  Expanded(
                    child: ref
                        .watch(getUserPostsInCommunityProvider(
                          Tuple2(currentUserUid, selectedCommunity!),
                        ))
                        .when(
                          data: (List<Post> posts) {
                            // Filter posts to show only those posted by the current user
                            final userPosts = posts
                                .where((post) => post.uid == currentUserUid)
                                .toList();
                            if (userPosts.isEmpty) {
                              return const Center(
                                child: Text(
                                  "You haven't posted anything in this community.",
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: userPosts.length,
                              itemBuilder: (context, index) {
                                return CPostCard(post: userPosts[index]);
                              },
                            );
                          },
                          loading: () =>
                              Center(child: CircularProgressIndicator()),
                          error: (error, _) {
                            print(error.toString());
                            return Center(
                              child: Text(
                                "Error: ${error.toString()}",
                              ),
                            );
                          },
                        ),
                  ),
              ],
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, _) {
            print(error.toString());
            return Center(
              child: Text(
                "Error: ${error.toString()}",
              ),
            );
          },
        );
  }
}

class TripsTab extends ConsumerStatefulWidget {
  final String uid;

  TripsTab({required this.uid});

  @override
  _TripsTabState createState() => _TripsTabState();
}

class _TripsTabState extends ConsumerState<TripsTab> {
  late FirebaseAuth _auth;
  User? currentUser;
  bool isLoading = true;
  String selectedPlace = '';
  List<String> selectedInterests = [];
  List<String> interests = [
    'Sky Diving',
    'Scuba diving',
    'Overland travel',
    'Jungle tourism',
    'Extreme travel',
    'Rock climbing',
  ];
  List<String> userInterests = [];

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _getCurrentUser();
    _getUserInterests();
  }

  Future<void> _getCurrentUser() async {
    currentUser = _auth.currentUser;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getUserInterests() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('interests')
        .where('uid', isEqualTo: widget.uid)
        .get();
    final List<String> interests = [];
    querySnapshot.docs.forEach((doc) {
      interests.add(doc['name']);
    });
    setState(() {
      userInterests = interests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trips And Interest'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentUser != null &&
                      currentUser!.uid == widget.uid) ...[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter a Place Visited',
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedPlace = value;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Select Interests',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Wrap(
                      children: interests.map((interest) {
                        final bool isInterestSelected =
                            userInterests.contains(interest);
                        return CheckboxListTile(
                          title: Text(interest),
                          value: isInterestSelected,
                          onChanged: (isChecked) {
                            setState(() {
                              if (isChecked!) {
                                selectedInterests.add(interest);
                                userInterests.add(
                                    interest); // Add interest to userInterests list when checked
                              } else {
                                selectedInterests.remove(interest);
                                userInterests.remove(
                                    interest); // Remove interest from userInterests list when unchecked
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Store trip data to Firebase Firestore
                            await FirebaseFirestore.instance
                                .collection('trips')
                                .add({
                              'uid': currentUser!.uid,
                              'place': selectedPlace,
                              'timestamp': DateTime.now(),
                            });

                            // Reset selected place
                            setState(() {
                              selectedPlace = '';
                            });

                            // Show a snackbar or toast message to indicate that the trip is saved
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Trip Saved Successfully!'),
                              ),
                            );
                          },
                          child: Text('Save Trip'),
                        ),
                        SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            // Store selected interests in the database
                            for (String interest in selectedInterests) {
                              await FirebaseFirestore.instance
                                  .collection('interests')
                                  .add({
                                'uid': currentUser!.uid,
                                'name': interest,
                              });
                            }

                            // Show a snackbar or toast message to indicate that the interests are added
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Interests Added Successfully!'),
                              ),
                            );

                            // Clear selected interests
                            setState(() {
                              selectedInterests.clear();
                            });
                          },
                          child: Text('Add Interests'),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 32.0),
                  // The remaining code for displaying trips and interests remains unchanged

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trips:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('trips')
                                  .where('uid', isEqualTo: widget.uid)
                                  .snapshots(),
                              builder: (context, tripSnapshot) {
                                if (tripSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                if (tripSnapshot.hasError) {
                                  return Text('Error: ${tripSnapshot.error}');
                                }

                                final tripDocs = tripSnapshot.data!.docs;
                                if (tripDocs.isEmpty) {
                                  return Text('No trips added yet.');
                                }

                                final trips = tripDocs
                                    .map((doc) => doc['place'])
                                    .toList();

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: trips.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(trips[index]),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interests:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('interests')
                                  .where('uid', isEqualTo: widget.uid)
                                  .snapshots(),
                              builder: (context, interestSnapshot) {
                                if (interestSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                if (interestSnapshot.hasError) {
                                  return Text(
                                      'Error: ${interestSnapshot.error}');
                                }

                                final interestDocs =
                                    interestSnapshot.data!.docs;
                                if (interestDocs.isEmpty) {
                                  return Text('No interests added yet.');
                                }

                                final interests = interestDocs
                                    .map((doc) => doc['name'])
                                    .toList();

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: interests.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(interests[index]),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
