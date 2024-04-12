import 'package:cultyvate/network/authservice.dart';
import 'package:cultyvate/savedata/sharedpref.dart';
import 'package:cultyvate/ui/dashboard/device_details.dart';
import 'package:cultyvate/ui/dashboard/select_farmland.dart';
import 'package:cultyvate/ui/dashboard/webview.dart';
import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_gif/flutter_gif.dart';
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// import 'package:gif/gif.dart';
import 'package:gif_view/gif_view.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';
import '../../logs/logfile.dart';
import '../../models/telematic_model.dart';
import '../../utils/styles.dart';
import '../../utils/constants.dart';
import '../../utils/flutter_toast_util.dart';
import '../../utils/string_extension.dart';
import '../../utils/common_functions.dart';
import '../../services/dashboard_service.dart';
import '../internetcheck/getXcontroller.dart';
import '../internetcheck/internetprovider.dart';
import '../internetcheck/nointernet.dart';
import '../irrigation_schedule/schedule_calendar.dart';
import '../login/login.dart';
import '../notifications/notifications.dart';
import '../../models/weather_model.dart';
import '../../models/farmer_profile.dart';
import '../../utils/waterflow_chart.dart';
import '../../network/api_helper.dart';
import '../login/choose_language.dart';
import 'dart:async';

import '../weather_station/weather_data.dart';
import '../widgets/snr_UI.dart';

enum Arrow { left, right }

class Dashboard extends StatefulWidget {
   Dashboard({required this.farmerID,this.selectedID});
  final int farmerID;
  int ?selectedID;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _fps = 30;
  String dateandtimeitc(DateTime? dateUtc) {
    if (dateUtc == null) {
      return '';
    }

    // Convert the UTC date to local time
    DateTime localDateTime = dateUtc.toLocal();

    // Get the current date in local time
    DateTime currentDate = DateTime.now();
       int day=localDateTime.day;
       int currentday=currentDate.day;
    // Calculate the time difference between the current date and the given date
    Duration difference = currentDate.difference(localDateTime);

    // Check if the given date is today
    if(localDateTime.month==currentDate.month) {
      if (currentday - day == 0) {
        // Format the time as 'hh:mm a'
        String formattedTime = DateFormat('hh:mm a').format(localDateTime);

        return formattedTime;
      }
      // Check if the given date is yesterday
      else if (currentday - day == 1) {
        String formattedTime = DateFormat('hh:mm a').format(localDateTime);
        return 'Yesterday $formattedTime';
      }
      else {

      // Format the date as 'dd MMM'
      String formattedDate = DateFormat('dd MMM').format(localDateTime);

      // Format the time as 'hh:mm a'
      String formattedTime = DateFormat('hh:mm a').format(localDateTime);

      return '$formattedDate $formattedTime';

      }
    }
    // Check if the given date is day before yesterday
 else {
      // Format the date as 'dd MMM'
      String formattedDate = DateFormat('dd MMM').format(localDateTime);

      // Format the time as 'hh:mm a'
      String formattedTime = DateFormat('hh:mm a').format(localDateTime);

      return '$formattedDate $formattedTime';
    }
  }





