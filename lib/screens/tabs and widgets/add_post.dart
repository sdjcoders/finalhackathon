import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    as riverpod; // Import riverpod with an 'as' prefix

import 'package:provider/provider.dart';

import 'package:routemaster/routemaster.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsathihackathon/community%20post/screens/add_post_type_screen.dart';
import 'package:tripsathihackathon/models/usermodel.dart';
import 'package:tripsathihackathon/providers/firebase_storage.dart';
import 'package:tripsathihackathon/providers/user_provider.dart';
import 'package:tripsathihackathon/utils/utils.dart';

// Import your existing AddPostScreen

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Posts',
            style: GoogleFonts.lobster(
              color: Colors.black,
              fontSize: 26.0,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Post'),
              Tab(text: 'Community Post'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PostTab(),
            CommunityPostScreen(),
          ],
        ),
      ),
    );
  }
}

class PostTab extends StatefulWidget {
  @override
  _PostTabState createState() => _PostTabState();
}

class _PostTabState extends State<PostTab> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void postImage(
    String uid,
    String username,
    String profileImage,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
          _descriptionController.text, _file!, uid, username, profileImage);
      if (res == "success") {
        setState(() {
          _isLoading = false;
          _descriptionController.clear();
        });
        clearImage();
        showSnackBar(
          "Post Uploaded",
          context,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(
          res,
          context,
        );
      }
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  _selectImage(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          alignment: Alignment.center,
          title: const Text(
            'Create Post',
          ),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List? file =
                    await pickAndCompressImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
              child: const Text('Take a Photo'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                Uint8List? file =
                    await pickAndCompressImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
              child: const Text('Choose from Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    return SingleChildScrollView(
      child: Column(
        children: [
          _isLoading
              ? const LinearProgressIndicator()
              : const Padding(padding: EdgeInsets.only(top: 0)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              CachedNetworkImage(
                imageUrl: user!.photoUrl,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 32.0,
                  backgroundImage: imageProvider,
                ),
                errorWidget: (context, url, error) => const Icon(
                    Icons.error), // Widget to show when loading fails
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.66,
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: "What's on your mind...",
                    hintStyle: GoogleFonts.balooPaaji2(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 140,
          ),
          SizedBox(
            height: 350,
            width: 390,
            child: _file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.memory(
                      _file!,
                      fit: BoxFit.cover,
                    ),
                  )
                : GestureDetector(
                    onTap: () => _selectImage(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              size: 50,
                              Icons.upload_rounded,
                              color: Colors.black,
                            ),
                            Text("Select Image To Post")
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          TextButton(
            onPressed: () => postImage(user.uid, user.username, user.photoUrl),
            child: const Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

class CommunityPostScreen extends riverpod.ConsumerWidget {
  const CommunityPostScreen({super.key});

  void navigateToType(BuildContext context, String type) {
    //Routemaster.of(context).push('/add-post/$type');
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddPostTypeScreen(type: type)));
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    double CardHeightWidth = 120;
    double iconSize = 60;
    //final  currenttheme =ref.watch(themeNotifierProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Post Image'),
            GestureDetector(
              onTap: () => navigateToType(context, 'image'),
              child: SizedBox(
                height: CardHeightWidth,
                width: CardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  // color: currenttheme.colorScheme.background,
                  elevation: 16,
                  child: Center(
                      child: Icon(
                    Icons.image_outlined,
                    size: iconSize,
                  )),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Post Text'),
            GestureDetector(
              onTap: () => navigateToType(context, 'text'),
              child: SizedBox(
                height: CardHeightWidth,
                width: CardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  //color: currenttheme.colorScheme.background,
                  elevation: 16,
                  child: Center(
                      child: Icon(
                    Icons.font_download_outlined,
                    size: iconSize,
                  )),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Post Link'),
            GestureDetector(
              onTap: () => navigateToType(context, 'link'),
              child: SizedBox(
                height: CardHeightWidth,
                width: CardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  // color: currenttheme.colorScheme.background,
                  elevation: 16,
                  child: Center(
                      child: Icon(
                    Icons.link_outlined,
                    size: iconSize,
                  )),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
