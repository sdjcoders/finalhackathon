import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripsathihackathon/screens/login.dart';
import 'package:tripsathihackathon/screens/signup.dart';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class BackgroundVideo extends StatefulWidget {
  const BackgroundVideo({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BackgroundVideoState createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  late VideoPlayerController _videoPlayerController;
  // ignore: unused_field
  late Future<void> _initializeVideoPlayerFuture;
  final List<String> videoPaths = [
    'assets/images/1.mp4',
    'assets/images/2.mp4',
    'assets/images/3.mp4',
    'assets/images/4.mp4',
    'assets/images/5.mp4',
    'assets/images/6.mp4',
    'assets/images/7.mp4',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _initializeRandomVideo();
  }

  void _initializeRandomVideo() {
    final Random random = Random();
    final int randomIndex = random.nextInt(videoPaths.length);
    final String randomVideoPath = videoPaths[randomIndex];
    _videoPlayerController = VideoPlayerController.asset(randomVideoPath)
      ..initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController.setVolume(0.0); // Mute the video audio
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          automaticallyImplyLeading: false,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPlayerController.value.size.width,
                height: _videoPlayerController.value.size.height,
                child: AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: SafeArea(
                    child: Chewie(
                      controller: ChewieController(
                        videoPlayerController: _videoPlayerController,
                        autoPlay: true,
                        looping: true,
                        showControls: false,
                        placeholder: Container(),
                        overlay: Container(),
                        materialProgressColors: ChewieProgressColors(
                          playedColor: Colors.transparent,
                          handleColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          bufferedColor: Colors.transparent,
                        ),
                        allowMuting: false,
                        autoInitialize: true,
                        allowPlaybackSpeedChanging: false,
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        deviceOrientationsAfterFullScreen: [
                          DeviceOrientation.portraitUp
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Overlay text fields on the video
          Positioned(
            top: 570,
            left: 20,
            right: 20,
            child: Column(
              children: [
                buildFrostedButton(
                  context,
                  'NEW USER? SIGNUP',
                  iconData: Icons.person,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                buildFrostedButton(
                  context,
                  'CONTINUE SIGN IN',
                  iconData: Icons.login,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                ),
                // const SizedBox(height: 16),
                // GoogleButton(
                //   onPressed: () {

                //     // Perf
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}

Widget buildFrostedButton(
  BuildContext context,
  String buttonText, {
  IconData? iconData,
  String? customImagePath,
  VoidCallback? onPressed,
}) {
  final Size size = MediaQuery.of(context).size;
  final double buttonWidth = size.width * 0.82;
  const double buttonHeight = 52.0;

  return Container(
    height: buttonHeight,
    width: buttonWidth,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18.0),
      color: Colors.grey.withOpacity(0.3),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 30.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(iconData),
                )
              else if (customImagePath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    customImagePath,
                    height: 35,
                    width: 35,
                  ),
                ),
              Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
