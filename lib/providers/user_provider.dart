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

  UserProvider() {
    auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if(firebaseUser!=null){
    driverStream = FireStoreUtils().getDriver(firebaseUser.uid);
    driverStream.listen((event) {
      // log('\x1b[92m in user provider --->${event.location.latitude} ${event.location.longitude}');
      // if(mounted){

      _currentUser = event;
      MyAppState.currentUser = _currentUser;
      // log("MK: updating provider");
      notifyListeners();
    });
    }
  }
userStream(){

}
  set currentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  User? get currentUser => _currentUser;
}
