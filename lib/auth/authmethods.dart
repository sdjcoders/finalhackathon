import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripsathihackathon/auth/storage_methods.dart';
import 'package:tripsathihackathon/models/usermodel.dart' as model;
// Import your APIs file

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  Future<String> signUpUsers({
    required String username,
    required String email,
    required String password,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'some error occured';
    try {
      if (username.isNotEmpty ||
          email.isNotEmpty ||
          password.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(cred.user!.uid);

        // Call createUser method from APIs file to create user profile in Firestore
        // Call createUser here

        String photoUrl = await Storagemethods()
            .uploadImageToStorage('profilePics', file, false);
        // await APIs.createUser(username, email, photoUrl);

        model.User user = model.User(
            uid: cred.user!.uid,
            username: username,
            email: email,
            bio: bio,
            followers: [],
            following: [],
            photoUrl: photoUrl,
            score: 0);

        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );

        res = 'success';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted.';
      } else if (err.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      } else if (err.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      }
    } catch (err) {
      print(
          'error in firestoreage do somethingggggggggggggggggggggggggggggjgbhjsbbrf');
      res = err.toString();
    }
    return res;
  }

  Future<String> loginInUsers({
    required String email,
    required String password,
  }) async {
    String res = 'some error occured';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        print(cred.user!.uid);
        res = 'success';
      } else {
        res = 'Please Enter All the Fields ';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted.';
      } else if (err.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      } else if (err.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (err.code == 'invalid-credential') {
        res = 'Wrong password provided for that user.';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
