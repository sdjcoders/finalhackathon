import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gonomad/features/auth/screen/profile_screen.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   bool isShowUsers = false;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: TextFormField(
//           controller: _searchController,
//           decoration: const InputDecoration(
//             labelText: 'Search for a user',
//           ),
//           onFieldSubmitted: (_) {
//             setState(() {
//               isShowUsers = true;
//             });
//           },
//         ),
//         flexibleSpace: ClipRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(
//               sigmaX: 9,
//               sigmaY: 9,
//             ),
//             child: Container(
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//         ),
//       ),
//       body: isShowUsers
//           ? FutureBuilder<QuerySnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('users')
//                   .where('username',
//                       isGreaterThanOrEqualTo: _searchController.text)
//                   .get(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No users found.'));
//                 }
//                 // Filter the snapshot data based on the search query
//                 final filteredData = snapshot.data!.docs.where((doc) {
//                   final userData = doc.data() as Map<String, dynamic>;
//                   final username = userData['username'] as String;
//                   return username.startsWith(_searchController.text);
//                 }).toList();
//                 if (filteredData.isEmpty) {
//                   return const Center(child: Text('No users found.'));
//                 }
//                 return ListView.builder(
//                   itemCount: filteredData.length,
//                   itemBuilder: (context, index) {
//                     final userData =
//                         filteredData[index].data() as Map<String, dynamic>;
//                     return InkWell(
//                       onTap: () => Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => ProfileScreen(
//                             uid: userData['uid'],
//                           ),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             radius: 64,
//                             backgroundImage: CachedNetworkImageProvider(
//                               userData['photoUrl'] ??
//                                   '', // Provide a default value
//                             ),
//                           ),
//                           title: Text(
//                             userData['username'],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             )
//           : FutureBuilder<QuerySnapshot>(
//               future: FirebaseFirestore.instance.collection('posts').get(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No posts found.'));
//                 }
//                 return StaggeredGridView.countBuilder(
//                   shrinkWrap: true,
//                   crossAxisCount: 3,
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final post = snapshot.data!.docs[index].data()
//                         as Map<String, dynamic>;
//                     return CachedNetworkImage(
//                       imageUrl: post['postUrl'],
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) =>
//                           const Center(child: CircularProgressIndicator()),
//                       errorWidget: (context, url, error) =>
//                           const Icon(Icons.error),
//                     );
//                   },
//                   staggeredTileBuilder: (index) => StaggeredTile.count(
//                     index % 7 == 0 ? 2 : 1,
//                     index % 7 == 0 ? 2 : 1,
//                   ),
//                   mainAxisSpacing: 4,
//                   crossAxisSpacing: 4,
//                 );
//               },
//             ),
//     );
//   }
// }

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a user',
          ),
          onChanged: (value) {
            setState(() {
              isShowUsers = value.isNotEmpty;
            });
          },
        ),
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
      ),
      body: isShowUsers ? _buildUserSuggestions() : _buildPostGrid(),
    );
  }

  Widget _buildUserSuggestions() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: _searchController.text)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        // Filter the snapshot data based on the search query
        final filteredData = snapshot.data!.docs.where((doc) {
          final userData = doc.data() as Map<String, dynamic>;
          final username = userData['username'] as String;
          return username.startsWith(_searchController.text);
        }).toList();
        if (filteredData.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final userData = filteredData[index].data() as Map<String, dynamic>;
            return InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    uid: userData['uid'],
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 64,
                    backgroundImage: CachedNetworkImageProvider(
                      userData['photoUrl'] ?? '', // Provide a default value
                    ),
                  ),
                  title: Text(userData['username']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostGrid() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('posts').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts found.'));
        }
        return StaggeredGridView.countBuilder(
          shrinkWrap: true,
          crossAxisCount: 3,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return CachedNetworkImage(
              imageUrl: post['postUrl'],
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
          staggeredTileBuilder: (index) => StaggeredTile.count(
            index % 7 == 0 ? 2 : 1,
            index % 7 == 0 ? 2 : 1,
          ),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        );
      },
    );
  }
}
