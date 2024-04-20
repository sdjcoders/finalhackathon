import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsathihackathon/community/constants/constants.dart';

import 'package:tripsathihackathon/community/constants/error.dart';
import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/community/constants/utils.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';
import 'package:tripsathihackathon/models/community_model.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;

  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;
//  Uint8List? bannerWebFile;
//   Uint8List? profileWebFile;

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref.read(CommunityControllerProvider.notifier).editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          community: community,
          // profileWebFile: profileWebFile,
          // bannerWebFile: bannerWebFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(CommunityControllerProvider);
    //final  currenttheme =ref.watch(themeNotifierProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (Community) => Scaffold(
              //backgroundColor: currenttheme.colorScheme.background,
              appBar: AppBar(
                title: const Text('Edit community'),
                centerTitle: false,
                actions: [
                  TextButton(
                      onPressed: () => save(Community),
                      child: const Text('Save'))
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(children: [
                              GestureDetector(
                                onTap: selectBannerImage,
                                child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    //  color: currenttheme.textTheme.bodyMedium!.color!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : Community.banner.isEmpty ||
                                                  Community.banner ==
                                                      Constants.banner
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  ),
                                                )
                                              : Image.network(Community.banner),
                                    )),
                              ),
                              Positioned(
                                left: 20,
                                bottom: 20,
                                child: GestureDetector(
                                  onTap: selectProfileImage,
                                  child: profileFile != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(profileFile!),
                                          radius: 32,
                                        )
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(Community.avator),
                                          radius: 32,
                                        ),
                                ),
                              )
                            ]),
                          )
                        ],
                      ),
                    ),
            ),
        error: (error, StackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
