import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:routemaster/routemaster.dart';
import 'package:tripsathihackathon/community/constants/constants.dart';
import 'package:tripsathihackathon/community/repository/community_repository.dart';
import 'package:tripsathihackathon/community/repository/storage_repository.dart';
import 'package:tripsathihackathon/models/community_model.dart';
import 'package:tripsathihackathon/utils/utils.dart';

final userCommunitiesProvider = StreamProvider(
  (ref) {
    final CommunityController = ref.watch(CommunityControllerProvider.notifier);
    return CommunityController.getUserCommunities();
  },
);

final CommunityControllerProvider =
    StateNotifierProvider<CommunityController, bool>(
  (ref) {
    final communityRepository = ref.watch(CommunityRepositoryProvider);
    final storageRepository = ref.watch(storageRepositoryProvider);
    return CommunityController(
        communityRepository: communityRepository,
        storageRepository: storageRepository,
        ref: ref);
  },
);

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(CommunityControllerProvider.notifier)
      .getCommunityByName(name);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  // void createCommunity(String name, BuildContext context) async {
  //   state = true;
  //   User currentUser = _auth.currentUser!;

  //   Community community = Community(
  //       id: name,
  //       name: name,
  //       banner: Constants.banner,
  //       avator: Constants.avatar,
  //       members: [currentUser.uid],
  //       mods: [currentUser.uid]);

  //   final res = await _communityRepository.createCommunity(community);
  //   state = false;
  //   res.fold((l) => showSnackBar(context, l.message), (r) {
  //     showSnackBar(context, 'Community Created Successfully');
  //     Routemaster.of(context).pop();
  //   });
  // }
  void createCommunity(String name, BuildContext context) async {
    state = true;
    User currentUser = _auth.currentUser!;

    Community community = Community(
        id: name,
        name: name,
        banner: Constants.banner,
        avator: Constants.avatar,
        members: [currentUser.uid],
        mods: [currentUser.uid]);

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context as String,
          l.message as BuildContext), // Pass the error message to showSnackBar
      (r) {
        showSnackBar(
            context as String,
            'Community Created Successfully'
                as BuildContext); // Pass a success message
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Community>> getUserCommunities() {
    User currentUser = _auth.currentUser!;
    return _communityRepository.getUserCommunities(currentUser.uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }
}
