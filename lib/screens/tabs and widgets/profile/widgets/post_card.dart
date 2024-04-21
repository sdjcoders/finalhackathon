import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsathihackathon/models/usermodel.dart';
import 'package:tripsathihackathon/providers/firebase_storage.dart';
import 'package:tripsathihackathon/providers/user_provider.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/view_profile_screen.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/widgets/comments.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/widgets/like_animation.dart';

class PostCard extends StatefulWidget {
  final dynamic snap;

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  late Stream<QuerySnapshot> commentsStream;
  late UserProvider _userProvider;
  User? _user;

  @override
  void initState() {
    super.initState();
    commentsStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .snapshots();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context);
    _user = _userProvider.getUser;
  }

  void _userProviderListener() {
    // Trigger a rebuild when user data changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    _userProvider.removeListener(_userProviderListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider? userProvider = Provider.of<UserProvider>(context);
    if (userProvider == null) {
      // Return a loading indicator or any other widget
      return CircularProgressIndicator();
    }

    final User? user = userProvider.getUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 0, // Remove shadow to improve performance
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 2.0, 8.0, 8.0),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.snap['profileImage'],
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 21.0,
                      backgroundImage: imageProvider,
                    ),
                    //  placeholder: (context, url) => CircularProgressIndicator(), // Placeholder widget while loading
                    errorWidget: (context, url, error) => const Icon(
                        Icons.error), // Widget to show when loading fails
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: widget.snap['uid'],
                            ),
                          ));
                        },
                        child: Text(
                          widget.snap['username'],
                          style: const TextStyle(
                              fontSize: 16.5, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),

                  //delete ppost
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Get the UID of the current user
                      String? currentUserUid =
                          Provider.of<UserProvider>(context, listen: false)
                              .getUser
                              ?.uid;

                      // Get the UID associated with the post
                      String postUid = widget.snap['uid'];

                      // Check if the current user uploaded the picture
                      bool isCurrentUserOwner = postUid == currentUserUid;

                      // Show the dialog with appropriate options
                      showDialog(
                        context: context,
                        builder: ((context) => Dialog(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shrinkWrap: true,
                                children: [
                                  if (isCurrentUserOwner) // Show delete option only if the current user uploaded the picture
                                    InkWell(
                                      onTap: () async {
                                        FirestoreMethods()
                                            .deletePost(widget.snap['postId']);
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: const Text(
                                          'Delete Post',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  //reporting post option
                                  if (!isCurrentUserOwner)
                                    InkWell(
                                      onTap: () {
                                        // Implement your report functionality here
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: const Text(
                                          'Report Post',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )),
                      );
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onDoubleTap: () async {
                await FirestoreMethods().likePost(
                    widget.snap['postId'], user!.uid, widget.snap['likes']);
                setState(() {
                  isLikeAnimating = true;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 350,

                    width: double.infinity, // Adjust the height as needed
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12.0), // Rounded corners
                      child: CachedNetworkImage(
                        imageUrl: widget.snap['postUrl'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 24.0,
                            height: 24.0,
                            // child: CircularProgressIndicator(
                            //   strokeWidth: 4.0,
                            //   valueColor: AlwaysStoppedAnimation<Color>(
                            //       Colors.black), // iOS style color
                            // ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons
                              .signal_wifi_statusbar_connected_no_internet_4_rounded,
                          size: 45,
                        ),
                        cacheManager: DefaultCacheManager(),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLikeAnimating ? 1 : 0,
                    child: LikeAnimation(
                      isAnimating: isLikeAnimating,
                      duration: const Duration(milliseconds: 400),
                      onEnd: () {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 120,
                      ),
                    ),
                  )
                ],
              ),
            ),

            //like comment section
            Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(user!.uid),
                  smallLike: true,
                  child: IconButton(
                    onPressed: () async {
                      await FirestoreMethods().likePost(widget.snap['postId'],
                          user.uid, widget.snap['likes']);
                      setState(() {
                        isLikeAnimating = true;
                      });
                    },
                    icon: widget.snap['likes'].contains(user.uid)
                        ? const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: 30,
                          )
                        : const Icon(
                            Icons.favorite_border_rounded,
                            size: 30,
                            //color: Colors.black,
                          ),
                  ),
                ),
                IconButton(
                  //onPressed: (){},
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                            snap: widget.snap,
                          ))),
                  icon: const Icon(
                    Icons.comment_outlined,
                    size: 30,
                  ),
                ),

                //   const Spacer(),
                //   IconButton(
                //     onPressed: () {},
                //     icon: const Icon(
                //       Icons.bookmark_border_rounded,
                //       size: 30,
                //     ),
                //   ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.snap['likes'].length} likes',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text: ' ${widget.snap['description']}',
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: commentsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final commentCount = snapshot.data?.docs.length ?? 0;
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CommentsScreen(
                                snap: widget.snap,
                              ),
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Text(
                              'view all $commentCount comments',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Text(
                    DateFormat.yMMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showOptionsDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Options for the post'),
  //       // content: const Text(''),
  //       actions: [
  //         TextButton(onPressed: () {}, child: const Text('Edit')),
  //         TextButton(onPressed: () {}, child: const Text('Delete')),
  //       ],
  //     ),
  //   );
  // }
}
