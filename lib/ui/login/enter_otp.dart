import 'package:cultyvate/ui/notifications/push_notification_manager.dart';
import 'package:cultyvate/utils/flutter_toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/styles.dart';
import '../../utils/string_extension.dart';
import '../dashboard/dashboard.dart';

class EnterOTP extends StatefulWidget {
  const EnterOTP(
      {Key? key,
      required this.mobile,
      required this.otp,
      required this.farmerID})
      : super(key: key);
  final String mobile;
  final int otp;
  final int farmerID;

  @override
  State<EnterOTP> createState() => _EnterOTPState();
}

// MG: Done
class _EnterOTPState extends State<EnterOTP> {
  TextEditingController otp1 = TextEditingController();
  TextEditingController otp2 = TextEditingController();
  TextEditingController otp3 = TextEditingController();
  TextEditingController otp4 = TextEditingController();
  FocusNode otp1Focus = FocusNode();
  FocusNode otp2Focus = FocusNode();
  FocusNode otp3Focus = FocusNode();
  FocusNode otp4Focus = FocusNode();
  String finalOTP = "";

  submitOTP() {
    finalOTP = otp1.text + otp2.text + otp3.text + otp4.text;
    print('OTP submitted: $finalOTP');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          width: ScreenUtil.defaultSize.width,
          height: ScreenUtil.defaultSize.height,
          padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              Text(
                'Enter the OTP sent'.i18n,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0.h),
                child: Text('to your mobile'.i18n,
                    style: TextStyle(
                        fontSize: bodyFont.sp, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.only(left: 10.w),
                width: ScreenUtil.defaultSize.width,
                child: Row(
                  children: [
                    SizedBox(
                      height: 40.h,
                      width: 40.h,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: otp1,
                        focusNode: otp1Focus,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color:Colors.black),
                        decoration:
                            const InputDecoration(fillColor: cultLightGrey),
                        onTap: () {
                          otp1.text = '';
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        onChanged: (newValue) {
                          if (newValue.isNotEmpty) {
                            otp2Focus.nextFocus();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20.h),
                    SizedBox(
                      height: 40.h,
                      width: 40.h,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: otp2,
                        focusNode: otp2Focus,
                        style: TextStyle(color:Colors.black),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(fillColor: cultLightGrey),
                        onTap: () {
                          otp2.text = '';
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        onChanged: (newValue) {
                          if (newValue.isEmpty) {
                            otp1Focus.requestFocus();
                          } else {
                            otp3Focus.requestFocus();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20.w),
                    SizedBox(
                      height: 40.h,
                      width: 40.h,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: otp3,
                        focusNode: otp3Focus,
                        style: TextStyle(color:Colors.black),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(fillColor: cultLightGrey),
                        onTap: () {
                          otp3.text = '';
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        onChanged: (newValue) {
                          if (newValue.isEmpty) {
                            otp2Focus.requestFocus();
                          } else {
                            otp4Focus.requestFocus();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20.w),
                    SizedBox(
                      height: 40.h,
                      width: 40.h,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: otp4,
                        focusNode: otp4Focus,
                        style: TextStyle(color:Colors.black),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(fillColor: cultLightGrey),
                        onTap: () {
                          otp4.text = '';
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        onChanged: (newValue) async {
                          if (newValue.isEmpty) return;
                          submitOTP();
                          if (finalOTP == widget.otp.toString()) {
                            final SharedPreferences _prefs =
                                await SharedPreferences.getInstance();
                            bool tokenSaved =
                                _prefs.getBool('TOKENSAVED') ?? false;
                            if (!tokenSaved) {
                              String token = _prefs.getString("FCMToken") ?? '';
                              PushNotificationsManager()
                                  .saveFCMToken(token, widget.farmerID);
                            }

                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Dashboard(farmerID: widget.farmerID)));
                          } else {
                            FlutterToastUtil.showErrorToast(
                                "OTP incorrect, please try again or change the mobile number."
                                    .i18n);
                            otp1.text = '';
                            otp2.text = '';
                            otp3.text = '';
                            otp4.text = '';
                            otp1Focus.requestFocus();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.h),
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: cultGreen,
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Center(
                        child: Text(
                      'Did not get OTP, try again'.i18n,
                      style: TextStyle(
                          fontSize: bodyFont.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                  )),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Wrong Number?'.i18n,
                      style:
                          TextStyle(color: cultGrey, fontSize: footerFont.sp)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text('Change Number'.i18n,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: footerFont.sp,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
