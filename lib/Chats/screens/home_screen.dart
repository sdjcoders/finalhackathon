
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tripsathihackathon/chats/apis/apis.dart';
import 'package:tripsathihackathon/chats/screens/chat_screen.dart';
import 'package:tripsathihackathon/chats/screens/person_list.dart';

import 'package:tripsathihackathon/screens/navbar.dart';

import 'package:tripsathihackathon/chats/helper/dialogs.dart';


import 'package:tripsathihackathon/chats/widgets/chat_user_card.dart';
import 'package:tripsathihackathon/chats/screens/profile_screen.dart';

import 'package:tripsathihackathon/models/chat_user.dart';
import 'package:tripsathihackathon/models/message.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    String name = APIs.user.displayName.toString();
    String email = APIs.user.email.toString();
    String photoURL = APIs.user.photoURL.toString();
    APIs.getSelfInfo(name, email, photoURL);

    _tabController =
        TabController(length: 1, vsync: this); // Changed length to 1

    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });

    _fetchRecentMessages(); // Fetch recent messages when the screen initializes
  }

  void _fetchRecentMessages() {
    APIs.getAllUsers().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<ChatUser> users = snapshot.docs
            .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
            .where((user) => user.id != APIs.user.uid)
            .toList();

        // Fetch recent messages for each user
        Future.wait(users.map((user) => getRecentMessage(user)))
            .then((List<Message?> messages) {
          // Filter users with recent messages
          List<ChatUser> recentMessageUsers = [];
          for (int i = 0; i < users.length; i++) {
            if (messages[i] != null) {
              recentMessageUsers.add(users[i]);
            }
          }

          // Update the _list with users who have recent messages
          setState(() {
            _list = recentMessageUsers;
          });
        });
      }
    });
  }

  Future<Message?> getRecentMessage(ChatUser chatUser) async {
    try {
      // Query to get messages sent to the chat user
      var sentMessagesQuery = FirebaseFirestore.instance
          .collection('chatting')
          .doc(APIs.getConversationID(chatUser.id))
          .collection('messages')
          .where('fromId', isEqualTo: APIs.user.uid)
          .orderBy('sent', descending: true)
          .limit(1);

      // Query to get messages received from the chat user
      var receivedMessagesQuery = FirebaseFirestore.instance
          .collection('chatting')
          .doc(APIs.getConversationID(chatUser.id))
          .collection('messages')
          .where('toId', isEqualTo: APIs.user.uid)
          .orderBy('sent', descending: true)
          .limit(1);

      // Execute both queries
      var sentMessages = await sentMessagesQuery.get();
      var receivedMessages = await receivedMessagesQuery.get();

      // Combine the results and get the most recent message
      var allMessages = [...sentMessages.docs, ...receivedMessages.docs];
      allMessages.sort((a, b) => b['sent'].compareTo(a['sent']));

      if (allMessages.isNotEmpty) {
        // If there are messages, return the most recent one
        return Message.fromJson(
            allMessages.first.data() as Map<String, dynamic>);
      } else {
        // If there are no messages, return null
        return null;
      }
    } catch (error) {
      // Handle errors, such as Firestore query errors
      print('Error fetching messages: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalFeed()),
                );
              },
            ),
            title: _isSearching
                ? TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Name, Email, ...'),
              autofocus: true,
              style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
              onChanged: (val) {
                _searchList.clear();

                for (var i in _list) {
                  if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())) {
                    _searchList.add(i);
                    setState(() {
                      _searchList;
                    });
                  }
                }
              },
            )
                : const Text('We Chat'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat),
                      SizedBox(width: 5),
                      Text('Chats'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        user: APIs.me,
                        uid: '',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.more_vert),
              )
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PersonList(usersDisplayedInHomeScreen: _list),
                  ),
                );
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ListView.builder(
                itemCount: _isSearching
                    ? _searchList.length
                    : (_list.isNotEmpty ? _list.length : 1),
                itemBuilder: (context, index) {
                  if (_isSearching && _searchList.isEmpty) {
                    return ListTile(
                      title: Text(
                        'No results found',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  } else if (!_isSearching && _list.isEmpty) {
                    return ListTile(
                      title: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 250),
                          child: Text(
                            'No Recent Chats',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  } else {
                    final chatUser =
                    _isSearching ? _searchList[index] : _list[index];
                    return ChatUserCard(
                        user: chatUser); // Use ChatUserCard here
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
