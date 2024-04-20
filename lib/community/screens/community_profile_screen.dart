// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tripsathihackathon/community/constants/error.dart';
import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({
    super.key,
    required this.name,
  });

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
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                                community.mods.contains(currentUser.uid)
                                    ? OutlinedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25)),
                                        child: Text('Admin'),
                                      )
                                    : OutlinedButton(
                                        onPressed: () {},
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
                  body: Center(child: Text('Posts'))),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ));
  }
}
