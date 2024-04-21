// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fpdart/fpdart.dart';

// import 'package:routemaster/routemaster.dart';
// import 'package:tripsathihackathon/community/constants/constants.dart';
// import 'package:tripsathihackathon/community/repository/community_repository.dart';
// import 'package:tripsathihackathon/community/repository/storage_repository.dart';
// import 'package:tripsathihackathon/models/community_model.dart';
// import 'package:tripsathihackathon/utils/utils.dart';

// final userCommunitiesProvider = StreamProvider(
//   (ref) {
//     final CommunityController = ref.watch(CommunityControllerProvider.notifier);
//     return CommunityController.getUserCommunities();
//   },
// );

// final CommunityControllerProvider =
//     StateNotifierProvider<CommunityController, bool>(
//   (ref) {
//     final communityRepository = ref.watch(CommunityRepositoryProvider);
//     final storageRepository = ref.watch(storageRepositoryProvider);
//     return CommunityController(
//         communityRepository: communityRepository,
//         storageRepository: storageRepository,
//         ref: ref);
//   },
// );

// final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
//   return ref
//       .watch(CommunityControllerProvider.notifier)
//       .getCommunityByName(name);
// });

// class CommunityController extends StateNotifier<bool> {
//   final CommunityRepository _communityRepository;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final Ref _ref;
//   final StorageRepository _storageRepository;
//   CommunityController({
//     required CommunityRepository communityRepository,
//     required Ref ref,
//     required StorageRepository storageRepository,
//   })  : _communityRepository = communityRepository,
//         _ref = ref,
//         _storageRepository = storageRepository,
//         super(false);

//   // void createCommunity(String name, BuildContext context) async {
//   //   state = true;
//   //   User currentUser = _auth.currentUser!;

//   //   Community community = Community(
//   //       id: name,
//   //       name: name,
//   //       banner: Constants.banner,
//   //       avator: Constants.avatar,
//   //       members: [currentUser.uid],
//   //       mods: [currentUser.uid]);

//   //   final res = await _communityRepository.createCommunity(community);
//   //   state = false;
//   //   res.fold((l) => showSnackBar(context, l.message), (r) {
//   //     showSnackBar(context, 'Community Created Successfully');
//   //     Routemaster.of(context).pop();
//   //   });
//   // }
//   void createCommunity(String name, BuildContext context) async {
//     state = true;
//     User currentUser = _auth.currentUser!;

//     Community community = Community(
//         id: name,
//         name: name,
//         banner: Constants.banner,
//         avator: Constants.avatar,
//         members: [currentUser.uid],
//         mods: [currentUser.uid]);

//     final res = await _communityRepository.createCommunity(community);
//     state = false;
//     res.fold(
//       (l) => showSnackBar(context as String,
//           l.message as BuildContext), // Pass the error message to showSnackBar
//       (r) {
//         showSnackBar(
//             context as String,
//             'Community Created Successfully'
//                 as BuildContext); // Pass a success message
//         Routemaster.of(context).pop();
//       },
//     );
//   }

//   Stream<List<Community>> getUserCommunities() {
//     User currentUser = _auth.currentUser!;
//     return _communityRepository.getUserCommunities(currentUser.uid);
//   }

//   Stream<Community> getCommunityByName(String name) {
//     return _communityRepository.getCommunityByName(name);
//   }
// }

// import 'dart:async';
// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gonomad/core/community/constants/constants.dart';
// import 'package:gonomad/core/community/repository/community_repository.dart';
// import 'package:gonomad/core/community/repository/storage_repository.dart';
// import 'package:gonomad/models/community.dart';
// import 'package:gonomad/providers/user_provider.dart';
// import 'package:gonomad/utils/utils.dart';

// final UserCommunitiesProvider = StreamProvider((ref) {
//   final communityController = ref.watch(communiytControllerProvider.notifier);
//   return communityController.getUserCommunities();
// });

// final communiytControllerProvider =
//     StateNotifierProvider<CommunityController, bool>((ref) {
//   final commmunityRepository = ref.watch(CommunityRepositoryProvider);
//    final storageRepository = ref.watch(storageRepositoryProvider);

//   return CommunityController(
//       communityRepository: commmunityRepository,
//        storageRepository: storageRepository,
//        ref: ref);
// });

// final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
//   return ref
//       .watch(communiytControllerProvider.notifier)
//       .getCommunityByName(name);
// });

// class CommunityController extends StateNotifier<bool> {
//   final CommunityRepository _communityRepository;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//    final StorageRepository _storageRepository;

