import 'package:cultyvate/utils/flutter_toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../kuwaitproject/screens/kuwait_screen.dart';
import '../../models/farmer_profile.dart';
import '../../models/weather_model.dart';
import '../../network/api_helper.dart';
import '../../network/authservice.dart';
import '../../services/dashboard_service.dart';
import '../../services/savepassword.dart';
import '../notifications/push_notification_manager.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../utils/string_extension.dart';
import '../../services/login_service.dart';
import '../dashboard/dashboard.dart';
import '../updateappdialog.dart';
import '../weather_station/weather_data.dart';
import './enter_otp.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
///Test build
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

// MG Done
class _LoginState extends State<Login> {
  final AuthService authService = AuthService();
  static const String _errorText = "Please enter your 10 digit mobile number";
  Farmer? farmer;
  bool _obscurePassword = true;
  String localTimeZone='UTC';
  var version;
  bool later = false;
  final db = DatabaseHelper();
  bool savepassword = true;

  void _toggleCheckbox(bool value) {
    setState(() {
      savepassword = value;
    });
  }


  @override
  void initState() {
    super.initState();
    getTimeZone();
    getversion();
  }



  getTimeZone() async {
    try {
      localTimeZone =await FlutterNativeTimezone.getLocalTimezone();
      print("local timezone ${localTimeZone}");
      // loading=false;
    } catch (e) {
      localTimeZone= 'UTC'; // Default to UTC if unable to determine the time zone
    }
  }
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  Future<void> loginPasswordValidate() async {
    if (loginController.text.trim() == "" ||
        passwordController.text.trim() == "") {
      FlutterToastUtil.showErrorToast(
          "Please enter your user name and password.".i18n);
    } else {
      Map<String, dynamic> response = await LoginService().validateUser(
          loginController.text.trim(), passwordController.text.trim());

      if (response == {} || (response["farmerID"] ?? "") == "") {
        FlutterToastUtil.showErrorToast("Invalid user id / pwd.".i18n);
        return;
      }

      await PushNotificationsManager().saveFCMToken(userToken, response["userID"]);
      print('weater station ${response['onlyWeatherStationYN']}');
      if (response["onlyWeatherStationYN"] == true) {
        getFarmerData(response["farmerID"]);
      }
      else if(response["onlyPolyhouseYN"]==true){
        authService.login(username: loginController.text, password: passwordController.text, id: response["farmerID"].toString(), farmerdashboard: false, polyhouse: true, weaterstation: false);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
            builder: (_) =>WeaterDevices(utc: localTimeZone,farmerid:response["farmerID"] ,)));

      }
      else {
     //    farmerIDname=response["farmerID"];
     //    await db.initDatabase();
     // try{
     //   if(savepassword) {
     //
     //     final username = loginController.text.trim();
     //     final password = passwordController.text.trim(); // Hash this password securely
     //     // final hashedPassword = hashPassword(password); // Implement hashPassword function
     //     await db.insertUser(username, password);
     //     // farmer: farmer,
     //   }
     //   else {
     //     await db.deleteUser();
     //   }
     // }
     // catch(e){
     //
     // }
        authService.login(polyhouse: false,weaterstation: false,farmerdashboard: true,username: loginController.text, password: passwordController.text,id: response["farmerID"].toString());
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => Dashboard(farmerID: response["farmerID"])));
      }
    }
  }

  Future<void> getversion() async {
    var versioncode = await LoginService().getversion();
    version = versioncode;
    await db.initDatabase();
    // if(savepassword) {
// Get the stored user data
   try{
     final user = await db.getUser();

     if (user != null) {
       final storedUsername = user['username'];
       final storedPassword = user['password'];

       loginController.text = storedUsername;
       passwordController.text = storedPassword;

       // You can use the stored data for authentication or any other purpose
     } else {
       print('No user data found.');
     }
   }
   catch(e){
     loginController.text = '';
     passwordController.text = '';
   }
    // }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getFarmerData(farmerID) async {
    setState(() {});
    DashboardService dashboardService = DashboardService();

    farmer = await dashboardService.getFarmer(farmerID);
       print("data weater startion,$farmer");
    if (farmer == null || farmer!.farmlands!.isEmpty) {
      Navigator.pop(context);
    }
    else {
      farmer!.farmlands!.forEach((element) {
        element.devices!.forEach((devices) {
          if (devices.type == "WST") {
            authService.login(username: loginController.text, password: passwordController.text, id: farmerID.toString(), farmerdashboard: false, polyhouse: false, weaterstation: true);
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

  Future<void> checkAppVersion(vesionfromapi) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versioncode = packageInfo.version;
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String buildNumber = packageInfo.buildNumber;
    setState((){
      versionglobaly=versioncode;
    });
    print("version ${versioncode == vesionfromapi}");
    print("version $appName");
    print("version $packageName");
    print("version $buildNumber");
    // versionCode = '1.1';
    if (vesionfromapi != versioncode) {
      showUpdateDialog(context, packageName);
    } else {
      loginPasswordValidate();
    }
  }

  Future<void> showUpdateDialog(context, String packageName) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext contexts) {
          return UpdateDialog(packageName: packageName);
        }).then((value) {
      setState(() {
        later = true;
      });
      print("value $value");
    });
  }

  Future<void> getOTP() async {
    {
      if (mobileController.text.length != 10 ||
          (int.tryParse(mobileController.text) ?? 0) == 0) {
        FlutterToastUtil.showErrorToast(_errorText.i18n);
      }
      var apiData = await LoginService().generateOTP(mobileController.text);
           print("otp is $apiData");
      if (apiData != {} &&
          (apiData["otp"] ?? "") != "" &&
          (apiData["farmerID"] ?? "") != "") {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EnterOTP(
                mobile: mobileController.text,
                otp: apiData["otp"],
                farmerID: apiData["farmerID"])));
      } else {
        FlutterToastUtil.showErrorToast(
            "Could not generate OTP. Please try later.".i18n);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
                backgroundColor: cultGreen,
                title: Text('Enter login details'.i18n,
                    style: TextStyle(color:Colors.white,fontSize: heading2Font.sp)),
                bottom: TabBar(
                  tabs: [
                    Text("OTP".i18n, style: TextStyle(color: Colors.white,fontSize: bodyFont.sp)),
                    Text("User Name".i18n,
                        style: TextStyle(color: Colors.white,fontSize: bodyFont.sp)),
                  ],
                 indicatorColor: Colors.green,
                  indicatorWeight: 5.0,
                )),
            body: TabBarView(
              children: [
                Container(
                    width: ScreenUtil.defaultSize.width,
                    height: ScreenUtil.defaultSize.height,
                    padding:
                        EdgeInsets.symmetric(vertical: 30.h, horizontal: 10.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter your'.i18n,
                          style: TextStyle(
                              fontSize: bodyFont.sp, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0.h),
                          child: Text('mobile number'.i18n,
                              style: TextStyle(
                                  fontSize: bodyFont.sp,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          width: ScreenUtil.defaultSize.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20.h),
                                    Text('+91',
                                        style: TextStyle(
                                            color: cultGrey,
                                            fontSize: bodyFont.sp,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              Container(
                                  width: ScreenUtil.defaultSize.width * 75 / 100,
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r)),
                                  height: 80.h,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: mobileController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: _errorText.i18n,
                                      hintStyle:
                                          TextStyle(color: Colors.black,fontSize: footerFont.sp),
                                      labelText: 'Mobile'.i18n,
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(10), // Limits input to 10 characters
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allows only digits
                                    ],
                                    style: TextStyle(color: Colors.black),
                                  )

                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                        InkWell(
                            onTap: () async => getOTP(),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20.h, vertical: 10.w),
                              height: 50.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: cultGreen,
                                  borderRadius: BorderRadius.circular(10.r)),
                              child: Center(
                                  child: Text(
                                'Get OTP'.i18n,
                                style: TextStyle(
                                    fontSize: bodyFont.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                            )),
                      ],
                    )),
                Container(
                    decoration: BoxDecoration(
                        color: cultLightGrey,
                        borderRadius: BorderRadius.circular(10.r)),
                    width: ScreenUtil.defaultSize.width,
                    height: ScreenUtil.defaultSize.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Container(
                            padding: EdgeInsets.all(10.r),
                            height: 80.h,
                            width: double.infinity,
                            child: TextField(
                              controller: loginController,
                              style:TextStyle(color:Colors.black),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9a-zA-Z]")),
                              ],
                              decoration: InputDecoration(
                                icon: const FaIcon(FontAwesomeIcons.circleUser),
                                iconColor: cultGrey,
                                labelText: 'User Name'.i18n,
                              ),
                            )),
                        Container(
                            padding: EdgeInsets.only(left: 50.w, right: 10.w),
                            decoration: BoxDecoration(
                                color: cultLightGrey,
                                borderRadius: BorderRadius.circular(10.r)),
                            height: 80.h,
                            width: double.infinity,
                            child: TextField(
                              controller: passwordController,
                              style:TextStyle(color:Colors.black),
                              // inputFormatters: [
                              //   FilteringTextInputFormatter.allow(
                              //       RegExp(r'^[ A-Za-z0-9]_@./#&+-*\%!^$'))
                              // ],
                              decoration: InputDecoration(
                                labelText: 'Password'.i18n,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),

                              obscureText: _obscurePassword,
                              // obscureText: true,
                            )),
                        SizedBox(height: 20.h),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: <Widget>[
                        //     Text('Save password',style: TextStyle(color: Colors.black),),
                        //     Checkbox(
                        //       value:savepassword,
                        //       activeColor: Colors.green,
                        //       onChanged: (bool ?vale){
                        //         _toggleCheckbox(vale!);
                        //       },
                        //     ),
                        //
                        //   ],
                        // ),
                        InkWell(
                            onTap: () {
                              later
                                  ? loginPasswordValidate()
                                  : checkAppVersion(version);
                              //
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10.h),
                              height: ScreenUtil().setHeight(50.h),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: cultGreen,
                                  borderRadius: BorderRadius.circular(10.r)),
                              child: Center(
                                  child: Text(
                                'Login'.i18n,
                                style: TextStyle(
                                    fontSize: bodyFont.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                            )),
                      ],
                    )),
              ],
            ),
          ),
        ),
      );

  }
}
