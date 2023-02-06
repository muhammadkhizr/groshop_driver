import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gromartdriver/constants.dart';
import 'package:gromartdriver/services/FirebaseHelper.dart';
import 'package:gromartdriver/services/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_model.dart';

class LanguageChooseScreen extends StatefulWidget {
  bool isContainer = false;

  LanguageChooseScreen({Key? key, required this.isContainer}) : super(key: key);

  @override
  State<LanguageChooseScreen> createState() => _LanguageChooceScreenState();
}

class _LanguageChooceScreenState extends State<LanguageChooseScreen> {
  var languageList = <Data>[];
  String selectedLanguage = "en";

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    languageList.clear();
    await FireStoreUtils.firestore.collection(Setting).doc("languages").get().then((value) {
      if (value != null) {
        List list = value.data()!["list"];
        for (int i = 0; i < list.length; i++) {
          Map data = list[i];
          if (data["isActive"]) {
            Data langData = new Data();
            langData.language = data["title"];
            langData.languageCode = data["slug"];

            if (langData.languageCode == "en") {
              langData.icon = "assets/flags/ic_uk.png";
            } else if (langData.languageCode == "es") {
              langData.icon = "assets/flags/ic_spain.png";
            } else if (langData.languageCode == "ar") {
              langData.icon = "assets/flags/ic_uae.png";
            } else if (langData.languageCode == "fr") {
              langData.icon = "assets/flags/ic_france.png";
            } else if (langData.languageCode == "hi") {
              langData.icon = "assets/flags/ic_india.png";
            } else if (langData.languageCode == "mr") {
              langData.icon = "assets/flags/ic_india.png";
            } else if (langData.languageCode == "dt") {
              langData.icon = "assets/flags/ic_dutch.png";
            } else if (langData.languageCode == "DE") {
              langData.icon = "assets/flags/ic_germany.png";
            } else if (langData.languageCode == "pt") {
              langData.icon = "assets/flags/ic_portugal.png";
            } else {
              langData.icon = "assets/flags/ic_uk.png";
            }
            languageList.add(langData);
          }

          if (i == (languageList.length - 1)) {
            setState(() {});
          }
        }
      }
    });
    // final response = await rootBundle.loadString("assets/translations/language.json");
    // final decodeData = jsonDecode(response);
    // var productData = decodeData["data"];
    // setState(() {
    //   languageList = List.from(productData).map<Data>((item) => Data.fromJson(item)).toList();
    // });
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.containsKey("languageCode")) {
      selectedLanguage = sp.getString("languageCode")!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ListView.builder(
                itemCount: languageList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedLanguage = languageList[index].languageCode.toString();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        decoration: languageList[index].languageCode == selectedLanguage
                            ? BoxDecoration(
                                border: Border.all(color: Color(COLOR_PRIMARY)),
                                borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                    ),
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Image.asset(
                                languageList[index].icon.toString(),
                                height: 60,
                                width: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Text(languageList[index].language.toString(), style: const TextStyle(fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(COLOR_PRIMARY),
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            onPressed: () async {
              if (selectedLanguage == "en") {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", selectedLanguage);
                context.setLocale(Locale(selectedLanguage));
              } else if (selectedLanguage == "ar") {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", selectedLanguage);
                context.setLocale(Locale(selectedLanguage));
              } else if (selectedLanguage == "hi") {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", selectedLanguage);
                context.setLocale(Locale(selectedLanguage));
              }else if (selectedLanguage == "mr") {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", selectedLanguage);
                context.setLocale(Locale(selectedLanguage));
              } else {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", "en");
                context.setLocale(Locale("en"));
              }

              if (widget.isContainer) {
                SnackBar snack = SnackBar(
                  content: Text(
                    'languageChangeSuccessfully'.tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              'save'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode(context) ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
