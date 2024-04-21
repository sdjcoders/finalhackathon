// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsathihackathon/community%20post/screens/cpost_card.dart';
import 'package:tripsathihackathon/community/constants/error.dart';
import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';
import 'package:tripsathihackathon/community/screens/mod_tools.dart';
import 'package:tripsathihackathon/models/community_model.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({
    super.key,
    required this.name,
  });

  void navigateToModTools(BuildContext context, Community community) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ModToolsScreen(
                community: community,
              )),
    );
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(CommunityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User currentUser = _auth.currentUser!;

    return Scaffold(
        body: ref.watch(getCommunityByNameProvider(name)).when(
              data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 150,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                              child: Image.network(
                            community.banner,
                            fit: BoxFit.cover,
                          ))
                        ],
                      ),
                    ),
                    SliverPadding(
                        padding: EdgeInsets.all(16),
                        sliver: SliverList(
                            delegate: SliverChildListDelegate([
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(community.avator),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ts/${community.name}',
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              community.mods.contains(currentUser.uid)
                                  ? OutlinedButton(
                                      onPressed: () {
                                        navigateToModTools(context, community);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25)),
                                      child: Text('Admin'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () => joinCommunity(
                                          ref, community, context),
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25)),
                                      child: Text(community.members
                                              .contains(currentUser.uid)
                                          ? 'I am your Saathi '
                                          : 'Be a TripSaathi'),
                                    )
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child:
                                  Text('${community.members.length} members'))
                        ])))
                  ];
                },
                body: ref.watch(getCommunityPostsProvider(name)).when(
                      data: (data) {
                        return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final post = data[index];
                              return CPostCard(post: post);
                            });
                      },
                      error: (error, stackTrace) {
                        return ErrorText(error: error.toString());
                      },
                      loading: () => const Loader(),
                    ),
              ),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ));
  }
}
