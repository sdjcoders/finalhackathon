import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsathihackathon/community/drawer/drawers.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {},
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
      ),
      drawer: const CommunityList(),
      body: Container(
          color: const Color.fromARGB(255, 229, 238, 245),
          child: Center(child: Text('HomePage'))),
    );
  }
}
