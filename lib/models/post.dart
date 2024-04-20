import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postId;
  final String username;
  final dynamic datePublished; // Adjusted data type to dynamic
  final String postUrl;
  final String profileImage;
  final dynamic likes; // Adjusted data type to dynamic

  Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.username,
    required this.datePublished,
    required this.postUrl,
    required this.profileImage,
    required this.likes,
  });

  // Convert Post object to JSON
  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "postId": postId,
        "username": username,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "profileImage": profileImage,
        "likes": likes,
      };

  // Create Post object from Firestore document snapshot
  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot['description'] ?? '',
      uid: snapshot['uid'] ?? '',
      postId: snapshot['postId'] ?? '',
      username: snapshot['username'] ?? '',
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'] ?? '',
      profileImage: snapshot['profileImage'] ?? '',
      likes: snapshot['likes'],
    );
  }
}
