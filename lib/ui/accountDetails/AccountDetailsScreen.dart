import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gromartdriver/constants.dart';
import 'package:gromartdriver/main.dart';
import 'package:gromartdriver/model/User.dart';
import 'package:gromartdriver/services/FirebaseHelper.dart';
import 'package:gromartdriver/services/helper.dart';
import 'package:gromartdriver/ui/reauthScreen/reauth_user_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  final User user;

  AccountDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late User user;
  GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? firstName, lastName, carName, carPlate, email, mobile;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
        appBar: AppBar(
          title: Text(
            "accountDetails",
            style: TextStyle(
              color: isDarkMode(context) ? Colors.white : Colors.black,
            ),
          ).tr(),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _key,
            autovalidateMode: _validate,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                child: Text(
                  'publicInfo',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ).tr(),
              ),
              Material(
                  elevation: 2,
                  color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                  child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: ListTile.divideTiles(context: context, tiles: [
                        ListTile(
                          title: Text(
                            'First Name',
                            style: TextStyle(
                              color: isDarkMode(context) ? Colors.white : Colors.black,
                            ),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                firstName = val;
                              },
                              validator: validateName,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: user.firstName,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration:
                                  InputDecoration(border: InputBorder.none, hintText: 'First Name'.tr(), contentPadding: EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Last Name',
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                lastName = val;
                              },
                              validator: validateName,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: user.lastName,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration:
                                  InputDecoration(border: InputBorder.none, hintText: 'Last Name'.tr(), contentPadding: EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Car Model',
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                carName = val;
                              },
                              validator: validateEmptyField,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: user.carName,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration:
                                  InputDecoration(border: InputBorder.none, hintText: 'Car Model'.tr(), contentPadding: EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Car Plate',
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                carPlate = val;
                              },
                              validator: validateEmptyField,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: user.carNumber,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration:
                                  InputDecoration(border: InputBorder.none, hintText: 'Car Plate'.tr(), contentPadding: EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                      ]).toList())),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                child: Text(
                  'privateDetails',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ).tr(),
              ),
              Material(
                elevation: 2,
                color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: [
                        ListTile(
                          title: Text(
                            'Email Address',
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: TextFormField(
                              onSaved: (String? val) {
                                email = val;
                              },
                              validator: validateEmail,
                              textInputAction: TextInputAction.next,
                              initialValue: user.email,
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                                  InputDecoration(border: InputBorder.none, hintText: 'Email Address'.tr(), contentPadding: EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Phone Number',
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: TextFormField(
                              onSaved: (String? val) {
                                mobile = val;
                              },
                              validator: validateMobile,
                              textInputAction: TextInputAction.done,
                              initialValue: user.phoneNumber,
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(border: InputBorder.none, hintText: 'Phone Number'.tr(), contentPadding: EdgeInsets.only(bottom: 2)),
                            ),
                          ),
                        ),
                      ],
                    ).toList()),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: Material(
                      elevation: 2,
                      color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(12.0),
                        onPressed: () async {
                          _validateAndSave();
                        },
                        child: Text(
                          'save',
                          style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY)),
                        ).tr(),
                      ),
                    ),
                  )),
            ]),
          ),
        ));
  }

  _validateAndSave() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      AuthProviders? authProvider;
      List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
      await Future.forEach(userInfoList, (auth.UserInfo info) {
        if (info.providerId == 'password') {
          authProvider = AuthProviders.PASSWORD;
        } else if (info.providerId == 'phone') {
          authProvider = AuthProviders.PHONE;
        }
      });
      bool? result = false;
      if (authProvider == AuthProviders.PHONE && auth.FirebaseAuth.instance.currentUser!.phoneNumber != mobile) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            phoneNumber: mobile,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, 'savingDetails'.tr(), false);
          await _updateUser();
          await hideProgress();
        }
      } else if (authProvider == AuthProviders.PASSWORD && auth.FirebaseAuth.instance.currentUser!.email != email) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            email: email,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, 'savingDetails'.tr(), false);
          await _updateUser();
          await hideProgress();
        }
      } else {
        showProgress(context, 'savingDetails'.tr(), false);
        await _updateUser();
        hideProgress();
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _updateUser() async {
    user.firstName = firstName!;
    user.lastName = lastName!;
    user.email = email!;
    user.phoneNumber = mobile!;
    user.carNumber = carPlate!;
    user.carName = carName!;
    var updatedUser = await FireStoreUtils.updateCurrentUser(user);
    if (updatedUser != null) {
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'detailsSavedSuccessfully',
        style: TextStyle(fontSize: 17),
      ).tr()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'couldntSaveDetails,PleaseTryAgain',
        style: TextStyle(fontSize: 17),
      ).tr()));
    }
  }
}
