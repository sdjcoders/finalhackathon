import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsathihackathon/auth/authmethods.dart';
import 'package:tripsathihackathon/models/usermodel.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}

//
//import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gonomad/features/auth/controller/auth_controller.dart';
// import 'package:gonomad/features/auth/repository/auth_repository.dart';
// import 'package:gonomad/models/user.dart';
// import 'package:gonomad/resources/auth_methods.dart';

// final userProvider = StateNotifierProvider<UserProvider, User?>((ref) {
//   return UserProvider(AuthMethods());
// });

// class UserProvider extends StateNotifier<User?> {
//   final AuthMethods _authMethods;

//   UserProvider(this._authMethods) : super(null);

//   Future<void> refreshUser() async {
//     state = await _authMethods.getUserDetails();
//   }

//   User? get getUser => state;
// }

// }



