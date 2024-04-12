import 'package:cultyvate/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../utils/common_functions.dart';
import '../dashboard/dashboard.dart';
import './manage_schedule.dart';
import '../../utils/string_extension.dart';
import '../../services/irrigation_service.dart';
import '../../models/irrigation_schedule_model.dart';
import '../../models/farmer_profile.dart';

class ScheduleCalendar extends StatefulWidget {
   ScheduleCalendar(
      {required this.farmerID,
      required this.farmlandID,
        required this.farmlandname,
      required this.allBlocks,
         required this.farmlandselected,
      Key? key})
      : super(key: key);
  final int farmlandID;
  final String farmlandname;
  final List<Block> allBlocks;
  int farmlandselected;
  final int farmerID;
  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  Widget cardsColumn =
      Container(); // Card for the irrigation history + future schedule
  late int farmlandID;
  final calendarController = AdvancedCalendarController.today();
  // final _calendarControllerCustom =
  // AdvancedCalendarController(DateTime(2023, 10, 26));
  List<IrrigationScheduleModel> farmlandSchedules = [];
  List<String> scheduleDates = [];
  List<Widget> scheduleCards = [];
  List<DateTime> events = [];

  List<DateTime> listStringsToDates(List<String> dateStrings) {
    List<DateTime> returnList = [];
    for (String dateString in dateStrings) {
      DateTime eventDate = DateTime.parse(dateString);
      // if (returnList.contains(eventDate)) {
        returnList.add(DateTime.parse(dateString));
      // }
    }

    return returnList;
  }

  String toYMD(DateTime inputDate) {
    try {
      print("input date string ${inputDate.toString()}");
      String returnValue = inputDate.year.toString() +
          ((inputDate.month > 9)? inputDate.month.toString(): '0' + inputDate.month.toString()) +
          ((inputDate.day > 9)? inputDate.day.toString(): '0' + inputDate.day.toString());
      return returnValue;
    } catch (e) {
      print('Return ' + e.toString());
    }
    return '';
  }

