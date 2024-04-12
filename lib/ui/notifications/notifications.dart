import 'package:cultyvate/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:time_machine/time_machine.dart' as tz;
import '../../models/notifications_model.dart';
import '../../services/notifications_service.dart';
import '../../utils/common_functions.dart';
import '../../utils/styles.dart';
import 'package:intl/intl.dart';
import 'package:time_machine/time_machine.dart' as tz;
import 'package:time_machine/time_machine.dart';
import 'package:flutter/services.dart';
class Notifications extends StatefulWidget {
  final int? farmerid;
  const Notifications({Key? key,this.farmerid}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with SingleTickerProviderStateMixin  {

  late TabController _tabController;
  List<NotificationsAll> urgent_notifications=[];
  List<NotificationsAll> action_notifications=[];
  List<NotificationsAll> information_notifications=[];
  List<NotificationsAll> iSchadule_notifications=[];
  bool isloading=false;
  late DateTimeZone getlocationusertime;

  @override
  void initState() {
    getlocation();
    getNotifications();
    super.initState();

    _tabController = new TabController(length: 4, vsync: this);

  }

  getlocation()async{
    await tz.TimeMachine.initialize({
      'rootBundle': rootBundle,
    });
  DateTimeZone.local.toString();
    var tzdb = await DateTimeZoneProviders.tzdb;


    var now = Instant.now();

    // if()
    getlocationusertime = await tzdb[DateTimeZone.local.toString()];
  }

  getTimeoflocal(dateandtime){
    DateTime dateTimee = DateTime.parse(dateandtime).toUtc();
    print("date sent on ${dateTimee}");


    // var taiInstant = tz.dateTimee.now(tz.UTC).toLocal();
    var now = Instant.dateTime(dateTimee);

    print('Hello, ${DateTimeZone.local}  ${now}from the Dart Time Machine!\n');

    var convertedtime='';
    bool isKolkataTime = DateTimeZone.local.toString() == 'Asia/Kolkata';
    print(isKolkataTime);
    print(DateTimeZone.local.toString()=='Asia/Kolkata');
    if(DateTimeZone.local.toString()=='Asia/Kolkata'){
      convertedtime = now.toString('dd-MM-yyyy HH:mm');
    }
    else {

      convertedtime = now.inZone(getlocationusertime).toString('dd-MM-yyyy HH:mm');
    }


    print("time converted ${convertedtime}");
    // var paris = tz.getLocation('Europe/Paris');

    // // Convert the input date and time to the target time zone
    // var convertedDateTime = tz.TZDateTime.from(dateTime, paris);
    //
    // // Format the converted date and time as a string
    // var convertedDateTimeString = tz.TZDateTime.from(dateTime, paris).toString();


    // var convertedenddate = dateTime.inZone(paris).toString('yyyy-MM-dd HH:mm');
    // var tzdb = await DateTimeZoneProviders.tzdb;
    return convertedtime;
  }

  DateFormate(String date){
    DateTime dateTime=DateTime.parse(date);

    return DateFormat('EE, MMM d, yyyy').format(dateTime);
  }

  // Widget NotificationsView(List<NotificationsAll> notifications){
  //    print("notifications length");
  //   return ListView.builder(
  //       itemCount: notifications.length,
  //       itemBuilder: (context, i){
  //
  //         print("date string ${notifications[i].sentOn.toString()}");
  //         DateTime dateTime = DateTime.parse(notifications[i].sentOn.toString());
  //         print(dateTime);
  //         String formattedString = DateFormat("dd-MM-yyyy hh:mm a").format(dateTime.toLocal());
  //
  //        print("notifications time ${formattedString}");
  //         String removeT=getTimeoflocal(notifications[i].sentOn.toString());
  //         DateTime parseDate =  DateFormat("yyyy-MM-dd'T'HH:mm").parse(notifications[i].sentOn.toString());
  //         // String Time = DateFormat('hh:mm a').format(parseDate);
  //
  //         double screenWidth = MediaQuery.of(context).size.width;
  //         double screenHeight = MediaQuery.of(context).size.height;
  //         // Location userLocation = tz.getLocation(tz.localName);
  //         // Calculate font size based on screen width and height
  //         double fontSize = screenWidth * screenHeight * 0.000038; // Adjust the factor as needed
  //
  //         String outputString = notifications[i].message!.replaceAll(RegExp(r'\s+'), ' ').trim();
  //
  //         print(outputString);
  //
  //         print("date ${parseDate.toLocal()}");
  //         return Card(
  //           elevation: 2,
  //           margin: EdgeInsets.only(left: 10,right: 10,top: 10),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                 margin: EdgeInsets.only(top: 5),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //
  //                 Padding(padding: EdgeInsets.only(left: 10),
  //                 child:    CircleAvatar(
  //                   backgroundColor: cultGreen,
  //                   child: Text(notifications[i].prossestype.toString()??""),
  //                 )
  //                 ) ,
  //                     SizedBox(width: 10),
  //                    Padding(padding: EdgeInsets.only(top: 10),
  //
  //                    child: notifications[i].prossestype=='SCH'? Text("Scheduler",style: TextStyle(color: Colors.black),):Text(""),
  //                    ),
  //
  //
  //                     Spacer(),
  //                     Text('${removeT}',style: TextStyle(fontSize: fontSize,fontWeight: FontWeight.bold,color: Colors.black)),
  //                     SizedBox(width: 10,),
  //
  //                   ],
  //                 ),
  //               ),
  //
  //               Container(
  //
  //                 child:Row(
  //                   children: [
  //                     SizedBox(width: 20,),
  //                     notifications[i].title ==null ?SizedBox():notifications[i].title=='T'?Text("Timer based",style: TextStyle(color: Colors.black),):notifications[i].title=='S'?Text("Sensor based",style: TextStyle(color: Colors.black),):notifications[i].title=='V'?Text("Volume based",style: TextStyle(color: Colors.black),):Text(notifications[i].title??"",style: TextStyle(fontSize: fontSize,fontWeight: FontWeight.bold,color: Colors.black),),
  //                     Spacer(),
  //                     notifications[i].headder ==null ?SizedBox(): Text(notifications[i].headder.toString(),style: TextStyle(fontSize: fontSize,fontWeight: FontWeight.bold,color: Colors.black),),
  //                     SizedBox(width: 30,),
  //                   ],
  //                 ),
  //               ),
  //
  //               Padding(
  //                 padding:
  //                 const EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Container(
  //                           width: ScreenUtil.defaultSize.width * 80 / 100,
  //                           child: Text(outputString.toString().i18n ,
  //                             overflow: TextOverflow.ellipsis,
  //                             softWrap: false,
  //                             maxLines: notifications[i].textvisuble==false? 2:80,
  //                             style: TextStyle(
  //                             color: Colors.black,
  //                               fontSize: 14.sp,
  //                             ),
  //                           ),
  //                         ),
  //
  //                         SizedBox(height: 5),
  //
  //                       ],
  //                     ),
  //                     outputString!.length >80?IconButton(
  //                       onPressed: () {
  //                         for(int index=0;index<outputString.length;index++){
  //                           if(i==index){
  //                             setState((){
  //                               if(notifications[i].textvisuble==true) {
  //                                 notifications[i].textvisuble = false;
  //
  //                               }
  //                               else notifications[i].textvisuble=true;
  //                             });
  //                           }
  //                           else{
  //                             print("index value else is $index");
  //                             setState((){
  //                               notifications[index].textvisuble=false;
  //                             });
  //                           }
  //                         }
  //
  //
  //                       },
  //                       icon:notifications[i].textvisuble==true? FaIcon(FontAwesomeIcons.chevronUp):FaIcon(FontAwesomeIcons.chevronDown),
  //                       iconSize: 15,
  //                     ):SizedBox()
  //                   ],
  //                 ),
  //               ),
  //               // Divider()
  //             ],
  //           ),
  //         );
  //       });
  // }
  Widget NotificationsView(List<NotificationsAll> notifications) {
    print("notifications length");
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, i) {
        print("date string ${notifications[i].sentOn.toString()}");
        DateTime dateTime = DateTime.parse(notifications[i].sentOn.toString());
        print(dateTime);
        String formattedString = DateFormat("dd-MM-yyyy hh:mm a").format(dateTime.toLocal());

        print("notifications time ${formattedString}");
        String removeT = getTimeoflocal(notifications[i].sentOn.toString());
        DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm").parse(notifications[i].sentOn.toString());

        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        double fontSize = screenWidth * screenHeight * 0.000038; // Adjust the factor as needed

        String outputString = notifications[i].message!.replaceAll(RegExp(r'\s+'), ' ').trim();
        print(outputString);

        return Card(
          elevation: 2,
          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                        backgroundColor: cultGreen,
                        child: Text(notifications[i].prossestype.toString() ?? ""),
                      ),
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: notifications[i].prossestype == 'SCH'
                          ? Text("Scheduler", style: TextStyle(color: Colors.black))
                          : Text(""),
                    ),
                    Spacer(),
                    Text('${removeT}', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    notifications[i].title == null
                        ? SizedBox()
                        : (notifications[i].title == 'T'
                        ? Text("Timer based", style: TextStyle(color: Colors.black))
                        : (notifications[i].title == 'S'
                        ? Text("Sensor based", style: TextStyle(color: Colors.black))
                        : (notifications[i].title == 'V'
                        ? Text("Volume based", style: TextStyle(color: Colors.black))
                        : Text(notifications[i].title ?? "", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black))))),
                    Spacer(),
                    notifications[i].headder == null
                        ? SizedBox()
                        : Text(notifications[i].headder.toString(), style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(width: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.78,
                          child: Text(
                            outputString.toString().i18n,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: notifications[i].textvisuble == false ? 1 : 45,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                    outputString!.length > 40
                        ? IconButton(
                      onPressed: () {
                        for (int index = 0; index < outputString.length; index++) {
                          if (i == index) {
                            setState(() {
                              if (notifications[i].textvisuble == true) {
                                notifications[i].textvisuble = false;
                              } else
                                notifications[i].textvisuble = true;
                            });
                          } else {
                            print("index value else is $index");
                            setState(() {
                              notifications[index].textvisuble = false;
                            });
                          }
                        }
                      },
                      icon: notifications[i].textvisuble == true
                          ? FaIcon(FontAwesomeIcons.chevronUp)
                          : FaIcon(FontAwesomeIcons.chevronDown),
                      iconSize: 15,
                    )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: cultGreen,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: "Schedule"),
                  Tab( text: "Urgent".i18n),
                  Tab( text: "Action Required".i18n),
                  Tab( text: " Information".i18n),
                   ],
              ),
              title: const Text('Notifications'),
              leading: Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.chevronLeft,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )),
          body:isloading?Center(
              child: CircularProgressIndicator()
          ) :
          TabBarView(
              controller: _tabController,
              children: [
                NotificationsView(iSchadule_notifications),
                NotificationsView(urgent_notifications),
                NotificationsView(action_notifications),
                NotificationsView(information_notifications),


              ]),
        ));
  }
  Future<void> getNotifications() async {
    setState((){
      isloading=true;
    });
    NotificationsService notificationsService = NotificationsService();
    try {
      final responce = await notificationsService.getNotifications(int.parse(widget.farmerid.toString()));
      print("responce is ${responce}");
      for(int i=0;i<responce.length;i++){
        print("notification ${responce[i].message}");
        print("responce request ${responce[i].criticality=="2"}");
        print("responce request ${responce[i].prossestype!="SCH"}");
        print("notification ${responce[i].criticality=="2"&&responce[i].prossestype!="SCH"}");
        if(responce[i].criticality=="1"){
          urgent_notifications.add(responce[i]);
          if(responce[i].prossestype=="SCH") {
            print("notification ${responce[i]}");
            iSchadule_notifications.add(responce[i]);
          }
        }

        else if(responce[i].criticality=="2"){
          action_notifications.add(responce[i]);
          if(responce[i].prossestype=="SCH"){
            iSchadule_notifications.add(responce[i]);
          }
        }
        else if(responce[i].criticality=='3'){
          information_notifications.add(responce[i]);
          if(responce[i].prossestype=="SCH") {
            print("notification ${responce[i]}");
            iSchadule_notifications.add(responce[i]);
          }
        }
      }
      setState((){
        isloading=false;
      });
    }
    catch(e){
      setState((){
        isloading=false;
      });
      print("error $e");
    }
  }

}
