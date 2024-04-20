import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to TripSaathi!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'TripSaathi is a unique travel companion app designed to enhance your travel experience. Here are some key features:',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            // List of key features
            FeatureItem(
              icon: Icons.chat,
              text: 'Connect with people and chat',
            ),
            FeatureItem(
              icon: Icons.group,
              text: 'Create and join groups',
            ),
            FeatureItem(
              icon: Icons.public,
              text: 'Engage with the community',
            ),
            FeatureItem(
              icon: Icons.attach_money,
              text: 'Track trip expenses',
            ),
            FeatureItem(
              icon: Icons.location_on,
              text: 'View live location',
            ),
            FeatureItem(
              icon: Icons.post_add,
              text: 'Create and delete posts',
            ),
            // Add more feature items as needed
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24.0),
          SizedBox(width: 10.0),
          Text(text),
        ],
      ),
    );
  }
}
