import 'dart:async';

import 'package:cultyvate/utils/string_extension.dart';
import 'package:flutter/material.dart';
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:intl/intl.dart';
import '../../models/farmer_profile.dart';
import '../../models/weater_station_v2.dart';
import '../../models/weather_model.dart';
import '../../models/weather_station_model.dart';
import '../../network/api_helper.dart';
import '../../services/weather_station_service.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../internetcheck/getXcontroller.dart';
import '../internetcheck/nointernet.dart';
import '../login/login.dart';

class ChartData {
  ChartData({this.x, this.y});
  final String? x;
  final double? y;
}

BoxDecoration boxDecorationSelected = BoxDecoration(
    color: cultGreen, border: Border.all(color: cultGrey, width: 0.2));

BoxDecoration boxDecorationUnselected = BoxDecoration(
    color: cultGreenOpacity, border: Border.all(color: cultGrey, width: 0.2));

class WeatherData extends StatefulWidget {
  bool gotWeatherData = false;
  Farmer? farmer;
  final comefrom;
  final Farmerid;
  final selectedfarmland;
  final Device;
  final deviceid;

  WeatherData(
      {this.comefrom,
      this.Farmerid, this.Device,
      this.selectedfarmland,
      this.deviceid,
      this.farmer});

  @override
  State<WeatherData> createState() => WeatherDataState();
}

class WeatherDataState extends State<WeatherData> {

  CurrentWeatherModel? currentWeatherModel;
  bool gotWeatherData = false;
  Timer? timer;
  bool loading = false;
  String waterflowDuration = 'T';
  bool loadingchart = false;
  WeaterData2? weatherStation ;
  List<Chart>? chartdata = [];
  List<ChartData> chartData = [];
  List<ChartData> chartDataline = [];
  List<double> solarirdeance = [];
  List<double> temperaturevalues = [];
  List<double> wiendspeed = [];
  List<double> humditvalues = [];
  Stopwatch stopWatch = Stopwatch();
  int remainingTime = 0;
  double? width;
  void dispose() {
    print("dispose");
    stopWatch.stop();
    super.dispose();
  }

