// ignore_for_file: non_constant_identifier_names

import 'package:gromartdriver/model/CurrencyModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
const COLOR_ACCENT = 0xFF8fd468;
const COLOR_PRIMARY_DARK = 0xFF2c7305;
var COLOR_PRIMARY = 0xFF00B761;
const DARK_VIEWBG_COLOR = 0xff191A1C;
const DARK_CARD_BG_COLOR = 0xff35363A;
// 0xFF5EA23A;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;
const USERS = 'users';
const CHANNEL_PARTICIPATION = 'channel_participation';
const CHANNELS = 'channels';
const THREAD = 'thread';
const REPORTS = 'reports';
const CATEGORIES = 'vendor_categories';
const VENDORS = 'vendors';
const PRODUCTS = 'vendor_products';
const Setting = 'settings';
const CONTACT_US = 'ContactUs';
const ORDERS = 'vendor_orders';
const OrderTransaction = "order_transactions";
const driverPayouts = "driver_payouts";
const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
const SERVER_KEY =
    'AAAAZdT9e88:APA91bFXnpTamK5X_zPb8Qm3f6jWco4aUKtH3RPYAF0bF-hGdlM9teiNGUo5PycjDUMGIUAhtTEK2-Cf6qDM1joOdqcrpbppw9aZyvUF0_Kp4TEaiyiOE7X6ULlzbX8JIOD3pk7vpOwK';
// const GOOGLE_API_KEY = 'AIzaSyA-F2l1Ae8bSwyDrJo3OAKeYuwyu4iUDRo';
const GOOGLE_API_KEY = 'AIzaSyA7ks8X2YnLcxTuEC3qydL2adzA0NYbl6c';

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_ACCEPTED = 'Driver Accepted';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_COMPLETED = 'Order Completed';

const USER_ROLE_DRIVER = 'driver';

const DEFAULT_CAR_IMAGE =
    'https://firebasestorage.googleapis.com/v0/b/gromart-5dd93.appspot.com/o/images%2Fcar_default_image.png?alt=media&token=503e1888-2231-4621-a2d0-51f9bb7e7208';

const Currency = 'currencies';
String symbol = '';
bool isRight = false;
int decimal = 0;
String currName = "";
CurrencyModel? currencyData;
