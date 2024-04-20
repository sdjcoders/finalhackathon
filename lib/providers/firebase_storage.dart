// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripsathihackathon/auth/storage_methods.dart';
import 'package:tripsathihackathon/models/post.dart';

import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profileImage,
  ) async {
    String res = "some error occured";
    try {
      String photoUrl =
          await Storagemethods().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        postId: postId,
        username: username,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: [],
      );
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Future<String> reportPost(
  //     {required postId, required username, required profilePic, required photoUrl}) async {
  //   String res = "some error occured";
  //   try {
  //     await _firestore.collection('reportedPosts').doc(postId).set({
  //       'postId': postId,
  //       'username': username,
  //       'profilePic': profilePic,
  //       'date': DateTime.now(),
  //     });
  //     res = "success";
  //   } catch (e) {
  //     res = e.toString();
  //   }
  //   return res;
  // }

//   Future<void> deleteComment(
//       String postId, String commentId, String uid, String username) async {
//     try {
//       await _firestore
//           .collection('posts')
//           .doc(postId)
//           .collection('comments')
//           .doc(commentId)
//           .delete();
//     } catch (e) {
//       print(e.toString());
//     }
// }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> postComment(String postId, String comment, String uid,
      String username, String profileImage) async {
    String res = "some error occured";
    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'comment': comment,
          'uid': uid,
          'username': username,
          'profileImage': profileImage,
          'datePublished': DateTime.now(),
        });
        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

//deleting posts
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      // List followers =
      //     (snap.data()! as dynamic)['followers']; // Retrieve followers list

      if (following.contains(followId)) {
        // If already following, unfollow
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        // If not following, follow
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print('Error in follow user: $e');
    }
  }
}
