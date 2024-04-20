import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    ref
        .read(CommunityControllerProvider.notifier)
        .createCommunity(communityNameController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(CommunityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a community'),
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      child: Text('Create your Trip Community Name ')),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: communityNameController,
                    decoration: InputDecoration(
                        hintText: 'ts/Community_name',
                        filled: true,
                        border: InputBorder.none,
                        fillColor: Color.fromARGB(255, 205, 203, 203),
                        contentPadding: const EdgeInsets.all(18)),
                    maxLength: 21,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 22, 16, 16),
                          minimumSize: Size(double.maxFinite, 50)),
                      onPressed: createCommunity,
                      child: Text('Create Community',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 253, 252, 252),
                              fontSize: 17)))
                ],
              ),
            ),
    );
  }
}
