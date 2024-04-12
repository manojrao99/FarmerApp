import 'dart:async';
import 'dart:core';
import 'dart:core';
import 'package:cultyvate/kuwaitproject/screens/radiobutton.dart';
import 'package:cultyvate/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../commonwidgets/Error_class_with_image.dart';
import '../../network/authservice.dart';
import '../../ui/dashboard/webview.dart';
import '../../ui/login/choose_language.dart';
import '../../ui/login/login.dart';
import '../../ui/notifications/notifications.dart';
import '../../utils/styles.dart';
import '../../utils/constants.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/controller.dart';
import '../controllers/deviceevent.dart';
import '../controllers/radiobuttoncontroller.dart';
import '../controllers/timerbloc.dart';
import '../controllers/userstare.dart';
import '../models/modelclass.dart';
const assetImagePath = 'assets/images/';
class WeaterDevices extends StatelessWidget {
  final String utc;
  final int farmerid;
  final UserBloc itemCubit = UserBloc();
  final RadioButtonCubit radiocubit=RadioButtonCubit();
   WeaterDevices({required this.utc,required this.farmerid});

  @override
  Widget build(BuildContext context) {

    return    Scaffold(
      body:


      MultiBlocProvider(
          providers: [


        BlocProvider<RadioButtonCubit>(
          create: (context) => RadioButtonCubit(),
        ),
        BlocProvider<UserBloc>(
        create: (context) => UserBloc(),
    ),

    ], child:  MyHomePage(utc: utc,title: utc,farmerid: farmerid),
    ),


    );
  }
}







class UserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('User List'),
          ),
          body: UserList(),
        ),
      ),
    );
  }
}

class UserList extends StatefulWidget {
  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    // userBloc.add(FetchUsers(4877,userBloc));
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return Center(child: Text(state.toString())
          // CircularProgressIndicator()
          );
        } else if (state is UserLoaded) {
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(state.users[index].farmlandid.toString()),
                subtitle: Text(state.users[index].currenthumidity.toString()),
              );
            },
          );
        } else if (state is UserError) {
          return Center(child: Text(state.error));
        } else {
          return Center(child: Text("Unknown state"));
        }
      },
    );
  }
}








class MyHomePage extends StatefulWidget {
   MyHomePage({Key? key, required this.utc, required this.title,required this.farmerid}) : super(key: key);

  final int farmerid;
  final String title;
  final utc;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TimerBloc _timerBloc = TimerBloc();
  int initialTime = 9;
  int _counter = 0;
  String localTimeZone ='UTC';
  bool loading =false;
  bool addeddataoutside=false;
   List<farmer_kuwait> data=[];

  getTimeZone() async {
    try {
      localTimeZone =await FlutterNativeTimezone.getLocalTimezone();
      loading=false;
    } catch (e) {
      localTimeZone= 'UTC'; // Default to UTC if unable to determine the time zone
    }
  }
  Stopwatch stopWatch = Stopwatch();
  @override
  void initState() {
    context.read<UserBloc>().add(FetchUsers(farmerID: widget.farmerid));
    // widget.itemCubit.add();
    // getTimeZone();
    // TODO: implement initState
    super.initState();
  }
  // final List<String> deviceEUIIDs = widget.itemCubit.r;
  String convertUtcToLocalkuwait(String utcTime) {
    // Parse the UTC time string

    DateTime utcDateTime = DateTime.parse(utcTime);
    DateTime startDate = utcDateTime.toLocal();

    DateFormat localDateFormat = DateFormat('MMM d, yyyy');

    // Format the UTC time to the local time zone
    String localTime = localDateFormat.format(startDate);

    return localTime;
  }
  String convertUtcToTimeLocalkuwait(String utcTime) {
    // Parse the UTC time string

    DateTime utcDateTime = DateTime.parse(utcTime);
    DateTime startDate = utcDateTime.toLocal();

    DateFormat localDateFormat = DateFormat('h:mm a');

    // Format the UTC time to the local time zone
    String localTime = localDateFormat.format(startDate);

    return localTime;
  }

