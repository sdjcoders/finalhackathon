import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:tripsathihackathon/community/constants/failure.dart';
import 'package:tripsathihackathon/community/constants/firebase_Constants.dart';
import 'package:tripsathihackathon/community/constants/typedefs.dart';
import 'package:tripsathihackathon/models/ccoments_model.dart';
import 'package:tripsathihackathon/models/community_model.dart';
import 'package:tripsathihackathon/models/cpost_model.dart';
import 'package:tripsathihackathon/providers/firebase_providers.dart';

final PostRepositoryProvider = Provider((ref) {
  return PostRespository(firestore: ref.watch(firestoreProvider));
});

class PostRespository {
  final FirebaseFirestore _firestore;

  PostRespository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _post =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_post.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _post
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => Post.fromMap(
                e.data() as Map<String, dynamic>,
              ),
            )
            .toList());
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_post.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.upvotes.contains(userId)) {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downvote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.downvotes.contains(userId)) {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addComment(CComment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_post.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Post>> getUserPostsInCommunity(String uid, String communityName) {
    return _posts
        .where('uid', isEqualTo: uid)
        .where('communityName',
            isEqualTo: communityName) // Filter by community name
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<CComment>> getCommentsOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => CComment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<Post> getPostById(String postId) {
    return _post
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  // FutureVoid updateUserScore(User user) async {
  //   try {
  //     return right(_users.doc(user.uid).update({
  //       'score': user.score,
  //     }));
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   } catch (e) {
  //     return left(Failure(e.toString()));
  //   }
  // }
}
