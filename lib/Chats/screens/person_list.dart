// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'chat_screen.dart'; // Import ChatScreen
// import 'package:gonomad/models/chat_user.dart'; // Import the ChatUser class
//
// class PersonList extends StatefulWidget {
//   const PersonList({Key? key}) : super(key: key);
//
//   @override
//   State<PersonList> createState() => _PersonListState();
// }
//
// class _PersonListState extends State<PersonList> {
//   late Future<DocumentSnapshot> _userDataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _userDataFuture = _getUserData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Users'),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: _userDataFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('User not found.'));
//           } else {
//             List<dynamic> following = snapshot.data!.get('following') ?? [];
//             if (following.isNotEmpty) {
//               return ListView.builder(
//                 itemCount: following.length,
//                 itemBuilder: (context, index) {
//                   return _buildUserTile(following[index]);
//                 },
//               );
//             } else {
//               return const Center(child: Text('No followers found.'));
//             }
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildUserTile(String userId) {
//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting ||
//             !snapshot.hasData ||
//             !snapshot.data!.exists) {
//           return const SizedBox.shrink();
//         }
//         Map<String, dynamic> userData =
//         snapshot.data!.data() as Map<String, dynamic>;
//
//         String? photoUrl = userData['photoUrl'] as String?;
//
//         // Check if photoUrl is not null or empty
//         if (photoUrl != null && photoUrl.isNotEmpty) {
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundImage: CachedNetworkImageProvider(photoUrl),
//             ),
//             title: Text(userData['username'] ?? ''),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChatScreen(user: ChatUser.fromJson(userData)),
//                 ),
//               );
//             },
//           );
//         } else {
//           // Provide a default avatar image if photoUrl is null or empty
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundImage: AssetImage('assets/images/default_avatar.png'),
//             ),
//             title: Text(userData['username'] ?? ''),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChatScreen(user: ChatUser.fromJson(userData)),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
//
//   Future<DocumentSnapshot> _getUserData() async {
//     final String uid = FirebaseAuth.instance.currentUser!.uid;
//     return FirebaseFirestore.instance.collection('users').doc(uid).get();
//   }
// }
// PersonList
import 'package:flutter/material.dart';
import 'package:tripsathihackathon/chats/apis/apis.dart'; // Import the file where APIs are defined
import 'package:tripsathihackathon/models/chat_user.dart'; // Import the ChatUser class
import 'package:tripsathihackathon/chats/widgets/chat_user_card.dart'; // Import the ChatUserCard widget
import 'package:tripsathihackathon/chats/screens/chat_screen.dart'; // Import the ChatScreen widget

class PersonList extends StatefulWidget {
  final List<ChatUser> usersDisplayedInHomeScreen;

  const PersonList({Key? key, required this.usersDisplayedInHomeScreen}) : super(key: key);

  @override
  _PersonListState createState() => _PersonListState();
}

class _PersonListState extends State<PersonList> with TickerProviderStateMixin {
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    APIs.getAllUsers().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        setState(() {
          _list = [];
        });
      } else {
        setState(() {
          List<ChatUser> homeScreenUsers = widget.usersDisplayedInHomeScreen;
          _list = snapshot.docs
              .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
              .where((user) => user.id != APIs.user.uid) // Filter out the user's own profile
              .where((user) => !homeScreenUsers.any((homeUser) => homeUser.id == user.id)) // Filter out users displayed in HomeScreen
              .toList();
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Person List'),
      ),
      body: _list.isNotEmpty
          ? ListView.builder(
        itemCount: _isSearching ? _searchList.length : _list.length,
        padding: EdgeInsets.only(top: mq.size.height * .01),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return ChatUserCard(
            user: _isSearching ? _searchList[index] : _list[index],
          );
        },
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}