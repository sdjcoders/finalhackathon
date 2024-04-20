// class CComment {
//   final String id;
//   final String text;
//   final DateTime createdAt;
//   final String postId;
//   final String username;
//   final String profilePic;
//   CComment({
//     required this.id,
//     required this.text,
//     required this.createdAt,
//     required this.postId,
//     required this.username,
//     required this.profilePic,
//   });

//   CComment copyWith({
//     String? id,
//     String? text,
//     DateTime? createdAt,
//     String? postId,
//     String? username,
//     String? profilePic,
//   }) {
//     return CComment(
//       id: id ?? this.id,
//       text: text ?? this.text,
//       createdAt: createdAt ?? this.createdAt,
//       postId: postId ?? this.postId,
//       username: username ?? this.username,
//       profilePic: profilePic ?? this.profilePic,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'text': text,
//       'createdAt': createdAt.millisecondsSinceEpoch,
//       'postId': postId,
//       'username': username,
//       'profilePic': profilePic,
//     };
//   }

//   factory CComment.fromMap(Map<String, dynamic> map) {
//     return CComment(
//       id: map['id'] ?? '',
//       text: map['text'] ?? '',
//       createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
//       postId: map['postId'] ?? '',
//       username: map['username'] ?? '',
//       profilePic: map['profilePic'] ?? '',
//     );
//   }

//   @override
//   String toString() {
//     return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, username: $username, profilePic: $profilePic)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is CComment &&
//         other.id == id &&
//         other.text == text &&
//         other.createdAt == createdAt &&
//         other.postId == postId &&
//         other.username == username &&
//         other.profilePic == profilePic;
//   }

//   @override
//   int get hashCode {
//     return id.hashCode ^
//         text.hashCode ^
//         createdAt.hashCode ^
//         postId.hashCode ^
//         username.hashCode ^
//         profilePic.hashCode;
//   }
// }

class CComment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String userId; // Reference to the user's profile document
  final String username;
  final String profilePic;

  CComment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.userId,
    required this.username,
    required this.profilePic,
  });

  CComment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? userId,
    String? username,
    String? profilePic,
  }) {
    return CComment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'userId': userId, // Include userId in the map
      'username': username,
      'profilePic': profilePic,
    };
  }

  factory CComment.fromMap(Map<String, dynamic> map) {
    return CComment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '', // Initialize userId from map
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }

  @override
  String toString() {
    return 'CComment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, userId: $userId, username: $username, profilePic: $profilePic)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CComment &&
        other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.userId == userId &&
        other.username == username &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        postId.hashCode ^
        userId.hashCode ^
        username.hashCode ^
        profilePic.hashCode;
  }
}