  void updateWidgetColumns(DateTime selectedDate) {
    scheduleCards = [];

    if (farmlandSchedules.isNotEmpty && scheduleDates.contains(toYMD(selectedDate))) {
      for (int i = 0; i < farmlandSchedules.length; i++) {
        int position = 0;
        print(farmlandSchedules[i].DeleteYN);
        if (farmlandSchedules[i].scheduleType == 'W') {



          String weekDay = DateFormat('E').format(selectedDate);
          if (weekDay.length == 3) {
            switch (weekDay) {
              case 'Sun':
                position = 0;
                break;
              case 'Mon':
                position = 1;
                break;
              case 'Tue':
                position = 2;
                break;
              case 'Wed':
                position = 3;
                break;
              case 'Thu':
                position = 4;
                break;
              case 'Fri':
                position = 5;
                break;
              case 'Sat':
                position = 6;
                break;
            }
          }
          var todaydate= int.parse(toYMD(selectedDate));

          var curentdate=  int.parse(toYMD(farmlandSchedules[i].scheduleFromDate?? DateTime.now()));
          if (farmlandSchedules[i].scheduleWeeks!.split('').map((String text) => text).toList()[position] =='1' && curentdate <= todaydate) {



          print("lessthan ${curentdate<todaydate}");
            print('selected date is in delete ${farmlandSchedules[i].DeleteDate}');
            print('fromdate date is ${toYMD(farmlandSchedules[i].scheduleFromDate?? DateTime.now())}');
            print(toYMD(farmlandSchedules[i].scheduleFromDate ?? DateTime.now()));


print("today date ${todaydate}");


    //         if(farmlandSchedules[i].DeleteYN==true ){
    // // &&int.parse(toYMD(farmlandSchedules[i].DeleteDate??DateTime.now()))>todaydate
    //           print(int.parse(toYMD(farmlandSchedules[i].DeleteDate??DateTime.now())));
    //           print(curentdate);
    //           print(todaydate<int.parse(toYMD(farmlandSchedules[i].DeleteDate??DateTime.now())));
    //           print('todaydate ${todaydate}');
    //           print(todaydate);
    //           print(int.parse(toYMD(farmlandSchedules[i].DeleteDate??DateTime.now())));
    //           print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    //           Widget schedule = ScheduleCard(
    //             irrigationSchedule: farmlandSchedules[i],
    //             deleteSchedule: (int id) => deleteSchedule(id, context),
    //             editSchedule: (int id) => editSchedule(id, context),
    //           );
    //           scheduleCards.add(schedule);
    //         }
    //         else{
    //           if(farmlandSchedules[i].DeleteYN=!true ) {

            if(farmlandSchedules[i].DeleteYN==true && selectedDate!.isBefore(farmlandSchedules[i].DeleteDate??DateTime.now())){
              Widget schedule = ScheduleCard(
                irrigationSchedule: farmlandSchedules[i],
                deleteSchedule: (int id) => deleteSchedule(id, context),
                editSchedule: (int id) => editSchedule(id, context),
              );
              scheduleCards.add(schedule);
            }
            else {
              if (farmlandSchedules[i].DeleteYN == false) {
                Widget schedule = ScheduleCard(
                  irrigationSchedule: farmlandSchedules[i],
                  deleteSchedule: (int id) => deleteSchedule(id, context),
                  editSchedule: (int id) => editSchedule(id, context),
                );
                scheduleCards.add(schedule);
              }
            }
              // }
            // }



          }
        } else {
          if (toYMD(selectedDate) ==  toYMD(farmlandSchedules[i].scheduleFromDate ?? DateTime.now())) {
            Widget schedule = ScheduleCard(
              irrigationSchedule: farmlandSchedules[i],
              deleteSchedule: (id) => deleteSchedule(id, context),
              editSchedule: (id) => editSchedule(id, context),
            );
            scheduleCards.add(schedule);
            scheduleCards.add(SizedBox(height: 20.h));
          }
        }
        cardsColumn = Column(children: scheduleCards);
      }
    } else {
      cardsColumn = const SizedBox();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    farmlandID = widget.farmlandID;
    // Get Calendar data for future and past dates

    getScheduleDates(fromInit: true);

    // Listener trigerred on user selection of a data on calendar control
    calendarController.addListener(() {
      DateTime selectedDate = calendarController.value;
      updateWidgetColumns(selectedDate);

    });
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  Future<void> deleteSchedule(int id, BuildContext context) async {
    bool okCancel = false;
    AlertDialog dialog = AlertDialog(
      backgroundColor: cultLightGrey,
      title: Text(
        'Delete Schedule'.i18n,
        style: const TextStyle(
          color: Colors.black,
            fontSize: heading2Font, fontWeight: FontWeight.bold),
      ),
      content: Text("Do you really want to delete this schedule?".i18n,
          style: const TextStyle(  color: Colors.black,fontSize: bodyFont)),
      actions: [
        InkWell(
            onTap: () {
              okCancel = true;
              Navigator.pop(context);
            },
            child: Text('Delete'.i18n,
                style: const TextStyle(fontSize: bodyFont, color: cultRed))),
        SizedBox(width: 20.w),
        InkWell(
            onTap: () {
              okCancel = false;
              Navigator.pop(context);
            },
            child: Text('Cancel'.i18n,
                style: const TextStyle(fontSize: bodyFont, color: cultGreen))),
      ],
    );

    await showDialog(context: context, builder: (_) => dialog);

    if (okCancel) {
      await IrrigationService().deleteSchedule(id);
      await getScheduleDates();
    }

    updateWidgetColumns(calendarController.value);
    if (mounted) setState(() {});
  }

  Future<void> editSchedule(int id, BuildContext context) async {
    for (int i = 0; i < farmlandSchedules.length; i++) {
      if (id == farmlandSchedules[i].id) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManageSchedule(
                    schedule: farmlandSchedules[i],
                    farmlandname: widget.farmlandname,
                    allBlocks: widget.allBlocks,
                    farmlandID: farmlandID)));
        await getScheduleDates();
        updateWidgetColumns(calendarController.value);
      }
    }
  }

