// // ignore_for_file: no_leading_underscores_for_local_identifiers

// import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:provider/provider.dart';
// import 'package:tripsathihackathon/models/usermodel.dart';
// import 'package:tripsathihackathon/providers/user_provider.dart';
// import 'package:tripsathihackathon/utils/globals.dart';

// class PersonalFeed extends StatefulWidget {
//   const PersonalFeed({Key? key}) : super(key: key);

//   @override
//   State<PersonalFeed> createState() => _PersonalFeedState();
// }

// class _PersonalFeedState extends State<PersonalFeed> {
//   int _page = 0;
//   late PageController pageController;

//   @override
//   void initState() {
//     super.initState();
//     pageController = PageController();
//     addData();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top]);

//     // Make the system navigation gesture transparent
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.dark,
//         systemNavigationBarColor: Colors.transparent,
//         systemNavigationBarDividerColor: Colors.white70.withOpacity(0.3),
//         systemNavigationBarIconBrightness: Brightness.dark,
//       ),
//     );
//   }

//   void addData() async {
//     UserProvider _userProvider = Provider.of(context, listen: false);
//     await _userProvider.refreshUser();
//   }

//   void navigationTapped(int page) {
//     pageController.jumpToPage(page);
//   }

//   void onPageChange(int page) {
//     setState(() {
//       _page = page;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final User? user = Provider.of<UserProvider>(context).getUser;

//     if (user != null) {
//       return Scaffold(
//         resizeToAvoidBottomInset:
//             false, // Prevents resizing when keyboard appears
//         body: Stack(
//           children: [
//             PageView(
//               physics: const NeverScrollableScrollPhysics(),
//               controller: pageController,
//               onPageChanged: onPageChange,
//               children: homeScreenItems,
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: ClipRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                   child: Container(
//                     height: 70,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.4),
//                       // boxShadow: [
//                       //   BoxShadow(
//                       //     color: Colors.white.withOpacity(0.3),
//                       //     spreadRadius: 2,
//                       //     blurRadius: 5,
//                       //     offset: const Offset(0, 8),
//                       //   ),
//                       // ],
//                     ),
//                     child: CupertinoTabBar(
//                       height: 65,
//                       // border: Border(
//                       //   top: BorderSide(
//                       //     color: Colors.grey.withOpacity(0.2),
//                       //     width: 0.5,
//                       //   ),
//                       // ),
//                       iconSize: 28,
//                       backgroundColor: Colors.transparent,
//                       items: [
//                         BottomNavigationBarItem(
//                           icon: Center(
//                             child: _page == 0
//                                 ? Icon(Icons.home,
//                                     color: Color.fromARGB(255, 6, 6, 6))
//                                 : Icon(Icons.home_outlined,
//                                     color: Color.fromARGB(255, 6, 6, 6)),
//                           ),
//                         ),
//                         // BottomNavigationBarItem(
//                         //   icon: _page == 1
//                         //       ? Icon(Icons.trending_up,
//                         //           color: Color.fromARGB(255, 6, 6, 6))
//                         //       : Icon(Icons.trending_up_rounded,
//                         //           color: Color.fromARGB(255, 6, 6, 6)),
//                         // ),
//                         BottomNavigationBarItem(
//                           icon: _page == 1
//                               ? Icon(Icons.add_box,
//                                   color: Color.fromARGB(255, 6, 6, 6))
//                               : Icon(Icons.add_box_outlined,
//                                   color: Color.fromARGB(255, 6, 6, 6)),
//                         ),
//                         BottomNavigationBarItem(
//                           icon: _page == 2
//                               ? Icon(Icons.location_on,
//                                   color: Color.fromARGB(255, 6, 6, 6))
//                               : Icon(Icons.location_on_outlined,
//                                   color: Color.fromARGB(255, 6, 6, 6)),
//                         ),
//                         BottomNavigationBarItem(
//                           icon: CircleAvatar(
//                             radius: 15.0,
//                             backgroundImage:
//                                 CachedNetworkImageProvider(user.photoUrl),
//                           ),
//                         ),
//                       ],
//                       onTap: navigationTapped,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }

//   @override
//   void dispose() {
//     // Restore the system navigation gesture color
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         systemNavigationBarColor: Colors.transparent,
//       ),
//     );

//     pageController.dispose(); // Dispose of the page controller
//     super.dispose();
//   }
// }
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:tripsathihackathon/models/usermodel.dart';
import 'package:tripsathihackathon/providers/user_provider.dart';
import 'package:tripsathihackathon/utils/globals.dart';

class PersonalFeed extends StatefulWidget {
  const PersonalFeed({Key? key}) : super(key: key);

  @override
  State<PersonalFeed> createState() => _PersonalFeedState();
}

class _PersonalFeedState extends State<PersonalFeed> {
  int _page = 0;
  late PageController pageController;
  bool _isSystemNavBarVisible = true; // Track system navigation bar visibility
  Timer? _timer; // Timer to hide system navigation bar

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    addData();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    // Make the system navigation gesture transparent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.white70.withOpacity(0.3),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    hideNavigationBar(); // Hide initially
    _startTimer(); // Start timer to hide navigation bar
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isSystemNavBarVisible = false;
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _startTimer();
  }

  void hideNavigationBar() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
  }

  void addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    if (user != null) {
      return Scaffold(
        resizeToAvoidBottomInset:
            false, // Prevents resizing when keyboard appears
        body: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              onPageChanged: onPageChange,
              children: homeScreenItems,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.white.withOpacity(0.3),
                      //     spreadRadius: 2,
                      //     blurRadius: 5,
                      //     offset: const Offset(0, 8),
                      //   ),
                      // ],
                    ),
                    child: CupertinoTabBar(
                      height: 65,
                      // border: Border(
                      //   top: BorderSide(
                      //     color: Colors.grey.withOpacity(0.2),
                      //     width: 0.5,
                      //   ),
                      // ),
                      iconSize: 28,
                      backgroundColor: Colors.transparent,
                      items: [
                        BottomNavigationBarItem(
                          icon: Center(
                            child: _page == 0
                                ? Icon(Icons.home,
                                    color: Color.fromARGB(255, 6, 6, 6))
                                : Icon(Icons.home_outlined,
                                    color: Color.fromARGB(255, 6, 6, 6)),
                          ),
                        ),
                        // BottomNavigationBarItem(
                        //   icon: _page == 1
                        //       ? Icon(Icons.trending_up,
                        //           color: Color.fromARGB(255, 6, 6, 6))
                        //       : Icon(Icons.trending_up_rounded,
                        //           color: Color.fromARGB(255, 6, 6, 6)),
                        // ),
                        BottomNavigationBarItem(
                          icon: _page == 1
                              ? Icon(Icons.add_box,
                                  color: Color.fromARGB(255, 6, 6, 6))
                              : Icon(Icons.add_box_outlined,
                                  color: Color.fromARGB(255, 6, 6, 6)),
                        ),
                        BottomNavigationBarItem(
                          icon: _page == 2
                              ? Icon(Icons.location_on,
                                  color: Color.fromARGB(255, 6, 6, 6))
                              : Icon(Icons.location_on_outlined,
                                  color: Color.fromARGB(255, 6, 6, 6)),
                        ),
                        BottomNavigationBarItem(
                          icon: CircleAvatar(
                            radius: 15.0,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                        ),
                      ],
                      onTap: navigationTapped,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    // Restore the system navigation gesture color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    pageController.dispose(); // Dispose of the page controller
    super.dispose();
  }
}
