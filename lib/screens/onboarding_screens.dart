import 'package:flutter/material.dart';

import 'package:tripsathihackathon/screens/onboard_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPageIndex < 2) {
      // Assuming there are 3 pages including the last one
      setState(() {
        _currentPageIndex++;
      });
      _pageController.animateToPage(
        _currentPageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BackgroundVideo()),
      );
    }
  }

  Widget _buildPage(
      {required String image,
      required String title,
      required String subtitle}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 30.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPage(
      {required String image,
      required String buttonText,
      required String title,
      required String subtitle}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 150.0), // Adjusted padding
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 20.0), // Adjusted height
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0), // Adjusted height
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 40.0), // Adjusted height
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BackgroundVideo()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              backgroundColor: Colors.blue, // Blue color
              textStyle: TextStyle(color: Colors.white), // Text color
            ),
            child: Text(
              buttonText,
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        SizedBox(width: 8.0),
        _buildDot(1),
        SizedBox(width: 8.0),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPageIndex == index ? Colors.blue : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                _buildPage(
                  image: 'assets/images/8.jpeg',
                  title: 'Welcome to TripSaathi!',
                  subtitle: 'Your passport to endless adventures awaits.',
                ),
                _buildPage(
                  image: 'assets/images/7.jpg',
                  title: 'Discover',
                  subtitle: 'Explore new places tailored just for you.',
                ),
                _buildLastPage(
                  image: 'assets/images/10.jpeg',
                  title: 'Connect',
                  subtitle:
                      'Traveling solo doesn\'t mean traveling alone. It means embarking on a journey where strangers become friends and every moment is an adventure.',
                  buttonText: 'Get Started',
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0), // Adjusted space
          _buildIndicator(),
          SizedBox(height: 20.0), // Adjusted space
        ],
      ),
    );
  }
}
