// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:gromartdriver/constants.dart';
import 'package:gromartdriver/main.dart';
import 'package:gromartdriver/model/CurrencyModel.dart';
import 'package:gromartdriver/model/User.dart';
import 'package:gromartdriver/services/FirebaseHelper.dart';
import 'package:gromartdriver/services/helper.dart';
import 'package:gromartdriver/ui/Language/language_choose_screen.dart';
import 'package:gromartdriver/ui/auth/AuthScreen.dart';
import 'package:gromartdriver/ui/bank_details/bank_details_Screen.dart';
import 'package:gromartdriver/ui/home/HomeScreen.dart';
import 'package:gromartdriver/ui/ordersScreen/OrdersScreen.dart';
import 'package:gromartdriver/ui/profile/ProfileScreen.dart';
import 'package:gromartdriver/ui/wallet/walletScreen.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

enum DrawerSelection {
  Home,
  Cuisines,
  Search,
  Cart,
  Profile,
  Orders,
  Logout,
  Wallet,
  BankInfo,
  chooseLanguage,
}

class ContainerScreen extends StatefulWidget {
  final User user;

  ContainerScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ContainerScreen createState() {
    return _ContainerScreen();
  }
}

class _ContainerScreen extends State<ContainerScreen> {
  late User user;
  String _appBarTitle = 'Home'.tr();
  final fireStoreUtils = FireStoreUtils();
  late Future<List<CurrencyModel>> futureCurrency;
  late Widget _currentWidget;
  DrawerSelection _drawerSelection = DrawerSelection.Home;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    futureCurrency = FireStoreUtils().getCurrency();
    _currentWidget = HomeScreen(
      refresh: () {
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<UserProvider>().userStream(widget.user.userID);
      updateCurrentLocation();
    });

    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  updateCurrentLocation() async {
    print("---->22222");

    LocationData currentLocation;

    Location location = Location();

    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      print("---->");
      location.enableBackgroundMode(enable: true);
      location.changeSettings(interval: 60000);
      location.onLocationChanged.listen((locationData) async {
        currentLocation = locationData;
        UserLocation location = UserLocation(
            latitude: currentLocation.latitude!.toDouble(),
            longitude: currentLocation.longitude!.toDouble());
        // if(!mounted)return;
        if (Provider.of<UserProvider>(context, listen: false).currentUser ==
            null) {
          await Future.delayed(Duration(seconds: 1));
          return updateCurrentLocation();
        }
        MyAppState.currentUser =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        MyAppState.currentUser!.location = location;
        MyAppState.currentUser!.rotation = currentLocation.heading;
        MyAppState.currentUser!.geoFireData = GeoFireData(
            geohash: Geoflutterfire()
                .point(
                    latitude: locationData.latitude!.toDouble(),
                    longitude: locationData.longitude!.toDouble())
                .hash,
            geoPoint: GeoPoint(locationData.latitude!.toDouble(),
                locationData.longitude!.toDouble()));
        // log("MK: update user in main: 101: ${MyAppState.currentUser!.walletAmount} and ${context.watch<UserProvider>().currentUser!.walletAmount}");
        FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
      });
    } else {
      location.requestPermission().then((permissionStatus) {
        if (permissionStatus == PermissionStatus.granted) {
          print("---->");
          location.enableBackgroundMode(enable: true);
          location.changeSettings(interval: 60000);
          location.onLocationChanged.listen((locationData) async {
            currentLocation = locationData;
            UserLocation location = UserLocation(
                latitude: currentLocation.latitude!.toDouble(),
                longitude: currentLocation.longitude!.toDouble());

            if (Provider.of<UserProvider>(context, listen: false).currentUser ==
                null) {
              await Future.delayed(Duration(seconds: 1));
              return updateCurrentLocation();
            }

            MyAppState.currentUser = context.read<UserProvider>().currentUser;

            MyAppState.currentUser!.location = location;
            MyAppState.currentUser!.rotation = currentLocation.heading;
            MyAppState.currentUser!.geoFireData = GeoFireData(
                geohash: Geoflutterfire()
                    .point(
                        latitude: locationData.latitude!.toDouble(),
                        longitude: locationData.longitude!.toDouble())
                    .hash,
                geoPoint: GeoPoint(locationData.latitude!.toDouble(),
                    locationData.longitude!.toDouble()));
            FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
          });
        }
      });
    }
  }

  DateTime pre_backpress = DateTime.now();
  final audioPlayer = AudioPlayer(playerId: "playerId");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if (cantExit) {
          //show snackbar
          final snack = SnackBar(
            content: Text(
              'pressBackButtonAgainToExit',
              style: TextStyle(color: Colors.white),
            ).tr(),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false; // false will do nothing when back press
        } else {
          return true; // true will exit the app
        }
      },
      child: ChangeNotifierProvider.value(
        value: user,
        child: Consumer<User>(
          builder: (context, user, _) {
            return Scaffold(
              drawer: Drawer(
                backgroundColor: isDarkMode(context)
                    ? Color(DARK_VIEWBG_COLOR)
                    : Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Consumer<User>(builder: (context, user, _) {
                      return DrawerHeader(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            displayCircleImage(
                                user.profilePictureURL, 75, false),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                user.fullName(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  user.email,
                                  style: TextStyle(color: Colors.white),
                                )),
                            Container(
                              height: 0,
                              child: FutureBuilder<List<CurrencyModel>>(
                                  future: futureCurrency,
                                  initialData: [],
                                  builder: (context, snapshot) {
                                    return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return curcy(snapshot.data![index]);
                                        });
                                  }),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Color(COLOR_PRIMARY),
                        ),
                      );
                    }),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Home,
                        title: Text('Home').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Home;
                            _appBarTitle = 'Home'.tr();
                            _currentWidget = HomeScreen(
                              refresh: () {
                                if (mounted) setState(() {});
                              },
                            );
                          });
                        },
                        leading: Icon(CupertinoIcons.home),
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Orders,
                        leading: Image.asset(
                          'assets/images/truck.png',
                          color: _drawerSelection == DrawerSelection.Orders
                              ? Color(COLOR_PRIMARY)
                              : isDarkMode(context)
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade600,
                          width: 24,
                          height: 24,
                        ),
                        title: Text('Orders').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Orders;
                            _appBarTitle = 'Orders'.tr();
                            _currentWidget = OrdersScreen();
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Wallet,
                        leading: Icon(Icons.account_balance_wallet_sharp),
                        title: Text('wallet').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Wallet;
                            _appBarTitle = 'earnings'.tr();
                            _currentWidget = WalletScreen();
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.BankInfo,
                        leading: Icon(Icons.account_balance),
                        title: Text('bankDetails').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.BankInfo;
                            _appBarTitle = 'bankInfo'.tr();
                            _currentWidget = BankDetailsScreen();
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Profile,
                        leading: Icon(CupertinoIcons.person),
                        title: Text('Profile').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Profile;
                            _appBarTitle = 'myProfile'.tr();
                            _currentWidget = Consumer<UserProvider>(
                                builder: (context, pro, _) {
                              return ProfileScreen(
                                user: pro.currentUser!,
                              );
                            });
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected:
                            _drawerSelection == DrawerSelection.chooseLanguage,
                        leading: Icon(
                          Icons.language,
                          color:
                              _drawerSelection == DrawerSelection.chooseLanguage
                                  ? Color(COLOR_PRIMARY)
                                  : isDarkMode(context)
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade600,
                        ),
                        title: const Text('language').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.chooseLanguage;
                            _appBarTitle = 'language'.tr();
                            _currentWidget = LanguageChooseScreen(
                              isContainer: true,
                            );
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Logout,
                        leading: Icon(Icons.logout),
                        title: Text('Log out').tr(),
                        onTap: () async {
                          audioPlayer.stop();
                          Navigator.pop(context);
                          user = context.read<UserProvider>().currentUser!;
                          user.isActive = false;
                          user.lastOnlineTimestamp = Timestamp.now();
                          await FireStoreUtils.updateCurrentUser(user);
                          await auth.FirebaseAuth.instance.signOut();
                          MyAppState.currentUser = null;
                          pushAndRemoveUntil(context, AuthScreen(), false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
                centerTitle:
                    _drawerSelection == DrawerSelection.Wallet ? true : false,
                backgroundColor: isDarkMode(context)
                    ? Color(DARK_VIEWBG_COLOR)
                    : Colors.white,
                actions: [
                  if (_currentWidget is HomeScreen &&
                      MyAppState.currentUser != null &&
                      MyAppState.currentUser!.isActive &&
                      MyAppState.currentUser!.orderRequestData == null &&
                      MyAppState.currentUser!.inProgressOrderID == null)
                    IconButton(
                        icon: Icon(
                          CupertinoIcons.power,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          MyAppState.currentUser =
                              context.read<UserProvider>().currentUser;
                          MyAppState.currentUser!.isActive = false;
                          setState(() {});
                          await FireStoreUtils.updateCurrentUser(
                              MyAppState.currentUser!);
                        }),
                ],
                title: Text(
                  _appBarTitle,
                  style: TextStyle(
                    color: isDarkMode(context) ? Colors.white : Colors.black,
                  ),
                ),
              ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }

  curcy(CurrencyModel currency) {
    if (currency.isactive == true) {
      symbol = currency.symbol;
      isRight = currency.symbolatright;
      decimal = currency.decimal;
      return Center();
    }
    return Center();
  }
}