  Future<String> convertUtcToLocal(String utcTime) async {
    // final localTimeZone = await getTimeZone();
    final utcDateTime = tz.TZDateTime.parse(tz.getLocation(localTimeZone), utcTime);
    final formatter = DateFormat.yMMMMd().add_Hm(); // Customize the date format
    return formatter.format(utcDateTime);
  }
  // String formatDateTime(datetime) {
  //   final dateandtime =DateTime.parse(datetime);
  //   final formatter = DateFormat('MMM d, yyyy');
  //   return formatter.format(dateandtime);
  // }

  bool isTimeWithinOneHour(String utcDateTimeString) {
    // Parse the input UTC date and time string into a DateTime object
    DateTime dateTime = DateTime.parse(utcDateTimeString);
    print(dateTime);
    DateTime inputDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime.toString(), true).toUtc();

    // Get the current UTC time
    DateTime currentUtcTime = DateTime.now().toUtc();

    // Calculate the difference in milliseconds between the input time and current time
    int timeDifferenceMillis = inputDateTime.difference(currentUtcTime).inMilliseconds;

    // Check if the absolute difference is less than one hour (in milliseconds)
    return timeDifferenceMillis.abs() < Duration(hours: 1).inMilliseconds;
  }


  String calculateTimeDifference(String dateString) {
    DateTime utcDateTime = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(utcDateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      final monthsDifference = now.month - utcDateTime.month + (now.year - utcDateTime.year) * 12;
      return '$monthsDifference months ago';
    }
  }

  int initialSeconds = 15 * 60; // 15 minutes in seconds
  int currentSeconds = 15 * 60; // Initialize the timer with 15 minutes
  Timer? timer;
  int remainingTime = 0;
