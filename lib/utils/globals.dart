import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripsathihackathon/chatbot/chatbot.dart';
import 'package:tripsathihackathon/screens/home.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/add_post.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/maps.dart';
import 'package:tripsathihackathon/screens/tabs%20and%20widgets/profile/view_profile_screen.dart';

List<Widget> homeScreenItems = [
  const homepage(),
  ChatPage(),
  const AddPostScreen(),
  Maping(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  )
];