//   Future<void> getScheduleDates1({bool fromInit = false}) async {
//     events = [];
//     scheduleDates = [];
//     DateTime endDate;
//     farmlandSchedules = await IrrigationService().getSchedules(farmlandID);
//
//     if (farmlandSchedules.isNotEmpty) {
//       for (var i = 0; i < farmlandSchedules.length; i++) {
//         IrrigationScheduleModel irrigationSchedule = farmlandSchedules[i];
//         if ((irrigationSchedule.scheduleType ?? "") == "A") {
//           scheduleDates.add(
//               toYMD(irrigationSchedule.scheduleFromDate ?? DateTime.now()));
//         } else {
//           DateTime eventDate = DateTime.parse(irrigationSchedule.CreatDate.toString());
//           scheduleDates.add(toYMD(eventDate));
//           if (((irrigationSchedule.scheduleWeeks ?? "") != "") &&
//               (irrigationSchedule.scheduleWeeks!.length == 7)) {
//             List<String> weekdays = irrigationSchedule.scheduleWeeks!
//                 .split('') // split the text into an array
//                 .map((String text) => text)
//                 .toList();
//             // Schedule starts from today or specified date
//             DateTime startDate =
//                 irrigationSchedule.scheduleFromDate ?? DateTime.now();
//             scheduleDates.add(startDate.toString());
//             print("startDate ${startDate}");
//             // Schedule ends on specified date or last day of next month
//             //(max future view in Calendar)
//
//             DateTime monthEndDate =
//                 DateTime(DateTime.now().year, DateTime.now().month +2, 0);
//
//
//             if (irrigationSchedule.scheduleToDate != null) {
//               if (monthEndDate.compareTo(irrigationSchedule.scheduleToDate ?? monthEndDate) >
//                   0) {
//                 endDate = irrigationSchedule.scheduleToDate!;
//               } else {
//                 endDate = monthEndDate;
//               }
//             }
//             else {
//               if(irrigationSchedule.DeleteYN==true){
// if(irrigationSchedule.DeleteDate != null) {
//   print("delete date ${irrigationSchedule.DeleteDate}");
//   endDate = DateTime(
//       irrigationSchedule.DeleteDate!.year, irrigationSchedule.DeleteDate!.month,
//       irrigationSchedule.DeleteDate!.day);
// }
// else{
//   endDate = monthEndDate;
// }
//               print(""
//                   "fggdgg ${endDate}");
//             //
//               }else{
//                 endDate = monthEndDate;
//                 print("enddate ${endDate}");
//               }
//
//
//             }
//
//             DateTime monthStartDate =
//                 DateTime(DateTime.now().year, DateTime.now().month - 2, 0);
//
//             if (irrigationSchedule.scheduleFromDate != null) {
//
//
//               if (monthStartDate.compareTo(irrigationSchedule.scheduleFromDate!) <= 0) {
//                 startDate = irrigationSchedule.scheduleFromDate!;
//
//               } else {
//                 startDate = monthStartDate;
//               }
//             } else {
//               startDate = monthStartDate;
//             }
//             DateTime tempDate = startDate;
//             bool done = false;
//
//
//             while (!done) {
//               print(
//                   "date1}");
//               String weekDay = DateFormat('E').format(tempDate);
//               if (weekDay.length == 3) {
//                 switch (weekDay) {
//                   case 'Sun':
//                     weekdays[0] == '1'
//                         ? scheduleDates.add(toYMD(tempDate))
//                         : {};
//                     break;
//                   case 'Mon':
//                     weekdays[1] == '1'
//                         ? scheduleDates.add(toYMD(tempDate))
//                         : {};
//                     break;
//                   case 'Tue':
//                     weekdays[2] == '1'
//                         ? scheduleDates.add(toYMD(tempDate))
//                         : {};
//                     break;
//                   case 'Wed':
//                     weekdays[3] == '1'
//                         ? scheduleDates.add(toYMD(tempDate))
//                         : {};
//                     break;
//                   case 'Thu':
//                     weekdays[4] == '1'
//                         ? scheduleDates.add(toYMD(tempDate))
//                         : {};
//                     break;
//                   case 'Fri':
//                     weekdays[5] == '1'
//                         ? scheduleDates.add(toYMD(tempDate))
//                         : {};
//                     break;
//                   case 'Sat':
//                     weekdays[6] == '1'
//                         ? scheduleDates.add(toYMD(tempDate))
//                         : {};
//                     break;
//                 }
//                 print(
//                     "loop not stoped }");
//               }
//               if (tempDate.isBefore(endOfCurrentMonth)) {
//                 tempDate = tempDate.add(const Duration(days: 1));
//               } else {
//                 done = true;
//               }
//               if (toYMD(tempDate) == toYMD(endDate) ) done = true;
//               tempDate = tempDate.add(const Duration(days: 1));
//             }
//             print("staert and end ${startDate.toString() + " " + endDate.toString()}");
//           }
//         }
//       }
//     }
//     events = listStringsToDates(scheduleDates);
//     if (fromInit) updateWidgetColumns(DateTime.now());
//     if (mounted) setState(() {});
//   }
  Future<void> getScheduleDates({bool fromInit = false}) async {
    events = [];
    scheduleDates = [];
    DateTime? endDate;
    farmlandSchedules = await IrrigationService().getSchedules(farmlandID);

    if (farmlandSchedules.isNotEmpty) {
      for (var i = 0; i < farmlandSchedules.length; i++) {
        IrrigationScheduleModel irrigationSchedule = farmlandSchedules[i];
        if ((irrigationSchedule.scheduleType ?? "") == "A") {
          scheduleDates.add(toYMD(irrigationSchedule.scheduleFromDate ?? DateTime.now()));
        } else {
          DateTime eventDate = DateTime.parse(irrigationSchedule.CreatDate.toString());
          scheduleDates.add(toYMD(eventDate));

          if (((irrigationSchedule.scheduleWeeks ?? "") != "") && (irrigationSchedule.scheduleWeeks!.length == 7)) {
            List<String> weekdays = irrigationSchedule.scheduleWeeks!
                .split('') // split the text into an array
                .map((String text) => text)
                .toList();

            // Schedule starts from today or specified date
            DateTime startDate = irrigationSchedule.scheduleFromDate ?? DateTime.now();
            scheduleDates.add(startDate.toString());
            print("startDate ${startDate}");

            // Determine the end of the current month
            DateTime endOfCurrentMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

            // Schedule ends on specified date or last day of next month (max future view in Calendar)
            if (irrigationSchedule.scheduleToDate != null) {
              endDate = DateTime(
                irrigationSchedule.scheduleToDate!.year,
                irrigationSchedule.scheduleToDate!.month,
                irrigationSchedule.scheduleToDate!.day,
              ).isBefore(endOfCurrentMonth) ? irrigationSchedule.scheduleToDate : endOfCurrentMonth;
            } else {
              // Handle other cases for determining the end date
              if (irrigationSchedule.DeleteYN == true) {
                if (irrigationSchedule.DeleteDate != null) {
                  print("delete date ${irrigationSchedule.DeleteDate}");
                  endDate = DateTime(
                    irrigationSchedule.DeleteDate!.year,
                    irrigationSchedule.DeleteDate!.month,
                    irrigationSchedule.DeleteDate!.day,
                  );
                } else {
                  endDate = endOfCurrentMonth;
                }
                print("fggdgg ${endDate}");
              } else {
                endDate = endOfCurrentMonth;
                print("enddate ${endDate}");
              }
            }

            // Determine the start date
            DateTime monthStartDate = DateTime(DateTime.now().year, DateTime.now().month - 2, 0);
            if (irrigationSchedule.scheduleFromDate != null) {
              startDate = monthStartDate.compareTo(irrigationSchedule.scheduleFromDate!) <= 0
                  ? irrigationSchedule.scheduleFromDate!
                  : monthStartDate;
            } else {
              startDate = monthStartDate;
            }

            DateTime tempDate = startDate;
            bool done = false;

            while (!done) {
              print("date1}");
              String weekDay = DateFormat('E').format(tempDate);
              if (weekDay.length == 3) {
                switch (weekDay) {
                  case 'Sun':
                    weekdays[0] == '1'
                        ? scheduleDates.add(toYMD(tempDate))
                        : {};
                    break;
                  case 'Mon':
                    weekdays[1] == '1'
                        ? scheduleDates.add(toYMD(tempDate))
                        : {};
                    break;
                  case 'Tue':
                    weekdays[2] == '1'
                        ? scheduleDates.add(toYMD(tempDate))
                        : {};
                    break;
                  case 'Wed':
                    weekdays[3] == '1'
                        ? scheduleDates.add(toYMD(tempDate))
                        : {};
                    break;
                  case 'Thu':
                    weekdays[4] == '1'
                        ? scheduleDates.add(toYMD(tempDate))
                        : {};
                    break;
                  case 'Fri':
                    weekdays[5] == '1'
                        ? scheduleDates.add(toYMD(tempDate))
                        : {};
                    break;
                  case 'Sat':
                    weekdays[6] == '1'
                        ? scheduleDates.add(toYMD(tempDate))
                        : {};
                    break;
                }
                print("loop not stopped }");
              }

              // Check if tempDate is before the end of the current month
              if (tempDate.isBefore(endOfCurrentMonth)) {
                tempDate = tempDate.add(const Duration(days: 1));
              } else {
                done = true;
              }
            }
            print("start and end ${startDate.toString() + " " + endDate.toString()}");
          }
        }
      }
    }

    events = listStringsToDates(scheduleDates);
    if (fromInit) updateWidgetColumns(DateTime.now());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Dashboard(farmerID: widget.farmerID,selectedID: widget.farmlandselected)));
        return Future.value(true);
      },
      child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: SafeArea(
                child: Container(
                  color: cultLightGrey,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: cultGreen,
                      title: Text('Irrigation Schedule'.i18n),
                      // leading: InkWell(
                      //     onTap: () => Navigator.of(context).pushReplacement(
                      //         MaterialPageRoute(builder: (context) => Dashboard(farmerID: widget.farmerID,selectedID: widget.farmlandselected,
                      //
                      //
                      //         ))),
                      //     child: const FaIcon(
                      //       FontAwesomeIcons.chevronLeft,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      leading: Padding(
                        padding: EdgeInsets.all(20.r),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Dashboard(farmerID: widget.farmerID,selectedID: widget.farmlandselected,


                    ))),
                          child: const FaIcon(
                            FontAwesomeIcons.chevronLeft,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      actions: [
                        InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ManageSchedule(
                                  farmlandname: widget.farmlandname,
                                    allBlocks: widget.allBlocks,
                                    farmlandID: farmlandID)));
                            await getScheduleDates(fromInit: true);
                          },
                          child: const Image(
                            image:
                                AssetImage('assets/images/calendar_plus.png'),
                          ),
                        )
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Positioned(
                              child: Container(
                                  height: ScreenUtil.defaultSize.height,
                                  width: ScreenUtil.defaultSize.width,
                                  decoration:
                                      BoxDecoration(color: Colors.white)),
                              top: 0,
                              left: 0),
                          Container(
                            decoration: BoxDecoration(color: Colors.white),
                            padding: EdgeInsets.all(10.r),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Theme(
                                  data: ThemeData.light().copyWith(
                                    backgroundColor: Colors.white,
                                    textTheme:
                                        ThemeData.light().textTheme.copyWith(
                                              subtitle1: ThemeData.light()
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                    fontSize: bodyFont,
                                                    color: Colors.white,
                                                  ),
                                              bodyText1: ThemeData.light()
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                    fontSize: footerFont,
                                                    color: Colors.white,
                                                  ),
                                              bodyText2: ThemeData.light()
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                    fontSize: footerFont,
                                                    color: cultBlack,
                                                  ),
                                            ),
                                    primaryColor: cultGreen,
                                    secondaryHeaderColor: Colors.blueGrey,
                                    highlightColor: Colors.blue,

                                    disabledColor: cultLightGrey,
                                  ),
                                  child: AdvancedCalendar(
                                    controller: calendarController,
                                    events: events,



                                    // weeksInMonthViewAmount: 6,
                                    weekLineHeight: 45.0,

// dateStyle: ,
                                    // calendarTextStyle: TextStyle(
                                    //     fontSize: 16.sp, color: cultGreen),
                                      headerStyle:TextStyle(
                                            fontSize: 16.sp, color: cultGreen),
                                    todayStyle: TextStyle(
                                        fontSize: 16.sp, color: Colors.blue),
                                    preloadMonthViewAmount: 4,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                cardsColumn,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}





