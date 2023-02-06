import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gromartdriver/constants.dart';
import 'package:gromartdriver/model/AddressModel.dart';
import 'package:gromartdriver/model/OrderModel.dart';

class User with ChangeNotifier {
  String email;

  String firstName;

  String lastName;

  UserSettings settings;

  String phoneNumber;
  bool isActive;
  bool active;

  Timestamp lastOnlineTimestamp;
  Timestamp createdAt;

  String userID;

  String profilePictureURL;

  String appIdentifier;

  String fcmToken;

  UserLocation location;

  AddressModel shippingAddress;

  String role;

  String carName;

  String carNumber;

  String carPictureURL;

  String? inProgressOrderID;
  GeoFireData geoFireData;
  GeoPoint coordinates;
  OrderModel? orderRequestData;
  UserBankDetails userBankDetails;
  String vehicleType;
  String carMakes;
  num walletAmount;
  num? rotation;

  User(
      {this.email = '',
      this.userID = '',
      this.profilePictureURL = '',
      this.firstName = '',
      this.phoneNumber = '',
      this.lastName = '',
      this.isActive = false,
      this.active = true,
      lastOnlineTimestamp,
      createdAt,
      settings,
      this.fcmToken = '',
      location,
      shippingAddress,
      this.role = USER_ROLE_DRIVER,
      this.carName = 'Uber Car',
      this.carNumber = 'No Plates',
      this.carPictureURL = DEFAULT_CAR_IMAGE,
      this.inProgressOrderID,
      this.walletAmount = 0.0,
      this.vehicleType = "",
      this.carMakes = "",
      this.rotation,
      userBankDetails,
      geoFireData,
      coordinates,
      this.orderRequestData})
      :
        this.lastOnlineTimestamp = (lastOnlineTimestamp is int
                ? Timestamp.fromMillisecondsSinceEpoch(lastOnlineTimestamp)
                : lastOnlineTimestamp) ??
            Timestamp.now(),
        this.createdAt = (createdAt is int
                ? Timestamp.fromMillisecondsSinceEpoch(createdAt)
                : createdAt) ??
            Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.appIdentifier = 'Gromart Driver ${Platform.operatingSystem}',
        this.shippingAddress = shippingAddress ?? AddressModel(),
        this.userBankDetails = userBankDetails ?? UserBankDetails(),
        this.location = location ?? UserLocation(),
        this.coordinates = coordinates ?? GeoPoint(0.0, 0.0),
        this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  String fullName() {
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        email: parsedJson['email'] ?? '',
        walletAmount: parsedJson['wallet_amount'] ?? 0.0,
        userBankDetails: parsedJson.containsKey('userBankDetails')
            ? UserBankDetails.fromJson(parsedJson['userBankDetails'])
            : UserBankDetails(),
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        isActive: parsedJson['isActive'] ?? false,
        active: parsedJson['active'] ?? true,
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'] is int
            ? Timestamp.fromMillisecondsSinceEpoch(
                parsedJson['lastOnlineTimestamp'])
            : parsedJson['lastOnlineTimestamp'],
        createdAt: parsedJson['createdAt'] is int
            ? Timestamp.fromMillisecondsSinceEpoch(
                parsedJson['createdAt'])
            : parsedJson['createdAt'],
        settings: parsedJson.containsKey('settings')
            ? UserSettings.fromJson(parsedJson['settings'])
            : UserSettings(),
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        location: parsedJson.containsKey('location')
            ? UserLocation.fromJson(parsedJson['location'])
            : UserLocation(),
        shippingAddress: parsedJson.containsKey('shippingAddress')
            ? AddressModel.fromJson(parsedJson['shippingAddress'])
            : AddressModel(),
        role: parsedJson['role'] ?? '',
        carName: parsedJson['carName'] ?? '',
        carNumber: parsedJson['carNumber'] ?? '',
        carPictureURL: parsedJson['carPictureURL'] ?? '',
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        coordinates: parsedJson['coordinates'] ?? GeoPoint(0.0, 0.0),
        rotation: parsedJson['rotation'] ?? 0.0,
        inProgressOrderID: parsedJson['inProgressOrderID'],
        orderRequestData: parsedJson.containsKey('orderRequestData') &&
                parsedJson['orderRequestData'] != null
            ? OrderModel.fromJson(parsedJson['orderRequestData'])
            : null);
  }

  factory User.fromPayload(Map<String, dynamic> parsedJson) {
    return User(
        email: parsedJson['email'] ?? '',
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        walletAmount: parsedJson['wallet_amount'] ?? 0.0,
        rotation: parsedJson['rotation'] ?? 0.0,
        userBankDetails: parsedJson.containsKey('userBankDetails')
            ? UserBankDetails.fromJson(parsedJson['userBankDetails'])
            : UserBankDetails(),
        isActive: parsedJson['isActive'] ?? false,
        active: parsedJson['active'] ?? true,
        coordinates: parsedJson['coordinates'] ?? GeoPoint(0.0, 0.0),
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'] is int
            ? Timestamp.fromMillisecondsSinceEpoch(
                parsedJson['lastOnlineTimestamp'])
            : parsedJson['lastOnlineTimestamp'],
        createdAt: parsedJson['createdAt'] is int
            ? Timestamp.fromMillisecondsSinceEpoch(
                parsedJson['createdAt'])
            : parsedJson['createdAt'],
        settings: parsedJson.containsKey('settings')
            ? UserSettings.fromJson(parsedJson['settings'])
            : UserSettings(),
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        location: parsedJson.containsKey('location')
            ? UserLocation.fromJson(parsedJson['location'])
            : UserLocation(),
        shippingAddress: parsedJson.containsKey('shippingAddress')
            ? AddressModel.fromJson(parsedJson['shippingAddress'])
            : AddressModel(),
        role: parsedJson['role'] ?? '',
        carName: parsedJson['carName'] ?? '',
        carNumber: parsedJson['carNumber'] ?? '',
        carPictureURL: parsedJson['carPictureURL'] ?? '',
        inProgressOrderID: parsedJson['inProgressOrderID'],
        orderRequestData: parsedJson.containsKey('orderRequestData') &&
                parsedJson['orderRequestData'] != null
            ? OrderModel.fromJson(parsedJson['orderRequestData'])
            : null);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'wallet_amount': this.walletAmount,
      "userBankDetails": this.userBankDetails.toJson(),
      'id': this.userID,
      'isActive': this.isActive,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp.millisecondsSinceEpoch,
      'createdAt': this.createdAt,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'shippingAddress': this.shippingAddress.toJson(),
      if (orderRequestData != null)
        'orderRequestData': this.orderRequestData!.toJson(),
      'role': this.role
    };
    if (this.role == USER_ROLE_DRIVER) {
      json.addAll({
        'role': this.role,
        'carName': this.carName,
        'carNumber': this.carNumber,
        'carPictureURL': this.carPictureURL,
        'vehicleType': this.vehicleType,
        'carMakes': this.carMakes,
        'rotation': this.rotation,
      });
    }
    if (this.inProgressOrderID != null) {
      json.addAll({'inProgressOrderID': this.inProgressOrderID});
    }
    return json;
  }

  Map<String, dynamic> toPayload() {
    Map<String, dynamic> json = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'isActive': this.isActive,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp.millisecondsSinceEpoch,
      'createdAt': this.createdAt.millisecondsSinceEpoch,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      "g": this.geoFireData.toJson(),
      'coordinates': this.coordinates,
      'shippingAddress': this.shippingAddress.toJson(),
      'role': this.role
    };
    if (this.role == USER_ROLE_DRIVER) {
      json.addAll({
        'role': this.role,
        'carName': this.carName,
        'carNumber': this.carNumber,
        'carPictureURL': this.carPictureURL,
        'vehicleType': this.vehicleType,
        'carMakes': this.carMakes,
        'rotation': this.rotation,
      });
    }
    if (this.inProgressOrderID != null) {
      json.addAll({'inProgressOrderID': this.inProgressOrderID});
    }
    return json;
  }

  @override
  String toString() {
    return 'User{email: $email, firstName: $firstName, lastName: $lastName, settings: ${settings.toJson()}, phoneNumber: $phoneNumber, isActive: $isActive, lastOnlineTimestamp: $lastOnlineTimestamp, createdAt: $createdAt, userID: $userID, profilePictureURL: $profilePictureURL, appIdentifier: $appIdentifier, fcmToken: $fcmToken, location: $location, shippingAddress: ${shippingAddress.toJson()}, role: $role, carName: $carName, carNumber: $carNumber, carPictureURL: $carPictureURL, inProgressOrderID: $inProgressOrderID, orderRequestData: ${orderRequestData?.toJson()}}';
  }
}

