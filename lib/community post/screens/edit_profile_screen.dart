import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tripsathihackathon/auth/storage_methods.dart';
import 'package:tripsathihackathon/providers/user_provider.dart';
import 'package:tripsathihackathon/utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;

  const EditProfileScreen({required this.uid, Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Uint8List _image = Uint8List.fromList([]);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  Map<String, dynamic>? userData;

  void initState() {
    super.initState();
    // Fetch user data from Firebase and populate the controllers
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get() as DocumentSnapshot<Map<String, dynamic>>;

      // Access the data from the snapshot
      userData = userDataSnapshot.data();

      if (userData != null) {
        // Set the text of the controllers with the fetched data
        setState(() {
          _usernameController.text = userData!['username'];
          _bioController.text = userData!['bio'];
          _image = Uint8List(0);
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Container(
          width: screenSize.width * 0.95,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white70.withOpacity(0.4),
                Colors.white70.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfilePicture(),
              SizedBox(height: screenSize.height * 0.032),
              _buildTextField(
                hintText: 'Enter Username',
                controller: _usernameController,
              ),
              SizedBox(height: screenSize.height * 0.022),
              _buildTextField(
                hintText: 'Enter Bio',
                controller: _bioController,
              ),
              SizedBox(height: screenSize.height * 0.032),
              _buildSaveButton(screenSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _image.isEmpty
            ? userData != null && userData!['photoUrl'] != null
                ? CircleAvatar(
                    radius: 64,
                    backgroundImage:
                        CachedNetworkImageProvider(userData!['photoUrl']),
                  )
                : CircleAvatar(
                    radius: 64,
                    child: Icon(Icons.account_circle,
                        size: 64), // Placeholder icon if photoUrl is null
                  )
            : CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(_image),
              ),
        IconButton(
          onPressed: selectImage,
          icon: Icon(Icons.add_a_photo),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      controller: controller,
    );
  }

  Widget _buildSaveButton(Size screenSize) {
    return ElevatedButton(
      onPressed: saveChanges,
      child: Text(
        'Save Changes',
        style: GoogleFonts.josefinSans(),
      ),
    );
  }

  void selectImage() async {
    final Uint8List? img = await pickAndCompressImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  void saveChanges() async {
    try {
      // Get the current user data
      final String currentUsername = userData!['username'];
      final String currentBio = userData!['bio'];
      final String currentPhotoUrl = userData!['photoUrl'];

      // Get the new data entered by the user
      final String newUsername = _usernameController.text;
      final String newBio = _bioController.text;
      final Uint8List newProfilePicture = _image;

      // Check if any data has changed
      final bool isNameChanged = currentUsername != newUsername;
      final bool isBioChanged = currentBio != newBio;
      final bool isProfilePictureChanged = _image.isNotEmpty;

      if (isNameChanged || isBioChanged || isProfilePictureChanged) {
        // Prepare the updated user data
        final Map<String, dynamic> updatedUserData = {};
        final Map<String, dynamic> updatedCpostData = {};
        final Map<String, dynamic> updatedCommentData = {};

        // Update username if changed
        if (isNameChanged) {
          updatedUserData['username'] = newUsername;
          updatedCpostData['username'] = newUsername;

          updatedCommentData['username'] = newUsername;
        }

        // Update bio if changed
        if (isBioChanged) {
          updatedUserData['bio'] = newBio;
        }

        // Update profile picture if changed
        if (isProfilePictureChanged) {
          // Upload the new profile picture to Firestore Storage
          final String photoUrl = await uploadProfilePicture(newProfilePicture);

          // Update photoUrl field with the new download URL
          updatedUserData['photoUrl'] = photoUrl;
        }

        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .update(updatedUserData);

        // Update username in 'cposts' collection if username changed
        if (isNameChanged) {
          final QuerySnapshot cpostSnapshot = await FirebaseFirestore.instance
              .collection('cposts')
              .where('uid', isEqualTo: widget.uid)
              .get();

          for (final doc in cpostSnapshot.docs) {
            try {
              // Update the username field for each document
              await doc.reference.update({'username': newUsername});
            } catch (error) {
              print('Error updating username in document: $error');
              // Handle error as needed
            }
          }
        }

        if (isNameChanged) {
          final QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
              .collection('ccomments')
              .where('userId', isEqualTo: widget.uid)
              .get();

          for (final doc in commentSnapshot.docs) {
            try {
              // Update the username field for each document
              await doc.reference.update({'username': newUsername});
            } catch (error) {
              print('Error updating username in comment: $error');
              // Handle error as needed
            }
          }
        }

        await Provider.of<UserProvider>(context, listen: false).refreshUser();

        // Navigate back to the profile screen
        Navigator.pop(context);
      } else {
        // No changes were made, show a message or handle it accordingly
        print('No changes were made.');
      }
    } catch (error) {
      // Handle error
      print('Error saving changes: $error');
      // You may want to show an error message to the user
    }
  }

  Future<String> uploadProfilePicture(Uint8List image) async {
    try {
      // Upload the new image to Firestore Storage
      final String photoUrl = await Storagemethods()
          .uploadImageToStorage('profile_pictures', image, false);
      return photoUrl;
    } catch (error) {
      // Handle error
      print('Error uploading profile picture: $error');
      // You may want to show an error message to the user
      rethrow; // Rethrow the error to handle it in the caller
    }
  }
}