//   CommunityController(
//       {required CommunityRepository communityRepository, required Ref ref , required StorageRepository storageRepository})
//       : _communityRepository = communityRepository,
//        _storageRepository = storageRepository,
//         super(false);

//   void createCommunity(String name, BuildContext context) async {
//     state = true;

//     User currentUser = _auth.currentUser!;

//     // _ref.read(userProvider)?.uid ?? '';

//     Community community = Community(
//         id: name,
//         name: name,
//         banner: Constants.banner,
//         avator: Constants.avatar,
//         members: [currentUser.uid],
//         mods: [currentUser.uid]);

//     final res = await _communityRepository.createCommunity(community);
//     state = false;
//     res.fold((l) => showSnackBar(l.message, context), (r) {
//       showSnackBar('Community Created Successfully', context);
//       Navigator.of(context).pop();
//     });
//   }

//   Stream<List<Community>> getUserCommunities  () {
//     User currentUser = _auth.currentUser!;
//     return _communityRepository.getUserCommunities(currentUser.uid);
//   }

//   Stream<Community> getCommunityByName(String name) {
//     return _communityRepository.getCommunityByName(name);
//   }

// void editCommunity({
//     required File? profileFile,
//     required File? bannerFile,
//     // required Uint8List? profileWebFile,
//     // required Uint8List? bannerWebFile,
//     required BuildContext context,
//     required Community community,
//   }) async {
//     state = true;
//     if (profileFile != null )
//     // || profileWebFile != null)
//     {
//       // communities/profile/communityname
//       final res = await _storageRepository.storeFile(
//         path: 'communities/profile',
//         id: community.name,
//         file: profileFile,
//         // webFile: profileWebFile,
//       );
//       res.fold(
//         (l) => showSnackBar(context, l.message),
//         (r) => community = community.copyWith(avator: r),
//       );
//     }

//     if (bannerFile != null )
//     // || bannerWebFile != null)
//       {
//       // communities/banner/name
//       final res = await _storageRepository.storeFile(
//         path: 'communities/banner',
//         id: community.name,
//         file: bannerFile,
//         // webFile: bannerWebFile,
//       );
//       res.fold(
//         (l) => showSnackBar(context, l.message),
//         (r) => community = community.copyWith(banner: r),
//       );
//     }

//     final res = await _communityRepository.editCommunity(community);
//     state = false;
//     res.fold(
//       (l) => showSnackBar(context, l.message),
//       (r) => Routemaster.of(context).pop(),
//     );
//   }

// }

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:routemaster/routemaster.dart';
import 'package:tripsathihackathon/community/constants/constants.dart';
import 'package:tripsathihackathon/community/constants/failure.dart';
import 'package:tripsathihackathon/community/constants/utils.dart';
import 'package:tripsathihackathon/community/repository/community_repository.dart';
import 'package:tripsathihackathon/community/repository/storage_repository.dart';
import 'package:tripsathihackathon/models/community_model.dart';
import 'package:tripsathihackathon/models/cpost_model.dart';

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

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(CommunityControllerProvider.notifier).searchCommunity(query);
});

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(CommunityControllerProvider.notifier).getCommunityPosts(name);
});

final allCommunitiesProvider = StreamProvider<List<Community>>((ref) {
  final communityController = ref.watch(CommunityControllerProvider.notifier);
  return communityController.getAllCommunities();
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
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community Created Successfully');
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(Community community, BuildContext context) async {
    User currentUser = _auth.currentUser!;
    Either<Failure, void> res;
    if (community.members.contains(currentUser.uid)) {
      res = await _communityRepository.LeaveCommunity(
          community.name, currentUser.uid);
    } else {
      res = await _communityRepository.joinCommunity(
          community.name, currentUser.uid);
    }

    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => {
              if (community.members.contains(currentUser.uid))
                {showSnackBar(context, 'Community Left Successfully')}
              else
                {showSnackBar(context, 'Community Joined Successfully')}
            });
  }

  Stream<List<Community>> getAllCommunities() {
    return _communityRepository.getAllCommunities();
  }

  Stream<List<Community>> getUserCommunities() {
    User currentUser = _auth.currentUser!;
    return _communityRepository.getUserCommunities(currentUser.uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    // required Uint8List? profileWebFile,
    // required Uint8List? bannerWebFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null)
    // || profileWebFile != null)
    {
      // communities/profile/communityname
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
        // webFile: profileWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avator: r),
      );
    }

    if (bannerFile != null)
    // || bannerWebFile != null)
    {
      // communities/banner/name
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
        // webFile: bannerWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  // Stream<List<Community>> searchCommunity(String query) {
  //   return _communityRepository.searchCommunityAutoSuggest(query);
  // }
  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }
}
