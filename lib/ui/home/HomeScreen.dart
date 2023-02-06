import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gromartdriver/constants.dart';
import 'package:gromartdriver/main.dart';
import 'package:gromartdriver/model/ConversationModel.dart';
import 'package:gromartdriver/model/CurrencyModel.dart';
import 'package:gromartdriver/model/HomeConversationModel.dart';
import 'package:gromartdriver/model/OrderModel.dart';
import 'package:gromartdriver/model/User.dart';
import 'package:gromartdriver/providers/user_provider.dart';
import 'package:gromartdriver/services/FirebaseHelper.dart';
import 'package:gromartdriver/services/helper.dart';
import 'package:gromartdriver/ui/chat/ChatScreen.dart';
import 'package:gromartdriver/ui/home/pick_order.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class HomeScreen extends StatefulWidget {
  final VoidCallback refresh;

  const HomeScreen({Key? key, required this.refresh}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final fireStoreUtils = FireStoreUtils();

  GoogleMapController? _mapController;
  bool canShowSheet = true;

  late Future<List<CurrencyModel>> futureCurrency;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;

  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<String, Marker> _markers = {};

  setIcons() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/pickup.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/dropoff.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/bike_icon.png")
        .then((value) {
      taxiIcon = value;
    });
  }

  @override
  void initState() {
    // FireStoreUtils().temp();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getDriver();
      setIcons();
      futureCurrency = FireStoreUtils().getCurrency();
      setCurrency();
    });
    super.initState();
  }
  @override
  void setState(VoidCallback fn) {
    // log("MK: homescreen mounted: ${mounted}");
    if(mounted){
    super.setState(fn);
    }
  }

  late Stream<OrderModel?> ordersFuture;
  OrderModel? currentOrder;

  late Stream<User> driverStream;
  User? _driverModel = User();

  getCurrentOrder() async {
    ordersFuture = FireStoreUtils().getOrderByID(MyAppState.currentUser!.inProgressOrderID.toString());
    ordersFuture.listen((event) async {
      if(mounted) {

        setState(() {
          currentOrder = event;
          getDirections();
        });
        if(currentOrder!.status == ORDER_STATUS_DRIVER_PENDING){
          currentOrder!.status = ORDER_STATUS_DRIVER_ACCEPTED;
          await FireStoreUtils.updateOrder(currentOrder!);
        }
      }
    });
  }

  int _start = 90;

  void startTimer(User _driverModel) {
    const oneSec = const Duration(seconds: 1);
    Timer _timer = new Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (_start == 0) {
            timer.cancel();
            bool isRejected = await rejectOrder(_driverModel);
            if(isRejected)Navigator.pop(context);
          // setState(() async {
          // });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  getDriver() async {
    driverStream = FireStoreUtils().getDriver(MyAppState.currentUser!.userID);
    driverStream.listen((event) {
      log('\x1b[92m --->${event.location.latitude} ${event.location.longitude} $mounted');
      // if(mounted){
      setState(() => _driverModel = event);
      setState(() => MyAppState.currentUser = _driverModel);
      // context.read()<UserProvider>().currentUser = _driverModel;
      // }
      // if(_driverModel!= null)acceptOrder(_driverModel!);

      getDirections();
      if (_driverModel!.isActive) {
        if (_driverModel!.orderRequestData != null) {
          showDriverBottomSheet(_driverModel!);
          startTimer(_driverModel!);
        }
      }
      if (_driverModel!.inProgressOrderID != null) {
        getCurrentOrder();
      }
    });
  }

  void dispose() {
    _mapController!.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  setCurrency() {
    FireStoreUtils().getCurrency().then((value) => value.forEach((element) {
          if (element.isactive = true) {
            symbol = element.symbol;
            isRight = element.symbolatright;
            decimal = element.decimal;
            currName = element.code;
            currencyData = element;
          }
        }));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (isDarkMode(context))
      _mapController?.setMapStyle('[{"featureType": "all","'
          'elementType": "'
          'geo'
          'met'
          'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');
  }

  @override
  Widget build(BuildContext context) {
    // FireStoreUtils().temp();
    isDarkMode(context)
        ? _mapController?.setMapStyle('[{"featureType": "all","'
            'elementType": "'
            'geo'
            'met'
            'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]')
        : _mapController?.setMapStyle(null);

    return Scaffold(
      body: _driverModel!.isActive
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(polyLines.values),
                  markers: _markers.values.toSet(),
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    target: LatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
                  ),
                ),
                if (_driverModel!.inProgressOrderID != null && currentOrder != null) buildOrderActionsCard()
              ],
            )
          : Center(
              child: showEmptyState('You are offline'.tr(), 'Go online in order to start getting delivery requests from customers and vendors.'.tr(),
                  isDarkMode: isDarkMode(context),
                  buttonTitle: 'Go Online'.tr(),
                  action: () => showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          // title: Text("Alert Dialog Box"),
                          content: Text.rich(TextSpan(children: [
                            TextSpan(text: "gromartDriverApp".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "collectsLocationDataOfStoreAndOtherPlacesNearbyToIdentifyPickupAndDeliveryLocationsEvenWhenTheAppIsClosedOrNotInUse.".tr())
                          ])),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: Text("deny".tr().toUpperCase()),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                goOnline(_driverModel!);
                              },
                              child: Text("accept".tr().toUpperCase()),
                            ),
                          ],
                        ),
                      )
                  // goOnline(user!),
                  ),
            ),
    );
  }

  openChatWithCustomer() async {
    late String channelID;
    if (currentOrder!.driver!.userID.compareTo(currentOrder!.author.userID) < 0) {
      channelID = currentOrder!.driver!.userID + currentOrder!.author.userID;
    } else {
      channelID = currentOrder!.author.userID + currentOrder!.driver!.userID;
    }

    ConversationModel? conversationModel = await fireStoreUtils.getChannelByIdOrNull(channelID);
    push(
      context,
      ChatScreen(
        homeConversationModel: HomeConversationModel(members: [currentOrder!.author], conversationModel: conversationModel),
      ),
    );
  }

  goOnline(User user) async {
    await showProgress(context, 'Going online...'.tr(), false);
    Position locationData = await getCurrentLocation();
    print('HomeScreenState.goOnline');
    user.isActive = true;
    if (locationData != null) {
      user.location = UserLocation(latitude: locationData.latitude, longitude: locationData.longitude);
      user.geoFireData = GeoFireData(
          geohash: Geoflutterfire().point(latitude: locationData.latitude, longitude: locationData.longitude).hash,
          geoPoint: GeoPoint(locationData.latitude, locationData.longitude));
    }
    MyAppState.currentUser = user;
    await FireStoreUtils.updateCurrentUser(user);

    await hideProgress();
  }

  showDriverBottomSheet(User user) async {
    double distanceInMeters = Geolocator.distanceBetween(user.orderRequestData!.vendor.latitude, user.orderRequestData!.vendor.longitude,
        user.orderRequestData!.author.shippingAddress.location.latitude, user.orderRequestData!.author.shippingAddress.location.longitude);
    double kilometer = distanceInMeters / 1000;
    if (canShowSheet) {
      canShowSheet = false;
      await showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          playSound();
          return WillPopScope(
            // ignore: missing_return
            onWillPop: () async => false,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Container(
                height: MediaQuery.of(context).size.height / 2.6,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                decoration: BoxDecoration(
                  color: Color(0xff212121),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'New Order!'.tr(),
                          style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinssb", letterSpacing: 0.5),
                        ),
                      ),
                      SizedBox(height: 10),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Container(
                            //   width: MediaQuery.of(context).size.width / 2.5,
                            //   height: MediaQuery.of(context).size.height / 9.2,
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //     children: [
                            //       Text(
                            //         "Expected Earning",
                            //         style: TextStyle(
                            //           color: Color(0xffADADAD),
                            //           fontFamily: "Poppinsr",
                            //           letterSpacing: 0.5,
                            //         ),
                            //       ),
                            //       Text(
                            //         symbol+ "${25.00}",
                            //         style: TextStyle(
                            //             color: Color(0xffFFFFFF),
                            //             fontFamily: "Poppinsm",
                            //             letterSpacing: 0.5),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // VerticalDivider(color: Color(0xff4E4F53)),
                            Container(
                              width: MediaQuery.of(context).size.width / 2.5,
                              height: MediaQuery.of(context).size.height / 9.2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Trip Distance".tr(),
                                    style: TextStyle(color: Color(0xffADADAD), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                  ),
                                  Text(
                                    // '0',
                                    "${kilometer.toStringAsFixed(2)} km",
                                    style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Card(
                        color: Color(0xffFFFFFF),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/location3x.png',
                                height: 55,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 270,
                                    child: Text(
                                      "${user.orderRequestData!.vendor.location} ",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                    ),
                                  ),
                                  SizedBox(height: 22),
                                  SizedBox(
                                    width: 270,
                                    child: Text(
                                      "${user.orderRequestData!.address.line1} "
                                      "${user.orderRequestData!.address.line2} "
                                      "${user.orderRequestData!.address.city}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Text('${currentOrder!.author.shippingAddress.line1} '
                      //     '${currentOrder!.author.shippingAddress.line2} '
                      //     '${currentOrder!.author.shippingAddress.city}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                backgroundColor: Color(COLOR_PRIMARY),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              child: Text(
                                'reject'.tr().toUpperCase(),
                                style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                              ),
                              onPressed: () async {
                                audioPlayer.pause();
                                Navigator.pop(context);
                                showProgress(context, 'Rejecting order...'.tr(), false);
                                try {
                                  await rejectOrder(user);
                                  hideProgress();
                                } catch (e) {
                                  hideProgress();
                                  print('HomeScreenState.showDriverBottomSheet $e');
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                  primary: Color(COLOR_PRIMARY),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'accept'.tr().toUpperCase(),
                                  style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                ),
                                onPressed: () async {
                                  audioPlayer.pause();
                                  Navigator.pop(context);
                                  showProgress(context, 'Accepting order...'.tr(), false);
                                  try {
                                    await acceptOrder(user);
                                    updateProgress('Finding the best route...'.tr());
                                    hideProgress();
                                    // setState(() {});
                                  } catch (e) {
                                    hideProgress();
                                    log('HomeScreenState.showDriverBottomSheet $e');
                                  }
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
      canShowSheet = true;
    }
  }

  Widget buildOrderActionsCard() {
    // log("order text: ${currentOrder!.status}");
    bool showCard = true;
    late String title;
    String? buttonText;
    if (currentOrder!.status == ORDER_STATUS_SHIPPED || currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED) {
      title = '${currentOrder!.vendor.title}';
      buttonText = 'reachedStoreForPickup'.tr();
    } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
      title = 'deliverTo'.tr(args: ['${currentOrder!.author.firstName}']);
      // buttonText = 'Complete Pick Up'.tr();
      buttonText = 'reachedCustomerDoorStep'.tr();
    }else{
      showCard = false;
    }
    if(!showCard){
      // log("error: unable to show order card as order's status is bit unexpected");
      return SizedBox();
    }

    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      padding: EdgeInsets.symmetric(vertical: 15),
      height: MediaQuery.of(context).size.height / 3.2,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(18)),
        color: isDarkMode(context) ? Color(0xff000000) : Color(0xffFFFFFF),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentOrder!.status == ORDER_STATUS_SHIPPED || currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED)
              ListTile(
                title: Text(
                  title,
                  style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsm", letterSpacing: 0.5),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${currentOrder!.vendor.location}',
                    maxLines: 2,
                    style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                  ),
                ),
                trailing: TextButton.icon(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: BorderSide(color: Color(0xff3DAE7D)),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(85, 30),
                      alignment: Alignment.center,
                      backgroundColor: Color(0xffFFFFFF),
                    ),
                    onPressed: () {
                      UrlLauncher.launch("tel://${currentOrder!.vendor.phonenumber}");
                    },
                    icon: Image.asset(
                      'assets/images/call3x.png',
                      height: 14,
                      width: 14,
                    ),
                    label: Text(
                      "call".tr(),
                      style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                    )),
              ),
            if (currentOrder!.status == ORDER_STATUS_SHIPPED || currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED)
              ListTile(
                tileColor: Color(0xffF1F4F8),
                contentPadding: EdgeInsets.only(left: 15),
                title: Row(
                  children: [
                    Text(
                      'orderId'.tr(),
                      style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff555555), fontFamily: "Poppinsr", letterSpacing: 0.5),
                    ),
                    Expanded(
                      child: Text(
                        ' ${currentOrder!.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${currentOrder!.author.shippingAddress.name}',
                    style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff333333), fontFamily: "Poppinsm", letterSpacing: 0.5),
                  ),
                ),
              ),

            if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT)
              ListTile(
                leading: Image.asset(
                  'assets/images/user3x.png',
                  height: 42,
                  width: 42,
                  color: Color(COLOR_PRIMARY),
                ),
                title: Text(
                  '${currentOrder!.author.shippingAddress.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsm", letterSpacing: 0.5),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'orderId'.tr(),
                        style: TextStyle(color: Color(0xff555555), fontFamily: "Poppinsr", letterSpacing: 0.5),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          ' ${currentOrder!.id} ',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton.icon(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(color: Color(0xff3DAE7D)),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(85, 30),
                          alignment: Alignment.center,
                          backgroundColor: Color(0xffFFFFFF),
                        ),
                        onPressed: () {
                          UrlLauncher.launch("tel://${currentOrder!.author.phoneNumber}");
                        },
                        icon: Image.asset(
                          'assets/images/call3x.png',
                          height: 14,
                          width: 14,
                        ),
                        label: Text(
                          "CALL".tr(),
                          style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                        )),
                  ],
                ),
              ),

            if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT)
              ListTile(
                leading: Image.asset(
                  'assets/images/delivery_location3x.png',
                  height: 42,
                  width: 42,
                  color: Color(COLOR_PRIMARY),
                ),
                title: Text(
                  'DELIVER'.tr(),
                  style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsr", letterSpacing: 0.5),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${currentOrder!.author.shippingAddress.line1},${currentOrder!.author.shippingAddress.line2},${currentOrder!.author.shippingAddress.city},${currentOrder!.author.shippingAddress.country}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff333333), fontFamily: "Poppinsr", letterSpacing: 0.5),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton.icon(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(color: Color(0xff3DAE7D)),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(100, 30),
                          alignment: Alignment.center,
                          backgroundColor: Color(0xffFFFFFF),
                        ),
                        onPressed: () => openChatWithCustomer(),
                        icon: Icon(
                          Icons.message,
                          size: 16,
                          color: Color(0xff3DAE7D),
                        ),
                        // Image.asset(
                        //   'assets/images/call3x.png',
                        //   height: 14,
                        //   width: 14,
                        // ),
                        label: Text(
                          "Message",
                          style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                        )),
                  ],
                ),
              ),

            if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    backgroundColor: Color(COLOR_PRIMARY),
                  ),
                  onPressed: () async {
                    if (currentOrder!.status == ORDER_STATUS_SHIPPED || currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED)
                      completePickUp();
                    //////////////////////////////////////////////////////////////
                    /////picked order
                    else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT)
                      //////////////////////////////////////////////////////////////
                      /////make order deliver
                      push(
                        context,
                        Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              icon: Icon(Icons.chevron_left),
                              onPressed: () => Navigator.pop(context),
                            ),
                            titleSpacing: -8,
                            title: Text(
                              "Deliver".tr() + ": ${currentOrder!.id}",
                              style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000), fontFamily: "Poppinsr", letterSpacing: 0.5),
                            ),
                            centerTitle: false,
                          ),
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(color: Colors.grey.shade100, width: 0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 2.0,
                                          spreadRadius: 0.4,
                                          offset: Offset(0.2, 0.2),
                                        ),
                                      ],
                                      color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'DELIVER'.tr().toUpperCase(),
                                            style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                          ),
                                          TextButton.icon(
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6.0),
                                                  side: BorderSide(color: Color(0xff3DAE7D)),
                                                ),
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(85, 30),
                                                alignment: Alignment.center,
                                                backgroundColor: Color(0xffFFFFFF),
                                              ),
                                              onPressed: () {
                                                UrlLauncher.launch("tel://${currentOrder!.author.phoneNumber}");
                                              },
                                              icon: Image.asset(
                                                'assets/images/call3x.png',
                                                height: 14,
                                                width: 14,
                                              ),
                                              label: Text(
                                                "CALL".tr().toUpperCase(),
                                                style: TextStyle(color: Color(0xff3DAE7D), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                              )),
                                        ],
                                      ),
                                      Text(
                                        '${currentOrder!.author.shippingAddress.name}',
                                        style: TextStyle(color: Color(0xff333333), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '${currentOrder!.author.shippingAddress.line1},'
                                          '${currentOrder!.author.shippingAddress.line2},'
                                          '${currentOrder!.author.shippingAddress.city}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsr", letterSpacing: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 28),
                                Text(
                                  "ITEMS".tr().toUpperCase(),
                                  style: TextStyle(color: Color(0xff9091A4), fontFamily: "Poppinsm", letterSpacing: 0.5),
                                ),
                                SizedBox(height: 24),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: currentOrder!.products.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: CachedNetworkImage(
                                                    height: 55,
                                                    // width: 50,
                                                    imageUrl: '${currentOrder!.products[index].photo}',
                                                    imageBuilder: (context, imageProvider) => Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              image: DecorationImage(
                                                                image: imageProvider,
                                                                fit: BoxFit.cover,
                                                              )),
                                                        )),
                                              ),
                                              Expanded(
                                                flex: 10,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 14.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${currentOrder!.products[index].name}',
                                                        style: TextStyle(
                                                            fontFamily: 'Poppinsr',
                                                            letterSpacing: 0.5,
                                                            color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff333333)),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.close,
                                                            size: 15,
                                                            color: Color(COLOR_PRIMARY),
                                                          ),
                                                          Text('${currentOrder!.products[index].quantity}',
                                                              style: TextStyle(
                                                                fontFamily: 'Poppinsm',
                                                                letterSpacing: 0.5,
                                                                color: Color(COLOR_PRIMARY),
                                                              )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ));
                                      // Card(
                                      //   child: Text(widget.currentOrder!.products[index].name),
                                      // );
                                    }),
                                SizedBox(height: 28),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Color(0xffC2C4CE)),
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //       color: Colors.grey.shade200,
                                      //       blurRadius: 8.0,
                                      //       spreadRadius: 1.2,
                                      //       offset: Offset(0.2, 0.2)),
                                      // ],
                                      color: Colors.white),
                                  child: ListTile(
                                    minLeadingWidth: 20,
                                    leading: Image.asset(
                                      'assets/images/mark_selected3x.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                    title: Text(
                                      "Given".tr() + " ${currentOrder!.products.length} " + "item to customer".tr(),
                                      style: TextStyle(color: Color(0xff3DAE7D), fontFamily: 'Poppinsm', letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 26),
                              ],
                            ),
                          ),
                          bottomNavigationBar: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 26),
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  backgroundColor: Color(0xff3DAE7D),
                                ),
                                child: Text(
                                  "MARK ORDER DELIVER".tr(),
                                  style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontFamily: 'Poppinsm',
                                  ),
                                ),
                                onPressed: () => completeOrder(),
                              ),
                            ),
                          ),
                        ),
                      );



                    // completeOrder();
                  },
                  child: Text(
                    buttonText ?? "",
                    style: TextStyle(color: Color(0xffFFFFFF), fontFamily: "Poppinsm", letterSpacing: 0.5),
                  ),
                ),
              ),
            ),

            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  acceptOrder(User user) async {
    OrderModel orderModel = user.orderRequestData!;
    orderModel.status = ORDER_STATUS_DRIVER_ACCEPTED;
    orderModel.driverID = user.userID;

    Position? locationData = await getCurrentLocation();
    if (locationData != null) {
      user.location = UserLocation(latitude: locationData.latitude, longitude: locationData.longitude);
      user.geoFireData = GeoFireData(
          geohash: Geoflutterfire().point(latitude: locationData.latitude, longitude: locationData.longitude).hash,
          geoPoint: GeoPoint(locationData.latitude, locationData.longitude));
    }
    orderModel.driver = user;
    await FireStoreUtils.updateOrder(orderModel);
    currentOrder = orderModel;

    user.orderRequestData = null;
    user.inProgressOrderID = orderModel.id;

    MyAppState.currentUser = user;
    await FireStoreUtils.updateCurrentUser(user);

    await FireStoreUtils.sendFcmMessage("Delivery Agent Assigned.".tr(), user.firstName + " " + user.lastName + " will deliver Your Order.",
        orderModel.author.fcmToken, orderModel.vendor.fcmToken);
  }

  completePickUp() async {
    print('HomeScreenState.completePickUp');
    showProgress(context, 'Updating order...', false);
    currentOrder!.status = ORDER_STATUS_IN_TRANSIT;
    await FireStoreUtils.updateOrder(currentOrder!);

    hideProgress();
    setState(() {});
    push(
      context,
      PickOrder(currentOrder: currentOrder),
    );
  }

  completeOrder() async {
    showProgress(context, 'Completing Delivery...'.tr(), false);
    currentOrder!.status = ORDER_STATUS_COMPLETED;
    updateWallateAmount(currentOrder!);
    await FireStoreUtils.updateOrder(currentOrder!);
    Position? locationData = await getCurrentLocation();
    if (locationData != null) {
      MyAppState.currentUser!.location = UserLocation(latitude: locationData.latitude, longitude: locationData.longitude);
      MyAppState.currentUser!.geoFireData = GeoFireData(
          geohash: Geoflutterfire().point(latitude: locationData.latitude, longitude: locationData.longitude).hash,
          geoPoint: GeoPoint(locationData.latitude, locationData.longitude));
    }
    await FireStoreUtils.sendFcmMessage("Order Complete".tr(), "Our Delivery agent delivered order.".tr(), currentOrder!.author.fcmToken, null);
    MyAppState.currentUser!.inProgressOrderID = null;
    currentOrder = null;
    await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
    hideProgress();
    _markers.clear();
    polyLines.clear();
    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(locationData.latitude, locationData.longitude), zoom: 15),
      ),
    );

    setState(() {});
    Navigator.pop(context);
  }

  rejectOrder(User user) async {
    bool isRejected = false;
    if(user.orderRequestData != null){
      OrderModel orderModel = user.orderRequestData!;
      orderModel.rejectedByDrivers.add(user.userID);
      orderModel.status = ORDER_STATUS_DRIVER_REJECTED;
      OrderModel? order = await FireStoreUtils.getOrder(orderModel.id);
      if(order != null && order.status == ORDER_STATUS_ACCEPTED){
        // log("MK: rejecting order");
        await FireStoreUtils.updateOrder(orderModel);
        isRejected = true;
      }
      user.orderRequestData = null;
      MyAppState.currentUser = user;
      await FireStoreUtils.updateCurrentUser(user);
    }

    return isRejected;
  }

  getDirections() async {
    if (currentOrder != null) {
      if (currentOrder!.status == ORDER_STATUS_SHIPPED) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
          PointLatLng(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
          travelMode: TravelMode.driving,
        );

        print("----?${result.points}");
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        setState(() {
          _markers.remove("Driver");
          _markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position: LatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
              icon: taxiIcon!,
              rotation: double.parse(_driverModel!.rotation.toString()));
        });

        _markers.remove("Destination");
        _markers['Destination'] = Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
          icon: destinationIcon!,
        );
        if(polylineCoordinates.length>1)
        addPolyLine(polylineCoordinates);
      } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
          PointLatLng(currentOrder!.author.shippingAddress.location.latitude, currentOrder!.author.shippingAddress.location.longitude),
          travelMode: TravelMode.driving,
        );

        print("----?${result.points}");
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        setState(() {
          _markers.remove("Driver");
          _markers['Driver'] = Marker(
            markerId: const MarkerId('Driver'),
            infoWindow: const InfoWindow(title: "Driver"),
            position: LatLng(_driverModel!.location.latitude, _driverModel!.location.longitude),
            rotation: double.parse(_driverModel!.rotation.toString()),
            icon: taxiIcon!,
          );
        });

        _markers.remove("Destination");
        _markers['Destination'] = Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(currentOrder!.author.shippingAddress.location.latitude, currentOrder!.author.shippingAddress.location.longitude),
          icon: destinationIcon!,
        );
        if(polylineCoordinates.length>1)
        addPolyLine(polylineCoordinates);
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color(COLOR_PRIMARY),
      points: polylineCoordinates,
      width: 4,
      geodesic: true,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, _mapController);
    setState(() {});
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  playSound() async {
    final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 15,
        ctx: AudioContext(
            android: AudioContextAndroid(
                contentType: AndroidContentType.music,
                isSpeakerphoneOn: true,
                stayAwake: true,
                usageType: AndroidUsageType.alarm,
                audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(defaultToSpeaker: true, category: AVAudioSessionCategory.playback, options: [])));
  }
}
