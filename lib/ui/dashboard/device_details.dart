import 'package:cultyvate/services/dashboard_service.dart';
import 'package:cultyvate/services/irrigation_service.dart';
import 'package:cultyvate/utils/styles.dart';
import 'package:flutter/material.dart';
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/sms.dart';
import 'package:cultyvate/savedata/sharedpref.dart';
import 'package:get/get.dart';
import '../../network/api_helper.dart';
import '../../utils/constants.dart';
import '../../utils/flutter_toast_util.dart';
import '../../utils/string_extension.dart';
import '../../utils/common_functions.dart';
import '../../models/farmer_profile.dart';
import '../../models/telematic_model.dart';

class DeviceDetails extends StatefulWidget {
   DeviceDetails(
      {required this.deviceDetails,
      required this.isOn,
      required this.isOnline,
         this.interaptflag,
        this.isScheduleRunning,

       this.iopDevice,
      required this.valveDevices,
      this.telematicModel,
      this.updateDate,
      required  this.farmlandID,
      Key? key})
      : super(key: key);
  final Device? deviceDetails;
  final bool ?isScheduleRunning;
  final bool isOn;
  final DateTime? updateDate;
  final bool isOnline;
  final int ?interaptflag;
  final int farmlandID;
   String ?iopDevice;
  final List<String> valveDevices;
  final TelematicModel? telematicModel;

  @override
  State<DeviceDetails> createState() => _DeviceDetailsState();
}

class _DeviceDetailsState extends State<DeviceDetails> {



  late bool isOn;
  late bool isOnline;
  bool buttonDisabled = false;
  late Device? deviceDetails;
  late String deviceType;
  String duration = '';
  String deviceName = '';


  // void sendSMS(String recipient, String message) {
  //   SmsSender smsSender = SmsSender();
  //   SmsMessage smsMessage = SmsMessage(recipient, message);
  //   smsSender.sendSms(smsMessage);
  //   // setState(() {
  //   //   messages.add(smsMessage);
  //   // });
  //   // _textController.clear();
  // }

