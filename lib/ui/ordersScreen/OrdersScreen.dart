import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gromartdriver/constants.dart';
import 'package:gromartdriver/main.dart';
import 'package:gromartdriver/model/OrderModel.dart';
import 'package:gromartdriver/model/ProductModel.dart';
import 'package:gromartdriver/services/FirebaseHelper.dart';
import 'package:gromartdriver/services/helper.dart';

import '../container/ContainerScreen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderModel>> ordersFuture;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<OrderModel> ordersList = [];

  @override
  void initState() {
    super.initState();
    ordersFuture =
        _fireStoreUtils.getDriverOrders(MyAppState.currentUser!.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
      body: FutureBuilder<List<OrderModel>>(
          future: ordersFuture,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(
                      Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
              );
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: showEmptyState(
                    'noPreviousOrders'.tr(), 'letsDeliverFood!'.tr()),
              );
            } else {
              ordersList = snapshot.data!;
              return ListView.builder(
                  itemCount: ordersList.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) =>
                      buildOrderItem(ordersList[index]));
            }
          }),
    );
  }

  Widget buildOrderItem(OrderModel orderModel) {
    double total = 0.0;
    total = 0.0;
    orderModel.products.forEach((element) {
      total += element.quantity * double.parse(element.price);
    });
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              if (orderModel.status == ORDER_STATUS_SHIPPED && MyAppState.currentUser!.inProgressOrderID == null) {
                // AlertDialog(),
                // AlertDialog alert = AlertDialog(
                //     title: Text("Complete this order?"),
                //     content: Text("Do you want to continue this order?"),
                //     actions: [TextButton(onPressed: () {}, child: Text("OK"))]);

                showAlertDialog(context, "Complete this order?",
                    "Do you want to continue this order?", true, onPressed: () async {
                      MyAppState.currentUser!.inProgressOrderID = orderModel.id;
                      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
                      pushAndRemoveUntil(context, ContainerScreen(user: MyAppState.currentUser!), false);
                });
              }
            },
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(orderModel.products.first.photo),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
              child: Center(
                child: Text(
                  '${orderDate(orderModel.createdAt)} - ${orderModel.status}',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment Method'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0XFF9091A4),
                      letterSpacing: 0.5,
                      fontFamily: 'Poppinsm',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${orderModel.payment_method.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0XFF9091A4),
                      letterSpacing: 0.5,
                      fontFamily: 'Poppinsm',
                    ),
                  ),
                ),
              ],
            ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: orderModel.products.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                ProductModel product = orderModel.products[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: Color(COLOR_PRIMARY)),
                    ),
                    child: Text(
                      '${product.quantity}',
                      style: TextStyle(
                          color: Color(COLOR_PRIMARY),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    symbol +
                        '${double.parse(product.price).toStringAsFixed(decimal)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'total:'.tr() + symbol + '${total.toStringAsFixed(decimal)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  playSound() async {
    final path = await rootBundle
        .load("assets/audio/mixkit-happy-bells-notification-937.mp3");

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
            iOS: AudioContextIOS(
                defaultToSpeaker: true,
                category: AVAudioSessionCategory.playback,
                options: [])));
  }
}
