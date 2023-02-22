import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/User.dart';
import '../services/FirebaseHelper.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  late Stream<User> driverStream;
  // bool isStreamed = false;

  UserProvider() {
    auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if(firebaseUser!=null){
    userStream(firebaseUser.uid);
    }
  }
userStream(String uid){
    // if(!stream)return;
  driverStream = FireStoreUtils().getDriver(uid);
  driverStream.listen((event) {
    _currentUser = event;
    MyAppState.currentUser = _currentUser;
    // log("MK: updating provider");
    notifyListeners();
  });
}
  set currentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  User? get currentUser => _currentUser;
}
