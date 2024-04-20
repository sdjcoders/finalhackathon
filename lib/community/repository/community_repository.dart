import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tripsathihackathon/community/constants/failure.dart';
import 'package:tripsathihackathon/community/constants/firebase_Constants.dart';
import 'package:tripsathihackathon/community/constants/typedefs.dart';
import 'package:tripsathihackathon/models/community_model.dart';
import 'package:tripsathihackathon/providers/firebase_providers.dart';

final CommunityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community Name already exixts';
      }

      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid LeaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getAllCommunities() {
    return FirebaseFirestore.instance.collection('communities').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Community.fromMap(doc.data())).toList());
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }

      return communities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Stream<List<Post>> getCommunityPosts(String name) {
  //   return _posts
  //       .where('communityName', isEqualTo: name)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map(
  //         (event) => event.docs
  //             .map(
  //               (e) => Post.fromMap(
  //                 e.data() as Map<String, dynamic>,
  //               ),
  //             )
  //             .toList(),
  //       );
  // }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? '' : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        var communityData = community.data();
        if (communityData != null) {
          communities
              .add(Community.fromMap(communityData as Map<String, dynamic>));
        }
      }
      return communities;
    });
  }

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