class ScheduleCard extends StatelessWidget {
  const ScheduleCard(
      {required this.irrigationSchedule,
      required this.deleteSchedule,
      required this.editSchedule,
      Key? key})
      : super(key: key);
  final IrrigationScheduleModel irrigationSchedule;
  final Function deleteSchedule;
  final Function editSchedule;

  @override
  Widget build(BuildContext context) {
    String hour = (irrigationSchedule.scheduleTime!.hour == 0)
        ? '00'
        : (irrigationSchedule.scheduleTime!.hour < 9)
            ? '0' + irrigationSchedule.scheduleTime!.hour.toString()
            : irrigationSchedule.scheduleTime!.hour.toString();
    String minutes = (irrigationSchedule.scheduleTime!.minute == 0)
        ? '00'
        : (irrigationSchedule.scheduleTime!.minute < 9)
            ? '0' + irrigationSchedule.scheduleTime!.minute.toString()
            : irrigationSchedule.scheduleTime!.minute.toString();
    return Column(children: [

      Container(
        height: ScreenUtil().setHeight(80.h),
        decoration: BoxDecoration(
            color: cultLightGrey,
            border: Border.all(color: cultGrey, width: 0.5),
            borderRadius: BorderRadius.circular(5.r)),
        padding: EdgeInsets.all(5.r),
        margin: EdgeInsets.only(bottom: 5.h),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 5.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 5.h),


                  ( irrigationSchedule.ScheduleActiveYN==true ||irrigationSchedule!.DeleteYN==true  ) ? SizedBox():InkWell(
                    onTap: () => editSchedule(irrigationSchedule.id),
                    child: FaIcon(
                      FontAwesomeIcons.penToSquare,
                      color: cultGreen,
                      size: 15.r,
                    ),
                  ),

                  ( irrigationSchedule.ScheduleActiveYN==true ||irrigationSchedule!.DeleteYN==true  ) ? SizedBox(): InkWell(
                    onTap: () => deleteSchedule(irrigationSchedule.id),
                    child: FaIcon(
                      FontAwesomeIcons.trash,
                      color: cultRed,
                      size: 15.r,
                    ),
                  ),
                  SizedBox(height: 5.h),


                ],
              ),
              SizedBox(width: 5.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      (irrigationSchedule.scheduleType == 'W'
                              ? "Weekly"
                              : "One - Time")
                          .i18n,
                      style: TextStyle(
                          color: cultGrey,
                          fontSize: footerFont.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 5.h,
                  ),
                  (irrigationSchedule.scheduleIrrigationType != 'S') ? Text('Start Time: '.i18n + ' ' + hour + ':' + minutes,
                      style:
                          TextStyle(fontSize: footerFont.sp, color: cultGrey)):SizedBox(),
                  SizedBox(height: 2.h),
                  (irrigationSchedule.scheduleIrrigationType == 'T')
                      ? Text(
                          'Duration: '.i18n +
                              (irrigationSchedule.scheduleIrrigationValue ?? 0)
                                  .round()
                                  .toString() +
                              ' mins'.i18n,
                          style: TextStyle(
                              fontSize: footerFont.sp, color: cultGrey))
                      : (irrigationSchedule.scheduleIrrigationType == 'V')
                          ? Text(
                              'Volume: '.i18n +
                                  (irrigationSchedule.scheduleIrrigationValue ??
                                          0.0)
                                      .round()
                                      .toString() +
                                  ' liters'.i18n,
                              style: TextStyle(
                                  fontSize: footerFont.sp, color: cultGrey))
                          :  Text(
                      'Sensor threshold: '.i18n+'\n Lower '+
                          (irrigationSchedule.scheduleSoilMoistureLow ??
                              0.0)
                              .round()
                              .toString()+'%' +
                          ' Upper '+ (irrigationSchedule.scheduleSoilMoistureHigh ??
                              0.0)
                              .round()
                              .toString()+'%'. i18n,
                      style: TextStyle(
                          fontSize: footerFont.sp, color: cultGrey)),

                  ((irrigationSchedule!.DeleteYN) ??false|| (irrigationSchedule.ScheduleActiveYN??false || irrigationSchedule.DeleteDate!=null ))? irrigationSchedule.DeleteDate ==null?Text("Deleted",style: TextStyle(
    fontSize: footerFont.sp, color: cultRed)):Text("Deleted on(${Dateformatschduler(datetime: irrigationSchedule.DeleteDate.toString()??"")})" , style: TextStyle(
    fontSize: footerFont.sp, color: cultRed)):SizedBox()

                ],
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select block sequence'.i18n,
                      style: TextStyle(
                        color:Colors.black,
                          fontSize: footerFont.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10.h,
                  ),
                  SizedBox(
                    width: ScreenUtil.defaultSize.width * 45 / 100,
                    child: Text(irrigationSchedule.farmerBlockLinkedNames ?? "",
                        maxLines: 3,
                        style: TextStyle(
                            fontSize: footerFont.sp, color: cultGrey)),
                  )
                ],
              ),
            ]),
      ),
    ]);
  }
}