  @override
  void initState() {
    super.initState();
    isOn = widget.isOn;
    isOnline = widget.isOnline;

    deviceDetails = widget.deviceDetails;
    print("device details $deviceDetails");
    deviceType = deviceDetails?.type == 'ENG'
        ? 'Pump Controller V2'.i18n
        : deviceDetails?.type == 'IOP'
            ? 'Pump Controller V1'.i18n:
    deviceDetails?.type == 'MEM'
        ? 'Pump Controller V3'.i18n
            : 'Irrigation Valve'.i18n;
    deviceName = deviceDetails?.name ?? '';
    // print("update date ${}")
    duration =widget.updateDate !=null ? getDuration(widget.updateDate):"";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          backgroundColor: cultGreen,
          title: Text(
            'Device Details'.i18n,
          ),
          leading: Padding(
            padding: EdgeInsets.all(10.h),
            child: IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.chevronLeft,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )),
      body: Container(
        padding: EdgeInsets.all(10.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: ScreenUtil.defaultSize.width,
            height: 10.h,
          ),
          Text(
            deviceType,
            style: const TextStyle(
                fontSize: heading2Font, fontWeight: FontWeight.bold, color: cultGrey),
          ),
          Container(
              padding: EdgeInsets.only(top: 30.h),
              width: 80.h,
              height: 80.h,
              child: Image(
                  image: AssetImage(deviceDetails?.type == 'IOP' ||
                          deviceDetails?.type == 'ENG' || deviceDetails?.type == 'MEM'
                      ? 'assets/images/pump_black_large.jpg'
                      : isOn
                          ? 'assets/images/valve_open_large.jpg'
                          : 'assets/images/valve_closed_black_large.jpg'))),
          SizedBox(
            height: 20.h,
          ),
          Text(
            deviceName.trim(),
            style: const TextStyle(
                fontSize: bodyFont, fontWeight: FontWeight.bold, color: cultGrey),
          ),
          SizedBox(height: 20.h),
          Text(
            'Device ID: '.i18n + deviceDetails!.deviceEUIID??"",
            style: TextStyle(fontSize: 12.sp, color: cultGrey),
          ),
          SizedBox(height: 5.h),
          Text(
            'Hardware Serial Number:'.i18n +
                ' ' +
                (deviceDetails!.hardwareSerialNumber ?? ''),
            style: TextStyle(fontSize: 12.sp, color: cultGrey),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: Row(
                  children: [
                    Container(
                      height: 120.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                          border: Border.all(color: cultLightGrey, width: 2),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text('STATUS'.i18n,
                              style:
                                  TextStyle(fontSize: 10.sp, color: cultGrey)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(
                              deviceDetails!.type == 'IOP' ||
                                      deviceDetails!.type == 'ENG'||deviceDetails!.type == 'MEM'
                                  ? (isOn)
                                      ? 'On'.i18n
                                      : 'Off'.i18n
                                  : (isOn)
                                      ? 'Open'.i18n
                                      : 'Close'.i18n,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: cultGrey,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(duration,
                              style:
                                  TextStyle(fontSize: 12.sp, color: cultGrey)),
                        )
                      ]),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    Container(
                      height: ScreenUtil().setHeight(120),
                      width: ScreenUtil().setWidth(100),
                      decoration: BoxDecoration(
                          border: Border.all(color: cultLightGrey, width: 2),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text('CONNECTION'.i18n,
                              style:
                                  TextStyle(fontSize: 10.sp, color: cultGrey)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(isOnline ? 'Online'.i18n : 'Offline'.i18n,
                              style: const TextStyle(
                                  color: cultGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(duration,
                              style:
                                  TextStyle(fontSize: 12.sp, color: cultGrey)),
                        )
                      ]),
                    )
                  ],
                ),
              ),
              deviceDetails!.type != 'IOP' && deviceDetails!.type != 'ENG'
                  ? Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Row(
                        children: [
                          Container(
                            height: 120.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: cultLightGrey, width: 2.w),
                                borderRadius: BorderRadius.circular(10.r)),
                            child: Column(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text('BATTERY'.i18n,
                                    style: TextStyle(
                                        fontSize: 10.sp, color: cultGrey)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                    (widget.telematicModel?.batteryMV ?? 0)
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: cultGreen,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(duration,
                                    style: TextStyle(
                                        fontSize: 12.sp, color: cultGrey)),
                              )
                            ]),
                          )
                        ],
                      ),
                    )
                  : SizedBox()
            ],
          ),
          SizedBox(height: 10.h),
          deviceDetails!.type == 'IOP' || deviceDetails!.type == 'ENG'||deviceDetails!.type == 'MEM'
              ? Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Row(
                        children: [
                          Container(
                            height: 120.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: cultLightGrey, width: 2),
                                borderRadius: BorderRadius.circular(10.r)),
                            child: Column(children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text('Volt/Amps'.i18n + ' Blue',
                                    style: TextStyle(
                                        fontSize: 10.sp, color: cultGrey)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                    (widget.telematicModel?.emVolatgeB ?? 0)
                                            .toString() +
                                        ' volts'.i18n,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: cultGrey,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                    (widget.telematicModel?.emCurrentB ?? 0)
                                            .toString() +
                                        ' amps'.i18n,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: cultGrey,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        children: [
                          Container(
                            height: ScreenUtil().setHeight(120),
                            width: ScreenUtil().setWidth(100),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: cultLightGrey, width: 2),
                                borderRadius: BorderRadius.circular(10.r)),
                            child: Column(children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text('Volt/Amps'.i18n + ' Yellow',
                                    style: TextStyle(
                                        fontSize: 10.sp, color: cultGrey)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                    (widget.telematicModel?.emVolatgeY ?? 0)
                                            .toString() +
                                        ' volts'.i18n,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: cultGrey,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                    (widget.telematicModel?.emCurrentY ?? 0)
                                            .toString() +
                                        ' amps'.i18n,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: cultGrey,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Row(
                        children: [
                          Container(
                            height: 120.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: cultLightGrey, width: 2.w),
                                borderRadius: BorderRadius.circular(10.r)),
                            child: Column(children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text('Volt/Amps'.i18n + ' Red',
                                    style: TextStyle(
                                        fontSize: 10.sp, color: cultGrey)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                    (widget.telematicModel?.emVolatgeR ?? 0)
                                            .toString() +
                                        ' volts'.i18n,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: cultGrey,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                    (widget.telematicModel?.emCurrentR ?? 0)
                                            .toString() +
                                        ' amps'.i18n,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: cultGrey,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : SizedBox(height: 50),
          SizedBox(height: 10.h),
          // deviceDetails!.type == 'IOP' || deviceDetails!.type == 'ENG'||deviceDetails!.type == 'MEM'
        widget.isScheduleRunning==true?  InkWell(
          onTap:(){
      showCustomDialog(context,'Running scheduler will be cancel & permanently deleted\n Are you sure?');
         // Navigator.pop(context);
          },
            child: Container(
              height: ScreenUtil().setHeight(50),
              width: double.infinity,
              decoration: isOnline && !buttonDisabled
                  ? BoxDecoration(
                  color: cultGreen,
                  borderRadius: BorderRadius.circular(10.r))
                  : BoxDecoration(
                  color: cultSoftGrey,
                  borderRadius: BorderRadius.circular(10.r)),
              child: Center(
                  child: Text(
                  "Terminating Running Schedule & stop pump",
                    style: isOnline
                        ? TextStyle(
                        fontSize: bodyFont.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)
                        : TextStyle(
                        fontSize: bodyFont.sp,
                        fontWeight: FontWeight.bold,
                        color: cultLightGrey),
                  )),
            ),
          ):SizedBox(height: 10.h),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () async {
              var onoff=isOn?0:1;
              DashboardService dashboardService = DashboardService();
              List<dynamic> dynamicList = widget.valveDevices;

              String formattedString = dynamicList
                  .map((element) => "'$element'")
                  .join(',');
              print(formattedString);

              // void readFromSharedPreferences() async {

                // print(value);
              // }
              if (!isOnline || buttonDisabled) return;
              if (deviceDetails!.type == 'BR1') {
                var body=  {
                  "deviceID":deviceDetails!.deviceEUIID,
                  "OperationType" :isOn?'CloseOFF':'OpenON',
                  "DeviceTypeID":2
                };
                print('flow data${body}');
                var flowData = await ApiHelper().post(path:'$watherstationURL/common/downlink', postData: body);
                if(flowData['success']==true){

                  String? value = await SharedPreferencesService.getString(deviceDetails!.deviceEUIID);
                  // var onoff=isOn?1:0;
                  if (value!.contains(deviceDetails!.deviceEUIID)) {
                    // Update existing value

                    var data= await SharedPreferencesService.remove(deviceDetails!.deviceEUIID);
                    await SharedPreferencesService.setString(deviceDetails!.deviceEUIID!, '${onoff}');
                    await SharedPreferencesService.setString(action_check, '1');
                    // prefs.setString(deviceId!, value!);
                  } else {
                    // Add new value
                    await SharedPreferencesService.setString(action_check, '1');
                    await SharedPreferencesService.setString(deviceDetails!.deviceEUIID!, '${onoff}');
                    // prefs.setString(deviceId!, value!);
                  }

                  FlutterToastUtil.showSuccessToastExit('Device turned '.i18n +
                      (isOn ? 'on'.i18n : 'off'.i18n) +
                      '.command sent'
                          .i18n,2).then((value) => Navigator.pop(context));
                }
                else {
                  FlutterToastUtil.showErrorToast(
                      'Operation failed: Please try later.'.i18n +
                          flowData["message"].toString().i18n);
                }
              print('flow data${flowData}');
              }
              else if (deviceDetails!.type == 'BR2') {
                var body=  {
                  "deviceID":deviceDetails!.deviceEUIID,
                  "OperationType" :isOn?'CloseOFF2':'OpenON2',
                  "DeviceTypeID":31
                };
                print(body);
                var flowData = await ApiHelper().post(path:'$watherstationURL/common/downlink', postData: body);
               if(flowData['success']==true){

                 String? value = await SharedPreferencesService.getString(deviceDetails!.deviceEUIID);
                 if (value!.contains(deviceDetails!.deviceEUIID)) {
                   // Update existing value
                   var data= await SharedPreferencesService.remove(deviceDetails!.deviceEUIID);
                   await SharedPreferencesService.setString(deviceDetails!.deviceEUIID!, '${onoff}');
                   await SharedPreferencesService.setString(action_check, '1');
                   // prefs.setString(deviceId!, value!);
                 } else {
                   // Add new value
                   await SharedPreferencesService.setString(action_check, '1');
                   await SharedPreferencesService.setString(deviceDetails!.deviceEUIID!, '${onoff}');
                   // prefs.setString(deviceId!, value!);
                 }

                 FlutterToastUtil.showSuccessToastExit('Device turned '.i18n +
                     (isOn ? 'on'.i18n : 'off'.i18n) +
                     '.command sent.'
                         .i18n,2);
               }
               else {
                 FlutterToastUtil.showErrorToast(
                     'Operation failed: Please try later.'.i18n +
                         flowData["message"].toString().i18n);
               }
                print('flow data${flowData}');
              }
              // else if(deviceDetails!.type=='ENG' ||deviceDetails!.type=='IOP' ){
              //   sendSMS('+917013944309',isOn?"ON":"OFF");
              // }
              else {


                buttonDisabled = await DashboardService().deviceTurnOnOff(
                    deviceDetails!.deviceEUIID,
                    deviceDetails!.type,
                    widget?.iopDevice??'',
                    widget.valveDevices,
                    !isOn);
                setState(() {});



              }

            },
            child: Container(
              height: ScreenUtil().setHeight(50),
              width: double.infinity,
              decoration: isOnline && !buttonDisabled
                  ? BoxDecoration(
                      color: cultGreen,
                      borderRadius: BorderRadius.circular(10.r))
                  : BoxDecoration(
                      color: cultSoftGrey,
                      borderRadius: BorderRadius.circular(10.r)),
              child: Center(
                  child: Text(
                deviceDetails!.type == 'IOP' ||deviceDetails!.type == 'ENG'||deviceDetails!.type == 'MEM'
                    ? isOnline
                        ? isOn
                            ? 'Off'.i18n
                            : 'On'.i18n
                        :deviceDetails!.type == 'MEM'? "${widget.interaptflag ==0? "No Power":widget.interaptflag==2?"Low Voltage":widget.interaptflag==3?"High Voltage":widget.interaptflag==4?"Over Load":widget.interaptflag==5?"Dry Run":""}": 'Offline'.i18n
                    : isOnline
                        ? isOn
                            ? 'Close'.i18n
                            : 'Open'.i18n
                        : deviceDetails!.type == 'MEM'?"No Power": 'Offline'.i18n,
                style: isOnline
                    ? TextStyle(
                        fontSize: bodyFont.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)
                    : TextStyle(
                        fontSize: bodyFont.sp,
                        fontWeight: FontWeight.bold,
                        color: cultLightGrey),
              )),
            ),
          ),



        ]),
      ),
    ));
  }

   showCustomDialog(BuildContext context, Message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.warning, // You can use any desired icon
                color: Colors.orange,
                size: 50.0,
              ),
              SizedBox(height: 16.0),
              Text(Message,style: TextStyle(color: Colors.black),),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: ()async {

                IrrigationService irrigation=IrrigationService();
              bool data= await   irrigation.Terminateschdule(blockPlotDevices:widget.valveDevices ,farmerFarmlandid:widget.farmlandID ,Iopdevice:widget.iopDevice ,contxt: context);
                Navigator.pop(context);
             if(data){
               showsucess(context,'Scheduler Successfully Terminated\nPump OFF comand sent \n \n Scheduler Deleted \n Please recreate schedule');

             }
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                // Handle the "No" button action here
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false); // Close the dialog and return false
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }


  void showsucess(BuildContext context, Message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.warning, // You can use any desired icon
                color: Colors.orange,
                size: 50.0,
              ),
              SizedBox(height: 16.0),
              Text(Message,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: ()async {
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false);
                // IrrigationService irrigation=IrrigationService();
                // bool data= await   irrigation.Terminateschdule(blockPlotDevices:widget.valveDevices ,farmerFarmlandid:widget.farmlandID ,Iopdevice:widget.iopDevice ,contxt: context);
                // if(data){
                //   Navigator.of(context).pop(false);
                //
                // }
              },
              child: Text("Ok"),
            ),

          ],
        );
      },
    );
  }

}
