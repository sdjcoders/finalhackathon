// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsathihackathon/community%20post/controller/add_Cpost_controller.dart';
import 'package:tripsathihackathon/community/constants/error.dart';
import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/community/constants/utils.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';
import 'package:tripsathihackathon/models/community_model.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final LinkController = TextEditingController();

  File? bannerFile;
  File? profileFile;
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    LinkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            file: bannerFile,
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            description: descriptionController.text.trim(),
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        LinkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            link: LinkController.text.trim(),
          );
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    // final  currenttheme =ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Post ${widget.type}'), actions: [
        TextButton(onPressed: sharePost, child: const Text('Share')),
      ]),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter title here',
                        filled: true,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLength: 30,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (isTypeImage)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            dashPattern: const [10, 4],
                            strokeCap: StrokeCap.round,
                            //   color: currenttheme.textTheme.bodyMedium!.color!,
                            child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: bannerFile != null
                                    ? Image.file(bannerFile!)
                                    : const Center(
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        ),
                                      ))),
                      ),
                    ),
                  if (isTypeText)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter description here',
                          filled: true,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 5,
                      ),
                    ),
                  if (isTypeLink)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: LinkController,
                        decoration: InputDecoration(
                          hintText: 'Enter Link here',
                          filled: true,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Select Community',
                          style: TextStyle(fontSize: 17),
                        )),
                  ),
                  ref.watch(userCommunitiesProvider).when(
                        data: (data) {
                          communities = data;

                          if (data.isEmpty) {
                            return const SizedBox();
                          }
                          return DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e.name)))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                              });
                            },
                          );
                        },
                        loading: () => const Loader(),
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                      )
                ],
              ),
            ),
    );
  }
}
