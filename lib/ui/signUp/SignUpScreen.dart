import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gromartdriver/constants.dart';
import 'package:gromartdriver/main.dart';
import 'package:gromartdriver/model/User.dart';
import 'package:gromartdriver/services/FirebaseHelper.dart';
import 'package:gromartdriver/services/helper.dart';
import 'package:gromartdriver/ui/container/ContainerScreen.dart';
import 'package:gromartdriver/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../auth/AuthScreen.dart';

File? _image;
File? _carImage;

class SignUpScreen extends StatefulWidget {
  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _carNameController = TextEditingController();
  TextEditingController _carPlateController = TextEditingController();

  GlobalKey<FormState> _key = GlobalKey();
  bool isUserImage = true;
  String? firstName, lastName, carName, carPlate, email, mobile, password, confirmPassword;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  @override
  void initState() {
    if (MyAppState.currentUser != null) {
      _emailController.text = MyAppState.currentUser!.email;
      _phoneController.text = MyAppState.currentUser!.phoneNumber;
      _firstNameController.text = MyAppState.currentUser!.firstName;
      _lastNameController.text = MyAppState.currentUser!.lastName;
      _carNameController.text = MyAppState.currentUser!.carName;
      _carPlateController.text = MyAppState.currentUser!.carNumber;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      retrieveLostData();
    }

    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDarkMode(context) ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: Form(
            key: _key,
            autovalidateMode: _validate,
            child: formUI(),
          ),
        ),
      ),
    );
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (isUserImage) {
          _image = File(response.file!.path);
        } else {
          _carImage = File(response.file!.path);
        }
      });
    }
  }

  _onCameraClick(bool isUserImage) {
    isUserImage = isUserImage;
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'addProfilePicture' : 'addCarImage',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('chooseFromGallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                isUserImage ? _image = File(image.path) : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('takeAPicture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                isUserImage ? _image = File(image.path) : _carImage = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('removePicture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isUserImage ? _image = null : _carImage = null;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Widget formUI() {
    return Column(
      children: <Widget>[
        Align(
            alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.topLeft : Alignment.topRight,
            child: Text(
              'completeSetUp',
              style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 25.0),
            ).tr()),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 32, right: 8, bottom: 8),
          child: SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade400,
                      child: ClipOval(
                        child: SizedBox(
                          width: 170,
                          height: 170,
                          child: _image == null
                              ? Image.asset(
                                  'assets/images/placeholder.jpg',
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 80,
                      right: 0,
                      child: FloatingActionButton(
                        heroTag: 'profileImage',
                        backgroundColor: Color(COLOR_ACCENT),
                        child: Icon(
                          CupertinoIcons.camera,
                          color: isDarkMode(context) ? Colors.black : Colors.white,
                        ),
                        mini: true,
                        onPressed: () => _onCameraClick(true),
                      ),
                    )
                  ],
                ),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade400,
                      child: ClipOval(
                        child: SizedBox(
                          width: 170,
                          height: 170,
                          child: _carImage == null
                              ? Image.asset(
                                  'assets/images/car_default_image.png',
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _carImage!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 80,
                      right: 0,
                      child: FloatingActionButton(
                        heroTag: 'carImage',
                        backgroundColor: Color(COLOR_ACCENT),
                        child: Icon(
                          CupertinoIcons.camera,
                          color: isDarkMode(context) ? Colors.black : Colors.white,
                        ),
                        mini: true,
                        onPressed: () => _onCameraClick(false),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _firstNameController,
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              onSaved: (String? val) {
                firstName = val;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: easyLocal.tr('First Name'),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _lastNameController,
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              onSaved: (String? val) {
                lastName = val;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Last Name'.tr(),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carNameController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              onSaved: (String? val) {
                carName = val;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Model'.tr(),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _carPlateController,
              validator: validateEmptyField,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              onSaved: (String? val) {
                carPlate = val;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Car Plate'.tr(),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _phoneController,
              readOnly: true,
              keyboardType: TextInputType.phone,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmptyField,
              onSaved: (String? val) {
                mobile = val;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Phone Number'.tr(),
                // focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                    BorderSide(color: Colors.grey.shade200, width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              onSaved: (String? val) {
                email = val;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email Address'.tr(),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // ConstrainedBox(
        //   constraints: BoxConstraints(minWidth: double.infinity),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //     child: TextFormField(
        //       obscureText: true,
        //       textAlignVertical: TextAlignVertical.center,
        //       textInputAction: TextInputAction.next,
        //       controller: _passwordController,
        //       validator: validatePassword,
        //       onSaved: (String? val) {
        //         password = val;
        //       },
        //       style: TextStyle(fontSize: 18.0),
        //       cursorColor: Color(COLOR_PRIMARY),
        //       decoration: InputDecoration(
        //         contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         fillColor: Colors.white,
        //         hintText: 'Password'.tr(),
        //         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //         errorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         focusedErrorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.grey.shade200),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // ConstrainedBox(
        //   constraints: BoxConstraints(minWidth: double.infinity),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //     child: TextFormField(
        //       textAlignVertical: TextAlignVertical.center,
        //       textInputAction: TextInputAction.done,
        //       onFieldSubmitted: (_) => _signUp(),
        //       obscureText: true,
        //       validator: (val) => validateConfirmPassword(_passwordController.text, val),
        //       onSaved: (String? val) {
        //         confirmPassword = val;
        //       },
        //       style: TextStyle(fontSize: 18.0),
        //       cursorColor: Color(COLOR_PRIMARY),
        //       decoration: InputDecoration(
        //         contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         fillColor: Colors.white,
        //         hintText: 'Confirm Password'.tr(),
        //         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //         errorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         focusedErrorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.grey.shade200),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(COLOR_PRIMARY),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'finish'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () => _signUp(),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'or',
              style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ).tr(),
          ),
        ),
        InkWell(
          onTap: () async {
            User user = MyAppState.currentUser!;
            if (user == null) {
              pushAndRemoveUntil(context, AuthScreen(), false);
            } else {
            user.isActive = false;
            user.lastOnlineTimestamp = Timestamp.now();
            await FireStoreUtils.updateCurrentUser(user);
            await auth.FirebaseAuth.instance.signOut();
            MyAppState.currentUser = null;
            pushAndRemoveUntil(context, AuthScreen(), false);
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: 0, right: 40, left: 40),
            child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Color(COLOR_PRIMARY), width: 1)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Icon(Icons.logout),
                      Text(
                        'logout'.tr(),
                        style: TextStyle(
                            color: Color(COLOR_PRIMARY),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ])),
          ),
        )

        // Padding(
        //   padding: const EdgeInsets.all(32.0),
        //   child: Center(
        //     child: Text(
        //       'OR',
        //       style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
        //     ).tr(),
        //   ),
        // ),
        // InkWell(
        //   onTap: () {
        //     push(context, PhoneNumberInputScreen(login: false));
        //   },
        //   child: Padding(
        //     padding: EdgeInsets.only(top: 10, right: 40, left: 40),
        //     child: Container(
        //         alignment: Alignment.bottomCenter,
        //         padding: EdgeInsets.all(10),
        //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Color(COLOR_PRIMARY), width: 1)),
        //         child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        //           Icon(
        //             Icons.phone,
        //             color: Color(COLOR_PRIMARY),
        //           ),
        //           Text(
        //             'signUpWithPhoneNumber'.tr(),
        //             style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
        //           ),
        //         ])),
        //   ),
        // )
      ],
    );
  }

  /// if the fields are validated and location is enabled we create a new user
  /// and navigate to [ContainerScreen] else we show error
  _signUp() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      // await _signUpWithEmailAndPassword();
      await _updateData();
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _updateData() async {
    await showProgress(context, 'updatingDataToDatabase'.tr(), false);
    dynamic result = await FireStoreUtils.firebaseUpdateUserData(
        MyAppState.currentUser!.userID,
        email!.trim(),
        _image,
        _carImage,
        carName!,
        carPlate!,
        firstName!,
        lastName!,
        mobile!,
        context);
    await hideProgress();

    if (result != null && result is User) {
      MyAppState.currentUser = result;
      if (MyAppState.currentUser!.active != true) {
        // pushAndRemoveUntil(context, ContainerScreen(user: result), false);
        showAlertDialog(context,
            'yourAccountHasBeenDisabledPleaseContactToAdmin'.tr(), "", true);
      } else {
        pushAndRemoveUntil(context, ContainerScreen(user: result), false);
      }
      // pushAndRemoveUntil(context, ContainerScreen(user: result), false);
    } else {
      showAlertDialog(context, 'failed'.tr(), result, true);
      pushReplacement(context, AuthScreen());
    }
  }

  _signUpWithEmailAndPassword() async {
    await showProgress(context, 'creatingNewAccountPleaseWait'.tr(), false);
    dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
        email!.trim(), password!.trim(), _image, _carImage, carName!, carPlate!, firstName!, lastName!, mobile!);
    await hideProgress();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
      pushAndRemoveUntil(context, ContainerScreen(user: result), false);
    } else if (result != null && result is String) {
      showAlertDialog(context, 'failed'.tr(), result, true);
    } else {
      showAlertDialog(context, 'failed'.tr(), 'couldntSignUp'.tr(), true);
    }
  }

  @override
  void dispose() {
    // _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _carNameController.dispose();
    _carPlateController.dispose();
    _image = null;
    _carImage = null;
    super.dispose();
  }
}
