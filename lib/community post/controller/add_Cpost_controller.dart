import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:tripsathihackathon/community%20post/repository/add_Cpost_repository.dart';
import 'package:tripsathihackathon/community/constants/enums.dart';
import 'package:tripsathihackathon/community/repository/storage_repository.dart';
import 'package:tripsathihackathon/models/ccoments_model.dart';
import 'package:tripsathihackathon/models/community_model.dart';
import 'package:tripsathihackathon/models/cpost_model.dart';
import 'package:tripsathihackathon/utils/utils.dart';
import 'package:tuple/tuple.dart';

import 'package:uuid/uuid.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>(
  (ref) {
    final postRepository = ref.watch(PostRepositoryProvider);
    final storageRepository = ref.watch(storageRepositoryProvider);
    return PostController(
        postRepository: postRepository,
        storageRepository: storageRepository,
        ref: ref);
  },
);

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(postControllerProvider.notifier).getUserPosts(uid);
});

final getUserPostsInCommunityProvider =
    StreamProvider.family<List<Post>, Tuple2<String, String>>((ref, tuple) {
  final uid = tuple.item1;
  final communityName = tuple.item2;
  return ref
      .watch(postControllerProvider.notifier)
      .getUserPostsInCommunity(uid, communityName);
});

class PostController extends StateNotifier<bool> {
  final PostRespository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  PostController({
    required PostRespository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String description}) async {
    var userData = {};

    state = true;
    String postId = Uuid().v1();

    User currentUser = _auth.currentUser!;

    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    userData = userSnap.data()!;

    // final user =_ref.read(userProvider)!;
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avator,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: userData['username'],
        uid: currentUser.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: [],
        description: description);

    final res = await _postRepository.addPost(post);
    _ref.read(postControllerProvider.notifier).updateUserScore(Scores.textPost);
    //   _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context as String, l.message as BuildContext),
        (r) {
      showSnackBar(context as String, 'Posted successsfully' as BuildContext);
      Navigator.of(context).pop();
    });
  }

  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String link}) async {
    var userData = {};
    User currentUser = _auth.currentUser!;

    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    userData = userSnap.data()!;

    state = true;
    String postId = Uuid().v1();

    //final user =_ref.read(userProvider)!;
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avator,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: userData['username'],
        uid: currentUser.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);
    _ref.read(postControllerProvider.notifier).updateUserScore(Scores.linkPost);

    // _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(context as String, l.message as BuildContext),
        (r) {
      showSnackBar(context as String, 'Posted successsfully' as BuildContext);
      Navigator.of(context).pop();
      //Routemaster.of(context).pop();
    });
  }

  void shareImagePost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required File? file}) async {
    state = true;
    String postId = Uuid().v1();
    var userData = {};
    User currentUser = _auth.currentUser!;

    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    userData = userSnap.data()!;
    //final user =_ref.read(userProvider)!;

    final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    imageRes
        .fold((l) => showSnackBar(context as String, l.message as BuildContext),
            (r) async {
      final Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avator,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: userData['username'],
          uid: currentUser.uid,
          type: 'image',
          createdAt: DateTime.now(),
          awards: [],
          link: r);

      final res = await _postRepository.addPost(post);

      _ref
          .read(postControllerProvider.notifier)
          .updateUserScore(Scores.imagePost);
      state = false;
      res.fold(
          (l) => showSnackBar(context as String, l.message as BuildContext),
          (r) {
        showSnackBar(context as String, 'Posted successsfully' as BuildContext);
        Navigator.of(context).pop();
      });
    });
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);

    _ref
        .read(postControllerProvider.notifier)
        .updateUserScore(Scores.deletePost);
    // _ref
    //     .read(userProfileControllerProvider.notifier)
    //     .updateUserKarma(UserKarma.deletePost);

    res.fold(
      (failure) {
        // Handle failure, e.g., show error message
        print('Failed to delete post: ${failure.message}');
        showSnackBar(context as String,
            'Failed to delete post: ${failure.message}' as BuildContext);
      },
      (_) {
        // Post deleted successfully
        print('Post deleted successfully');
        showSnackBar(
            context as String, 'Post deleted successfully' as BuildContext);
      },
    );
  }

  void upvote(Post post) async {
    User currentUser = _auth.currentUser!;
    _postRepository.upvote(post, currentUser.uid);
  }

  void downvote(Post post) async {
    // final uid = _ref.read(userProvider)!.uid;
    User currentUser = _auth.currentUser!;
    _postRepository.downvote(post, currentUser.uid);
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _postRepository.getUserPosts(uid);
  }

  Stream<List<Post>> getUserPostsInCommunity(String uid, String communityName) {
    return _postRepository.getUserPostsInCommunity(uid, communityName);
  }

  Stream<List<CComment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final currentUser = _auth.currentUser!;
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get() as DocumentSnapshot<Map<String, dynamic>>;

    // Access the data from the snapshot
    var userData = userDataSnapshot.data();
    String userId = currentUser.uid;

    // final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    CComment comment = CComment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      userId: userId,
      username: userData!['username'],
      profilePic: userData['photoUrl'],
    );
    final res = await _postRepository.addComment(comment);
    // _ref.read(postControllerProvider.notifier).updateUserScore(Scores.comment);

    res.fold((l) => showSnackBar(context as String, l.message as BuildContext),
        (r) => null);
  }

  void updateUserScore(Scores score) async {
    final currentUser = _auth.currentUser!;
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get() as DocumentSnapshot<Map<String, dynamic>>;

    // Access the data from the snapshot
    var userData = userDataSnapshot.data();
    String userId = currentUser.uid;

    // Update the user's score
    int newScore = userData!['score'] + score.score;

    // Update the user's score in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'score': newScore});

    // Optionally, update the local user data as well
    userData!['score'] = newScore;
  }
}
