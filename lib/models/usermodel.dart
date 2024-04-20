// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final int score;
  final List followers;
  final List following;

  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.score,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'bio': bio,
        'score': score,
        'followers': followers,
        'following': following,
        'photoUrl': photoUrl,
      };

  @override
  String toString() {
    return 'User(email: $email, uid: $uid, photoUrl: $photoUrl, username: $username, bio: $bio, score: $score, followers: $followers, following: $following)';
  }

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      email: snapshot['email'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      username: snapshot['username'],
      bio: snapshot['bio'],
      score: snapshot['score'],
      followers: snapshot['followers'],
      following: snapshot['following'],
    );
  }

  User copyWith({
    String? email,
    String? uid,
    String? photoUrl,
    String? username,
    String? bio,
    int? score,
    List? followers,
    List? following,
  }) {
    return User(
      email: email ?? this.email,
      uid: uid ?? this.uid,
      photoUrl: photoUrl ?? this.photoUrl,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      score: score ?? this.score,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