  Future<void> getWeatherData() async {
    if (currentWeatherModel != null) {
      return;
    }
    print("****************");
    double lat = widget.Device.lat ?? 0;
    double long = widget.Device.long ?? 0;
    if(lat !=null){
    print('weater api $weatherAPIURL/onecall?lat=$lat&lon=$long&appid=c0303fa192dfd0d6ff74f8a5564c16f3&units=metric&lang=hi');
    print("****************");
    var getData = await ApiHelper().get('$weatherAPIURL/onecall?lat=$lat&lon=$long&appid=c0303fa192dfd0d6ff74f8a5564c16f3&units=metric&lang=hi');
    if (getData.isNotEmpty) {
      currentWeatherModel = CurrentWeatherModel.fromJson(getData);
    }
    }

    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        gotWeatherData = true;
      });
    });
  }

  Datecheck(date) {
    DateTime parseDate = DateFormat("yyyy-MM-dd").parse(date);
    DateTime time = DateTime.now();
    DateTime parse = DateFormat('yyyy-MM-dd').parse(time.toString());
    return parseDate == parse;
  }

  getDate(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    var parse = DateFormat('yyyy-MM-dd').parse(date.toString());
    var formate2;
    if (waterflowDuration == 'M') {
      formate2 = "${parse.year}-01-01";
    } else {
      formate2 = "${parse.year}-${parse.month}-${parse.day}";
    }
    return formate2;
  }

  getDateAndTime(DateTime d) {
    var formate2 = "${d.year}-${d.month}-${d.day}";
    print("formate2" + formate2);
    return formate2;
  }
  final HomePageController controller =
  Get.put(HomePageController(), permanent: true);
  @override
  void initState() {
    super.initState();
    getWeatherData();
    getWatherdata();
    waterflowDuration = 'T';
    getchartdata(getDate(date), getDateAndTime(DateTime.now()));
    // timer = Timer.periodic(Duration(minutes: 15), (Timer t) => getWatherdata());
  }

  List<_ChartData> data = [];
  DateTime date = DateTime.now();

  Future<bool> _onWillPop() async {
    if (widget.comefrom == 'Login') {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: Row(
                children: [
                  Image(
                    image: AssetImage('${assetImagePath}exit.png'),
                    height: 30,
                    width: 40,
                  ),
                  Text("Do you want to logout?",style: TextStyle(color: Colors.black),),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Yes",style: TextStyle(color: Colors.black),),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                      Login()), (Route<dynamic> route) => false),
                ),
                TextButton(
                  child: Text("No",style: TextStyle(color: Colors.black),),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          )) ??
          false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      width = MediaQuery.of(context).size.width;
    });

    if (controller.ActiveConnection == false) {
      return Material(
        child: SafeArea(
            child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
             SizedBox(
               height:  ScreenUtil().setHeight(30),
               child:    IconButton(onPressed:_onWillPop, icon: Icon(Icons.arrow_back_ios_new_outlined)),
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
                Text(
                  "Weather Station",
                  style: TextStyle(color:Colors.black,fontSize: 20, fontWeight: FontWeight.bold),
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
        )),
      );
    } else {
      return  WillPopScope(
          onWillPop: _onWillPop,
          child: SafeArea(
            child: Material(
                color: Colors.white,
                child:  loading
            ? Container(
            height: MediaQuery.of(context).size.height,
    child: Center(child: SpinKitCircle(
    itemBuilder: (BuildContext context, int index) {
    return  DecoratedBox(
    decoration: BoxDecoration(
    color: cultGreen,
    ),
    );
    },
    )),
    )
        : weatherStation !=null?SingleChildScrollView(
                  // physics:  AlwaysScrollableScrollPhysics(),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height:  ScreenUtil().setHeight(30),
                                child:    IconButton(onPressed: _onWillPop, icon: Icon(Icons.arrow_back_ios_new_outlined)),
                              ),
                              SizedBox(
                                width: 5,
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
                                width: 10,
                              ),
                              Text(
                                "Weather Station",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),

                              IconButton(
                                onPressed: () {
                                  getWatherdata();
                                  setState(() {
                                    waterflowDuration = 'T';
                                  });

                                  getchartdata(
                                      getDate(date),
                                      getDateAndTime(
                                          DateTime.now()));
                                },
                                icon: const Icon(Icons.refresh),
                                iconSize: 25.h,
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
                                      backgroundColor: Colors.white,
                                      color: Colors.red),
                                  child: Image(
                                    image: AssetImage(
                                        '${assetImagePath}bell.png'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: Text(
                                'Data refresh in'.i18n +
                                    ' ' +
                                    (remainingTime / 60)
                                        .floor()
                                        .toString() +
                                    ':' +
                                    ((remainingTime % 60)
                                        .toString()
                                        .length ==
                                        1
                                        ? '0' +
                                        (remainingTime % 60)
                                            .toString()
                                        : (remainingTime % 60)
                                        .toString()),
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            // margin: EdgeInsets.all(20),
                            padding: EdgeInsets.only(
                                top: 20, left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Farmer Name: ${widget.farmer!.name}",
                                  style: TextStyle(   color: Colors.black,fontSize: 15),
                                ),
                                Text(
                                  "Father Name: ${widget.farmer!.fathername}",
                                  style: TextStyle(   color: Colors.black,fontSize: 15),
                                ),
                                Text(
                                  "Village Name: ${widget.farmer!.villageName}",
                                  style: TextStyle(   color: Colors.black,fontSize: 15),
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    // SizedBox(width: 20,),

                                    Text(
                                      "Device Id: ${weatherStation!.data !=null?weatherStation!.data![0].deviceID:""}",
                                      style:
                                      TextStyle(   color: Colors.black,fontSize: 15),
                                    ),
                                    // SizedBox(width: 20,),
                                    Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.only(
                                              topRight: Radius
                                                  .circular(10),
                                              topLeft: Radius
                                                  .circular(10),
                                              bottomLeft: Radius
                                                  .circular(10),
                                              bottomRight:
                                              Radius.circular(
                                                  10)),
                                          color: Dateformatediferrance(

                                              weatherStation!.data![0].createDate) >
                                              60
                                              ? Colors.red
                                              : Colors.green),
                                      height: 25,
                                      width: 60,
                                      child: Center(
                                        child: Text(
                                          Dateformatediferrance(
                                               weatherStation!.data![0].createDate) >
                                              60 ? "Offline" : "Online",
                                          style: TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                weatherStation!.data![0].HardwareSerialnumber !=
                                    'NULL'
                                    ? Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // SizedBox(width: 20,),

                                    Text(
                                      "SerialNumber:${weatherStation!.data![0].HardwareSerialnumber ?? ""} ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15),
                                    ),
                                    Spacer(),
                                  ],
                                )
                                    : SizedBox(),
                                Text(
                                  "Last Communicated On: ${Dateformate(weatherStation!.data![0].createDate)}",
                                  style: TextStyle(   color: Colors.black,fontSize: 15),
                                ),

                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            // margin: EdgeInsets.only(left:10 ,right:10 ),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black)
                            // ),
                              height: 350.h,
                              child: Card(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10),
                                  color: Dateformatediferrance(
                                      weatherStation!.data![0].createDate) >
                                      60
                                      ? HexColor("#dedede")
                                      : Colors.white,
                                  elevation: 2,
                                  child: Column(children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: width! / 2.3,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets
                                                      .only(
                                                      left: 20),
                                                  child: Text(
                                                      "Today",style: TextStyle(   color: Colors.black,),)),
                                              SizedBox(
                                                height: ScreenUtil()
                                                    .setHeight(70),
                                                width: ScreenUtil()
                                                    .setWidth(250),
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    Image(
                                                        image: NetworkImage(
                                                            '$weatherIconURL/${currentWeatherModel?.icon}@2x.png')),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsets
                                                          .only(
                                                          top: 20),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        // mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${Datecheck(weatherStation!.data![0].createDate) ? double.parse(weatherStation!.data![0].currentTemperature.toString()).round() : 0} \u00B0C Temp',
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize:
                                                                10.sp,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          Text(
                                                            '${Datecheck(weatherStation!.data![0].createDate) ? double.parse(weatherStation!.data![0]!.currentHumidity.toString()).round() : 0} % Hum',
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize:
                                                                10.sp,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Text("         Feels Like    :   ${Datecheck(weatherStation!.data![0].createDate) ?currentWeatherModel!.feels_like:0}  \u00B0C ", style: TextStyle(
                                              //     color: Colors.black,
                                              //     fontSize:
                                              //     10.sp,
                                              //     fontWeight: FontWeight.bold),)
                                              // Card(

                                              //   child:
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 100,
                                          width: 160,
                                          child: Card(
                                            elevation: 2,
                                            margin: EdgeInsets.only(
                                                top: 10,
                                                bottom: 10),

                                            child: Column(
                                              children: [
                                                Row(
                                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 45,
                                                    ),
                                                    Text(
                                                      'Temp',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey),
                                                    ),
                                                    SizedBox(
                                                      width: 40,
                                                    ),
                                                    Text(
                                                      'Hum',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [

                                                    Text("High",
                                                        style: TextStyle(
                                                            color:
                                                            cultGreen,
                                                            fontSize:
                                                            12.sp)),

                                                    Text(
                                                        "${Datecheck(weatherStation!.data![0].createDate) ? (double.parse(weatherStation!.data![0].highfTemperature.toString()) >= 10 && double.parse(weatherStation!.data![0].highfTemperature.toString()) <= 70) ?double.parse(weatherStation!.data![0].highfTemperature.toString()).toStringAsFixed(1):"..":"..."}\u00B0C"
                                                    ,style: TextStyle(color: Colors.black),
                                                    ),

                                                    Text(
                                                        "${Datecheck(weatherStation!.data![0].createDate) ? (double.parse(weatherStation!.data![0].highfHumidity.toString()) >= 30 && double.parse(weatherStation!.data![0].highfHumidity.toString()) <= 100) ? double.parse(weatherStation!.data![0].highfHumidity.toString()).toStringAsFixed(1):"..":"..."} %"  ,style: TextStyle(color: Colors.black),        )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                                                  children: [
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Low",
                                                        style: TextStyle(
                                                            color:
                                                            cultGreen,
                                                            fontSize:
                                                            12.sp)),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                        "${ double.parse(weatherStation!.data![0].lowfTemperature.toString()).toStringAsFixed(1)}\u00B0C"  ,style: TextStyle(color: Colors.black),        ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                        "${double.parse(weatherStation!.data![0].lowfHumidity.toString()).toStringAsFixed(1) ?? 0} %"  ,style: TextStyle(color: Colors.black),        )
                                                  ],
                                                )
                                              ],
                                              // ),
                                            ),


                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 5.h,
                                          left: 10.w,
                                          bottom: 10.h),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                waterflowDuration =
                                                'T';
                                              });

                                              getchartdata(
                                                  getDate(date),
                                                  getDateAndTime(
                                                      DateTime
                                                          .now()));
                                            },
                                            child: Container(
                                                padding:
                                                EdgeInsets.all(
                                                    0),
                                                width: (MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width -
                                                    45.w) /
                                                    3,
                                                height: 20.h,
                                                decoration: waterflowDuration ==
                                                    'T'
                                                    ? boxDecorationSelected
                                                    : boxDecorationUnselected,
                                                child: Center(
                                                  child: Text(
                                                    "Today",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontSize:
                                                        footerFont
                                                            .sp,
                                                        color: waterflowDuration ==
                                                            'T'
                                                            ? Colors
                                                            .white
                                                            : cultGrey),
                                                  ),
                                                )),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                waterflowDuration =
                                                'W';
                                              });
                                              getchartdata(
                                                  getDate(date.subtract(
                                                      Duration(
                                                          days: date
                                                              .weekday -
                                                              1))),
                                                  getDateAndTime(
                                                      DateTime
                                                          .now()));
                                            },
                                            child: Container(
                                                width: (MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width -
                                                    45.w) /
                                                    3,
                                                height: 20.h,
                                                decoration: waterflowDuration ==
                                                    'W'
                                                    ? boxDecorationSelected
                                                    : boxDecorationUnselected,
                                                child: Center(
                                                  child: Text(
                                                    "Week",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontSize:
                                                        footerFont
                                                            .sp,
                                                        color: waterflowDuration ==
                                                            'W'
                                                            ? Colors
                                                            .white
                                                            : cultGrey),
                                                  ),
                                                )),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                waterflowDuration =
                                                'M';
                                              });

                                              getchartdata(
                                                  getDate(DateTime
                                                      .now()),
                                                  getDateAndTime(
                                                      DateTime
                                                          .now()));
                                            },
                                            child: Container(
                                                width: ((MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    45.w) /
                                                    3 -
                                                    5.w),
                                                height: 20.h,
                                                decoration: waterflowDuration ==
                                                    'M'
                                                    ? boxDecorationSelected
                                                    : boxDecorationUnselected,
                                                child: Center(
                                                  child: Text(
                                                    "Month",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontSize:
                                                        footerFont
                                                            .sp,
                                                        color: waterflowDuration ==
                                                            'M'
                                                            ? Colors
                                                            .white
                                                            : cultBlack),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    loadingchart
                                        ? Center(
                                        child: SpinKitCircle(
                                          itemBuilder:
                                              (BuildContext
                                          context,
                                              int index) {
                                            return const DecoratedBox(
                                              decoration:
                                              BoxDecoration(
                                                color: cultGreen,
                                              ),
                                            );
                                          },
                                        ))
                                        : Container(
                                        height: 200,
                                        width: 400,
                                        child:Column(
                                          children: [
                                           Container(
                                             height: 175,
                                             child:SfCartesianChart(
                                               margin: EdgeInsets.only(left: 20),
                                               primaryXAxis: CategoryAxis(
                                                 title: AxisTitle(
                                                   text: waterflowDuration == "T"
                                                       ? "Hours"
                                                       : waterflowDuration == "W"
                                                       ? "Week Days"
                                                       : "Month",
                                                   textStyle: TextStyle(
                                                     color: Colors.black,
                                                     fontFamily: 'Roboto',
                                                     fontSize: 16,
                                                     fontStyle: FontStyle.italic,
                                                     fontWeight: FontWeight.w300,
                                                   ),
                                                 ),
                                               ),
                                               primaryYAxis: NumericAxis(
                                                 labelFormat: '{value}',
                                                 interval: 20, // Set the interval of the y-axis to 20
                                                 maximum: 100,
                                                 majorTickLines: MajorTickLines(
                                                   size: 0, // Set the size of the tick lines to 0 to hide them
                                                 ),
                                                 minorTickLines: MinorTickLines(
                                                   size: 0, // Set the size of the tick lines to 0 to hide them
                                                 ),
                                                 axisLine: AxisLine(
                                                   color: Colors.black, // Set the color of the axis line
                                                   width: 2, // Set the width of the axis line
                                                 ),
                                                 majorGridLines: MajorGridLines(
                                                   width: 1, // Set the width of the gridlines
                                                   color: Colors.grey, // Set the color of the gridlines
                                                 ),
                                               ),
                                               series: <CartesianSeries>[
                                                 ColumnSeries<ChartData, String>(
                                                   width: 0.2,
                                                   spacing: 0,
                                                   dataSource: chartData,
                                                   xValueMapper: (ChartData data, _) => data.x,
                                                   yValueMapper: (ChartData data, _) => data.y,
                                                 ),
                                                 LineSeries<ChartData, String>(
                                                   width: 0.8,
                                                   dataSource: chartDataline,
                                                   color: Colors.brown,
                                                   xValueMapper: (ChartData data, _) => data.x,
                                                   yValueMapper: (ChartData data, _) => data.y,
                                                 ),
                                               ],
                                             ),





                                           ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children:[
                                                  Text("Temperature",style: TextStyle(color:Colors.black),),
                                                  Container(
                                                    width: 25,
                                                    height: 25,

                                                    color: Colors.blue.withOpacity(0.75),
                                                  ),
                                                  Text("Humidity",style: TextStyle(color:Colors.black),),
                                                  Container(
                                                    width: 25,
                                                    height: 25,
                                                    color: Colors.brown.withOpacity(0.75),
                                                  )
                                                ]
                                            )
                                          ],
                                        )



                                        ),
                                  ]))
                            // width:,

                            // width: 80,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            // margin: EdgeInsets.only(left:10 ,right:10 ),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black)
                            // ),
                            height: 220.h,

                            child: Card(
                              color: Dateformatediferrance(
                                  weatherStation!.data![0].createDate) >
                                  60
                                  ? HexColor("#dedede")
                                  : Colors.white,
                              margin: EdgeInsets.only(
                                  left: 10, right: 10),
                              elevation: 2,
                              child: Row(
                                children: [
                                  Container(
                                    // width: width/2,
                                    child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          // SizedBox(height: 10,),
                                          Padding(
                                            padding:
                                            const EdgeInsets
                                                .only(left: 25),
                                            child: Text(
                                              '  Wind Direction',
                                              style: TextStyle(
                                             color: Colors.black,
                                                fontSize: 15,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                          ),
                                          SizedBox(
                                            // height: ScreenUtil().setHeight(4),
                                            width: ScreenUtil()
                                                .setWidth(MediaQuery.of(
                                                context)
                                                .size
                                                .width /
                                                2),
                                            child: Column(
                                              // mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 25),
                                                  child: Container(
                                                    height: 120,
                                                    width: 100,
                                                    child:
                                                    SfRadialGauge(
                                                      axes: <
                                                          RadialAxis>[
                                                        RadialAxis(
                                                            showAxisLine:
                                                            false,
                                                            radiusFactor:
                                                            1.2,
                                                            // showLastLabel: true,
                                                            canRotateLabels:
                                                            false,
                                                            // labelFormat: ,
                                                            tickOffset:
                                                            0.32,
                                                            offsetUnit: GaugeSizeUnit
                                                                .factor,
                                                            onLabelCreated:
                                                            axisLabelCreated,
                                                            startAngle:
                                                            270,
                                                            endAngle:
                                                            270,
                                                            labelOffset:
                                                            0.05,
                                                            maximum:
                                                            360,
                                                            minimum:
                                                            0,
                                                            interval:
                                                            90,
                                                            // minorTicksPerInterval: 4,
                                                            axisLabelStyle: GaugeTextStyle(
                                                                color: const Color(
                                                                    0xFF949494)),
                                                            minorTickStyle: MinorTickStyle(
                                                                color: const Color(
                                                                    0xFF616161),
                                                                thickness:
                                                                1.6,
                                                                length:
                                                                0.058,
                                                                lengthUnit: GaugeSizeUnit
                                                                    .factor),
                                                            majorTickStyle: MajorTickStyle(
                                                                color: const Color(
                                                                    0xFF949494),
                                                                thickness:
                                                                2.3,
                                                                length:
                                                                0.087,
                                                                lengthUnit: GaugeSizeUnit
                                                                    .factor),
                                                            pointers: <
                                                                GaugePointer>[
                                                              NeedlePointer(
                                                                value: Datecheck(weatherStation!.data![0].createDate)
                                                                    ? double.parse(weatherStation!.data![0].currentWindDirectionDegree.toString())
                                                                    : 0,
                                                                lengthUnit:
                                                                GaugeSizeUnit.logicalPixel,
                                                                needleLength:
                                                                20,
                                                                needleEndWidth:
                                                                2,
                                                                needleStartWidth:
                                                                0.20,
                                                              )
                                                            ]),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // SizedBox(width: 10,),
                                                Padding(
                                                  padding: EdgeInsets
                                                      .only(
                                                      top: 20,
                                                      left: 25),
                                                  child: Container(
                                                    height: 60.h,
                                                    width: 125.w,
                                                    child: Card(
                                                      elevation: 2,
                                                      child: Center(
                                                        child:
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          // mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              '${Datecheck(weatherStation!.data![0].createDate) ? double.parse(weatherStation!.data![0].currentWindDirectionDegree.toString()).round() : 0} \u00B0',
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 12.sp,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                              5,
                                                            ),
                                                            Datecheck(weatherStation!.data![0].createDate)
                                                                ? Direaction(double.parse(weatherStation!.data![0].currentWindDirectionDegree.toString()),
                                                            )
                                                                : Text(""),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            right: 30.0,
                                            bottom: 10),
                                        child: Text(
                                          'Wind Speed',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            right: 10.0),
                                        child: Container(
                                          height: 60.h,
                                          width: 125.w,
                                          child: Card(
                                            elevation: 2,
                                            child: Row(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                  children: [
                                                    // Text(""),
                                                    Text(" High",
                                                        style: TextStyle(
                                                            color:
                                                            cultGreen,
                                                            fontSize:
                                                            12.sp)),
                                                    Text(" Low",
                                                        style: TextStyle(
                                                            color:
                                                            cultGreen,
                                                            fontSize:
                                                            12.sp))
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                  children: [
                                                    Text(
                                                      "${double.parse(weatherStation!.data![0].highWindSpeedKmHr.toString()).toStringAsFixed(2)?? 0} Km/Hr",
                                                      style: TextStyle(
                                                          color: Colors.black,

                                                          fontSize:
                                                          12.sp),
                                                    ),
                                                    Text(
                                                      "${double.parse(weatherStation!.data![0].lowWindSpeedKmHr.toString()).toStringAsFixed(2)?? 0} Km/Hr",
                                                      style: TextStyle(
                                                          color: Colors.black,

                                                          fontSize:
                                                          12.sp),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            top: 10, left: 25),
                                        child: Container(
                                          height: 120,
                                          width: 130,
                                          child: SfRadialGauge(
                                            // title: GaugeTitle(text: "Speed Meter"), //title for guage
                                              enableLoadingAnimation:
                                              true,
                                              //show meter pointer movement while loading
                                              animationDuration:
                                              4500,
                                              //pointer movement speed
                                              axes: <RadialAxis>[
                                                //Radial Guage Axix, use other Guage type here
                                                RadialAxis(
                                                    minimum: 0,
                                                    maximum: 100,
                                                    showLabels:
                                                    true,
                                                    showLastLabel:
                                                    true,
                                                    interval: 20,

                                                    // radiusFactor: 0.20,
                                                    ranges: <
                                                        GaugeRange>[
                                                      //Guage Ranges

                                                      GaugeRange(
                                                          startValue:
                                                          0,
                                                          endValue:
                                                          50,
                                                          //start and end point of range
                                                          color: Colors
                                                              .green,
                                                          startWidth:
                                                          10,
                                                          endWidth:
                                                          10),
                                                      GaugeRange(
                                                          startValue:
                                                          50,
                                                          endValue:
                                                          70,
                                                          color: Colors
                                                              .orange,
                                                          startWidth:
                                                          10,
                                                          endWidth:
                                                          10),
                                                      GaugeRange(
                                                          startValue:
                                                          70,
                                                          endValue:
                                                          100,
                                                          color: Colors
                                                              .red,
                                                          startWidth:
                                                          10,
                                                          endWidth:
                                                          10),

                                                      //add more Guage Range here
                                                    ],
                                                    pointers: <
                                                        GaugePointer>[
                                                      NeedlePointer(
                                                        value: double.parse(weatherStation!.data![0].currentWindSpeedKmHr
                                                            .toString()),
                                                        lengthUnit:
                                                        GaugeSizeUnit
                                                            .logicalPixel,
                                                        needleLength:
                                                        20,
                                                        needleEndWidth:
                                                        2,
                                                        needleStartWidth:
                                                        0.20,
                                                      )
                                                    ],
                                                    annotations: <
                                                        GaugeAnnotation>[
                                                      GaugeAnnotation(
                                                          widget: Container(
                                                              child: Text(
                                                                  "${weatherStation!.data![0].currentWindSpeedKmHr} kh",
                                                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.bold))),
                                                          angle: 90,
                                                          positionFactor: 0.7),
                                                      //add more annotations 'texts inside guage' here
                                                    ])
                                              ]),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // width:,

                            // width: 80,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            height: 120,
                            child: Card(
                              color: Dateformatediferrance(
                                  weatherStation!.data![0].createDate) >
                                  60
                                  ? HexColor("#dedede")
                                  : Colors.white,
                              elevation: 2,
                              margin: EdgeInsets.only(
                                  left: 10, right: 10),
                              child: Container(
                                // width: MediaQuery.of(context).size.width/4,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25),
                                        child: Text(
                                          "Solar Irradiance",
                                          style: TextStyle(
                                              color: Colors.black,

                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 15),
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceAround,
                                        children: [
                                          // SizedBox(width: 20,),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 5),
                                            child: Container(
                                              // decoration: BoxDecoration(
                                              //     border: Border.all(color: Colors.black)
                                              // ),
                                              height: 60.h,
                                              width: 125.w,
                                              // width: 90.w,
                                              child: Card(
                                                elevation: 2,
                                                child: Column(
                                                  children: [
                                                    Text("Now",
                                                        style: TextStyle(
                                                            fontSize:
                                                            12,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .grey)),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                        "${Datecheck(weatherStation!.data![0].createDate) ? double.parse(weatherStation!.data![0].currentRadiationWM2.toString()).round() : 0} W/m2",
                                                        style: TextStyle(
                                                            color: Colors.black,

                                                            fontSize:
                                                            15)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 2,
                                            height: 25,
                                          ),
                                          Container(
                                            // decoration: BoxDecoration(
                                            //     border: Border.all(color: Colors.black)
                                            // ),
                                            height: 60.h,
                                            width: 125.w,
                                            // width: 90.w,
                                            child: Card(
                                              elevation: 2,
                                              margin: EdgeInsets.only(
                                                  left: 5, right: 5),
                                              child: Column(
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      'Today',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: Colors
                                                              .grey),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                        children: [
                                                          Text(
                                                            " High",
                                                            style: TextStyle(
                                                                color:
                                                                cultGreen,
                                                                fontSize:
                                                                12.sp),
                                                          ),
                                                          // Spacer(),
                                                          Text(
                                                            " ${double.parse(weatherStation!.data![0].highRadiationWM2.toString()).toStringAsFixed(2)} W/m2",
                                                            style:
                                                            TextStyle(
                                                              color: Colors.black,

                                                              fontSize:
                                                              13,
                                                            ),
                                                          )
                                                        ],
                                                      ),

                                                      // SizedBox(height: 5,),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                        children: [
                                                          Text(" Low",
                                                              style: TextStyle(
                                                                  color:
                                                                  cultGreen,
                                                                  fontSize:
                                                                  12.sp)),
                                                          Spacer(),
                                                          Text(
                                                            " ${double.parse(weatherStation!.data![0].lowRadiationWM2.toString()).toStringAsFixed(2)?? 0} W/m2",
                                                            style: TextStyle(
                                                                color: Colors.black,

                                                                fontSize:
                                                                13),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                              height: 200.h,
                              child: Card(
                                color: Dateformatediferrance(
                                    weatherStation!.data![0].createDate) >
                                    60
                                    ? HexColor("#dedede")
                                    : Colors.white,
                                elevation: 2,
                                margin: EdgeInsets.only(
                                    left: 10, right: 10),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 25),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Rain',
                                            style: TextStyle(
                                                color: Colors.black,

                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                              height: 50,
                                              width: 100,
                                              child: Card(
                                                  elevation: 2,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                          "${Datecheck(weatherStation!.data![0].createDate) ? double.parse(weatherStation!.data![0].currentRain!.toStringAsFixed(0)).round() : 0} MM",
                                                          style: TextStyle(
                                                              color: Colors.black,

                                                              fontSize:
                                                              15)),
                                                    ],
                                                  )))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150.h,
                                      child: SfCartesianChart(
                                          enableAxisAnimation:
                                          false,
                                          primaryXAxis:
                                          CategoryAxis(),
                                          primaryYAxis: NumericAxis(
                                            isVisible: true,

                                            // borderWidth: 1,
                                          ),
                                          // primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
                                          // tooltipBehavior: _tooltip,
                                          series: <
                                              ChartSeries<
                                                  _ChartData,
                                                  String>>[
                                            ColumnSeries<_ChartData,
                                                String>(
                                                isTrackVisible:
                                                true,
                                                borderColor:
                                                Colors.white,
                                                isVisibleInLegend:
                                                false,
                                                spacing: 0.20,
                                                dataSource: data,
                                                xValueMapper:
                                                    (_ChartData data,
                                                    _) =>
                                                data.x,
                                                yValueMapper:
                                                    (_ChartData data,
                                                    _) =>
                                                data.y,
                                                trackColor:
                                                HexColor(
                                                    '#e3e6e6'),
                                                trackBorderColor:
                                                Colors.white,
                                                // name: 'Gold',
                                                color: HexColor(
                                                    '#5587bd'))
                                          ]),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                              height: ScreenUtil().setHeight(20)),
                          if (gotWeatherData &&
                              currentWeatherModel != null)
                            WeatherView(
                                currentWeatherModel:
                                currentWeatherModel!,
                                location: ((language == 'en')
                                    ? widget
                                    .farmer!
                                    .farmlands![widget
                                    .selectedfarmland]
                                    .farmlandVillageName ??
                                    ''
                                    : widget
                                    .farmer!
                                    .farmlands![widget
                                    .selectedfarmland]
                                    .farmlandVillageAlias ??
                                    ''),
                                farmerId: widget.Farmerid,
                                handleTap: showWeeklyForecast),
                          const SizedBox(height: 20),
                          Container(
                              height: 100.h,
                              width:
                              MediaQuery.of(context).size.width,
                              child: Card(
                                // color:Dateformatediferrance(weatherStation![0].createDate)>60 ? HexColor("#dedede"):Colors.white,
                                  elevation: 2,
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            left: 25),
                                        child: Text("Advisory",
                                            style: TextStyle(
                                                color: Colors.black,

                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight
                                                    .bold)),
                                      ),
                                      Center(
                                        child: Text(

                                            "Coming up shortly",style: TextStyle(        color: Colors.black,),),
                                      )
                                    ],
                                  ))),
                          SizedBox(
                            height: 20,
                          )
                        ])


                ):Center(
                  child: Text("No Records..!",style: TextStyle(        color: Colors.black,),)
                )

            ),
          )

      );
    }
  }

  void axisLabelCreated(AxisLabelCreatedArgs args) {
    print("args text ${args.text}");
    if (args.text == '90') {
      print("inside 90");
      args.text = 'E';
      args.labelStyle =
          GaugeTextStyle(fontSize: 5, color: const Color(0xFFDF5F2D));
    } else if (args.text == '0') {
      args.text = 'N';
      args.labelStyle =
          GaugeTextStyle(fontSize: 5, color: const Color(0xFFDF5F2D));
    } else if (args.text == '180') {
      args.text = 'S';
      args.labelStyle =
          GaugeTextStyle(fontSize: 5, color: const Color(0xFFDF5F2D));
    } else if (args.text == '270') {
      args.text = 'W';
      args.labelStyle =
          GaugeTextStyle(fontSize: 5, color: const Color(0xFFDF5F2D));
    }
  }

  WeatherStationService weatherStationService = WeatherStationService();
  Future<dynamic> getchartdata(startdate, enddate) async {
    chartData.clear();
    chartDataline.clear();
    setState(() {
      loadingchart = true;
    });

    var type = waterflowDuration == 'T'
        ? 'T'
        : waterflowDuration == 'W'
            ? "W"
            : "M";
    chartdata = await weatherStationService.chartdara(
        widget.deviceid, startdate, enddate, type);
    print("monthdata $chartdata");
    chartdata!.forEach((element) {
      late var parsedDate;
      if (waterflowDuration != 'M') {
        parsedDate = DateTime.parse(element!.forDate.toString());
      }
      if (waterflowDuration == 'T') {
        chartData.add(ChartData(
            x: element!.onHour.toString(),
            y: double.parse(element!.temperature.toString())));
        chartDataline.add(ChartData(
            x: element!.onHour.toString(),
            y: double.parse(element!.humidity.toString())));
        setState(() {
          loadingchart = false;
        });
      } else if (waterflowDuration == 'W') {
        chartData.add(ChartData(
            x: DateFormat('EE').format(parsedDate).toString(),
            y: double.parse(element!.temperature.toString())));
        chartDataline.add(ChartData(
            x: DateFormat('EE').format(parsedDate).toString(),
            y: double.parse(element!.humidity.toString())));
        setState(() {
          loadingchart = false;
        });
      } else {
        chartData.add(ChartData(
            x: element.forDate!.substring(0, 3),
            y: double.parse(element!.temperature.toString())));
        chartDataline.add(ChartData(
            x: element.forDate!.substring(0, 3),
            y: double.parse(element!.humidity.toString())));
        setState(() {
          loadingchart = false;
        });
      }
    });

    setState(() {
      loadingchart = false;
    });
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
                                    style: TextStyle(fontSize: 12.sp,color: Colors.black),
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
                                    style: TextStyle(

                                        fontSize: 10.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    children: [
                                      Text(
                                          'Max: ${currentWeatherModel!.dailyWeather[i].max.round()}',
                                          style: TextStyle( color: Colors.black,fontSize: 10.sp)),
                                      const SizedBox(height: 5),
                                      Text(
                                          'Min: ${currentWeatherModel!.dailyWeather[i].min.round()}',
                                          style: TextStyle(          color: Colors.black,fontSize: 10.sp)),
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

  Future<void> getWatherdata() async {
    setState(() {
      loading = true;
    });
    waterflowDuration = '';
    weatherStation =null;
    data = [];
    temperaturevalues = [];
    solarirdeance = [];
    wiendspeed = [];
    humditvalues = [];
    chartData = [];
    chartDataline = [];

    weatherStation =await weatherStationService.WeatherStationdata(widget.deviceid);
    if (weatherStation == null) {
      Future.delayed(const Duration(seconds: 10), () {
        setState(() {
          loading = false;
        });
      });
    } else {
      // var onehordata = await weatherStationService.onehorrain(widget.deviceid);
      data.add(_ChartData("hour\n${weatherStation!.data![0].sumRainmmComputedLastHour?.toStringAsFixed(2)??0} mm", weatherStation!.data![0].sumRainmmComputedLastHour!));
      // var lastday = await weatherStationService.lastday(widget.deviceid);
      data.add(_ChartData("Day\n${weatherStation!.data![0].sumRainmmComputedLastDay?.toStringAsFixed(2)??0} mm", weatherStation!.data![0].sumRainmmComputedLastDay!.toDouble()));
      // var lastweek = await weatherStationService.week(widget.deviceid);
      data.add(_ChartData(
          "Week\n${weatherStation!.data![0].sumRainmmComputedLastWeek!.toStringAsFixed(3) == 0.00 ? 0 : weatherStation!.data![0].sumRainmmComputedLastWeek!.toStringAsFixed(2)} mm",
          weatherStation!.data![0].sumRainmmComputedLastWeek!));
      // var month = await weatherStationService.month(widget.deviceid);
      data.add(_ChartData("Month\n${weatherStation!.data![0].sumRainmmComputedLastMonth!.toStringAsFixed(2)} mm", weatherStation!.data![0].sumRainmmComputedLastMonth!));
      // var total = await weatherStationService.total(widget.deviceid);
      data.add(_ChartData("Year\n${weatherStation!.data![0].totalrainmm!.toStringAsFixed(2)} mm", weatherStation!.data![0].totalrainmm!));
      // Future.delayed(const Duration(seconds: 10), () {


      // });
      setState(() {
        loading=false;
        waterflowDuration = 'T';

      });

      getchartdata(getDate(date), getDateAndTime(DateTime.now())).then((value) {
        setState((){
          loading=false;
        });
      });
      resetStopWatch();
    }
    // getWeatherData();
  }
  void setTimerRemaining() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {

        remainingTime = (10 * 60) - stopWatch.elapsed.inSeconds;

      if (mounted) {
        setState(() {});
        if (remainingTime <= 0) {
          timer?.cancel();
          await    getWatherdata();
        }
      }
    });
  }
  // void setTimerRemaining() {
  //   remainingTime = 1 * 60;
  //   bool apiCalled = false;
  //
  //   void timerCallback(Timer t) {
  //     // remainingTime -= 1;
  //
  //     // if (mounted) {
  //       if (remainingTime <= 0 && !apiCalled && controller.ActiveConnection) {
  //         apiCalled = true;
  //         // Call the getWeatherData function
  //         getWatherdata();
  //       // }
  //       setState(() {});
  //     }
  //   }
  //
  //   timer = Timer.periodic(const Duration(seconds: 1), timerCallback);
  // }


  // void setTimerRemaining() {
  //    remainingTime = (10 * 60); // set initial remaining time to 10 minutes
  //   bool apiCalled = false;
  //    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
  //      remainingTime -= 10;
  //      if (mounted) {
  //        setState(() {});
  //        if (remainingTime <= 0 && !apiCalled && controller.ActiveConnection) {
  //      setState((){
  //        apiCalled=true;
  //      });
  //         getWatherdata();
  //       }
  //     }
  //   });
  // }

  void resetStopWatch() {
    stopWatch.reset();
    stopWatch.start();
    setTimerRemaining();
  }

  Dateformate(date) {
    DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('MM/dd/yyyy hh:mm a');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  Dateformatediferrance(date) {
    DateTime currentdate = DateTime.now();

    DateTime parseDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(date.toString());
    var inputDate = DateTime.parse(parseDate.toString());
    Duration diff = currentdate.difference(inputDate);
    print(diff.inMinutes);
    return diff.inMinutes;
  }

  double? maxvalue(List<double> arr) {
    var max = arr.reduce((curr, next) => curr > next ? curr : next);
    print(max); // 8 --> Max
    var min = arr.reduce((curr, next) => curr < next ? curr : next);
    // 1 --> Min
    return max;
  }

  double? minvalue(List<double> arr) {
    var min;
    if (arr.length > 1) {
      var max = arr.reduce((curr, next) => curr > next ? curr : next);
      print(max); // 8 --> Max
      min = arr.reduce((curr, next) => curr < next ? curr : next);
    } else {
      min = 0;
    }
    return min.toDouble();
  }
}

Widget Direaction(double value) {
  if (value > 1 && value <= 45) {
    // weatherStation[0]!.windDirectionDegree=200<300?"west":weatherStation[0]!.windDirectionDegree==0?North:North',
    return Text(
      "North East",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  } else if (value > 45 && value < 90) {
    return Text(
      "East",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  } else if (value > 90 && value < 135) {
    return Text(
      "South East",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  } else if (value > 135 && value < 180) {
    return Text(
      "South",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  } else if (value > 180 && value < 225) {
    return Text(
      "South West",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  } else if (value > 225 && value < 270) {
    return Text(
      "West",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  } else if (value > 270 && value < 315) {
    return Text(
      "North West",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  } else {
    return Text(
      "North",
      style: TextStyle(          color: Colors.black,fontSize: 12.sp, fontWeight: FontWeight.bold),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
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
    return Container(
        height: 200,
        child: Card(
          margin: EdgeInsets.only(left: 10, right: 10),

          // color:Dateformatediferrance(weatherStation![0].createDate)>60 ? HexColor("#dedede"):Colors.white,
          elevation: 2,
          child: Column(
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
                      'View More   '.i18n,
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
                height: ScreenUtil().setHeight(125),
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
                        const SizedBox(height: 10),
                        Text(
                          '${currentWeatherModel.temperature.round()} \u00B0C',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        )
                      ]),
                    ),
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('H:m EEE, MMM d').format(
                                    currentWeatherModel.currentDate.toLocal()),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text('Location: $location',
                                  style: TextStyle(

                                      color: cultGrey, fontSize: 10.sp)),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Image(
                                          image: AssetImage(
                                              '${assetImagePath}humidity_blue.png')),
                                      const SizedBox(width: 5),
                                      Text('${currentWeatherModel.humidity}',
                                          style: TextStyle(          color: Colors.black,fontSize: 14.sp)),
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
                                              currentWeatherModel.sunrise
                                                  .toLocal()),
                                          style: TextStyle(          color: Colors.black,fontSize: 14.sp)),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Image(
                                          image: AssetImage(
                                              '${assetImagePath}wind.png')),
                                      const SizedBox(width: 5),
                                      Text(
                                          '${currentWeatherModel.windSpeed.round()} mph',
                                          style: TextStyle(          color: Colors.black,fontSize: 14.sp)),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Row(
                                    children: [
                                      const Image(
                                          image: AssetImage(
                                              '${assetImagePath}sunset.png')),
                                      const SizedBox(width: 5),
                                      Text(
                                          DateFormat('H:m').format(
                                              currentWeatherModel.sunset
                                                  .toLocal()),
                                          style: TextStyle(color: Colors.black,fontSize: 14.sp)),
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
          ),
        ));
  }
}