  // String dateandtimeitc(DateTime ?dateUtc) {
  //   // Add the desired offset to convert from UTC to local time
  //   print("date utc ${dateUtc}");
  //   DateTime LOCAL =dateUtc!.toLocal();
  //   // DateTime localDateTime = dateUtc!.add(Duration(hours: 4, minutes: 30));
  //
  //   // Format the localDateTime as a string in 12-hour format
  //   String formattedDateTime = DateFormat('hh:mm a').format(LOCAL);
  //
  //   return formattedDateTime;
  // }
  void getFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('key');
    print(value); // 'value'
  }


  late int farmerID;
  bool action=false;
  String actionname='';
  // final HomePageController controller =
  //     Get.put(HomePageController(), permanent: true);
  int selectedFarmland = 0;
  int selectedBlock = 0;
  int blocksCount = 0;
  bool drawerIsOpen = false;
  CurrentWeatherModel? currentWeatherModel;
  String location = '';
  bool gotWeatherData = false;
  bool leftEnabled = false;
  bool rightEnabled = true;
  String scheduleType = '';
  DateTime ? lastirrigatedTime;
  DateTime ? operatingsenceTime;
  String scheduleSubHeading = '';
  String sensorValue = '';
  String farmlandDeviceList = '';
  List<String> waterMeterDeviceList = [];
  Map<String, dynamic> x = {};
  late Widget icon;
  Widget waterChart = Container();
  int selectedFarmlandID = 0;
  Farmer? farmer;
  bool farmlandDropDownOpen = false;
  bool iopFound = false;
  bool engFound = false;
  Device? iopDeviceDetails;
  Device? engDeviceDetails;
  Device? fcwDeviceDetails;
  Map<String, TelematicModel> telematicData = {};
  Map<String, String> moistureDevices = {};
  List<String> valveDeviceList = [];
  Map<String, dynamic> valveFlow = {};
  Map<String, dynamic> valveDuration = {};
  bool gatewayOnline = false;
  bool pumpControllerOnline = false;
  bool pumpControllerOnOff = false;
  bool engControllerOnline = false;
  bool engControllerOnOff = false;
  String pumpDurationText = '';
  bool telematicDone = false;
  bool scheduleTypeDone = false;
  bool waterflowDone = false;
  double blockFlow = 0;
  String farmlandWaterMeter = '';
  Map<String, dynamic> flowData = {};
  List<Widget> plots = [];
  List<BlockAggregate> blockAggregates = [];
  int farmFlow = 0;
  String waterflowDuration = 'W';
  Map<String, List<String>>? blockDevices;
  Map<int, Device>? plotWaterMeterDevices;
  bool showWaterFlowChart = false;
  Widget waterflowChart = const SizedBox();
  Stopwatch stopWatch = Stopwatch();
  bool isScheduleRunning = false;
  bool refreshOngoing = false;
  bool farmlandFCM = false;
  Map<int, double> blockDurationValues = {};
  Map<int, double> blockFlowValues = {};

  BoxDecoration boxDecorationSelected = BoxDecoration(
      color: cultGreen, border: Border.all(color: cultGrey, width: 0.2));

  BoxDecoration boxDecorationUnselected = BoxDecoration(
      color: cultGreenOpacity, border: Border.all(color: cultGrey, width: 0.2));

  final GlobalKey<DrawerControllerState> _drawerKey =
      GlobalKey<DrawerControllerState>();
  final drawerScrimColor = cultSoftGrey;
  int remainingTime = 0;
  // FlutterGifController ?controller;

  Log logger = Log();
  final HomePageController controllerinternet =
  Get.put(HomePageController(), permanent: true);
  Timer? timer;
  @override
  void didChangeDependencies() {
    print('didChangeDependencies(), counter ');
    super.didChangeDependencies();
  }
  final controller = GifController();

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    stopWatch.stop();
    print("cancel");
    super.dispose();

  }
  // Future<void> requestPermissions() async {
  //   var status = await Permission.sms.status;
  //   if (!status.isGranted) {
  //     await Permission.sms.request();
  //   }
  // }
  // late FlutterGifController controller1;
  @override
  void initState() {
    controller.play();
    version ();

    // Assume you have an API call that returns a response

    // controller1= FlutterGifController(vsync: this);
    // loop from 0 frame to 29 frame
    // controller1.repeat(min:0, max:29, period:const Duration(microseconds:300));

    // controller1 = GifController(vsync: this);
  // controller= FlutterGifController(vsync: this);
  //   WidgetsBinding.instance.addObserver(this);
  // WidgetsBinding.instance?.addPostFrameCallback((_) {
  //   controller!.repeat(
  //     min: 0,
  //     max: 13,
  //     period: const Duration(milliseconds: 200),
  //   );
  // });
    // requestPermissions();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    farmerID = widget.farmerID;
    if(widget.selectedID !=null){
      selectedFarmland=widget.selectedID!.toInt();
    }
    else {
      selectedFarmland =0;
    }
    getFarmerData();
    icon = const SizedBox();
  }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     timer?.cancel();
  //     stopWatch.stop();
  //  setState((){
  //    remainingTime =0;
  //  });
  //     print("app passed");
  //     // Perform cleanup operations when the app goes to the background
  //   }
  //   if(state == AppLifecycleState.resumed){
  //      getTelematics();
  //
  //
  //     print("app ressumed");
  //   }
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      timer?.cancel();
      stopWatch.stop();
      setState(() {
        remainingTime = 0;
      });
      print("App paused");
      // Perform cleanup operations when the app goes to the background
    } else if (state == AppLifecycleState.resumed) {
      getTelematics();
      print("App resumed");
    }
  }

  void version ()async{

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versioncode = packageInfo.version;
    setState((){
      versionglobaly=versioncode;
    });
  }


  void setTimerRemaining() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      if (isScheduleRunning) {
        remainingTime = (2 * 60) - stopWatch.elapsed.inSeconds;
      }
      else if (action){
        remainingTime =(2 * 60) - stopWatch.elapsed.inSeconds;
      }
      else {
        remainingTime = (15 * 60) - stopWatch.elapsed.inSeconds;
      }
      if (mounted) {
        setState(() {});
        if (remainingTime <= 0) {
          timer?.cancel();
          await getTelematics();
        }
      }
    });
  }



  void resetStopWatch() {
    stopWatch.reset();
    stopWatch.start();
    setTimerRemaining();
  }
  //final DragStartDetails drawerDragStartBehavior = DragStartDetails();

  void openDrawer() {
    _drawerKey.currentState?.open();
    drawerIsOpen = true;
    setState(() {});
  }

  void closeDrawer() {
    _drawerKey.currentState?.close();
    drawerIsOpen = false;
    setState(() {});
  }

  void setSelectedFarmland(int farm) {
    selectedFarmland = farm;
    selectedFarmlandID = farmer?.farmlands![farm].id??0;
    telematicDone = false;
    waterflowDone = false;
    scheduleTypeDone = false;
    setState(() {});
    getTelematics();
  }

  Widget _body() => (!telematicDone || !waterflowDone || !scheduleTypeDone)
      ? SpinKitCircle(
          itemBuilder: (BuildContext context, int index) {
            return const DecoratedBox(
              decoration: BoxDecoration(
                color: cultGreen,
              ),
            );
          },
        )
      : Material(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(color: cultLightGrey),
                padding: EdgeInsets.all(20.r),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                child: const Image(
                                    image: AssetImage(
                                        '${assetImagePath}hamburger.png')),
                                onTap: () {
                                  (drawerIsOpen) ? closeDrawer() : openDrawer();
                                }),
                            SizedBox(
                              width: 30.w,
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(40),
                              child: const Image(
                                  image: AssetImage(
                                      '${assetImagePath}cultyvate.png')),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    timer?.cancel();
                                    await getTelematics();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  iconSize: 25.h,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (iopFound || engFound) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ScheduleCalendar(
                                                    farmerID: farmerID,
                                                    farmlandID: selectedFarmlandID,
                                                    farmlandselected: selectedFarmland,
                                                    allBlocks: farmer
                                                            ?.farmlands![
                                                                selectedFarmland]
                                                            .blocks ??
                                                        [],
                                                    farmlandname: farmer
                                                        ?.farmlands![
                                                    selectedFarmland]
                                                        .name??"",
                                                  )));
                                    } else {
                                      FlutterToastUtil.showErrorToast(
                                          'Can not define irrigation schedule as IOP device not found for the farmland');
                                    }
                                  },
                                  child: const Image(
                                    image: AssetImage(
                                        '${assetImagePath}calendar_black.jpg'),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Notifications(
                                                farmerid: farmer!.farmerID,
                                              ))),
                                  child: const Image(
                                      image: AssetImage(
                                          '${assetImagePath}bell.png')),
                                ),
                              ],
                            ),
                          ]),
                      SizedBox(height: ScreenUtil().setHeight(5)),
                      Text(
                          'Data refresh in'.i18n +
                              ' ' +
                              (remainingTime / 60).floor().toString() +
                              ':' +
                              ((remainingTime % 60).toString().length == 1
                                  ? '0' + (remainingTime % 60).toString()
                                  : (remainingTime % 60).toString()),
                          style: const TextStyle( color:
                          Colors.orange,
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      SizedBox(height: ScreenUtil().setHeight(10)),
                      Material(
                        borderRadius: BorderRadius.circular(10),
                        elevation: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(2)),
                          height: ScreenUtil().setHeight(60),
                          width: ScreenUtil.defaultSize.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                      radius: 25.r,
                                      backgroundColor: cultLightGrey,
                                      backgroundImage: const AssetImage(
                                          '${assetImagePath}avataar.png')),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello '.i18n +
                                              (language == 'en'
                                                  ? '${farmer?.name}'
                                                  : '${farmer?.alias}'),
                                          style: TextStyle(
                                          color:Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: footerFont.sp),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                height:
                                                    ScreenUtil().setHeight(14),
                                                width:
                                                    ScreenUtil().setHeight(14),
                                                child: Center(
                                                    child: SizedBox(
                                                        height: ScreenUtil()
                                                            .setHeight(18),
                                                        width: ScreenUtil()
                                                            .setHeight(18),
                                                        child: const Image(
                                                            image: AssetImage(
                                                                '${assetImagePath}location_pin.png'))))),
                                            Container(
                                              height: 20.sp,
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Center(
                                                  child: Text(
                                                language == 'en'
                                                    ? farmer?.villageName
                                                            ?.trim() ??
                                                        ''
                                                    : farmer?.villageAlias
                                                            ?.trim() ??
                                                        '',
                                                style: TextStyle(
                                                    fontSize: footerFont.sp,color:Colors.black),
                                              )),
                                            ),
                                            SizedBox(width: 30),
                                            // const Text('V 2.0 beta Testing',
                                            //     style: TextStyle(
                                            //         color: Colors.red,
                                            //         fontSize: 10,
                                            //         fontWeight:
                                            //             FontWeight.bold))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                Visibility(
                                  visible: isScheduleRunning,
                                  child: 
                                  
                                      
                                  Padding(padding: EdgeInsets.only(
                                    left: 50,
                                  ),child:
                                    Column(
                                      children: [
                                        Container(
                                    height:35,
                                          child:   
                                          
                                          
                                          // Gif(
                                          //   controller: controller1,
                                          //   fps: _fps,
                                          //   image: const AssetImage('assets/images/giphy.gif'),
                                          // ),
                                          GifView.asset('${assetImagePath}giphy.gif'
                                              ,controller: controller,

                                          )
                                          // GifImage(
                                          //   controller: controller1,
                                          //   image: AssetImage("${assetImagePath}giphy.gif"),
                                          //    ),
                                        ),
                                        Text('Schedule running',style: TextStyle(color:Colors.black,fontSize: 10,fontWeight: FontWeight.bold),)
                                      ],
                                    )),
                                )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(10)),
                      Stack(children: [
                        Container(
                          width: double.infinity,
                          height: ScreenUtil().setHeight(150),
                          decoration: BoxDecoration(
                              image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image:
                                      AssetImage('${assetImagePath}farm.png')),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        Container(
                          width: double.infinity,
                          height: ScreenUtil().setHeight(150),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(17, 143, 128, .9)),
                        ),
                        Column(children: [
                          SizedBox(height: 10.r),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 10.r),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  (gatewayOnline)
                                      ? const Image(
                                          image: AssetImage(
                                              '${assetImagePath}gateway.png'))
                                      : const Image(
                                          image: AssetImage(
                                              '${assetImagePath}gateway_red.png')),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: gatewayOnline
                                        ? Text("Online".i18n,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp))
                                        : Text(
                                            "Offline".i18n,
                                            style: TextStyle(
                                                color: cultRed,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    language == 'en'
                                        ? farmer?.farmlands![selectedFarmland]
                                                .name ??
                                            ''
                                        : farmer?.farmlands![selectedFarmland]
                                                .alias ??
                                            '',
                                    style: TextStyle(
                                        // fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: 10.h),
                                  scheduleType == ""
                                      ? SizedBox()
                                      : scheduleType == 'T'
                                          ? Text('Timer based irrigation'.i18n,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold))
                                          : scheduleType == 'S'
                                              ? Text(
                                                  'Soil Moisture based irrigation'
                                                      .i18n,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : Text(
                                                  'Volume based Irrigation'
                                                      .i18n,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                ],
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              InkWell(
                                onTap: () {
                                  bool containweatherstatio = false;

                                  farmer?.farmlands!.forEach((element) {
                                    // if(element.devices())
                                    element.devices!.forEach((devices) {
                                      if (devices.type.contains("WST")) {
                                        setState(() {
                                          containweatherstatio = true;
                                        });

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => WeatherData(
                                                      Farmerid: farmerID,
                                                      deviceid:
                                                          devices.deviceEUIID,
                                                      Device: devices,
                                                      farmer: farmer,
                                                      selectedfarmland:
                                                          selectedFarmland,
                                                      comefrom: "Dashboard",
                                                    )));
                                      } else {}
                                    });
                                  });
                                  if (!containweatherstatio) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Row(children: [
                                                Image(
                                                    // color: Colors.white,
                                                    // height: 30,
                                                    //   width: 30,
                                                    image: AssetImage(
                                                        '${assetImagePath}WeatherStation.png'),
                                                    height: 40,
                                                    width: 40),
                                                SizedBox(width: 30),
                                                Text(
                                                    "Weather Station \n Not Installed",style: TextStyle(color: cultGrey,),),
                                              ]),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Ok"))
                                              ],
                                            ));
                                    // Fluttertoast.showToast(msg: "Weather Station Not Installed",
                                    //     backgroundColor: Colors.red,
                                    //     textColor: Colors.white
                                    //
                                    // );
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10.w),
                                  child: const Image(
                                      image: AssetImage(
                                          '${assetImagePath}WeatherStation.png'),
                                      height: 40,
                                      width: 40),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        (iopFound || engFound)
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                   Row(
                                                       children: [

                                                         Container(
                                                           height: ScreenUtil().setHeight(60),
                                                           // width:ScreenUtil().setWidth(130),
                                                           decoration: BoxDecoration(
                                                             // borderRadius: BorderRadius.circular(10.0),
                                                             // color: Colors.green,
                                                             // boxShadow: [
                                                             //   BoxShadow(
                                                             //     color: Colors.green[900]!, // Shadow color
                                                             //     offset: Offset(0, 3), // Shadow position (x, y)
                                                             //     blurRadius: 0.0, // Shadow spread
                                                             //   ),
                                                             // ],
                                                           ), child:  ElevatedButton(

                                                    onPressed: () {
                                                             print("ontap");
                                                             // if (isScheduleRunning) {
                                                             //   FlutterToastUtil
                                                             //       .showErrorToast(
                                                             //       "Irrigation Schedule Ongoing, Cannot Operate Device"
                                                             //           .i18n);
                                                             //   return;
                                                             // }
                                                             if (engDeviceDetails != null) {
                                                               print("ENg");
                                                               print( engDeviceDetails!
                                                                   .deviceEUIID);
                                                               print(telematicData[engDeviceDetails?.deviceEUIID]?.sensorDataPacketDateTime);
                                                               Navigator.push(
                                                                   context,
                                                                   MaterialPageRoute(
                                                                       builder: (context) => DeviceDetails(
                                                                           farmlandID: selectedFarmlandID,
                                                                           iopDevice:
                                                                           engDeviceDetails!
                                                                               .deviceEUIID,
                                                                           valveDevices:
                                                                           valveDeviceList,
                                                                           deviceDetails:
                                                                           engDeviceDetails,
                                                                           interaptflag:telematicData[iopDeviceDetails?.deviceEUIID]?.InterruptFlag??0 ,
                                                                           isScheduleRunning: isScheduleRunning,
                                                                           isOn:
                                                                           telematicData[engDeviceDetails?.deviceEUIID]?.operatingMode == 1,
                                                                           isOnline:
                                                                           telematicData[engDeviceDetails?.deviceEUIID]?.online ??
                                                                               false,
                                                                           telematicModel:
                                                                           telematicData[engDeviceDetails
                                                                               ?.deviceEUIID],
                                                                           updateDate:
                                                                           telematicData[engDeviceDetails?.deviceEUIID]
                                                                               ?.sensorDataPacketDateTime))).then((value)async{
                                                                 timer?.cancel();
                                                                 await getTelematics();
                                                               });
                                                             } else if (iopDeviceDetails !=
                                                                 null) {
                                                               print('pump online andn offline ${telematicData[iopDeviceDetails!.deviceEUIID]!.online }');
                                                               Navigator.push(
                                                                   context,
                                                                   MaterialPageRoute(
                                                                       builder: (context) => DeviceDetails(
                                                                           interaptflag: telematicData[iopDeviceDetails!.deviceEUIID]?.InterruptFlag??0,
                                                                           farmlandID: selectedFarmlandID,
                                                                           iopDevice:
                                                                           iopDeviceDetails!
                                                                               .deviceEUIID,
                                                                           valveDevices:
                                                                           valveDeviceList,
                                                                           deviceDetails:
                                                                           iopDeviceDetails,
                                                                           isOn:
                                                                           telematicData[iopDeviceDetails!.deviceEUIID]!.operatingMode ==
                                                                               1,
                                                                           isOnline:
                                                                           telematicData[iopDeviceDetails!.deviceEUIID]!.online ??
                                                                               false,
                                                                           telematicModel:
                                                                           telematicData[iopDeviceDetails
                                                                               ?.deviceEUIID],
                                                                           updateDate:
                                                                           telematicData[iopDeviceDetails?.deviceEUIID]
                                                                               ?.sensorDataPacketDateTime))).then((value)async{
                                                                 timer?.cancel();
                                                                 await getTelematics();
                                                               });
                                                             } else {
                                                               FlutterToastUtil
                                                                   .showErrorToast(
                                                                   "No Energy Meter or IOP device found for the farmland. Please contact support."
                                                                       .i18n);
                                                             }
                                                           },

                                                           style: ButtonStyle(
                                                             backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                                             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                               RoundedRectangleBorder(
                                                                 borderRadius: BorderRadius.circular(18.0),
                                                                 side: BorderSide(color: Colors.green),
                                                               ),
                                                             ),
                                                             elevation: MaterialStateProperty.all<double>(10), // Adjust the elevation for the 3D effect
                                                           ),


                                                           child: Column(
                                                             children: [

                                                               Container(
                                                                 padding: EdgeInsets.all(10.0),

                                                                 child:

                                                                 (pumpControllerOnline &&
                                                                     pumpControllerOnOff)

                                                                     ? Row(
                                                                   children: [
                                                                     const Image(
                                                                         image: AssetImage(
                                                                             '${assetImagePath}pump_white.png')),
                                                                     SizedBox(
                                                                         width:
                                                                         10.w),
                                                                     Text('On'.i18n,
                                                                         style: TextStyle(
                                                                             color:
                                                                             cultBlack,
                                                                             fontSize:
                                                                             footerFont
                                                                                 .sp,
                                                                             fontWeight:
                                                                             FontWeight.bold))
                                                                   ],
                                                                 )
                                                                     : (pumpControllerOnline &&
                                                                     !pumpControllerOnOff)
                                                                     ? Row(
                                                                   children: [
                                                                     const Image(
                                                                         image: AssetImage(
                                                                             '${assetImagePath}pump_black.png')),
                                                                     SizedBox(
                                                                         width: 10
                                                                             .w),
                                                                     Text(
                                                                         'Off'
                                                                             .i18n,
                                                                         style: TextStyle(
                                                                             color:
                                                                             cultBlack,
                                                                             fontSize:
                                                                             footerFont.sp,
                                                                             fontWeight: FontWeight.bold))
                                                                   ],
                                                                 )
                                                                     :  (!pumpControllerOnline)
                                                                     ? Row(
                                                                     children: [
                                                                       const Image(
                                                                           image: AssetImage('${assetImagePath}pump_red.png')),
                                                                       SizedBox(
                                                                           width: 10.w),
                                                                       Text(
                                                                           iopDeviceDetails!.type=='MEM'?'Off \n${telematicData[iopDeviceDetails!.deviceEUIID]?.InterruptFlag==0? "No Power":telematicData[iopDeviceDetails!.deviceEUIID]?.InterruptFlag==2?"Low Voltage":telematicData[iopDeviceDetails!.deviceEUIID]?.InterruptFlag==3?"High Voltage":telematicData[iopDeviceDetails!.deviceEUIID]?.InterruptFlag==4?"Over Load":telematicData[iopDeviceDetails!.deviceEUIID]?.InterruptFlag==5?"Dry Run":""}' :'Offline'.i18n,
                                                                           style: TextStyle(color: cultRed, fontSize: 12, fontWeight: FontWeight.bold))
                                                                     ])
                                                                     : const SizedBox(),
                                                               ),
                                                               iopDeviceDetails !=
                                                                   null? Row(
                                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                                 children: [
                                                                   SizedBox(width:10),
                                                                   Light(
                                                                     color: Colors.red,
                                                                     phace: telematicData[iopDeviceDetails!.deviceEUIID]?.emVolatgeR ==null? false: telematicData[iopDeviceDetails!.deviceEUIID]!.emVolatgeR> 0,
                                                                     voltage: telematicData[iopDeviceDetails!.deviceEUIID]?.emVolatgeR ?? 0,
                                                                   ),
                                                                   SizedBox(width:5),
                                                                   Light(color: Colors.blue,phace:telematicData[iopDeviceDetails!.deviceEUIID]?.emVolatgeB ==null?false: telematicData[iopDeviceDetails!.deviceEUIID]!.emVolatgeB > 0,voltage: telematicData[iopDeviceDetails!.deviceEUIID]?.emVolatgeB??0),
                                                                   SizedBox(width:5),
                                                                   Light(color: Colors.yellow,phace: telematicData[iopDeviceDetails!.deviceEUIID]?.emVolatgeY ==null?false:telematicData[iopDeviceDetails!.deviceEUIID]!.emVolatgeY  >0,voltage: telematicData[iopDeviceDetails!.deviceEUIID]?.emVolatgeY??0),
                                                                 ],
                                                               ):SizedBox()
                                                             ],
                                                           ),
                                                         ),
                                                         ),
                                                          SizedBox(width :3.w),
                                                         lastirrigatedTime !=null || operatingsenceTime !=null? Column(
                                                             children:[
                                                               Row(
                                                                 children:[
                                                                   Text("Pump ",style: TextStyle(
                                                                       color: Colors.white,
                                                                       fontSize: 12.sp)),
                                                                   Text(pumpControllerOnOff ?"ON":"OFF",style: TextStyle(
                                                                       fontWeight: FontWeight.bold,
                                                                       color: Colors.white,
                                                                       fontSize: 12.sp)),
                                                                 ]
                                                               ),
                                                               Text("at : ${ dateandtimeitc(pumpControllerOnOff? operatingsenceTime:lastirrigatedTime)}",style: TextStyle(
                                                                   color: Colors.white,
                                                                   fontSize: 12.sp))
                                                             ]
                                                         ):SizedBox()


                                                       ],
                                                   ),

                                                    SizedBox(height: 5.h),
                                                    (pumpControllerOnOff)
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .circleInfo,
                                                                  size: 15.r,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 5.w,
                                                                ),
                                                                Text(
                                                                    pumpDurationText,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ])
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .circleInfo,
                                                                  size: 15.r,
                                                                  color:
                                                                      cultRed,
                                                                ),
                                                                SizedBox(
                                                                  width: 5.w,
                                                                ),
                                                                Text(
                                                                    pumpDurationText,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12.sp)),
                                                              ]),
                                                  ])
                                            : const SizedBox(),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                      ],
                                    ),
                                  ),
                                  farmlandFCM ||farmer!.Address3=='#PlotFlowTrue'
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              child: Image(
                                                  height: 30.h,
                                                  width: 30.h,
                                                  image: const AssetImage(
                                                      '${assetImagePath}flow_white.png')),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Today: '.i18n +
                                                  farmFlow.toString() +
                                                  ' CBM',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            )
                                          ],
                                        )
                                      : SizedBox(),
                                ]),
                          )
                        ]),
                      ]),
                      Container(
                          height: (200.0.h +
                                  (270 * farmer!
                                          .farmlands![selectedFarmland]
                                          .blocks![selectedBlock]
                                          .plots!
                                          .length-1)),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: ScreenUtil().setHeight(130.h),
                                decoration: BoxDecoration(
                                       // color: Color(0xff43A478),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(horizontal: 10.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: ScreenUtil().setHeight(5)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => arrowClick(Arrow.left),
                                            child: leftEnabled
                                                ? const FaIcon(
                                                    FontAwesomeIcons
                                                        .arrowLeftLong,
                                                  )
                                                : const FaIcon(
                                                    FontAwesomeIcons
                                                        .arrowLeftLong,
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                          Text(
                                            (language == 'en')
                                                ? farmer!
                                                        .farmlands![
                                                            selectedFarmland]
                                                        .blocks![selectedBlock]
                                                        .name ??
                                                    ''
                                                : farmer!
                                                        .farmlands![
                                                            selectedFarmland]
                                                        .blocks?[selectedBlock]
                                                        .alias ??
                                                    '',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color:
                                                cultBlack,
                                                //  color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                arrowClick(Arrow.right),
                                            child: rightEnabled
                                                ? const FaIcon(
                                                    FontAwesomeIcons
                                                        .arrowRightLong,
                                                  )
                                                : const FaIcon(
                                                    FontAwesomeIcons
                                                        .arrowRightLong,
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: cultLightGrey,
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          farmlandFCM||farmer!.Address3=='#PlotFlowTrue'
                                              ? Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                vertical: 10.0,
                                                horizontal: 15),
                                            child: Column(
                                              children: [
                                                Text('Duration'.i18n,
                                                    style: TextStyle(
                                                        color: cultGrey,
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold)),
                                                SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(10)),
                                                const SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: Image(
                                                    image: AssetImage(
                                                        '${assetImagePath}time_sensor.png'),
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                Text(
                                                    (blockDurationValues[farmer!
                                                        .farmlands![
                                                    selectedFarmland]
                                                        .blocks![
                                                    selectedBlock]
                                                        .id]
                                                        ?.round()
                                                        .toString() ??
                                                        '0') +
                                                        ' mins'.i18n,
                                                    style: TextStyle(
                                                        color: cultGrey,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold)),
                                              ],
                                            ),
                                          )
                                              : SizedBox(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0, horizontal: 15),
                                            child: Column(
                                              children: [
                                                Text('Moisture'.i18n,
                                                    style: TextStyle(
                                                        color: cultGrey,
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                        FontWeight.bold)),
                                                SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(10)),
                                                const SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: Image(
                                                    image: AssetImage(
                                                        '${assetImagePath}soil_moist.png'),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(5)),
                                                blockAggregates[
                                                selectedBlock]
                                                    .soilMoisture.isNaN || blockAggregates[
                                                selectedBlock]
                                                    .soilMoisture.isInfinite?Text("0" +' %',  style: TextStyle(
                                                    color: cultGrey,
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                    FontWeight.bold)):
                                                Text(blockAggregates[
                                                    selectedBlock]
                                                        .soilMoisture
                                                        .round()
                                                        .toString()+' %',
                                                    style: TextStyle(
                                                        color: cultGrey,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                        FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                          farmlandFCM||farmer!.Address3=='#PlotFlowTrue'
                                              ? Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                vertical: 10.0,
                                                horizontal: 15),
                                            child: Column(
                                              children: [
                                                Text('Flow'.i18n,
                                                    style: TextStyle(
                                                        color: cultGrey,
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold)),
                                                SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(15)),
                                                const SizedBox(
                                                  child: Image(
                                                      height: 30,
                                                      width: 30,
                                                      image: AssetImage(
                                                          '${assetImagePath}flow.png')),
                                                ),
                                                SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(10)),
                                                Text(
                                                    (blockFlowValues[farmer?.farmlands![selectedFarmland].blocks![selectedBlock].id]
                                                        ?.round()
                                                        .toString() ??
                                                        '0') +
                                                        ' CBM',
                                                    style: TextStyle(
                                                        color: cultGrey,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold)),
                                              ],
                                            ),
                                          )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                    height: 0,
                                  ),
                                  Text(
                                    'Plots'.i18n,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color:
                                        cultBlack,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 0,
                                  ),
                                ],
                              ),
                              Column(children: plots)
                            ],
                          )),
                      SizedBox(height: ScreenUtil().setHeight(20)),
                      if (gotWeatherData && currentWeatherModel != null)
                        WeatherView(
                            currentWeatherModel: currentWeatherModel!,
                            location: ((language == 'en')
                                ? farmer?.farmlands![selectedFarmland]
                                        .farmlandVillageName ??
                                    ''
                                : farmer?.farmlands![selectedFarmland]
                                        .farmlandVillageAlias ??
                                    ''),
                            farmerId: widget.farmerID,
                            handleTap: showWeeklyForecast),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Water Consumption - '.i18n +
                                (scheduleType == 'T'
                                    ? 'Timer based'.i18n
                                    : scheduleType == 'V'
                                        ? 'Volume based'.i18n + ' (liters)'.i18n
                                        : 'Soil Moisture'.i18n),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox()
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.h, left: 5.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => handleDurationChange('W'),
                              child: Container(
                                  padding: EdgeInsets.all(0),
                                  width: (MediaQuery.of(context).size.width -
                                          45.w) /
                                      3,
                                  height: 20.h,
                                  decoration: waterflowDuration == 'W'
                                      ? boxDecorationSelected
                                      : boxDecorationUnselected,
                                  child: Center(
                                    child: Text(
                                      "Week".i18n,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: footerFont.sp,
                                          color: waterflowDuration == 'W'
                                              ? Colors.white
                                              : cultGrey),
                                    ),
                                  )),
                            ),
                            InkWell(
                              onTap: () => handleDurationChange('M'),
                              child: Container(
                                  width: (MediaQuery.of(context).size.width -
                                          45.w) /
                                      3,
                                  height: 20.h,
                                  decoration: waterflowDuration == 'M'
                                      ? boxDecorationSelected
                                      : boxDecorationUnselected,
                                  child: Center(
                                    child: Text(
                                      "Month".i18n,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(

                                          fontSize: footerFont.sp,
                                          color: waterflowDuration == 'M'
                                              ? Colors.white
                                              : cultGrey),
                                    ),
                                  )),
                            ),
                            InkWell(
                              onTap: () => handleDurationChange('Y'),
                              child: Container(
                                  width: ((MediaQuery.of(context).size.width -
                                              45.w) /
                                          3 -
                                      5.w),
                                  height: 20.h,
                                  decoration: waterflowDuration == 'Y'
                                      ? boxDecorationSelected
                                      : boxDecorationUnselected,
                                  child: Center(
                                    child: Text(
                                      "Year".i18n,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: footerFont.sp,
                                          color: waterflowDuration == 'Y'
                                              ? Colors.white
                                              : cultBlack),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(200.h),
                        //margin: const EdgeInsets.symmetric(vertical: 20),
                        child: showWaterFlowChart
                            ? waterflowChart
                            : SpinKitCircle(
                                itemBuilder: (BuildContext context, int index) {
                                  return const DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: cultGreen,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ]),
              ),
            ),
          ),
        );
  Future<bool> _onWillPop() async {
    // return (await showDialog(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //         title: Row(
    //           children: [
    //             Image(
    //               image: AssetImage('${assetImagePath}exit.png'),
    //               height: 30,
    //               width: 40,
    //             ),
    //             Text("Do you want to logout?",style: TextStyle(color: Colors.black),),
    //           ],
    //         ),
    //         actions: [
    //           TextButton(
    //             child: Text("Yes"),
    //             onPressed: () =>  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
    //                 Login()), (Route<dynamic> route) => false),
    //           ),
    //           TextButton(
    //             child: Text("No"),
    //             onPressed: () => Navigator.of(context).pop(false),
    //           ),
    //         ],
    //       ),
    //     )) ??
    //     false;
    // Navigator.of(context).pop();
       return true;;
  }

  _logout()async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Image(
                  image: AssetImage('${assetImagePath}exit.png'),
                  height: 30,
                  width: 40,
                ),
                Text("Do you want to logout?",style: TextStyle( fontSize: 14.sp,color: Colors.black),),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Yes"),
                onPressed: () {

                  AuthService auth=AuthService();
                  auth.logout();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => Login()),
                  // );
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                      Login()), (Route<dynamic> route) => false);
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        )) ??
        false;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Material(
        child: controllerinternet.ActiveConnection == false ? SafeArea(
        child:   Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height:  ScreenUtil().setHeight(30),
                  child:    IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new_outlined)),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                  child: const Image(
                      height: 60,
                      width: 80,
                      image: AssetImage(
                        '${assetImagePath}cultyvate.png',
                      )),
                ),
                SizedBox(
                  width: 20,
                ),

                SizedBox(
                  width: 10,
                ),

                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  height: 20,
                  width: 40,
                  child: Tooltip(
                    message: "In Progress",
                    textStyle: TextStyle(
                        backgroundColor: Colors.white, color: Colors.red),
                    child: Image(
                      image: AssetImage('${assetImagePath}bell.png'),
                    ),
                  ),
                ),
              ],
            ),
            Container(
                height: MediaQuery.of(context).size.height - 140,
                child: Expanded(
                  child: Center(child: NoInternetConnection()),
                )),
          ],
        )):



        Stack(
          children: [
            _body(),
            (drawerIsOpen)
                ? InkWell(
                    onTap: () => closeDrawer(),
                    child: Container(
                        width: ScreenUtil.defaultSize.width + 50,
                        height: ScreenUtil.defaultSize.height + 100,
                        color: Colors.grey.withOpacity(0.8)),
                  )
                : const SizedBox(),
            Positioned(
              top: 0,
              left: 0,
              child: DrawerController(
                key: _drawerKey,
                alignment: DrawerAlignment.start,
                child: Material(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    height:MediaQuery.of(context).size.height-5,
                    width: ScreenUtil.defaultSize.width * 80 / 100,
                    color: Colors.white,
                    child: SafeArea(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  width:
                                      ScreenUtil.defaultSize.width * 80 / 100,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(width: 20),
                                      const Image(
                                        image: AssetImage(
                                            '${assetImagePath}cultyvate.png'),
                                      ),
                                      IconButton(
                                        icon: const FaIcon(
                                            FontAwesomeIcons.xmark),
                                        onPressed: () => closeDrawer(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                  decoration:
                                      BoxDecoration(color: cultLightGrey),
                                  width:
                                      ScreenUtil.defaultSize.width * 80 / 100,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 25.r,
                                          backgroundColor: cultLightGrey,
                                          backgroundImage: const AssetImage(
                                              '${assetImagePath}avataar.png')),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Hello '.i18n + language == 'en'
                                                  ? (farmer?.name ?? '')
                                                  : farmer?.name?? '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                  cultBlack,
                                                  fontSize: 14.sp),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(14),
                                                    width: ScreenUtil()
                                                        .setHeight(14),
                                                    child: Center(
                                                        child: SizedBox(
                                                            height: ScreenUtil()
                                                                .setHeight(18),
                                                            width: ScreenUtil()
                                                                .setHeight(18),
                                                            child: const Image(
                                                                image: AssetImage(
                                                                    '${assetImagePath}location_pin.png'))))),
                                                Container(
                                                  height: 20.sp,
                                                  padding: EdgeInsets.only(
                                                      left: 10.w),
                                                  child: Center(
                                                      child: Text(
                                                    language == 'en'
                                                        ? farmer?.villageName ??
                                                            ''
                                                        : farmer?.villageAlias ??
                                                            '',
                                                    style: TextStyle(
                                                        color:
                                                        cultBlack,
                                                        fontSize: 12.sp),
                                                  )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  width:
                                      ScreenUtil.defaultSize.width * 80 / 100,
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => WebViewPage(
                                                    appBarText: 'Home'.i18n,
                                                    url: homeURL))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              height: 40,
                                              width: 40,
                                              child: const Image(
                                                image: AssetImage(
                                                    '${assetImagePath}home.png'),
                                              ),
                                            ),
                                            Text(
                                              'Home'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Notifications(
                                                      farmerid:
                                                          farmer!.farmerID,
                                                    ))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              height: 40,
                                              width: 40,
                                              child: const Image(
                                                image: AssetImage(
                                                    '${assetImagePath}notify.png'),
                                              ),
                                            ),
                                            Text(
                                              'Notifications'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          closeDrawer();
                                          if ((farmer?.farmlands!.length ?? 0) >
                                              1) {
                                            int i = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SelectFarmland(
                                                            farmlands: farmer!
                                                                .farmlands!,
                                                            setSelectedFarmland:
                                                                setSelectedFarmland)));

                                            setSelectedFarmland(i);
                                          } else {
                                            FlutterToastUtil.showSuccessToast(
                                                "You have only one farmland"
                                                    .i18n,context,1);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              height: 40,
                                              width: 40,
                                              child: const Image(
                                                image: AssetImage(
                                                    '${assetImagePath}my_farm.png'),
                                              ),
                                            ),
                                            Text(
                                              'My Farms'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => WebViewPage(
                                                    appBarText:
                                                        'Irrigation Advisory'
                                                            .i18n,
                                                    url:
                                                        irrigationAdvisoryURL))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              height: 40,
                                              width: 40,
                                              child: const Image(
                                                image: AssetImage(
                                                    '${assetImagePath}irrigation_advisory.png'),
                                              ),
                                            ),
                                            Text(
                                              'Irrigation Advisory'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final SharedPreferences _prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          bool success = await _prefs.setString(
                                              localeKey, '');
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => I18n(
                                                          child: ChooseLanguage(
                                                        fromDashboard: true,
                                                        farmerID:farmer!.farmerID,
                                                      ))));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              height: 40,
                                              width: 40,
                                              child: const Image(
                                                image: AssetImage(
                                                    '${assetImagePath}change_language.png'),
                                              ),
                                            ),
                                            Text(
                                              'Change Language'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => WebViewPage(
                                                    appBarText:
                                                        'How This Works'.i18n,
                                                    url: homeURL))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              height: 40,
                                              width: 40,
                                              child: const Image(
                                                image: AssetImage(
                                                    '${assetImagePath}info.png'),
                                              ),
                                            ),
                                            Text(
                                              'How this works'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => WebViewPage(
                                                    appBarText:
                                                        'Offers & Solutions'
                                                            .i18n,
                                                    url: offersSolutionsURL))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              height: 40,
                                              width: 40,
                                              child: const Image(
                                                image: AssetImage(
                                                    '${assetImagePath}offers.png'),
                                              ),
                                            ),
                                            Text(
                                              'Offers & Solutions'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _logout,


                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5),
                                              height: 40,
                                              width: 40,
                                              child:Icon(Icons.logout)
                                            ),
                                            Text(
                                              'Log Out'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 16.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    height: ScreenUtil().setHeight(125),
                                    decoration: const BoxDecoration(
                                        color: Colors.white),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        const Divider(
                                          color: Colors.grey,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                                width: 40,
                                                height: 40,
                                                margin:
                                                const EdgeInsets.symmetric(
                                                    vertical: 1,
                                                    horizontal: 20),
                                                child: const Image(
                                                    image: AssetImage(
                                                        '${assetImagePath}support.png'))),
                                            Column(
                                              children: [
                                                Text(
                                                  'Contact Support'.i18n,
                                                  style: TextStyle(
                                                      color:
                                                      cultBlack,
                                                      fontSize: 12.sp),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '+91 987 XXX XXXX',
                                                  style: TextStyle(  color:
                                                  cultBlack,
                                                      fontSize: 12.sp),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              'Terms & Conditions'.i18n,
                                              style: TextStyle(  color:
                                              cultBlack,fontSize: 12.sp),
                                            ),
                                            Text("Version \n $versionglobaly", style: TextStyle(  color:
                                                cultBlack,fontSize: 12.sp),)
                                          ],
                                        ),
                                      ],
                                    ))
                              ],
                            )
                      ]),
                    ),
                  ),
                ),
                drawerCallback: (isOpen) {
                  setState(() {
                    drawerIsOpen = isOpen;
                  });
                },
              ),
            ),
          ],
        ),
        // NoInternetConnection()
      ),
    );
  }

  List<Widget> buildPlotContainers() {
    print("inside plots ");
    Device? device;
    Device? soilMoistureDevice;
    Device? waterMeterDevice;
    Device? fcmDevice;
print("plots data ${farmer}");
    plots = [];
    var plotslength=  farmer?.farmlands![selectedFarmland].blocks![selectedBlock].plots!.length??0;
    for (int i = 0;i < plotslength;i++) {
      soilMoistureDevice = null;
      waterMeterDevice = null;
      fcmDevice = null;
      print("manojtestign");
      Plot plotData =farmer!.farmlands![selectedFarmland].blocks![selectedBlock].plots![i];
      for (int j = 0; j < plotData.devices!.length; j++) {
        device = farmer?.farmlands![selectedFarmland].blocks![selectedBlock]
            .plots![i].devices![j];
        print("devices ${device!.deviceEUIID}");
        print("device type ${device!.type}");
        if (device!.type == 'LSM' || device!.type == 'LSA'|| device!.type == 'LST'|| device!.type=="BAL"|| device!.type=="FMP"|| device!.type=="FCM") {

          soilMoistureDevice = device;
        }
        if (device!.type == 'FCM' || device!.type == 'FVW'|| device!.type=='FCV') {

          waterMeterDevice = device;
        }
        if (device!.type == 'FCM' ) {
          fcmDevice = device;
        }
        if(device!.type=='BR1'||device!.type=='BR2'){
          waterMeterDevice = device;
          fcmDevice=device;

        }
      }
      if (soilMoistureDevice == null && fcmDevice != null) {
        // soilMoistureDevice = fcmDevice;

      }
      print("water metter device ${waterMeterDevice?.type}");
     // var batteryvalue= getValue(telematicData[soilMoistureDevice?.deviceEUIID]!.batteryMV);
     //
     // var valvebattery=getValue(telematicData[waterMeterDevice?.deviceEUIID]?.batteryMV);
      // print();
      Widget plot = Container(
          margin: EdgeInsets.symmetric(
            horizontal: 10.h,
            vertical: 10.w,
          ),
          padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 15.w),
          decoration: BoxDecoration(
              color: cultLightGrey, borderRadius: BorderRadius.circular(10.r)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    language == 'en'
                        ? farmer?.farmlands![selectedFarmland]
                        .blocks![selectedBlock].plots![i].name ??
                        ''
                        : farmer?.farmlands![selectedFarmland]
                        .blocks![selectedBlock].plots![i].alias ??
                        '',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cultGrey,

                        fontSize: 14.sp),
                  ),
                  Text(
                      language == 'en'
                          ? '${plotData.cropName}'
                          : '${plotData.cropAlias}',
                      style: TextStyle(
                          color: cultGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp))
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Stack(children: [
                        Material(
                          borderRadius: BorderRadius.circular(10.r),
                          elevation: 15,
                          child: InkWell(
                            onTap: () {
                              // print("fcmDevice  manoj $fcmDevice");
                              Device? fcm;
                              Plot plotData1 =
                              farmer!.farmlands![selectedFarmland].blocks![selectedBlock].plots![i];
                              for (int j = 0; j < plotData1.devices!.length; j++) {
                                device = farmer?.farmlands![selectedFarmland]
                                    .blocks![selectedBlock]
                                    .plots![i].devices![j];
                               print(device!.type);
                                if (device!.type == 'FCM' ||device!.type=='BR1'||device!.type=='BR2') {
                                  print(device!.deviceEUIID);
                                  fcm = device;
                                }
                                else if(device!.type == 'FCM' ||device!.type=='FCV'||device!.type=='FCM'){
                                  waterMeterDevice=device;
                                  fcm=device;
                                }

                              }
                              if (isScheduleRunning) {
                                FlutterToastUtil
                                    .showErrorToast(
                                    "Irrigation Schedule Ongoing, Cannot Operate Device"
                                        .i18n);
                                return;
                              }

                              else if (waterMeterDevice != null) {
                                print('water metter ${
                                waterMeterDevice?.deviceEUIID}');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DeviceDetails(
                                            farmlandID: selectedFarmlandID,
                                            iopDevice:
                                            iopDeviceDetails?.deviceEUIID,
                                            valveDevices: valveDeviceList,
                                            deviceDetails: fcm,
                                            isOn: (fcm?.type=="BR2"? telematicData[fcm
                                                ?.deviceEUIID]
                                                ?.ro2status : telematicData[fcm
                                                ?.deviceEUIID]
                                                ?.operatingMode)==
                                                1,


                                            isOnline: telematicData[
                                            waterMeterDevice
                                                ?.deviceEUIID]
                                                ?.online ??
                                                false,
                                            telematicModel: telematicData[waterMeterDevice?.deviceEUIID],
                                            updateDate: telematicData[
                                            waterMeterDevice
                                                ?.deviceEUIID]
                                                ?.sensorDataPacketDateTime)));
                              }
                              else {
                                print( 'id ${waterMeterDevice?.deviceEUIID}');
                                FlutterToastUtil.showErrorToast(
                                    'No Valve device found. Please contact support.'
                                        .i18n);
                              }
                            },
                            child: telematicData[
                            waterMeterDevice?.deviceEUIID] !=
                                null? Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  // border: Border.all(color: cultGrey),

                                boxShadow: [
                              BoxShadow(
                              color: Colors.white!, // Shadow color
                                offset: Offset(0, 3), // Shadow position (x, y)
                                blurRadius: 5.0, // Shadow spread
                              ),
                              ],

                              ),

                              width: ScreenUtil().setWidth(
                                  ScreenUtil.defaultSize.width * 0.25),
                              height: ScreenUtil().setHeight(135.h),
                              child: Column(
                                children: [
                                  SizedBox(height: ScreenUtil().setHeight(20)),
                                  Text('Valve'.i18n,
                                      style: TextStyle(
                                          color: cultGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp)),
                                  SizedBox(
                                      height: ScreenUtil().setHeight(15.h)),
                                  telematicData[
                                  waterMeterDevice?.deviceEUIID] !=
                                      null
                                      ?
                                  // Text(waterMeterDevice!.deviceEUIID.toString()),
                                  ( waterMeterDevice?.type=='BR2'?
                              (telematicData[waterMeterDevice?.deviceEUIID]?.ro2status ?? 0):
                              (telematicData[waterMeterDevice?.deviceEUIID]?.operatingMode ?? 0))
                              == 1
                                      ?

                                  const Image(
                                    image: AssetImage(
                                        '${assetImagePath}valve_open.png'),
                                  )
                                      : const Image(
                                    image: AssetImage(
                                        '${assetImagePath}valve_closed_black.png'),
                                  )



                                      : Text("Not found".i18n),
                                  SizedBox(
                                      height: ScreenUtil().setHeight(10.h)),
                                  (waterMeterDevice != null &&
                                      telematicData[waterMeterDevice
                                          ?.deviceEUIID] !=
                                          null)
                                      ? Text(
                                      ( waterMeterDevice?.type=='BR2'?
                                      (telematicData[waterMeterDevice?.deviceEUIID]?.ro2status ?? 0):
                                      (telematicData[waterMeterDevice?.deviceEUIID]?.operatingMode ?? 0))==
                                          1
                                          ? 'Open'.i18n
                                          : 'Close'.i18n,
                                      style: TextStyle(
                                        color: cultGrey,
                                        fontSize: 12.sp,
                                      ))
                                      : const SizedBox(),
                                  SizedBox(height: ScreenUtil().setHeight(5.h)),
                                  telematicData[
                                  waterMeterDevice?.deviceEUIID] !=
                                      null
                                      ? Text(
                                      getDuration(telematicData[
                                      waterMeterDevice
                                          ?.deviceEUIID]!
                                          .sensorDataPacketDateTime),
                                      style: TextStyle(
                                          color: cultGrey, fontSize: 12.sp))
                                      : const SizedBox(),
                                ],
                              ),
                            ):SizedBox(width: 30,),
                          ),
                        ),
                        telematicData[
                        waterMeterDevice?.deviceEUIID] !=
                            null?   Positioned(
                            left: 5,
                            top: 12,
                            child: BatteryIndicator(
                              barColor: getValue(telematicData[waterMeterDevice?.deviceEUIID]?.batteryMV)==0.99?Colors.green:getValue(telematicData[waterMeterDevice?.deviceEUIID]?.batteryMV)==0.50?Colors.yellow.shade900:Colors.red,
                              value: getValue(telematicData[waterMeterDevice?.deviceEUIID]?.batteryMV))):SizedBox(),

                        telematicData[
                        waterMeterDevice?.deviceEUIID] !=
                            null?   Positioned(
                            right: 5,
                          top: 8,
                            child: Column(
                              children: [
                                SignalStrengthIndicator.bars(
                                  value: getrssi_signal_Value(telematicData[
                                  waterMeterDevice!.deviceEUIID]!.GateWayRSSI!),
                                  size: 15,
                                  barCount: 4,
                                  activeColor: Colors.blue,
                                  inactiveColor: Colors.blue[100],
                                ),
                                SizedBox(height:10),
                                Container(

                                    height: 15,
                                    width: 15,

                                    child: Snr_signal_Stringth(count:get_GateWaySNR_signal(telematicData[
                                    waterMeterDevice!.deviceEUIID]!.GateWaySNR!))),
                             ],
                            ),):SizedBox(),


                      ]),
                    
                      Container(
                        padding:
                        EdgeInsets.only(right: 10.w, left: 10.w, top: 10),
                        width: ScreenUtil()
                            .setWidth(ScreenUtil.defaultSize.width * 0.45),
                        height: ScreenUtil().setHeight(135.h),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r)),
                        margin: const EdgeInsets.only(left: 16),
                        child:
                        soilMoistureDevice!=
                            null
                            ? Stack(
                          children: [
                              Positioned(
                                right: 8,
                                top: 0,
                                child:Column(
                                    children: [
                                      SignalStrengthIndicator.bars(
                                        value: getrssi_signal_Value(telematicData[
                                        soilMoistureDevice!.deviceEUIID]!.GateWayRSSI!),

                                        size: 15,
                                        barCount: 4,
                                        activeColor: Colors.blue,
                                        inactiveColor: Colors.blue[100],
                                      ),
                                      SizedBox(height:10),
                                     
                                      Container(

                                        height: 15,
                                        width: 15,

                                        child: Snr_signal_Stringth(count:get_GateWaySNR_signal(telematicData[
                                        soilMoistureDevice!.deviceEUIID]!.GateWaySNR!))),
                                      
                                     ],
                                )
                              ),



                           Positioned(
                               left: 5,
                               top: 2,
                               child:
                                   BatteryIndicator(

                                       barColor: getValue(telematicData[soilMoistureDevice?.deviceEUIID]!.batteryMV)==0.99?Colors.green:getValue(telematicData[soilMoistureDevice?.deviceEUIID]!.batteryMV)==0.50?Colors.yellow.shade900:Colors.red,

                                     value: getValue(telematicData[soilMoistureDevice?.deviceEUIID]!.batteryMV),


                                   ),



                               ),

                           Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [

                                  soilMoistureDevice.type == 'BAL'
                                      ?  Column(
                                    // shrinkWrap: true,
                                    children: buildColorBoxes(soilMoistureDevice.deviceEUIID),

                                    //

                                      )
                                 : Padding(
                                    padding: EdgeInsets.only(
                                      top: 15.h,
                                    ),
                                    child:soilMoistureDevice.type == 'BAL'
                                        ?  Column(
                                      // shrinkWrap: true,
                                      children: buildtext()

                                    ):

                                    Column(children: [
                                      Row(

                                        children: [
                                          telematicData[soilMoistureDevice
                                              ?.deviceEUIID]
                                              ?.Activescheduler==true &&telematicData[soilMoistureDevice
                                              ?.deviceEUIID]
                                              ?.l1triger==1    ?telematicData[soilMoistureDevice?.deviceEUIID]!.activeschduleDevive==true? Container(
                                            width:20,
                                            child: Image(
                                                image: AssetImage(
                                                    '${assetImagePath}scheduler.png')),
                                          ):Container(
                                            width:20,
                                            child: Image(
                                                image: AssetImage(
                                                    '${assetImagePath}schedulerblack.jpeg')),
                                          ):SizedBox( width:20,),
                                          Container(
                                              width: ScreenUtil()
                                                  .setWidth(10.w),
                                              height:
                                              ScreenUtil()
                                                  .setHeight(23.h),
                                              decoration: BoxDecoration(
                                                  color: ((telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.online ??
                                                      false) &&
                                                      telematicData[soilMoistureDevice
                                                          ?.deviceEUIID]
                                                          ?.l1 !=
                                                          0)
                                                      ? (telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.l1Color ==
                                                      'G'
                                                      ? cultGreen
                                                      : telematicData[soilMoistureDevice?.deviceEUIID]
                                                      ?.l1Color ==
                                                      'R'
                                                      ? cultRed
                                                      : cultYellow)
                                                      : Colors.white,
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: cultBlack,
                                                  ))),
                                        ],
                                      ),
                                      SizedBox(height: 2.h),
                                      Row(
                                        children: [
                                          telematicData[soilMoistureDevice
                                              ?.deviceEUIID]
                                              ?.Activescheduler==true &&telematicData[soilMoistureDevice
                                              ?.deviceEUIID]
                                              ?.l2triger==1    ?telematicData[soilMoistureDevice?.deviceEUIID]!.activeschduleDevive==true? Container(
                                            width:20,
                                            child: Image(
                                                image: AssetImage(
                                                    '${assetImagePath}scheduler.png')),
                                          ):Container(
                                            width:20,
                                            child: Image(
                                                image: AssetImage(
                                                    '${assetImagePath}schedulerblack.jpeg')),
                                          ):SizedBox(   width:20,),
                                          Container(
                                              width: ScreenUtil()
                                                  .setWidth(10.w),
                                              height:
                                              ScreenUtil()
                                                  .setHeight(23.h),
                                              decoration: BoxDecoration(
                                                  color: ((telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.online ??
                                                      false) &&
                                                      telematicData[soilMoistureDevice
                                                          ?.deviceEUIID]
                                                          ?.l2 !=
                                                          0)
                                                      ? (telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.l2Color ==
                                                      'G'
                                                      ? cultGreen
                                                      : telematicData[soilMoistureDevice?.deviceEUIID]
                                                      ?.l2Color ==
                                                      'R'
                                                      ? cultRed
                                                      : cultYellow)
                                                      : Colors.white,
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: cultBlack,
                                                  )))
                                        ],
                                      ),
                                      SizedBox(height: 2.h),
                                      Row(
                                        children: [
                                          telematicData[soilMoistureDevice
                                              ?.deviceEUIID]?.Activescheduler==true &&telematicData[soilMoistureDevice?.deviceEUIID]?.l3triger==1
    ?telematicData[soilMoistureDevice?.deviceEUIID]!.activeschduleDevive==true? Container(
    width:20,
    child: Image(
    image: AssetImage(
    '${assetImagePath}scheduler.png')),
    ):Container(
                                            width:20,
                                            child: Image(
                                                image: AssetImage(
                                                    '${assetImagePath}schedulerblack.jpeg')),
                                          ):SizedBox(   width:20,),
                                          Container(
                                              width: ScreenUtil()
                                                  .setWidth(10.w),
                                              height:
                                              ScreenUtil()
                                                  .setHeight(23.h),
                                              decoration: BoxDecoration(
                                                  color: ((telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.online ??
                                                      false) &&
                                                      telematicData[soilMoistureDevice
                                                          ?.deviceEUIID]
                                                          ?.l3 !=
                                                          0)
                                                      ? (telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.l3Color ==
                                                      'G'
                                                      ? cultGreen
                                                      : telematicData[soilMoistureDevice?.deviceEUIID]
                                                      ?.l3Color ==
                                                      'R'
                                                      ? cultRed
                                                      : cultYellow)
                                                      : Colors.white,
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: cultBlack,
                                                  ))),
                                        ],
                                      ),
                                      SizedBox(height: 2.h),
                                      Row(
                                        children: [
                                          telematicData[soilMoistureDevice
                                              ?.deviceEUIID]
                                              ?.Activescheduler==true &&telematicData[soilMoistureDevice
                                              ?.deviceEUIID]
                                              ?.l4triger==1
                                               ?  telematicData[soilMoistureDevice?.deviceEUIID]!.activeschduleDevive==true? Container(
                                      width:20,
                                        child: Image(
                                            image: AssetImage(
                                                '${assetImagePath}scheduler.png')),
                                      ):Container(
                        width:20,
                        child: Image(
                            image: AssetImage(
                                '${assetImagePath}schedulerblack.jpeg')),
                      ):SizedBox(   width:20,),

                                          Container(
                                              width: ScreenUtil()
                                                  .setWidth(10.w),
                                              height:
                                              ScreenUtil()
                                                  .setHeight(23.h),
                                              decoration: BoxDecoration(
                                                  color: ((telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.online ??
                                                      false) &&
                                                      telematicData[soilMoistureDevice
                                                          ?.deviceEUIID]
                                                          ?.l4 !=
                                                          0)
                                                      ? (telematicData[soilMoistureDevice
                                                      ?.deviceEUIID]
                                                      ?.l4Color ==
                                                      'G'
                                                      ? cultGreen
                                                      : telematicData[soilMoistureDevice?.deviceEUIID]
                                                      ?.l4Color ==
                                                      'R'
                                                      ? cultRed
                                                      : cultYellow)
                                                      : Colors.white,
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: cultBlack,
                                                  )))
                                        ],
                                      ),
                                    ]),
                                  ),

                                  soilMoistureDevice!.type=="BAL"?

                                Container(
                                  width:25.w,
                                    child:  Column(
                                        children: [
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child : Text("2",
                                                style: TextStyle(
                                                    color:
                                                    cultBlack,
                                                    fontSize:
                                                    footerFont.sp),
                                              ),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("1",  style: TextStyle(
                                                      color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("0",  style: TextStyle(
                                                      color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("-1",  style: TextStyle(
                                                      color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("-2" , style: TextStyle(
                                                      color:
                                                  cultBlack,
    fontSize:
    footerFont.sp),),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("-3",  style: TextStyle(
                                                  color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),

                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("-4",  style: TextStyle(
                                                  color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("-5",  style: TextStyle(
                                                  color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("-6",  style: TextStyle(
                                                      color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),
                                          Container(
                                              // width: ScreenUtil().setWidth(5.w),
                                              height: ScreenUtil().setHeight(12.45.h),
                                              child:Center(child :     Text("-7",  style: TextStyle(
                                                      color:
                                                  cultBlack,
                                                  fontSize:
                                                  footerFont.sp),),)
                                          ),




                                        ]
                                    )
                                ):
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.h),
                                    child:Column(children:

                                    [
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          // const SizedBox(width: 5),
                                          Text(
                                            (telematicData[soilMoistureDevice
                                                ?.deviceEUIID]
                                                ?.l1
                                                ?.round() ??
                                                0)
                                                .toString() +
                                                ' %',
                                            style: TextStyle(
                                                    color:
                                                cultBlack,
                                                fontSize:
                                                footerFont.sp),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 5),
                                          Text(
                                            (telematicData[soilMoistureDevice
                                                ?.deviceEUIID]
                                                ?.l2
                                                ?.round() ??
                                                0)
                                                .toString() +
                                                ' %',
                                            style: TextStyle(
                                                    color:
                                                cultBlack,
                                                fontSize:
                                                footerFont.sp),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      Row(
                                        children: [
                                          const SizedBox(width: 5),
                                          Text(
                                            (telematicData[soilMoistureDevice
                                                ?.deviceEUIID]
                                                ?.l3
                                                ?.round() ??
                                                0)
                                                .toString() +
                                                ' %',
                                            style: TextStyle(
                                                color:
                                                cultBlack,
                                                fontSize:
                                                footerFont.sp),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      Row(
                                        children: [
                                          const SizedBox(width: 5),
                                          Text(
                                            (telematicData[soilMoistureDevice
                                                ?.deviceEUIID]
                                                ?.l4
                                                ?.round() ??
                                                0)
                                                .toString() +
                                                ' %',
                                            style: TextStyle(
                                                    color:
                                                cultBlack,
                                                fontSize:
                                                footerFont.sp),
                                          )
                                        ],
                                      ),
                                    ]),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(
                                          left: 5),
                                      width: 60.w,
                                      child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          children: [
                                            Flexible(
                                              child:

                                                  Text(
                                                'Soil Moisture'.i18n,
                                                maxLines: 2,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                                textAlign:
                                                TextAlign.center,
                                                softWrap: false,

                                                style: TextStyle(
                                                    color:
                                                    cultBlack,
                                                    fontSize: 13.sp,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            soilMoistureDevice!.type=="BAL"?Text(telematicData[soilMoistureDevice?.deviceEUIID]!.l1 !=-8?telematicData[soilMoistureDevice?.deviceEUIID]!.l1.toString():"-",style: TextStyle(
                                                fontSize: 16.sp,
                                                color:
                                                cultBlack,
                                                fontWeight:
                                                FontWeight
                                                    .bold)):
                                            telematicData[soilMoistureDevice ?.deviceEUIID]
                                                ?.Activescheduler==true ?  telematicData[soilMoistureDevice?.deviceEUIID]!.activeschduleDevive==true? Container(
    width:20,
    child: Image(
    image: AssetImage(
    '${assetImagePath}scheduler.png')),
    ):Container(
    width:20,
    child: Image(
    image: AssetImage(
    '${assetImagePath}schedulerblack.jpeg')),
    ):SizedBox(   width:20,),

                                            soilMoistureDevice!.type!="BAL"?       Text(
                                               telematicData[soilMoistureDevice?.deviceEUIID]!.scheduletypesensor!=true?

                                                (((telematicData[soilMoistureDevice?.deviceEUIID]!.l1 ?? 0) +
                                                    (telematicData[soilMoistureDevice?.deviceEUIID]!.l2 ??
                                                        0) +
                                                    (telematicData[soilMoistureDevice?.deviceEUIID]!.l3 ??
                                                        0) +
                                                    (telematicData[soilMoistureDevice?.deviceEUIID]!.l4 ??
                                                        0)) /
                                                    (4))
                                                    .round()
                                                    .toString() +
                                                    '%':
                                               (((telematicData[soilMoistureDevice?.deviceEUIID]!.l1triger==1

                                                   ?telematicData[soilMoistureDevice?.deviceEUIID]!.l1 ?? 0:0) +
                                                   (telematicData[soilMoistureDevice?.deviceEUIID]!.l2triger==1?telematicData[soilMoistureDevice?.deviceEUIID]!.l2 ??0:0) +
                                                   (telematicData[soilMoistureDevice?.deviceEUIID]!.l3triger==1?telematicData[soilMoistureDevice?.deviceEUIID]!.l3 ??0:0) +
                                                   (telematicData[soilMoistureDevice?.deviceEUIID]!.l4triger==1?telematicData[soilMoistureDevice?.deviceEUIID]!.l4 ?? 0:0)) /

                                                   ((telematicData[soilMoistureDevice?.deviceEUIID]!.l4triger ?? 0)+(telematicData[soilMoistureDevice?.deviceEUIID]!.l3triger ?? 0)+(telematicData[soilMoistureDevice?.deviceEUIID]!.l2triger ?? 0)+
                                            (telematicData[soilMoistureDevice?.deviceEUIID]!.l1triger ?? 0))

 )
                                                   .round()
                                                   .toString() +
                                                   '%',
                                                   // telematicData[soilMoistureDevice?.deviceEUIID]!.l1triger.toString(),
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color:
                                                    cultBlack,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold)):SizedBox(),
                                            SizedBox(
                                                height: ScreenUtil()
                                                    .setHeight(5)),
                                            telematicData[soilMoistureDevice?.deviceEUIID]!= null
                                                ? Text(
                                                getDuration(telematicData[
                                                soilMoistureDevice
                                                    ?.deviceEUIID]!
                                                    .sensorDataPacketDateTime),
                                                style: TextStyle(
                                                    color:
                                                    cultGrey,
                                                    fontSize:
                                                    12.sp))
                                                : const Text("")
                                          ])),

                                ]),
                          ],
                        )
                            :
                        Text("Device not found".i18n,style :TextStyle( color:
                        cultBlack,)),
                      ),
                    ],
                  )),
            SizedBox(height: 5,),
            // Row(
            //   children: [
            //     Text("Temperature ",style: TextStyle(fontWeight: FontWeight.bold),),
            //     Text("${telematicData[
            //     soilMoistureDevice
            //         ?.deviceEUIID]?.tempurature} °C",style: TextStyle(fontWeight: FontWeight.bold,color: cultGreen, fontSize: 13.sp),),
            //     SizedBox(width: 10,),
            //     Text("Humidity ",style: TextStyle(fontWeight: FontWeight.bold),),
            //     Text("${telematicData[
            //     soilMoistureDevice
            //         ?.deviceEUIID]?.humidity=='null'?0:telematicData[
            //     soilMoistureDevice
            //         ?.deviceEUIID]?.humidity} %",style: TextStyle(color: cultGreen, fontWeight: FontWeight.bold,fontSize: 13.sp)),
            //   ],
            // )
            ],
          ));
      plots.add(plot);
    }
    return plots;
  }


  Future<void> arrowClick(Arrow arrow) async {
    if (arrow == Arrow.left && !leftEnabled) return;
    if (arrow == Arrow.right && !rightEnabled) return;

    if (arrow == Arrow.left && selectedBlock != 0) selectedBlock -= 1;
    if (arrow == Arrow.right && selectedBlock != blocksCount - 1) {
      selectedBlock += 1;
    }

    if (selectedBlock == 0) {
      leftEnabled = false;
    } else {
      leftEnabled = true;
    }

    if (selectedBlock == blocksCount - 1) {
      rightEnabled = false;
    } else {
      rightEnabled = true;
    }

    if (selectedBlock != 0 && selectedBlock != blocksCount - 1) {
      leftEnabled = true;
      rightEnabled = true;
    }

    plots = buildPlotContainers();
    setState(() {});
  }

  double getSelectedBlockFlow() {
    double flow = 0.0;
    Block block = farmer!.farmlands![selectedFarmland].blocks![selectedBlock];

    return flow;
  }

  Future<void> getWeatherData() async {
    if (currentWeatherModel != null) {
      return;
    }
    double lat = farmer?.farmlands![selectedFarmland].lat ?? 0;
    double long = farmer?.farmlands![selectedFarmland].long ?? 0;
    print('farmland latlong ${farmer?.farmlands![selectedFarmland].id}');
      print("lat long ${lat} ${long}");
    var getData = await ApiHelper().get(
        '$weatherAPIURL/onecall?lat=$lat&lon=$long&appid=c0303fa192dfd0d6ff74f8a5564c16f3&units=metric&lang=hi');
    if (getData.isNotEmpty) {
      currentWeatherModel = CurrentWeatherModel.fromJson(getData);
    }

    if (mounted) {
      setState(() {
        gotWeatherData = true;
      });
    }
  }

  void showWeeklyForecast() {
    if (currentWeatherModel == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            width: ScreenUtil.defaultSize.width * 75 / 100,
            height: ScreenUtil.defaultSize.height * 100 / 100,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('7 Days Weather Forecast'.i18n,
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      InkWell(
                          onTap: () => Navigator.pop(context),
                          child: FaIcon(FontAwesomeIcons.xmark, size: 16.sp))
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: ScreenUtil.defaultSize.height * 75 / 100,
                  child: ListView.separated(
                    itemBuilder: (context, i) {
                      return Container(
                          decoration: const BoxDecoration(color: Colors.white),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('d, EEE').format(
                                        currentWeatherModel!
                                            .dailyWeather[i].weatherDate
                                            .toLocal()),
                                    style: TextStyle( color:
                                    cultBlack,fontSize: 12.sp),
                                  ),
                                  SizedBox(
                                      height: ScreenUtil().setHeight(50),
                                      width: ScreenUtil().setHeight(50),
                                      child: Image(
                                          image: NetworkImage(
                                              '$weatherIconURL/${currentWeatherModel!.dailyWeather[i].icon}@2x.png'))),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Avg: ${currentWeatherModel!.dailyWeather[i].min.round()}',
                                    style: TextStyle( color:
                                    cultBlack,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    children: [
                                      Text(
                                          'Max: ${currentWeatherModel!.dailyWeather[i].max.round()}',
                                          style: TextStyle( color:
                                          cultBlack,fontSize: 10.sp)),
                                      const SizedBox(height: 5),
                                      Text(
                                          'Min: ${currentWeatherModel!.dailyWeather[i].min.round()}',
                                          style: TextStyle( color:
                                          cultBlack,fontSize: 10.sp)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ));
                    },
                    separatorBuilder: (context, _) {
                      return const Divider(
                          indent: 5, endIndent: 5, color: cultGreenOpacity);
                    },
                    itemCount: (currentWeatherModel != null)
                        ? currentWeatherModel!.dailyWeather.length
                        : 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void buildDeviceList(int selectedFarmland) {
    farmlandDeviceList = "";
    selectedFarmlandID =
        farmer?.farmlands![selectedFarmland].id ?? 0; // Default to first famland
    getFarmlandDevices(selectedFarmland); // Default to first famland
  }

  void getFarmlandDevices(int index) {
    waterMeterDeviceList = [];
    moistureDevices = {};
    valveDeviceList = [];
    blockDevices = {};
    farmlandDeviceList = '';
    iopDeviceDetails = null;
    iopFound = false;
    engFound = false;
    farmlandFCM = false;
    engDeviceDetails = null;
    farmlandWaterMeter = '';
    var lengthvalue=farmer?.farmlands![index].devices?.length??0;
    for (int i = 0; i < lengthvalue; i++) {
      if (farmlandDeviceList == "") {
        farmlandDeviceList =
            farmer!.farmlands![index].devices![i].deviceEUIID.trim();
      } else {
        farmlandDeviceList +=
            ',' + farmer!.farmlands![index].devices![i].deviceEUIID.trim();
      }
      if (farmer?.farmlands![index].devices![i].type == 'IOP') {
        iopDeviceDetails = farmer?.farmlands![index].devices![i];
        iopFound = true;
      }
      if (farmer?.farmlands![index].devices![i].type == 'ENG') {
        iopDeviceDetails = farmer?.farmlands![index].devices![i];
        engDeviceDetails = farmer?.farmlands![index].devices![i];
        engFound = true;
      }
      if(farmer?.farmlands![index].devices![i].type == 'MEM'){
        print("IOP found ${farmer?.farmlands![index].devices![i].type}");
        iopDeviceDetails = farmer?.farmlands![index].devices![i];
        engDeviceDetails = farmer?.farmlands![index].devices![i];
        engFound = true;
      }
      if (farmer?.farmlands![index].devices![i].type == 'FCM' ||
          farmer?.farmlands![index].devices![i].type == 'FCW') {
        farmlandWaterMeter = farmer!.farmlands![index].devices![i].deviceEUIID;
        farmlandFCM = true;
      }
    }
    if (farmer?.farmlands![index].blocks?.isNotEmpty??false) {
      for (int i = 0; i < farmer!.farmlands![index].blocks!.length; i++) {
        List<String> devices = [];
        if (farmer!.farmlands![index].blocks![i].devices!.isNotEmpty) {
          for (int j = 0;
              j < farmer!.farmlands![index].blocks![i].devices!.length;
              j++) {
            if (farmlandDeviceList == "") {
              farmlandDeviceList = farmer!.farmlands![index].blocks![i].devices![j].deviceEUIID.trim();
            } else {
              farmlandDeviceList += ',' +farmer!.farmlands![index].blocks![i].devices![j].deviceEUIID.trim();
            }
            Device device = farmer!.farmlands![index].blocks![i].devices![j];

            if (device.type == 'LSM' || device.type == 'LSA'||device.type == 'FCM'||device.type == 'LST') {
              moistureDevices[device.deviceEUIID] = device.type;
            }
            if (device.type == 'FCM' || device.type == 'FCW' ||device.type == 'FCV' ) {
              waterMeterDeviceList.add(device.deviceEUIID);
              valveDeviceList.add(device.deviceEUIID);
            }
            devices.add(device.deviceEUIID);
          }
        }

        if (farmer!.farmlands![index].blocks![i].plots!.isNotEmpty) {
          for (int j = 0;
              j < farmer!.farmlands![index].blocks![i].plots!.length;
              j++) {
            if (farmer!
                .farmlands![index].blocks![i].plots![j].devices!.isNotEmpty) {
              for (int k = 0;
                  k <
                      farmer!.farmlands![index].blocks![i].plots![j].devices!
                          .length;
                  k++) {
                if (farmlandDeviceList == "") {
                  farmlandDeviceList = farmer!.farmlands![index].blocks![i]
                      .plots![j].devices![k].deviceEUIID
                      .trim();
                } else {
                  farmlandDeviceList += "," +
                      farmer!.farmlands![index].blocks![i].plots![j].devices![k]
                          .deviceEUIID
                          .trim();
                }

                Device device =
                    farmer!.farmlands![index].blocks![i].plots![j].devices![k];
                if (device.type == 'LSM' || device.type == 'LSA'||device.type == 'FCM' ||device.type == 'WST') {
                  moistureDevices[device.deviceEUIID] = device.type;
                }
                if (device.type == 'FCM' || device.type == 'FCW'|| device.type == 'FCV') {
                  waterMeterDeviceList.add(device.deviceEUIID);
                  valveDeviceList.add(device.deviceEUIID);
                }
                devices.add(device.deviceEUIID);
              }
            }
          }
        }
        blockDevices![farmer!.farmlands![index].blocks![i].id.toString()] =
            devices;
      }
    }
  }

  Future<void> getFarmerData() async {
    telematicDone = false;
    scheduleTypeDone = false;
    waterflowDone = false;
    setState(() {});
    DashboardService dashboardService = DashboardService();

    farmer = await dashboardService.getFarmer(farmerID);

    if (farmer == null || farmer!.farmlands!.isEmpty) {

      waterflowDone = true;
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>Login()));

    }
    getWeatherData();
    location = language == 'en'
        ? farmer?.farmlands![selectedFarmland].name ?? ''
        : farmer?.farmlands![selectedFarmland].alias ?? '';
    blocksCount = farmer?.farmlands![selectedFarmland].blocks?.length??0;
    await getTelematics();
  }
List<Widget> buildtext(){
  List<Text> boxes = [];
  for (double value = 2; value >= -7; value++) {
    Text box = Text('$value');

    boxes.add(box);
  }
  return boxes;
}

  buildColorBoxes(String soilMoistureDevice) {
    List<Container> boxes = [];

    double l3Value = telematicData[soilMoistureDevice]?.l1 ?? 0;


    for (double value = 2; value >= -7; value= value-0.5) {
      Color boxColor = Colors.white; // Default color

      if (value > l3Value) {

        boxColor = Colors.white;
      } else {
        if (value % 1 == 0.5) {
          boxColor = Colors.lightBlue;
        } else {
          boxColor = Colors.blue.withOpacity(0.50);
        }

      }

      Container box = Container(
        width: ScreenUtil().setWidth(10.w),
        height: ScreenUtil().setHeight(6.45.h),
        // height: ScreenUtil().setHeight(5.h),
        decoration: BoxDecoration(
          color: boxColor,
          border: Border.all(
            width: 0.5,
            color: cultBlack,
          ),
        ),
      );

      boxes.add(box);
    }

    return boxes;
  }
  Log log=Log();


  Future<void> getTelematics() async {
    telematicDone = false;
    scheduleTypeDone = false;
    waterflowDone = false;
    if (mounted) setState(() {});
    buildDeviceList(selectedFarmland);
    blocksCount = farmer?.farmlands![selectedFarmland].blocks!.length??0;
    if (blocksCount <= 1) {
      rightEnabled = false;
      leftEnabled = false;
    } else {
      if (selectedBlock == 0) {
        leftEnabled = false;
      } else {
        leftEnabled = true;
      }

      if (selectedBlock == blocksCount - 1) {
        rightEnabled = false;
      } else {
        rightEnabled = true;
      }

      if (selectedBlock != 0 && selectedBlock != blocksCount - 1) {
        leftEnabled = true;
        rightEnabled = true;
      }
    }

    DashboardService dashboardService = DashboardService();

    // var data=dashboardService.getTelematics(farmlandDeviceList);
    print("telemetrics daily data${farmlandDeviceList}");
    isScheduleRunning = false;
   await  dashboardService.getTelematics(deviceList: farmlandDeviceList,farmlandid: selectedFarmlandID).then((tData) {
      tData.forEach((key, value)async {
        String apiResponse = '{"status": "success", "data": {"message": "Hello, World!"}}';

        await logger.saveResponseToFile(apiResponse);
        String? value1 = await SharedPreferencesService.getString(key!);
        if (value1 !=null) {
          print("key shared  ${key} operatingmode${value1}");
          // print()
           var valeofshared=int.parse(value1!);
             if( valeofshared != value.operatingMode){
            await SharedPreferencesService.remove(key);
            setState((){
                   action =false;
                 });
             }
             else{
               setState((){
                 action =true;
               });

             }

                 }
      });
      // print("telemetrics data ${tData.}");
      telematicData = tData;
      if (telematicData != {}) {
        gatewayOnline = false;
        telematicData.forEach((key, value) {
          if (value.activeschduleDevive == true) {
            isScheduleRunning = true;
          }
          bool tempValue = value.online ?? false;
          if (!gatewayOnline) gatewayOnline = tempValue;
        });

        pumpControllerOnline = false;
        String pumpDevice = '';
        if (engDeviceDetails != null) {
          pumpDevice = engDeviceDetails?.deviceEUIID ?? '';
          if(engDeviceDetails!.type=='MEM'){
            pumpControllerOnline=(telematicData[engDeviceDetails?.deviceEUIID]?.online) ?? false;;
          }
          else {
            pumpControllerOnline =(telematicData[engDeviceDetails?.deviceEUIID]?.online) ?? false;
          }
          pumpControllerOnOff =
              (telematicData[engDeviceDetails?.deviceEUIID]?.operatingMode ??
                      0) !=
                  0;
        } else if (iopDeviceDetails != null) {
          pumpDevice = iopDeviceDetails?.deviceEUIID ?? '';
          if(iopDeviceDetails!.type=='MEM'){
            pumpControllerOnline=(telematicData[engDeviceDetails?.deviceEUIID]?.online) ?? false;;
          }
          else {
            pumpControllerOnline =
                (telematicData[iopDeviceDetails?.deviceEUIID]?.online) ?? false;
          }
          pumpControllerOnOff =
              (telematicData[iopDeviceDetails?.deviceEUIID]?.operatingMode ??
                      0) !=
                  0;
        }
        pumpDurationText = '';
        if (telematicData[pumpDevice]?.operatingSinceDateTime != null) {
          operatingsenceTime=telematicData[pumpDevice]?.operatingSinceDateTime;
          Duration duration = DateTime.now().difference(
              (telematicData[pumpDevice]?.operatingSinceDateTime ??
                  DateTime.now()));
          pumpDurationText = 'Operating Since '.i18n +
              getDuration(telematicData[pumpDevice]?.operatingSinceDateTime);
          print('pumpDurationText' + pumpDurationText);
        }
        else if (telematicData[pumpDevice]?.lastOperatingDateTime != null) {
          lastirrigatedTime=telematicData[pumpDevice]?.lastOperatingDateTime!;
          Duration duration = DateTime.now().difference(
              (telematicData[pumpDevice]?.lastOperatingDateTime ??
                  DateTime.now()));
          pumpDurationText = 'Last Irrigated '.i18n +
              getDuration(telematicData[pumpDevice]?.lastOperatingDateTime) + "ago";
        }

        buildPlotContainers();
      }
      telematicDone = true;
      aggregateBlockData();
      handleDurationChange('W');
      setState(() {});
    }).onError((error, stackTrace) {
      print('ERROR: ' + error.toString());
      print(stackTrace);
      telematicDone = true;
      aggregateBlockData();
      handleDurationChange('W');
      setState(() {});
    });
 await   getFlowData(selectedFarmland).onError((error, stackTrace) {
      waterflowDone = true;
      aggregateBlockData();
      handleDurationChange('W');
      setState(() {});
    }).then((value) {
      waterflowDone = true;
      aggregateBlockData();
      setTimerRemaining();
      handleDurationChange('W');
      setState(() {});
    });


  await  DashboardService()
        .getScheduleType(selectedFarmlandID)
        .onError((error, stackTrace) {
      scheduleType = '';
      scheduleTypeDone = true;
      handleDurationChange('W');
      setState(() {});
      return '';
    }).then((value) {
      scheduleType = value;
      scheduleTypeDone = true;
      handleDurationChange('W');
      if (mounted) {
        setState(() {});
      }
    });
    resetStopWatch();
  }

  Future<void> getFlowData(int farmlandID) async {
    flowData = {};
      //
      flowData = await DashboardService().getWaterflow(farmlandWaterMeter,
          waterMeterDeviceList, farmer!.farmlands![selectedFarmland].id);
      farmFlow = flowData['totalFlow']?.round() ?? 0;
      valveFlow = flowData['flowValues'] ?? {};
      valveDuration = flowData['duration'] ?? {};
      // isScheduleRunning = flowData['scheduleRunning'] ?? false;
      if(flowData.isEmpty) {
        farmFlow = 0;
      valveFlow = {};
      valveDuration = {};
      // isScheduleRunning = false;
      }


  }

  void aggregateBlockData() {
    double aggregateFlow = 0;
    double aggregateDuration = 0;
    double fcmSoilMoisture = 0;
    double aggregateSoilMoisture = 0;
    bool soilMoistureDeviceExists = false;
    blockDurationValues = {};
    blockFlowValues = {};
    int fcmSoilMoistureCount = 0;
    blockAggregates = [];

    if (!telematicDone || !waterflowDone) return;
    for (int i = 0;i < farmer!.farmlands![selectedFarmland].blocks!.length;i++) {
      print('plots ${farmer!.farmlands![selectedFarmland].blocks![i]}');
      BlockAggregate blockAggregate = BlockAggregate(
          blockID: farmer!.farmlands![selectedFarmland].blocks![i].id);
      blockDurationValues[farmer!.farmlands![selectedFarmland].blocks![i].id] =
          0;
      blockFlowValues[farmer!.farmlands![selectedFarmland].blocks![i].id] = 0;
      blockAggregate.flow = 0;
      blockAggregate.duration = 0;
      blockAggregate.soilMoisture = 0;
      int soilMoistureCount = 0;
      aggregateSoilMoisture = 0;
      aggregateFlow = 0;
      aggregateDuration = 0;
      fcmSoilMoisture = 0;
      fcmSoilMoistureCount = 0;
      soilMoistureDeviceExists = false;

      for (int j = 0;
          j < farmer!.farmlands![selectedFarmland].blocks![i].plots!.length;
          j++) {
        for (int k = 0; k < farmer!.farmlands![selectedFarmland].blocks![i].plots![j].devices!.length;k++) {


          Device device = farmer!.farmlands![selectedFarmland].blocks![i].plots![j].devices![k];
          print("plotdevices ${device}");
          if (flowData["flowValues"] != null) {
            blockFlowValues[farmer!.farmlands![selectedFarmland].blocks![i].id] =
                (blockFlowValues[farmer!.farmlands![selectedFarmland].blocks![i].id] ?? 0) +
                    (flowData["flowValues"][device.deviceEUIID] ?? 0);
            blockDurationValues[farmer!.farmlands![selectedFarmland].blocks![i]
                .id] = (blockDurationValues[farmer?.farmlands![selectedFarmland].blocks![i].id] ?? 0) +
                (flowData["duration"][device.deviceEUIID] ?? 0);
          }
          if (device.type == 'LSM' || device.type == 'LSA' ||device.type == 'WST') {
            aggregateSoilMoisture +=
                ((telematicData[device.deviceEUIID]?.l1 ?? 0) +
                        (telematicData[device.deviceEUIID]?.l2 ?? 0) +
                        (telematicData[device.deviceEUIID]?.l3 ?? 0) +
                        (telematicData[device.deviceEUIID]?.l4 ?? 0)) /
                    4;
            soilMoistureCount++;
            soilMoistureDeviceExists = true;
          }
          if (device.type == 'FCM') {
            fcmSoilMoisture += ((telematicData[device.deviceEUIID]?.l1 ?? 0) +
                    (telematicData[device.deviceEUIID]?.l2 ?? 0) +
                    (telematicData[device.deviceEUIID]?.l3 ?? 0) +
                    (telematicData[device.deviceEUIID]?.l4 ?? 0)) /
                4;
            fcmSoilMoistureCount++;
          }
        }
      }
      for (int j = 0;
          j < farmer!.farmlands![selectedFarmland].blocks![i].devices!.length;
          j++) {
        Device device =
            farmer!.farmlands![selectedFarmland].blocks![i].devices![j];

        if (device.type == 'LSM' || device.type == 'LSA'|| device.type == 'WST') {
          aggregateSoilMoisture +=
              ((telematicData[device.deviceEUIID]?.l1 ?? 0) +
                      (telematicData[device.deviceEUIID]?.l2 ?? 0) +
                      (telematicData[device.deviceEUIID]?.l3 ?? 0) +
                      (telematicData[device.deviceEUIID]?.l4 ?? 0)) /
                  4;
          soilMoistureCount++;
          soilMoistureDeviceExists = true;
        }

        if (device.type == 'FCM') {
          fcmSoilMoisture += ((telematicData[device.deviceEUIID]?.l1 ?? 0) +
                  (telematicData[device.deviceEUIID]?.l2 ?? 0) +
                  (telematicData[device.deviceEUIID]?.l3 ?? 0) +
                  (telematicData[device.deviceEUIID]?.l4 ?? 0)) /
              4;
          fcmSoilMoistureCount++;
        }
      }

      blockAggregate.flow = aggregateFlow;
      blockAggregate.duration = aggregateDuration;
      blockAggregate.soilMoisture = aggregateSoilMoisture / soilMoistureCount;
      if (!soilMoistureDeviceExists) {
        blockAggregate.soilMoisture = fcmSoilMoisture / fcmSoilMoistureCount;
      }
      blockAggregates.add(blockAggregate);
    }
  if(farmer!.Address3=="#PlotFlowTrue"){

    for (int i=0;i<farmer!.farmlands![selectedFarmland].blocks!.length;i++){
    setState((){
      farmFlow+= blockFlowValues![farmer?.farmlands![selectedFarmland].blocks![i].id]!.toInt();

    });

    }

  }
  }

  void handleDurationChange(String duration) async {
    Map<String, dynamic> data = {};
    waterflowDuration = duration;
    showWaterFlowChart = false;
    waterflowChart = const SizedBox();
    if (mounted) {
      setState(() {});
    }
    if (!telematicDone || !scheduleTypeDone) return;
    List alldevices=[];
    alldevices.addAll(waterMeterDeviceList);

    moistureDevices.forEach((key, value) {
    alldevices.add(key);
    });
    data = {
      "farmlandDevice": farmlandWaterMeter,
      "period": duration,
      "irrigationType": 'T', // scheduleType == '' ? 'S' : scheduleType,
      "waterflowDevices": alldevices,
      "soilMoistureDevices": moistureDevices,
      "blocks": blockDevices
    };
  
    Map<String, dynamic> irrigationData =await DashboardService().getHistoricData(duration, data);
    irrigationData1={};

    Map<String, int> graphData = {};
    if (irrigationData.isNotEmpty) {
      irrigationData.forEach((key, value)async {
        graphData[key] = (value ?? 0.0).round();
        waterflowChart = WaterflowChart(
            durationType: duration,
            scheduleType: scheduleType,
            irrigationData: graphData);
        showWaterFlowChart = true;
      });
    }
    else {
      waterflowChart = WaterflowChart(
          durationType: duration,
          scheduleType: scheduleType,
          irrigationData: const {'': 0});
      showWaterFlowChart = true;
    }
    if (mounted) {
      setState(() {});
    }
  }
}



class WeatherView extends StatelessWidget {
  const WeatherView(
      {Key? key,
      required this.currentWeatherModel,
      required this.location,
      required this.handleTap,
      required this.farmerId})
      : super(key: key);
  final CurrentWeatherModel currentWeatherModel;
  final String location;
  final Function handleTap;
  final int farmerId;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weather Forecast'.i18n,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => handleTap(),
              child: Text(
                'View More'.i18n,
                style: TextStyle(color: cultGreen, fontSize: 12.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(10)),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10)),
          height: ScreenUtil().setHeight(130),
          width: ScreenUtil.defaultSize.width,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  SizedBox(
                    height: ScreenUtil().setHeight(70),
                    width: ScreenUtil().setHeight(70),
                    child: Image(
                        image: NetworkImage(
                            '$weatherIconURL/${currentWeatherModel.icon}@2x.png')),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${currentWeatherModel.temperature.round()} \u00B0C',
                    style:
                        TextStyle(fontSize: 14.sp,  color:
                        cultBlack,fontWeight: FontWeight.bold),
                  )
                ]),
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('H:m EEE, MMM d').format(
                              currentWeatherModel.currentDate.toLocal()),
                          style: TextStyle( color:
                          cultBlack,fontSize: 12.sp),
                        ),
                        Text('Location: $location',
                            style: TextStyle(color: cultGrey, fontSize: 10.sp)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Image(
                                    image: AssetImage(
                                        '${assetImagePath}humidity_blue.png')),
                                const SizedBox(width: 5),
                                Text('${currentWeatherModel.humidity}',
                                    style: TextStyle( color:
                                    cultBlack,fontSize: 12.sp)),
                              ],
                            ),
                            Row(
                              children: [
                                const Image(
                                    image: AssetImage(
                                        '${assetImagePath}sunrise.png')),
                                const SizedBox(width: 5),
                                Text(
                                    DateFormat('H:m').format(
                                        currentWeatherModel.sunrise.toLocal()),
                                    style: TextStyle( color:
                                    cultBlack,fontSize: 12.sp)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Image(
                                    image: AssetImage(
                                        '${assetImagePath}wind.png')),
                                const SizedBox(width: 5),
                                Text(
                                    '${currentWeatherModel.windSpeed.round()} mph',
                                    style: TextStyle( color:
                                    cultBlack,fontSize: 12.sp)),
                              ],
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Row(
                              children: [
                                const Image(
                                    image: AssetImage(
                                        '${assetImagePath}sunset.png')),
                                const SizedBox(width: 5),
                                Text(
                                    DateFormat('H:m').format(
                                        currentWeatherModel.sunset.toLocal()),
                                    style: TextStyle(fontSize: 12.sp,color:Colors.black)),
                              ],
                            )
                          ],
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }


}

class BlockAggregate {
  int blockID;
  double soilMoisture;
  double duration;
  double flow;
  BlockAggregate(
      {required this.blockID,
      this.soilMoisture = 0,
      this.duration = 0,
      this.flow = 0});
}


class Light extends StatelessWidget {
  final Color color;
  final bool phace;
  final double voltage;

  Light({required this.color,required this.phace,required this.voltage});

  @override
  Widget build(BuildContext context) {
    return voltage>280?

Container(
    width: 15.0,
    height: 15.0,
  child: color==Colors.red?   Image.asset('assets/images/exclamation.png',):
    color==Colors.yellow? Image.asset('assets/images/warning.png'):
        Image.asset('assets/images/warningblue.png')
)

        : Container(
      width: 15.0,
      height: 15.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2), // changes the shadow position
          ),
        ],
      ),
      child:phace ==false
          ? Center(
        child: Icon(
           Icons.close,
          color: Colors.black,
          size: 15.0,
        ),
      )
          :null,
    );
  }
}