bool isStopWatchReset=false;
  void setTimerRemaining() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      // if (isScheduleRunning) {
      //   remainingTime = (5 * 60) - stopWatch.elapsed.inSeconds;
      // }
      // else if (action){
      //   remainingTime =(2 * 60) - stopWatch.elapsed.inSeconds;
      // }
      // else {
        remainingTime = (15 * 60) - stopWatch.elapsed.inSeconds;
      // }
      if (mounted) {
        setState(() {});
        if (remainingTime <= 0) {
          timer?.cancel();
          // widget.itemCubit.add ( UserDevicestatus(widget.itemCubit.deviceEUIIDs.toString(), widget.itemCubit.state) );
          // await getTelematics();
        }
      }
    });
  }
  bool drawerIsOpen = false;




  void resetStopWatch() {
    stopWatch.reset();
    stopWatch.start();
    setTimerRemaining();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentSeconds > 0) {
          currentSeconds--;
        } else {
          timer.cancel(); // Stop the timer when it reaches 0
        }
      });
    });
  }

  @override
  void dispose() {
    _timerBloc.dispose();
    // Cancel the timer when disposing of the widget
    debugPrint('Timer disposed');
    super.dispose();
  }

  // @override
  // void dispose() {
  //   timer?.cancel(); // Cancel the timer when disposing of the widget
  //   super.dispose();
  // }

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
  final GlobalKey<DrawerControllerState> _drawerKey =
  GlobalKey<DrawerControllerState>();
  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth *  0.030; // Adjust the factor as needed
    double fontSizeHeader = screenWidth  * 0.035;
    // String minutes = (currentSeconds ~/ 60).toString().padLeft(2, '0');
    // String seconds = (currentSeconds % 60).toString().padLeft(2, '0');
    return Scaffold(

        body:WillPopScope(
            onWillPop: _onWillPop,
            child: Material(
                child: Stack(
                    children: [

                      Material(
                        color:  cultLightGrey,
                        child: SafeArea(
                          child:Column(
                            mainAxisSize: MainAxisSize.max,
                    children: [
               Container(
                 height: MediaQuery.of(context).size.height * 0.14 ,
                 child: Column(
                   children: [
                     Container(
                       padding: EdgeInsets.all(20),
                       child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: [
                             InkWell(
                                 child: const Image(
                                     image: AssetImage(
                                         '${assetImagePath}hamburger.png')),
                                 onTap: () {
                                   (drawerIsOpen) ? closeDrawer() : openDrawer();
                                   // (drawerIsOpen) ? closeDrawer() : openDrawer();
                                 }),
                             SizedBox(
                               width: 40,
                             ),
                             SizedBox(
                               height:40,
                               child: const Image(
                                   image: AssetImage(
                                       '${assetImagePath}cultyvate.png')),
                             ),



                             IconButton(
                               onPressed: () async {
                                 // widget.itemCubit
                                 context.read<UserBloc>().add(FetchUsers(farmerID: widget.farmerid));
                                 // _timerBloc.fetchData(widget.itemCubit,data);

                                 // _timerBloc.restartTimer(9, widget.itemCubit);
                                 // timer?.cancel();
                                 // await getTelematics();
                               },
                               icon: const Icon(Icons.refresh),
                               iconSize: 30,
                             ),

                             SizedBox(
                               width: 10,
                             ),

                             InkWell(
                               onTap: () => Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                       builder: (context) => Notifications(
                                         farmerid: widget.farmerid,
                                       ))),


                               child: const Image(
                                   image: AssetImage(
                                       '${assetImagePath}bell.png')),
                             ),

                           ]),
                     ),
                     StreamBuilder<int>(
                       stream: _timerBloc.remainingTimeStream,
                       builder: (context, snapshot) {
                         if (snapshot.hasData) {
                           int remainingTime = snapshot.data!;
                           print(remainingTime/ 60);
                           print(remainingTime/60 <0.20);
                           if(remainingTime/60 < 0.20){
                             List<String> deviceEUIIDs=[];
                            deviceEUIIDs.addAll(data.map((element) {
                               return "'${element.deviceEUIID.toString()}'";
                             }).toList());
                             print(deviceEUIIDs);
                             String result = deviceEUIIDs.where((element) => element is String).join(', ');
                             context.read<UserBloc>().add(UserDevicestatus(telematicDataList: data,userbloc: context.read<UserBloc>(),deviceEUIIDs:result ));
                             // UserDevicestatus
                             // _timerBloc.fetchData(data);
                           }
                           return Text('Data refresh in' +
                               ' ' +
                               (remainingTime / 60).floor().toString() +
                               ':' +
                               ((remainingTime % 60).toString().length == 1
                                   ? '0' + (remainingTime % 60).toString()
                                   : (remainingTime % 60).toString()),
                             style:  TextStyle(
                                 fontSize: fontSize, color: Colors.orange,fontWeight: FontWeight.bold),
                           );
                         } else {
                           return Text('');
                         }
                       },
                     ),
                  ]
                 )
               ),
                      SizedBox(height: 20,),

                      Container(
                        height: MediaQuery.of(context).size.height * 0.80 ,
                        child:  BlocBuilder<UserBloc, UserState>(
    builder: (context, state) {
                            // bloc: widget.itemCubit, // Provide the ItemCubit to BlocBuilder
                            // buildWhen: (previousState, currentState) {
                            //   // Check if the current state is ApiDataInitial
                            //   // and if it's not the initial page (you can set a boolean flag for this)
                            //   return currentState is! ApiDataInitial;
                            // },
                            // builder:(context, state) {
    print("state running1 ${state.runtimeType}");

    if (state is UserLoading) {
   return Container(
    child: Center(child:

    SpinKitCircle(
    itemBuilder: (BuildContext context, int index) {
    return const DecoratedBox(
    decoration: BoxDecoration(
    color: cultGreen,
    ),
    );
    },
    ),

    )
    );}


                              else if (state is UserLoaded) {
    if(!addeddataoutside){
      // state!.props=state.users;
    data.addAll(state.users);
    addeddataoutside=true;
    }
    print("state running ${state.runtimeType}");
    _timerBloc.restartTimer(900,context.read<UserBloc>());
    bool gatewayonline = state.users
        .where((element) => element.deviceTypeID == 19)
        .any((element) => isTimeWithinOneHour(element.sensordateandtime.toString()));

    return

    Container(
    decoration: const BoxDecoration(color: cultLightGrey),
    padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
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
    height:60,
    // width: ScreenUtil.defaultSize.width,
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    CircleAvatar(
    radius: 25,
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
    'Hello ${state.users.first.farmerName}',

    style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontSize: footerFont),
    ),

    ],
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    SizedBox(height:10),
    Stack(children: [
    Container(
    width: double.infinity,
    height:80,
    decoration: BoxDecoration(
    image: const DecorationImage(
    fit: BoxFit.cover,
    image:
    AssetImage('${assetImagePath}farm.png')),
    borderRadius: BorderRadius.circular(10)),
    ),
    Container(
    width: double.infinity,
    height:80,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Color.fromRGBO(17, 143, 128, .9)),
    ),
    Column(children: [
    SizedBox(height: 10),
    Row(
    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(width: 10),
    Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
    gatewayonline? const Image(
    image: AssetImage(
    '${assetImagePath}gateway.png'))
        : const Image(
    image: AssetImage(
    '${assetImagePath}gateway_red.png')),
    Padding(
    padding: const EdgeInsets.all(5.0),
    child: gatewayonline
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

    // const Image(
    //     image: AssetImage(
    //         '${assetImagePath}gateway.png')),
    //
    // Padding(
    //     padding: const EdgeInsets.all(5.0),
    //     child:Text("Online",
    //         style: TextStyle(
    //             color: Colors.white,
    //             fontSize: 12))

    // ),
    ],
    ),


    SizedBox(
    width: 20,
    ),


    RadioButtonWidget(radiocubit: context.read<RadioButtonCubit>()),

    ],

    ),

    ]),
    ]),

    Container (
    height: MediaQuery.of(context).size.height *0.65,
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.only(top: 20,bottom: 0),
    child: SingleChildScrollView(
    physics: ScrollPhysics(),
    child: BlocBuilder<RadioButtonCubit, RadioButtonOption>(
    builder: (context, box) {

    return ListView.builder(
    itemCount: state.users.length+1,
    controller: _scrollController,
    // physics: ,
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (BuildContext context, int index){


    // Calculate font size based on screen width and height

    try {

    if (index < state.users.length) {
    if (box == RadioButtonOption.onlineDevices) {
    if (state.users[index].deviceTypeID == 13 && isTimeWithinOneHour(
    state.users[index]
        .sensordateandtime
        .toString())) {
    DateTime time = DateTime.now();
    var datetimelocal = convertUtcToLocalkuwait(
    state.users[index]
        .sensordateandtime
        .toString());
    final formattedTime = convertUtcToTimeLocalkuwait(state.users[index]
        .sensordateandtime
        .toString());
    // var dateandtime = convertUtcToLocal('$time');
    // var datetimelocal=formatDateTime(dateandtime);
    return Card(
    elevation: 8,
    color: Colors.white,
    margin: EdgeInsets.only(
    left: 10, bottom: 10),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius
        .all(
    Radius.circular(10))
    ),
    child: Container(
    height: MediaQuery
        .of(context)
        .size
        .height * 0.25,
    width: MediaQuery
        .of(context)
        .size
        .width,
    child: Row(
    children: [
    Container(

    width: MediaQuery
        .of(context)
        .size
        .width * 0.38,
    decoration: BoxDecoration(
    border: Border(
    right: BorderSide(
    color:Colors.grey.shade400, // Specify the color you want for the border
    width: 1.0, // Specify the width of the border
    ),
    ),
    ),

    margin: EdgeInsets
        .only(left: 0),
    child: Padding(
    padding: EdgeInsets
        .only(
    left: 2),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment
        .start,
    children: [
    SizedBox(
    height: 10,),
    Padding(
    padding: EdgeInsets
        .only(
    left: 15),
    child: Row(
    children: [
    CircleAvatar(
    backgroundColor: Colors
        .grey,
    radius: 23,
    child: Image
        .asset(
    '${assetImagePath}level_sensor.png'),
    ),


    ],
    )),


    // Text("Status: Online",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),),
    Textrow(
    key: "ID",

    value: "${state.users[index]
        .deviceEUIID}", size: fontSize),
    Textrow(
    key: "Updated Date",
    value: datetimelocal !=
    '' ||
    datetimelocal !=
    null
    ? "${datetimelocal}"
        : "", size: fontSize),
    Textrow(
    key: "Updated Time",
    value: "${formattedTime}", size: fontSize),
    Textrow(
    key: "Location",
    value: "${state.users[index]
        .farmlandname}", size: fontSize),
    Textrow(
    key: "Warehouse",
    value: "${state.users[index]
        .alias}", size: fontSize),
    Textrow(
    key: "Mobile No",
    value: "${state.users[index]
        .mobileNumberPrimary}", size: fontSize),
    Textrow(
    key: "Last record",
    value: "${calculateTimeDifference(
    state.users[index].sensordateandtime
        .toString())}", size: fontSize),

    Text(isTimeWithinOneHour(
    state.users[index]
        .sensordateandtime
        .toString())
    ? "Online"
        : "Offline[${calculateTimeDifference(
    state.users[index].sensordateandtime
        .toString())}]", style: TextStyle(
    fontSize: fontSize,
    color: isTimeWithinOneHour(
    state.users[index]
        .sensordateandtime
        .toString()) ? Colors.green : Colors
        .red),),


    ],
    ),
    )
    ),


    Container(
    width: (MediaQuery
        .of(context)
        .size
        .width * 0.62) - 40,
    child: Row(
    children: [
    Container(

    child: Column(
    children: [
    SizedBox(
    height: MediaQuery.of(context).size.height *0.09,),
    Text(
    "Temp",style: TextStyle(fontSize: fontSizeHeader, color: Colors.black,fontWeight: FontWeight.bold),),
    SizedBox(
    height: 30,),

    Text(
    "Hum",style: TextStyle(fontSize: fontSizeHeader, color: Colors.black,fontWeight: FontWeight.bold),),
    ],
    ),
    margin: EdgeInsets.only(left: 4),
    ),

    Container(
    child: Column(
    children: [
    Container(
    height: MediaQuery.of(context).size.height *0.09,
    child: Row(

    children: [
    Container(

    child: Center(
    child: Text(
    "Current", maxLines: 1,
    style: TextStyle(fontSize: fontSizeHeader, color: Colors.black,fontWeight: FontWeight.bold),),
    ),
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    ),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "Max",
    style: TextStyle(fontSize: fontSizeHeader, color: Colors.black,fontWeight: FontWeight.bold),),
    ),
    ),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "Min",
    style: TextStyle(fontSize: fontSizeHeader, color: Colors.black,fontWeight: FontWeight.bold),),
    ),
    ),

    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceAround,
    ),
    ),
    Row(

    children: [
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "${state
        .users[index]
        .currenttempurature}°C",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(state
        .users[index]
        .maxtempurature != 0.0 ?
    "${state
        .users[index]
        .maxtempurature}°C" : "  _  ",
    style: TextStyle(
    color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(state
        .users[index]
        .mintempurature != 0.0 ?
    "${state
        .users[index]
        .mintempurature}°C" : "  _  ",
    style: TextStyle(
    color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),
    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceBetween,
    ),
    SizedBox(
    height: 30,),
    Row(

    children: [
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child:
    Text(
    "${state
        .users[index]
        .currenthumidity}%",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    state.users[index].maxhumidity != 0.0
    ?
    "${state.users[index].maxhumidity}%"
        : " _ ", style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    // SizedBox(
    //   width: 25,),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    state.users[index].minhumidity != 0.0
    ?
    "${state.users[index].minhumidity}%"
        : " _ ", style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceAround,
    ),

    ],
    ),
    )
    ],
    ),
    )
    ],
    ),
    ),
    );
    }

    else {
    return SizedBox();
    }
    }
    else if (box == RadioButtonOption.offlineDevices) {
    if (state.users[index].deviceTypeID == 13 && !isTimeWithinOneHour(
    state
        .users[index]
        .sensordateandtime
        .toString())) {
    DateTime time = DateTime.now();
    var datetimelocal = convertUtcToLocalkuwait(
    state.users[index]
        .sensordateandtime
        .toString());
    final formattedTime = convertUtcToTimeLocalkuwait(state.users[index]
        .sensordateandtime
        .toString());
    // var dateandtime = convertUtcToLocal('$time');
    // var datetimelocal=formatDateTime(dateandtime);
    return Card(
    elevation: 8,
    color: Colors.white,
    margin: EdgeInsets.only(
    left: 10, bottom: 10),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius
        .all(
    Radius.circular(10))
    ),
    child: Container(
    height: MediaQuery
        .of(context)
        .size
        .height * 0.25,
    width: MediaQuery
        .of(context)
        .size
        .width,
    child: Row(
    children: [
    Container(
    decoration: BoxDecoration(
    border: Border(
    right: BorderSide(
    color:Colors.grey.shade400, // Specify the color you want for the border
    width: 1.0, // Specify the width of the border
    ),
    ),
    ),
    width: MediaQuery
        .of(context)
        .size
        .width * 0.38,
    margin: EdgeInsets
        .only(left: 0),
    child: Padding(
    padding: EdgeInsets
        .only(
    left: 2),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment
        .start,
    children: [
    SizedBox(
    height: 10,),
    Padding(
    padding: EdgeInsets
        .only(
    left: 15),
    child: Row(
    children: [
    CircleAvatar(
    backgroundColor: Colors
        .grey,
    radius: 23,
    child: Image
        .asset(
    '${assetImagePath}level_sensor.png'),
    ),


    ],
    )),


    // Text("Status: Online",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),),
    Textrow(
    key: "ID",
    value: "${state
        .users[index]
        .deviceEUIID}", size: fontSize),
    Textrow(
    key: "Updated Date",
    value: datetimelocal !=
    '' ||
    datetimelocal !=
    null
    ? "${datetimelocal}"
        : "", size: fontSize),
    Textrow(
    key: "Updated Time",
    value: "${formattedTime}", size: fontSize),
    Textrow(
    key: "Location",
    value: "${state
        .users[index]
        .farmlandname}", size: fontSize),
    Textrow(
    key: "Warehouse",
    value: "${state
        .users[index]
        .alias}", size: fontSize),
    Textrow(
    key: "Mobile No",
    value: "${state
        .users[index]
        .mobileNumberPrimary}", size: fontSize),
    Textrow(
    key: "Last record",
    value: "${calculateTimeDifference(
    state.users[index].sensordateandtime
        .toString())}", size: fontSize),

    Text(isTimeWithinOneHour(
    state
        .users[index]
        .sensordateandtime
        .toString())
    ? "Online"
        : "Offline[${calculateTimeDifference(
    state.users[index].sensordateandtime
        .toString())}]", style: TextStyle(
    fontSize: fontSize,
    color: isTimeWithinOneHour(
    state
        .users[index]
        .sensordateandtime
        .toString()) ? Colors.green : Colors
        .red),),


    ],
    ),
    )
    ),


    Container(
    width: (MediaQuery
        .of(context)
        .size
        .width * 0.62) - 40,
    child: Row(
    children: [
    Container(
    margin: EdgeInsets.only(left: 4),
    child: Column(
    children: [
    SizedBox(
    height: MediaQuery.of(context).size.height *0.09,),
    Text(
    "Temp",style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    SizedBox(
    height: 30,),

    Text(
    "Hum",style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ],
    ),
    ),

    Container(
    child: Column(
    children: [
    Container(
    height: MediaQuery.of(context).size.height *0.09,
    child: Row(

    children: [
    Container(

    child: Center(
    child: Text(
    "Current", maxLines: 1,
    style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ),
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    ),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "Max",
    style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ),
    ),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "Min",
    style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ),
    ),

    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceAround,
    ),
    ),
    Row(

    children: [
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "${state
        .users[index]
        .currenttempurature}°C",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(state
        .users[index]
        .maxtempurature != 0.0 ?
    "${state
        .users[index]
        .maxtempurature}°C" : "  _  ",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(state
        .users[index]
        .mintempurature != 0.0 ?
    "${state
        .users[index]
        .mintempurature}°C" : "  _  ",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),
    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceBetween,
    ),
    SizedBox(
    height: 30,),
    Row(

    children: [
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child:
    Text(
    "${state.users[index]
        .currenthumidity}%",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    state.users[index].maxhumidity != 0.0
    ?
    "${state.users[index].maxhumidity}%"
        : " _ ", style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    // SizedBox(
    //   width: 25,),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    state.users[index].minhumidity != 0.0
    ?
    "${state.users[index].minhumidity}%"
        : " _ ", style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceAround,
    ),

    ],
    ),
    )
    ],
    ),
    )
    ],
    ),
    ),
    );
    }

    else {
    return SizedBox();
    }
    }
    else {
    if (state.users[index].deviceTypeID == 13) {
    DateTime time = DateTime.now();
    var datetimelocal = convertUtcToLocalkuwait(
    state.users[index]
        .sensordateandtime
        .toString());
    final formattedTime = convertUtcToTimeLocalkuwait(state.users[index]
        .sensordateandtime
        .toString());
    // var dateandtime = convertUtcToLocal('$time');
    // var datetimelocal=formatDateTime(dateandtime);
    return Card(
    elevation: 8,
    color: Colors.white,
    margin: EdgeInsets.only(
    left: 10, bottom: 10),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius
        .all(
    Radius.circular(10))
    ),
    child: Container(
    height: MediaQuery
        .of(context)
        .size
        .height * 0.25,
    width: MediaQuery
        .of(context)
        .size
        .width,
    child: Row(
    children: [
    Container(
    decoration: BoxDecoration(
    border: Border(
    right: BorderSide(
    color: Colors.grey.shade400, // Specify the color you want for the border
    width: 1.0, // Specify the width of the border
    ),
    ),
    ),
    width: MediaQuery
        .of(context)
        .size
        .width * 0.38,

    // color: isTimeWithinOneHour(
    //     state
    //         .props[index]
    //         .sensordateandtime
    //         .toString())
    //     ? Colors.green
    //     : Colors.red,
    margin: EdgeInsets
        .only(left: 0),
    child: Padding(
    padding: EdgeInsets
        .only(
    left: 2),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment
        .start,
    children: [
    SizedBox(
    height: 10,),
    Padding(
    padding: EdgeInsets
        .only(
    left: 15),
    child: Row(
    children: [
    CircleAvatar(
    backgroundColor: Colors
        .grey,
    radius: 23,
    child: Image
        .asset(
    '${assetImagePath}level_sensor.png'),
    ),


    ],
    )),


    // Text("Status: Online",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),),
    Textrow(
    key: "ID",
    value: "${state
        .users[index]
        .deviceEUIID}", size: fontSize),
    Textrow(
    key: "Updated Date",
    value: datetimelocal !=
    '' ||
    datetimelocal !=
    null
    ? "${datetimelocal}"
        : "", size: fontSize),
    Textrow(
    key: "Updated Time",
    value: "${formattedTime}", size: fontSize),
    Textrow(
    key: "Location",
    value: "${state
        .users[index]
        .farmlandname}", size: fontSize),
    Textrow(
    key: "Warehouse",
    value: "${state
        .users[index]
        .alias}", size: fontSize),
    Textrow(
    key: "Mobile No",
    value: "${state
        .users[index]
        .mobileNumberPrimary}", size: fontSize),
    Textrow(
    key: "Last record",
    value: "${calculateTimeDifference(
    state.users[index].sensordateandtime
        .toString())}", size: fontSize),

    Text(isTimeWithinOneHour(
    state
        .users[index]
        .sensordateandtime
        .toString())
    ? "Online"
        : "Offline[${calculateTimeDifference(
    state.users[index].sensordateandtime
        .toString())}]", style: TextStyle(
    fontSize: fontSize,
    color: isTimeWithinOneHour(
    state
        .users[index]
        .sensordateandtime
        .toString()) ? Colors.green : Colors
        .red),),


    ],
    ),
    )
    ),


    Container(
    width: (MediaQuery
        .of(context)
        .size
        .width * 0.62) - 40,
    child: Row(
    children: [
    Container(
    margin: EdgeInsets.only(left: 4),
    child: Column(
    children: [
    SizedBox(
    height: MediaQuery.of(context).size.height *0.09,),
    Text(
    "Temp",style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    SizedBox(
    height: 30,),
    Text(
    "Hum",style: TextStyle( color: Colors.black, fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ],
    ),
    ),

    Container(
    child: Column(
    children: [
    Container(
    height: MediaQuery.of(context).size.height *0.09,
    child: Row(

    children: [
    Container(

    child: Center(
    child: Text(
    "Current", maxLines: 1,
    style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ),
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    ),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "Max",
    style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ),
    ),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "Min",
    style: TextStyle( color: Colors.black,fontSize: fontSizeHeader,fontWeight: FontWeight.bold),),
    ),
    ),

    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceAround,
    ),
    ),
    Row(

    children: [
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    "${state
        .users[index]
        .currenttempurature}°C",

    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(state
        .users[index]
        .maxtempurature != 0.0 ?
    "${state
        .users[index]
        .maxtempurature}°C" : "  _  ",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(state
        .users[index]
        .mintempurature != 0.0 ?
    "${state
        .users[index]
        .mintempurature}°C" : "  _  ",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),
    )),
    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceBetween,
    ),
    SizedBox(
    height: 30,),
    Row(

    children: [
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child:
    Text(
    "${state.users[index]
        .currenthumidity}%",
    style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    state.users[index].maxhumidity != 0.0
    ?
    "${state.users[index].maxhumidity}%"
        : " _ ", style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    // SizedBox(
    //   width: 25,),
    Container(
    width: MediaQuery
        .of(context)
        .size
        .width * 0.14,
    child: Center(
    child: Text(
    state.users[index].minhumidity != 0.0
    ?
    "${state.users[index].minhumidity}%"
        : " _ ", style: TextStyle( color: Colors.black,
    fontSize: fontSize),maxLines: 1),)),

    ],
    mainAxisAlignment: MainAxisAlignment
        .spaceAround,
    ),

    ],
    ),
    )
    ],
    ),
    )
    ],
    ),
    ),
    );
    }

    else {
    return SizedBox();
    }
    }
    }
    else {
    return SizedBox(height: 40.0);
    } }catch(e){
    print("error in ui ${e}");
    return SizedBox();

    }
    });

    }
    )

    ),
    )


    ],
    ),
    );
    }
                              else if(state is UserError) {
    return  NoNetwork(imagepath: 'assets/images/DeviceNotfound.png',error:state.error,hight: MediaQuery.of(context).size.height/2);

    }
                              else{
    return  Container();
    }
                              //   case ApiDataFailure: final errorState = state as ApiDataFailure;
                              //   return  NoNetwork(imagepath: 'assets/images/DeviceNotfound.png',error:errorState.Error,hight: MediaQuery.of(context).size.height/2);
                              //
                              //   case ApiDataNetwork :
                              //     final errorState = state as ApiDataNetwork;
                              //     return NoNetwork(imagepath: 'assets/images/wifi.png',error:errorState.Error,hight: MediaQuery.of(context).size.height/2);
                              //   case ApiDataServerNotReachable:  final errorState = state as ApiDataServerNotReachable;
                              //   return NoNetwork(imagepath: 'assets/images/usbcable.png',error:errorState.Error,hight: MediaQuery.of(context).size.height/2);
                              //   default: return Container(
                              //     child: Text(state.runtimeType.toString()),
                              //   );
                              // }

                            }),
                      )
                  ],
                )







                        ),
                      ),


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
                              height:MediaQuery.of(context).size.height,
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
                                                            ?
                                                        // (widget.itemCubit.state.users.isNotEmpty ? widget.itemCubit.state.users[0]?.farmerName ?? '':"")
                                                        //     :widget.itemCubit.state.users.isNotEmpty ? widget.itemCubit.state.users[0]?.alias ??
                                                            '':"",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold,
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
                                                        style: TextStyle(  color: Colors.black,fontSize: fontSizeHeader),
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
                                                               widget.farmerid,
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
                                                        style: TextStyle(  color: Colors.black,fontSize: fontSizeHeader),
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
                                                        style: TextStyle(  color: Colors.black,fontSize: fontSizeHeader),
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
                                                                  farmerID:
                                                                 widget.farmerid,
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
                                                        style: TextStyle(  color: Colors.black,fontSize: fontSizeHeader),
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
                                                        style: TextStyle(  color: Colors.black,fontSize: fontSizeHeader),
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
                                                        style: TextStyle(  color: Colors.black,fontSize: fontSizeHeader),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    AuthService auth=AuthService();
                                                    auth.logout();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => Login()),
                                                    );
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
                                              height: ScreenUtil().setHeight(100),
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
                                                            style: TextStyle(  color: Colors.black,
                                                                fontSize: 12.sp),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            '+91 987 XXX XXXX',
                                                            style: TextStyle(  color: Colors.black,
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
                                                        style: TextStyle(  color: Colors.black,fontSize: 12.sp),
                                                      ),
                                                      Text("Version $versionglobaly" ,  style: TextStyle(  color: Colors.black,fontSize: 12.sp),)
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


                    ])))


    );
  }

  Widget Textrow({required String key,required String value, size}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$key :" ,style: TextStyle(fontSize: size,color: Colors.black),),
        // Text(":" ,style: TextStyle(fontSize: 14,color: Colors.white),),
        Expanded(child: Text(value,maxLines :1,style: TextStyle(fontSize: size,color: Colors.black),)),
      ],
    );
  }
  Future<bool> _onWillPop() async {
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
            Text("Do you want to logout?",style: TextStyle(color: Colors.black),),
          ],
        ),
        actions: [
          TextButton(
              child: Text("Yes",style: TextStyle(color: Colors.black),),
              onPressed: ()
            =>
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
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
  }
}