class GeoFireData {
  String? geohash;
  GeoPoint? geoPoint;

  GeoFireData({this.geohash, this.geoPoint});

  factory GeoFireData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoFireData(
      geohash: parsedJson['geohash'] ?? '',
      geoPoint: parsedJson['geopoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': this.geohash,
      'geopoint': this.geoPoint,
    };
  }
}

class UserSettings {
  bool pushNewMessages;

  bool orderUpdates;

  bool newArrivals;

  bool promotions;

  UserSettings(
      {this.pushNewMessages = true,
      this.orderUpdates = true,
      this.newArrivals = true,
      this.promotions = true});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserSettings(
      pushNewMessages: parsedJson['pushNewMessages'] ?? true,
      orderUpdates: parsedJson['orderUpdates'] ?? true,
      newArrivals: parsedJson['newArrivals'] ?? true,
      promotions: parsedJson['promotions'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNewMessages': this.pushNewMessages,
      'orderUpdates': this.orderUpdates,
      'newArrivals': this.newArrivals,
      'promotions': this.promotions,
    };
  }
}

class UserLocation {
  double latitude;

  double longitude;

  UserLocation({this.latitude = 0.01, this.longitude = 0.01});

  factory UserLocation.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserLocation(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }
}

class UserBankDetails {
  String bankName;
  String branchName;
  String holderName;
  String accountNumber;
  String otherDetails;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.accountNumber = '',
    this.holderName = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': this.bankName,
      'branchName': this.branchName,
      'holderName': this.holderName,
      'accountNumber': this.accountNumber,
      'otherDetails': this.otherDetails,
    };
  }
}
