import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Notifications'),
            leading: Icon(Icons.notifications),
            trailing: Switch(
              value:
                  true, // Example value, you can replace it with a dynamic value based on user preference
              onChanged: (value) {
                // Handle switch state change
              },
            ),
          ),
          ListTile(
            title: Text('Dark Mode'),
            leading: Icon(Icons.dark_mode),
            trailing: Switch(
              value:
                  false, // Example value, you can replace it with a dynamic value based on user preference
              onChanged: (value) {
                // Handle switch state change
              },
            ),
          ),
          ListTile(
            title: Text('Language'),
            leading: Icon(Icons.language),
            onTap: () {
              // Navigate to language selection screen
              // You can implement this navigation similar to the About Us screen navigation
            },
          ),
          ListTile(
            title: Text('Change Password'),
            leading: Icon(Icons.lock),
            onTap: () {
              // Navigate to change password screen
            },
          ),
          ListTile(
            title: Text('Privacy Policy'),
            leading: Icon(Icons.privacy_tip),
            onTap: () {
              // Navigate to privacy policy screen
            },
          ),
          ListTile(
            title: Text('Terms of Service'),
            leading: Icon(Icons.description),
            onTap: () {
              // Navigate to terms of service screen
            },
          ),
          ListTile(
            title: Text('Log Out'),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              // Handle log out action
            },
          ),
          // Add more settings options as needed
        ],
      ),
    );
  }
}
