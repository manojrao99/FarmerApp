import 'package:cultyvate/models/login.dart';
import 'package:cultyvate/utils/flutter_toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../kuwaitproject/screens/kuwait_screen.dart';
import '../../models/farmer_profile.dart';
import '../../network/authservice.dart';
import '../../services/dashboard_service.dart';
import '../weather_station/weather_data.dart';
import './login.dart';
import '../dashboard/dashboard.dart';
import '../../utils/styles.dart';
import '../../utils/constants.dart';
import '../../utils/string_extension.dart';

class ChooseLanguage extends StatefulWidget {
  const ChooseLanguage({this.fromDashboard, this.farmerID, Key? key})
      : super(key: key);
  final bool? fromDashboard;
  final int? farmerID;
  @override
  State<ChooseLanguage> createState() => _ChooseLanguageState();
}

// MG: DONE
class _ChooseLanguageState extends State<ChooseLanguage> {
  List<String> supportedLanguages = ['en', 'kn', 'pb', 'te', 'mr', 'hi'];
  bool showUI = false; // Controls whether to show the UI or spinkit
  bool fromDashboard = false;
  int farmerID = 0;

  @override
  initState() {
    super.initState();
    if (widget.fromDashboard ?? false) {
      fromDashboard = true;
      farmerID = widget.farmerID ?? 0;
    }
    checkSavedLanguage();
  }

  /// Checks Shared Prefs if the language is already selected
  /// and if so then move to login screen
  Future<void> checkSavedLanguage() async {
    String localTimeZone='UTC';
    // getTimeZone() async {
      try {
        localTimeZone =await FlutterNativeTimezone.getLocalTimezone();
        print("local timezu ${localTimeZone}");
        // loading=false;
      } catch (e) {
        localTimeZone= 'UTC'; // Default to UTC if unable to determine the time zone
      }
    // }
    final AuthService authService = AuthService();
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? locale = _prefs.getString(localeKey);
    print("locale ${locale}");
    if ((locale ?? "") != "" && supportedLanguages.contains(locale)) {
      I18n.of(context).locale = Locale(locale!);
      language = locale;
      var userexist= await authService.doesUserExist();
     if(userexist){
       UserModel ?  data=await authService.getUserModel();
       print(data);
       print(data?.farmerDashboard);
       if(data?.farmerDashboard??false) {
         Navigator.of(context).pushReplacement(
             MaterialPageRoute(builder: (context) =>
                 Dashboard(farmerID: int.parse(data!.id))));
       }
       else if(data?.polyhouse??false){
         Navigator.pushReplacement(
             context,
             MaterialPageRoute(
                 builder: (_) =>WeaterDevices(utc: localTimeZone,farmerid:int.parse(data!.id) ,)));
       }
       else {
         getFarmerData(int.parse(data!.id) );
       }
     }
     else{
       Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => const Login()));
     }
     } else {
      setState(() {
        showUI = true;
      });
    }
  }
  Future<void> getFarmerData(farmerID) async {
    setState(() {});
    DashboardService dashboardService = DashboardService();
    Farmer? farmer;
    farmer = await dashboardService.getFarmer(farmerID);
    print("data weater startion,$farmer");
    if (farmer == null || farmer!.farmlands!.isEmpty) {
      Navigator.pop(context);
    }
    else {
      farmer!.farmlands!.forEach((element) {
        element.devices!.forEach((devices) {
          if (devices.type == "WST") {
            // authService.login(username: loginController.text, password: passwordController.text, id: farmerID.toString(), farmerdashboard: false, polyhouse: false, weaterstation: true);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => WeatherData(
                      Farmerid: farmerID,
                      farmer: farmer,
                      selectedfarmland: 0,
                      deviceid: devices.deviceEUIID,
                      comefrom: 'Login',
                    )));
          }
        });
      });
    }
  }
  // Method called on selection of a language by user
  void languageSelected(String locale) async {
    if (supportedLanguages.contains(locale)) {
      I18n.of(context).locale = Locale(locale);
      final SharedPreferences _prefs = await SharedPreferences.getInstance();
      if (!await _prefs.setString(localeKey, locale)) {
        FlutterToastUtil.showErrorToast(
          "Could not save your language preference.".i18n,
        );
      }
      if (fromDashboard) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Dashboard(farmerID: farmerID)));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()));
      }
    }
  }
  void languageSelectedc(String locale) async {
    print("language is ${locale}");
    if (supportedLanguages.contains(locale)) {
      final SharedPreferences _prefs = await SharedPreferences.getInstance();
      setState(() {
        I18n.of(context).locale = Locale(locale);
        _prefs.setString(localeKey, locale);
      });


      if (!await _prefs.setString(localeKey, locale)) {
        FlutterToastUtil.showErrorToast(
          "Could not save your language preference.".i18n,
        );
      }

      if (fromDashboard) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Dashboard(farmerID: farmerID)));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: (!showUI)
          ? SpinKitCircle(
              itemBuilder: (BuildContext context, int index) {
                return const DecoratedBox(
                  decoration: BoxDecoration(
                    color: cultGreen,
                  ),
                );
              },
            )
          : Container(
              width: ScreenUtil.defaultSize.width,
              height: ScreenUtil.defaultSize.height,
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ScreenUtil().setHeight(40.h)),
                  Text(
                    'Choose'.i18n,
                    style: TextStyle(
                        fontSize: heading2Font.sp, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.0.h),
                    child: Text('your language'.i18n,
                        style: TextStyle(
                            fontSize: heading2Font.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 40.h),
                  InkWell(
                      onTap: () => languageSelected("en"),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        height: ScreenUtil().setHeight(60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cultGreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(
                          'English',
                          style: TextStyle(
                              fontSize: bodyFont.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      )),
                  InkWell(
                      onTap: () => languageSelected("kn"),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 19, vertical: 10),
                        height: ScreenUtil().setHeight(60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cultGreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(
                          'தமிழ்',
                          style: TextStyle(
                              fontSize: heading2Font.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      )),
                  InkWell(
                      onTap: () => languageSelected("hi"),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 19, vertical: 10),
                        height: ScreenUtil().setHeight(60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cultGreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(
                          'हिन्दी',
                          style: TextStyle(
                              fontSize: heading2Font.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      )),
                  InkWell(
                      onTap: () => languageSelected("te"),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 19, vertical: 10),
                        height: ScreenUtil().setHeight(60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cultGreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(
                          'తెలుగు',
                          style: TextStyle(
                              fontSize: heading2Font.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      )),
                  InkWell(
                      onTap: () => languageSelected("mr"),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 19, vertical: 10),
                        height: ScreenUtil().setHeight(60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cultGreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(
                          'मराठी',
                          style: TextStyle(
                              fontSize: heading2Font.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      )),
                  InkWell(
                      onTap: () => languageSelected("pa"),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 19, vertical: 10),
                        height: ScreenUtil().setHeight(60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cultGreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(
                          'ਪੰਜਾਬੀ',
                          style: TextStyle(
                              fontSize: bodyFont.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      ))
                ],
              )),
    );
  }
}
