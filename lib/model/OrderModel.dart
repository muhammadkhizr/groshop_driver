// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gromartdriver/model/AddressModel.dart';
import 'package:gromartdriver/model/ProductModel.dart';
import 'package:gromartdriver/model/TaxModel.dart';
import 'package:gromartdriver/model/User.dart';
import 'package:gromartdriver/model/VendorModel.dart';

class OrderModel {
  String authorID, payment_method;

  User author;
  User? driver;
  String? driverID;
  List<ProductModel> products;

  Timestamp createdAt;

  String vendorID;

  VendorModel vendor;

  String status;
  AddressModel address;

  String id;
  num? discount;
  String? couponCode;
  String? couponId, notes;
  var extras = [];
  String? extra_size;
  String? tipValue;
  String? adminCommission;
  String? adminCommissionType;
  final bool? takeAway;
  String? deliveryCharge;
  TaxModel? taxModel;
  bool payment_shared = true;
  List<dynamic> rejectedByDrivers;
  Map<String, dynamic>? specialDiscount;
  Timestamp? trigger_delevery;

  OrderModel(
      {address,
      author,
      this.driver,
      this.driverID,
      this.authorID = '',
      this.payment_method = '',
      createdAt,
      this.id = '',
      this.products = const [],
      this.status = '',
      this.discount = 0,
      this.couponCode = '',
      this.couponId = '',
      this.payment_shared = true,
      this.trigger_delevery,
      this.notes = '',
      vendor,
      this.extras = const [],
      this.extra_size,
      this.tipValue,
      this.adminCommission,
      this.takeAway = false,
      this.adminCommissionType,
      this.deliveryCharge,
      this.vendorID = '',
      this.specialDiscount,
      taxModel,
      this.rejectedByDrivers = const []})
      : this.address = address ?? AddressModel(),
        this.author = author ?? User(),
        this.createdAt = createdAt ?? Timestamp.now(),
        this.vendor = vendor ?? VendorModel(),
        this.taxModel = taxModel ?? null;

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<ProductModel> products = parsedJson.containsKey('products')
        ? List<ProductModel>.from((parsedJson['products'] as List<dynamic>).map((e) => ProductModel.fromJson(e))).toList()
        : [].cast<ProductModel>();

    num discountVal = 0;
    if (parsedJson['discount'] == null || parsedJson['discount'] == double.nan) {
      discountVal = 0;
    } else if (parsedJson['discount'] is String) {
      discountVal = double.parse(parsedJson['discount']);
    } else {
      discountVal = parsedJson['discount'];
    }
    return OrderModel(
        address: parsedJson.containsKey('address') ? AddressModel.fromJson(parsedJson['address']) : AddressModel(),
        author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
        authorID: parsedJson['authorID'] ?? '',
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        id: parsedJson['id'] ?? '',
        products: products,
        status: parsedJson['status'] ?? '',
        payment_shared: parsedJson['payment_shared'] ?? true,
        trigger_delevery: parsedJson['trigger_delevery'] ?? Timestamp.now(),
        discount: discountVal,
        couponCode: parsedJson['couponCode'] ?? '',
        couponId: parsedJson['couponId'] ?? '',
        notes: (parsedJson["notes"] != null && parsedJson["notes"].toString().isNotEmpty) ? parsedJson["notes"] : "",
        vendor: parsedJson.containsKey('vendor') ? VendorModel.fromJson(parsedJson['vendor']) : VendorModel(),
        vendorID: parsedJson['vendorID'] ?? '',
        driver: parsedJson.containsKey('driver') ? User.fromJson(parsedJson['driver']) : null,
        driverID: parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
        adminCommission: parsedJson["adminCommission"] != null ? parsedJson["adminCommission"] : "",
        adminCommissionType: parsedJson["adminCommissionType"] != null ? parsedJson["adminCommissionType"] : "",
        tipValue: parsedJson["tip_amount"] != null ? parsedJson["tip_amount"] : "",
        specialDiscount: parsedJson["specialDiscount"] ?? {},
        takeAway: parsedJson["takeAway"] != null ? parsedJson["takeAway"] : false,
        taxModel: (parsedJson.containsKey('taxSetting') && parsedJson['taxSetting'] != null) ? TaxModel.fromJson(parsedJson['taxSetting']) : null,
        extras: parsedJson["extras"] != null ? parsedJson["extras"] : [],
        extra_size: parsedJson["extras_price"] != null ? parsedJson["extras_price"] : "",
        deliveryCharge: parsedJson["deliveryCharge"],
        payment_method: parsedJson['payment_method'] ?? '',
        rejectedByDrivers: parsedJson.containsKey('rejectedByDrivers') ? parsedJson['rejectedByDrivers'] : [].cast<String>());
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'address': this.address.toJson(),
      'author': this.author.toJson(),
      'authorID': this.authorID,
      'payment_method': this.payment_method,
      'payment_shared': this.payment_shared,
      'createdAt': this.createdAt,
      'id': this.id,
      // 'products': [...this.products.map((e) => e.toJson()).toList()],
      'status': this.status,
      'discount': this.discount,
      'couponCode': this.couponCode,
      'couponId': this.couponId,
      'notes': this.notes,
      'vendor': this.vendor.toJson(),
      'vendorID': this.vendorID,
      'adminCommission': this.adminCommission,
      'adminCommissionType': this.adminCommissionType,
      "tip_amount": this.tipValue,
      if (taxModel != null) "taxSetting": this.taxModel!.toJson(),
      "extras": this.extras,
      "extras_price": this.extra_size,
      "takeAway": this.takeAway,
      "deliveryCharge": this.deliveryCharge,
      "rejectedByDrivers": this.rejectedByDrivers,
      "specialDiscount": this.specialDiscount,
      'trigger_delevery': this.trigger_delevery,
    };
    if (this.driver != null) {
      json.addAll({'driverID': this.driverID, 'driver': this.driver!.toPayload()});
    }
    return json;
  }
}