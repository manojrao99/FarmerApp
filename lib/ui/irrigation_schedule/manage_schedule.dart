import 'package:cultyvate/services/irrigation_service.dart';
import 'package:cultyvate/utils/flutter_toast_util.dart';
import 'package:cultyvate/utils/waterflow_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/irrigation_schedule_model.dart';
import '../../utils/string_extension.dart';
import '../../utils/styles.dart';
import '../../models/farmer_profile.dart';
import '../../utils/constants.dart';

enum Mode { add, edit }

BoxDecoration selectedDecoration = BoxDecoration(
    color: cultGreenOpacity,
    border: Border.all(color: cultBlack),
    borderRadius: BorderRadius.circular(10.r));

BoxDecoration unSelectedDecoration = BoxDecoration(
    border: Border.all(color: cultSoftGrey),
    borderRadius: BorderRadius.circular(10.r));

class ManageSchedule extends StatefulWidget {
  const ManageSchedule(
      {this.schedule,
        required this.farmlandname,
      required this.allBlocks,
      required this.farmlandID,
      Key? key})
      : super(key: key);
  final IrrigationScheduleModel? schedule;
  final List<Block> allBlocks;
  final String farmlandname;
  final int farmlandID;

  @override
  State<ManageSchedule> createState() => _ManageScheduleState();
}

class _ManageScheduleState extends State<ManageSchedule>
    with SingleTickerProviderStateMixin {

  TextEditingController schedulename=new TextEditingController();
  List<Widget> blocks = [];
  String irrigationType = 'T';
  double irrigationValue = 0;
  double irrigationValueFrom = 0;
  double irrigationValueTo = 0;
  Mode mode = Mode.add;
  IrrigationScheduleModel? schedule;
  List<String> weeklyBits = [
    '0',
    '0',
    '0',
    '0',
    '0',
    '0',
    '0',
  ];
  List<Widget> weekContainers = [];
  List<int> selectedBlocks = [];
  String selectedIds = '';
  TextEditingController? scheduleStartTime;
  TimeOfDay time = const TimeOfDay(hour: 0, minute: 0);
  String timeText = '00:00';
  late TabController controller;
  int selectedIndex = 0;
  bool weeklySchedule = true;
  bool setTimeClicked = false;
  int soilL1 = 0;
  int soilL2 = 0;
  int soilL3 = 0;
  int soilL4 = 0;
  bool showWeeklyContainers = false;
  List<IrrigationScheduleModel>? schedules ;
  bool loading =false;
  activeshadules(farmlandID)async{
    schedules=[];
    print("calling");
    setState((){
      loading=true;
    });

      schedules = await IrrigationService().getactiveshadule(farmlandID);


   print("schadule ${schedules}") ;
   setState((){
      loading=false;
    });
  }

  @override
  void initState() {
    super.initState();
    activeshadules(widget.farmlandID);
    schedulename.text=widget.farmlandname;
    schedule = widget.schedule;

    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      if (controller.indexIsChanging) {
        switch (controller.index) {
          case 0:
            if (irrigationType != 'S') {
              showWeeklyContainers = true;
              weeklySchedule = true;
            }
            break;
          case 1:
            showWeeklyContainers = false;
            weeklySchedule = false;
            break;
        }
      }
      setState(() {});
    });

    if (schedule == null) {
      scheduleType = 'W';
      showWeeklyContainers = true;
      mode = Mode.add;
    } else {
      setTimeClicked = true;
      mode = Mode.edit;
      List<String> ids = (schedule!.farmerBlockLinkedIDs ?? '').split(',');
      for (int i = 0; i < ids.length; i++) {
        int id = int.tryParse(ids[i]) ?? 0;
        selectedBlocks.add(id);
      }
      if (schedule?.scheduleType == 'A' ||
          schedule?.scheduleIrrigationType == 'S') {
        weeklySchedule = false;
        showWeeklyContainers = false;
        soilL1=schedule?.soilL1??0;
        soilL2=schedule?.soilL2??0;
        soilL3=schedule?.soilL3??0;
        soilL4=schedule?.soilL4??0;
        irrigationValueFrom=schedule!.scheduleSoilMoistureLow??0;
        irrigationValueTo=schedule!.scheduleSoilMoistureHigh??0;



      } else {
        weeklySchedule = true;
        showWeeklyContainers = true;
      }

      if (!weeklySchedule) controller.animateTo(1);
      time = schedule!.scheduleTime ?? const TimeOfDay(hour: 0, minute: 0);
      updateUIEdit();
      // setState(() {});
    }
  }

  void updateSelectedList(List<int> selectedBlocksFromWidget) {
    selectedBlocks = selectedBlocksFromWidget;
  }

  void updateTimerBased(double minutes) {
    irrigationType = 'T';
    irrigationValue = minutes;
    setState(() {});
  }

  void updateVolumeBased(double liters) {
    irrigationType = 'V';
    irrigationValue = liters;
    if (controller.index == 0) {
      showWeeklyContainers = true;
    }
    setState(() {});
  }

  void updateSoilBased(
      double top, double bottom, int l1, int l2, int l3, int l4) {
    irrigationType = 'S';
    irrigationValueFrom = top;
    irrigationValueTo = bottom;
    soilL1 = l1;
    soilL2 = l2;
    soilL3 = l3;
    soilL4 = l4;
    showWeeklyContainers = false;
    setState(() {});
  }

  void updateIrrigationType(String type) {
    irrigationType = type;
    if (irrigationType == 'S') {
      showWeeklyContainers = false;
    } else {
      controller.index == 0
          ? showWeeklyContainers = true
          : showWeeklyContainers = false;
    }
    setState(() {});
  }

  void updateUIEdit() {
    scheduleStartTime?.text =
        (schedule!.scheduleIrrigationValue ?? 0).toString();
    String hour = (schedule!.scheduleTime!.hour == 0)
        ? '00'
        : (schedule!.scheduleTime!.hour < 9)
            ? '0' + schedule!.scheduleTime!.hour.toString()
            : schedule!.scheduleTime!.hour.toString();
    String minutes = (schedule!.scheduleTime!.minute == 0)
        ? '00'
        : (schedule!.scheduleTime!.minute < 9)
            ? '0' + schedule!.scheduleTime!.minute.toString()
            : schedule!.scheduleTime!.minute.toString();

    timeText = hour + ':' + minutes;
    irrigationValue = (schedule!.scheduleIrrigationValue ?? 0);
    weeklyBits = (schedule!.scheduleWeeks ?? '').split('');
    if (schedule!.scheduleIrrigationType == 'V') {
      updateVolumeBased(schedule!.scheduleIrrigationValue ?? 0);
    } else if (schedule!.scheduleIrrigationType == 'T') {
      updateTimerBased(schedule!.scheduleIrrigationValue ?? 0);
    } else {
      updateSoilBased(
          (schedule!.scheduleSoilMoistureLow ?? 0),
          (schedule!.scheduleSoilMoistureHigh ?? 0),
          schedule!.soilL1,
          schedule!.soilL2,
          schedule!.soilL3,
          schedule!.soilL4);
    }
    setState(() {});
  }

  void buildWeekdayContainers() {
    weekContainers = [];
    if (weeklySchedule && irrigationType != 'S') {
      weekContainers.add(InkWell(
        onTap: () {
          String bit = weeklyBits[0];
          if (bit == '0') {
            bit = '1';
          } else {
            bit = '0';
          }
          weeklyBits[0] = bit;
          setState(() {});
        },
        child: Container(
            height: 40.h,
            width: 40.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: (weeklyBits[0] == '1')
                ? selectedDecoration
                : unSelectedDecoration,
            child: Center(
                child: Text('Sun'.i18n,
                    style: (weeklyBits[0] == '1')
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : const TextStyle(color: cultSoftGrey)))),
      ));

      weekContainers.add(InkWell(
        onTap: () {
          String bit = weeklyBits[1];
          if (bit == '0') {
            bit = '1';
          } else {
            bit = '0';
          }
          weeklyBits[1] = bit;
          setState(() {});
        },
        child: Container(
            height: 40.h,
            width: 40.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: (weeklyBits[1] == '1')
                ? selectedDecoration
                : unSelectedDecoration,
            child: Center(
                child: Text('Mon'.i18n,
                    style: (weeklyBits[1] == '1')
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : const TextStyle(color: cultSoftGrey)))),
      ));

      weekContainers.add(InkWell(
        onTap: () {
          String bit = weeklyBits[2];
          if (bit == '0') {
            bit = '1';
          } else {
            bit = '0';
          }
          weeklyBits[2] = bit;
          setState(() {});
        },
        child: Container(
            height: 40.h,
            width: 40.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: (weeklyBits[2] == '1')
                ? selectedDecoration
                : unSelectedDecoration,
            child: Center(
                child: Text('Tue'.i18n,
                    style: (weeklyBits[2] == '1')
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : const TextStyle(color: cultSoftGrey)))),
      ));

      weekContainers.add(
        InkWell(
            onTap: () {
              String bit = weeklyBits[3];
              if (bit == '0') {
                bit = '1';
              } else {
                bit = '0';
              }
              weeklyBits[3] = bit;
              setState(() {});
            },
            child: Container(
                height: 40.h,
                width: 40.h,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: (weeklyBits[3] == '1')
                    ? selectedDecoration
                    : unSelectedDecoration,
                child: Center(
                    child: Text('Wed'.i18n,
                        style: (weeklyBits[3] == '1')
                            ? TextStyle(fontWeight: FontWeight.bold)
                            : TextStyle(color: cultSoftGrey))))),
      );

      weekContainers.add(InkWell(
        onTap: () {
          String bit = weeklyBits[4];
          if (bit == '0') {
            bit = '1';
          } else {
            bit = '0';
          }
          weeklyBits[4] = bit;
          setState(() {});
        },
        child: Container(
            height: 40.h,
            width: 40.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: (weeklyBits[4] == '1')
                ? selectedDecoration
                : unSelectedDecoration,
            child: Center(
                child: Text('Thu'.i18n,
                    style: (weeklyBits[4] == '1')
                        ? TextStyle(fontWeight: FontWeight.bold)
                        : TextStyle(color: cultSoftGrey)))),
      ));

      weekContainers.add(InkWell(
        onTap: () {
          String bit = weeklyBits[5];
          if (bit == '0') {
            bit = '1';
          } else {
            bit = '0';
          }
          weeklyBits[5] = bit;
          setState(() {});
        },
        child: Container(
            height: 40.h,
            width: 40.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: (weeklyBits[5] == '1')
                ? selectedDecoration
                : unSelectedDecoration,
            child: Center(
                child: Text('Fri'.i18n,
                    style: (weeklyBits[5] == '1')
                        ? TextStyle(fontWeight: FontWeight.bold)
                        : TextStyle(color: cultSoftGrey)))),
      ));

      weekContainers.add(InkWell(
        onTap: () {
          String bit = weeklyBits[6];
          if (bit == '0') {
            bit = '1';
          } else {
            bit = '0';
          }
          weeklyBits[6] = bit;
          setState(() {});
        },
        child: Container(
            height: 40.h,
            width: 40.h,
            margin: EdgeInsets.only(left: 3.w),
            decoration: (weeklyBits[6] == '1')
                ? selectedDecoration
                : unSelectedDecoration,
            child: Center(
                child: Text('Sat'.i18n,
                    style: (weeklyBits[6] == '1')
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : const TextStyle(color: cultSoftGrey)))),
      ));
    }
  }

  comaprissiontime(time){
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
DateTime currenttime=DateTime.now();
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    DateTime dateTime = DateTime(currenttime.year, currenttime.month, currenttime.day, timeOfDay.hour, timeOfDay.minute);
    // Duration totalDuration = Duration(hours: dateTime.hour, minutes: dateTime.minute);
    Duration timeDiff = dateTime.difference(DateTime.now());
    int timeDiffInMinutes = timeDiff.inMinutes;
return timeDiffInMinutes;
    print('total duration $timeDiffInMinutes');
  }


  Future<void> saveSchedule() async {
   var deferance=comaprissiontime(timeText);
   DateTime currenttimenow=DateTime.now();
   DateTime newTime = currenttimenow.add(Duration(minutes: 30));
   String timeFormatted = DateFormat('h:mm a').format(newTime);
    if (weeklyBits.join('') == '0000000' &&
        weeklySchedule &&
        irrigationType != 'S') {
      FlutterToastUtil.showErrorToast(
          'Please select at least one weekday for the schedule creation.'.i18n);
      return;
    } else if (selectedBlocks.isEmpty) {
      FlutterToastUtil.showErrorToast(
          'Please select at least one block for the schedule creation.'.i18n);
      return;
    } else if (timeText == '00:00' &&
        !setTimeClicked &&
        irrigationType != 'S') {
      FlutterToastUtil.showErrorToast(
          'Please select valid start time for the schedule creation.'.i18n);
      return;
    }
    else if (deferance< 30  &&
        irrigationType != 'S') {
      FlutterToastUtil.showErrorToast( 'New Schedule has to be after $timeFormatted \n Cannot be within 30 minutes  ');
      return;
    }
       else if(mode==Mode.add && schedules!.length!=0){
      FlutterToastUtil.showErrorToast(
          'Schedule existing this farmland.\n cannot create new schedule'
              .i18n);
      return;
    }
    else if ((irrigationType != 'S' && irrigationValue == 0) ||((irrigationType == 'S') && (irrigationValueTo == 0))) {
      FlutterToastUtil.showErrorToast(
          'Please select Time Duration or Volume or Soil Moisture using the sliders.'
              .i18n);
      return;



    } else if (irrigationType == 'S' &&
        (soilL1 == 0 && soilL2 == 0 && soilL3 == 0 && soilL4 == 0)) {
      FlutterToastUtil.showErrorToast(
          'Please select at least one level to be included for soil moisture calculation.'
              .i18n);
      return;
    }else if(irrigationType =='S' &&  irrigationValueFrom >= irrigationValueTo){
      FlutterToastUtil.showErrorToast(
          'Please select To value of From is greater than.'
              .i18n);
      return;
    }

    String selectedBlockString = '';
    print('selected length' + selectedBlocks.length.toString());

    for (int key in selectedBlocks) {
      selectedBlockString += key.toString() + ',';
    }

    selectedBlockString =
        selectedBlockString.substring(0, selectedBlockString.length - 1);

    String weeklyBitsString = '';
    weeklyBitsString = weeklyBits.fold('', (previousValue, element) {
      return previousValue + element;
    });
    int currentTime = (TimeOfDay.now().hour * 60) + TimeOfDay.now().minute;
    int scheduleTime = (time.hour * 60) + time.minute;

    if (scheduleTime < currentTime &&
        !weeklySchedule &&
        irrigationType != 'S') {
      print(scheduleTime.toString() + '---' + currentTime.toString());
      FlutterToastUtil.showErrorToast('Please select future start time.'.i18n);
      return;
    }

    IrrigationScheduleModel irrigationSchedule = IrrigationScheduleModel(
        farmerFarmLandDetailsID: widget.farmlandID,
        farmerBlockLinkedIDs: selectedBlockString,
        // farmerBlockLinkedNames:
        scheduleFromDate: DateTime.now(),
        scheduleToDate: DateTime.now().add(const Duration(days: 60)),
        scheduleWeeks: irrigationType == 'S' ? '1111111' : weeklyBitsString,
        // this.name,
        scheduleIrrigationType: irrigationType,
        scheduleIrrigationValue: irrigationValue,
        scheduleNextRunDateTime: DateTime.now(),
        name: schedulename.text,
        scheduleTime: time,
        scheduleSoilMoistureHigh: irrigationValueTo,
        scheduleSoilMoistureLow: irrigationValueFrom,
        // this.schedulePreviousSuccessDateTime,
        scheduleType: irrigationType == 'S'
            ? 'W'
            : weeklySchedule
                ? 'W'
                : 'A',
        soilL1: soilL1,
        soilL2: soilL2,
        soilL3: soilL3,
        soilL4: soilL4);
    if (mode == Mode.add) {
      await IrrigationService().createIrrigationSchedule(irrigationSchedule);
    } else {
      print(irrigationSchedule);
      await IrrigationService()
          .updateIrrigationSchedule(irrigationSchedule, schedule?.id);
    }
    Navigator.pop(context);
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (newTime != null) {
      setState(() {
        setTimeClicked = true;
        time = newTime;
        timeText = (time.hour > 9
                ? time.hour.toString()
                : '0' + time.hour.toString()) +
            ':';
        timeText += (time.minute > 9)
            ? (time.minute).toString()
            : '0' + (time.minute).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    buildWeekdayContainers();
    Widget pageContent = Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                showWeeklyContainers
                    ? Row(children: weekContainers)
                    : const SizedBox(),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, top: 15, bottom: 5),
                    child: irrigationType != 'S'
                        ? Row(
                            children: [
                              Text('Irrigation starts at: '.i18n,
                                  style: const TextStyle(
                                      color:
                                      cultBlack,
                                      fontSize: bodyFont,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                  width: 55.w,
                                  child: Text(timeText,
                                      style: const TextStyle(
                                          color:
                                          cultBlack,
                                          fontSize: bodyFont,
                                          fontWeight: FontWeight.bold))),
                              InkWell(
                                onTap: () async => await selectTime(context),
                                child: Container(
                                    height: 30.h,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                        color: cultGreen,
                                        borderRadius:
                                            BorderRadius.circular(5.sp)),
                                    child: Center(
                                      child: Text(
                                        'Select time'.i18n,
                                        style: TextStyle(

                                            color: Colors.white,
                                            fontSize: 14.sp),
                                      ),
                                    )),
                              ),
                            ],
                          )
                        : const SizedBox()),
                Blocks(
                  allBlocks: widget.allBlocks,
                  selectedBlocks: selectedBlocks,
                  updateSelectedList: updateSelectedList,
                ),
                IrrigationType(
                    updateTimerBased: updateTimerBased,
                    updateVolumeBased: updateVolumeBased,
                    updateSoilBased: updateSoilBased,
                    updateIrrigationType: updateIrrigationType,
                    editSchedule: (mode == Mode.add) ? null : schedule),
                SingleChildScrollView(
                  child:         Container(
                      width: ScreenUtil.defaultSize.width * 75 / 100,
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r)),
                      height: 80.h,
                      child: TextField(
                        // keyboardType: TextInputType.number,
                        controller: schedulename,
                        style: TextStyle(color:
                        cultBlack,),
                        autofocus: true,
                        decoration: InputDecoration(
                          // hintText: _errorText.i18n,
                          hintStyle:
                          TextStyle(color:
                          cultBlack,fontSize: footerFont.sp),
                          labelText: 'Schedule Name'.i18n,
                        ),
                      )),
                ),
                SizedBox(height: 40,)
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          child: Container(
            height: 50,
            width: MediaQuery.of(context)
                .size
                .width, // ScreenUtil.defaultSize.width,
            color: cultLightGrey,
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => saveSchedule(),
                child: Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                  child: Text(
                    mode == Mode.edit ? 'Update'.i18n : 'Create'.i18n,
                    style: const TextStyle(
                        color:
                        cultBlack,
                        fontWeight: FontWeight.bold, fontSize: bodyFont),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: cultGreen,
            title: Text((mode == Mode.add)
                ? 'New Irrigation Schedule'.i18n
                : 'Edit Irrigation Schedule'.i18n),
            leading: Padding(
              padding: EdgeInsets.all(20.r),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: Colors.white,
                ),
              ),
            ),
            bottom: TabBar(
                controller: controller,
                dragStartBehavior: DragStartBehavior.down,
                tabs: [
                  Tab(
                      child: Text('Weekly Schedule'.i18n,
                          style: TextStyle(

                              color: (mode == Mode.edit &&
                                      schedule?.scheduleType == 'A')
                                  ? Colors.grey
                                  : Colors.white))),
                  Tab(
                      child: Text('One Time'.i18n,
                          style: TextStyle(
                              color: (mode == Mode.edit &&
                                      schedule?.scheduleType == 'W')
                                  ? Colors.grey
                                  : Colors.white))),
                ]),
          ),
          body: Builder(builder: (context) {
            return loading?Center(
              child: CircularProgressIndicator(),
            ) :TabBarView(
                controller: controller, children: [pageContent, pageContent]);
          }),
        ),
      ),
    );
  }
}

class IrrigationType extends StatefulWidget {
  const IrrigationType({
    required this.updateTimerBased,
    required this.updateVolumeBased,
    required this.updateSoilBased,
    required this.updateIrrigationType,
    this.editSchedule,
  });
  final Function updateTimerBased;
  final Function updateVolumeBased;
  final Function updateSoilBased;
  final Function updateIrrigationType;
  final IrrigationScheduleModel? editSchedule;
  @override
  State<IrrigationType> createState() => _IrrigationTypeState();
}

class _IrrigationTypeState extends State<IrrigationType> {
  bool timerBased = true;
  bool volumeBased = false;
  bool soilmoistureBased = false;
  double topSliderValueVolume = 0;
  double bottomSliderValueVolume = 0;
  double topSliderValueTime = 0;
  double bottomSliderValueTime = 0;
  double topSliderValueSoil = 0;
  double bottomSliderValueSoil = 0;
  int includeL1 = 0;
  int includeL2 = 0;
  int includeL3 = 0;
  int includeL4 = 0;

  IrrigationScheduleModel? editSchedule;
//topSliderValueSoil
  @override
  void initState() {
    super.initState();
    editSchedule = widget.editSchedule;
    if (editSchedule != null) {
      if (editSchedule!.scheduleIrrigationType == 'T') {
        topSliderValueTime =
            ((editSchedule!.scheduleIrrigationValue ?? 0) / 60).floor() + 0.0;
        bottomSliderValueTime = (editSchedule!.scheduleIrrigationValue ?? 0) -
            (topSliderValueTime * 60);
        timerBased = true;
        volumeBased = false;
        soilmoistureBased = false;
      } else if (editSchedule!.scheduleIrrigationType == 'V') {
        topSliderValueVolume =
            ((editSchedule!.scheduleIrrigationValue ?? 0) / 1000).floor() + 0.0;
        bottomSliderValueVolume = (editSchedule!.scheduleIrrigationValue ?? 0) -
            (topSliderValueVolume * 1000);
        timerBased = false;
        volumeBased = true;
        soilmoistureBased = false;
      } else {
        topSliderValueSoil = (editSchedule!.scheduleSoilMoistureLow ?? 0);
        bottomSliderValueSoil = (editSchedule!.scheduleSoilMoistureHigh ?? 0);
        includeL1 = editSchedule!.soilL1;
        includeL2 = editSchedule!.soilL2;
        includeL3 = editSchedule!.soilL3;
        includeL4 = editSchedule!.soilL4;
        timerBased = false;
        volumeBased = false;
        soilmoistureBased = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Divider(
        color: cultGrey,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 10.0, bottom: 15),
        child: Text('Choose irrigation method'.i18n,
            style: const TextStyle(
                color:
                cultBlack,
                fontSize: bodyFont, fontWeight: FontWeight.bold)),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: ()
            {
              if(editSchedule?.scheduleIrrigationType !='T' && editSchedule !=null ){}
              else {
                timerBased = true;
                volumeBased = false;
                soilmoistureBased = false;
                widget.updateIrrigationType('T');
                setState(() {});
              }
            },
            child: Container(
              height: ScreenUtil().setHeight(40),
              width: ScreenUtil().setWidth(ScreenUtil.defaultSize.width * .3),
              decoration:
                  timerBased ? selectedDecoration : unSelectedDecoration,
              child: Center(
                  child: Text(
                'Timer'.i18n,
                style: TextStyle(
                    color:
                    cultBlack,
                    fontWeight:
                        timerBased ? FontWeight.bold : FontWeight.normal),
              )),
            ),
          ),
          InkWell(
            onTap: () {
              if(editSchedule?.scheduleIrrigationType !='V' && editSchedule !=null ){}
              else {
                volumeBased = true;
                timerBased = false;
                soilmoistureBased = false;
                widget.updateIrrigationType('V');
                setState(() {});
              }
            },
            child: Container(
              height: ScreenUtil().setHeight(40),
              width: ScreenUtil().setWidth(ScreenUtil.defaultSize.width * .3),
              decoration:
                  volumeBased ? selectedDecoration : unSelectedDecoration,
              child: Center(
                  child: Text(
                'Volume'.i18n,
                style: TextStyle(
                    color:
                    cultBlack,
                    fontWeight:
                        volumeBased ? FontWeight.bold : FontWeight.normal),
              )),
            ),
          ),
          InkWell(
            onTap: () {
              if(editSchedule?.scheduleIrrigationType !='S' && editSchedule !=null ){}
            else{
                soilmoistureBased = true;
                timerBased = false;
                volumeBased = false;
                widget.updateIrrigationType('S');
                setState(() {});
              }
            },
            child: Container(
              height: ScreenUtil().setHeight(40),
              width: ScreenUtil().setWidth(ScreenUtil.defaultSize.width * .3),
              decoration:
                  soilmoistureBased ? selectedDecoration : unSelectedDecoration,
              child: Center(
                  child: Text(
                'Soil Moisture'.i18n,
                style: TextStyle(
                    color:
                    cultBlack,
                    fontWeight: soilmoistureBased
                        ? FontWeight.bold
                        : FontWeight.normal),
              )),
            ),
          ),
          // Disable Soil Moisture
        ],
      ),
      timerBased
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0.h, vertical: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Irrigation time'.i18n,
                      style: const TextStyle(color:
                      cultBlack,fontWeight: FontWeight.bold)),
                  Text(
                    topSliderValueTime.toInt() == 0
                        ? ('${bottomSliderValueTime.toInt()}' + ' mins'.i18n)
                        : '${topSliderValueTime.toInt()}' +
                            ' hours, '.i18n +
                            '${bottomSliderValueTime.toInt()}' +
                            ' mins',
                    style: TextStyle(
                        color:
                        cultBlack,
                        fontWeight:
                            timerBased ? FontWeight.bold : FontWeight.normal),
                  )
                ],
              ),
            )
          : volumeBased
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Volume (Liters)'.i18n,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        topSliderValueVolume < 1
                            ? '${bottomSliderValueVolume.round()} L'
                            : '${topSliderValueVolume.round()},${bottomSliderValueVolume.round()} L',
                        style: TextStyle(color:
                        cultBlack,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soil Moisture (%)'.i18n,
                        style: const TextStyle(color:
                        cultBlack,fontWeight: FontWeight.bold),
                      ),
                      Text(
                        topSliderValueSoil.round().toString() +
                            ' ' +
                            'to'.i18n +
                            ' ' +
                            bottomSliderValueSoil.round().toString() +
                            '%',
                      ),
                    ],
                  ),
                ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: cultGreen,
          inactiveTrackColor: cultLightGrey,
          trackShape: const RectangularSliderTrackShape(),
          trackHeight: 8.0,
          thumbColor: cultOlive,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          overlayColor: cultRed.withAlpha(32),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
        ),
        child: timerBased
            ? Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: 35.w,
                          child: (Text(
                            "Hour".i18n,
                            style: TextStyle(color:
                            cultBlack,fontSize: footerFont.sp),
                          ))),
                      SizedBox(
                        width: 300.w,
                        height: 30,
                        child: Slider(
                          min: 0,
                          max: 11,
                          divisions: 11,
                          value: topSliderValueTime,
                          label: "${topSliderValueTime.round()} hours",
                          onChanged: (value) {
                            setState(() {
                              topSliderValueTime = value;
                              double minutes = topSliderValueTime * 60 +
                                  bottomSliderValueTime;
                              widget.updateTimerBased(minutes);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      SizedBox(
                          width: 35.w,
                          child: (Text(
                            "Mins".i18n,
                            style: TextStyle(color:
                            cultBlack,fontSize: footerFont.sp),
                          ))),
                      SizedBox(
                        width: 300.w,
                        height: 30.h,
                        child: Slider(
                          min: 0,
                          max: 59,
                          divisions: 59,
                          value: bottomSliderValueTime,
                          label: "${bottomSliderValueTime.round()} minutes",
                          onChanged: (value) {
                            setState(() {
                              bottomSliderValueTime = value;
                              double minutes = topSliderValueTime * 60 +
                                  bottomSliderValueTime;
                              widget.updateTimerBased(minutes);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : volumeBased
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: SizedBox(
                                width: 45.w,
                                child: (Text(
                                  "1000 L",
                                  style: TextStyle(color:
                                  cultBlack,fontSize: footerFont.sp),
                                ))),
                          ),
                          SizedBox(
                            width: 290.w,
                            height: 30.h,
                            child: Slider(
                              min: 0, // 0.25 hour
                              max: 9, // 3 hours
                              divisions: 9,
                              value: topSliderValueVolume,
                              label: "${topSliderValueVolume.round() * 1000}",
                              onChanged: (value) {
                                setState(() {
                                  topSliderValueVolume = value;
                                  double volume = topSliderValueVolume * 1000 +
                                      bottomSliderValueVolume;
                                  widget.updateVolumeBased(volume);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.only(left: 10.w),
                              width: 45.w,
                              child: (Text(
                                "Liter",
                                style: TextStyle(color:
                                cultBlack,fontSize: footerFont.sp),
                              ))),
                          SizedBox(
                            width: 290.w,
                            height: 30.h,
                            child: Slider(
                              min: 0, // 0.25 hour
                              max: 999, // 3 hours
                              divisions: 99,
                              value: bottomSliderValueVolume,
                              label:
                                  "${bottomSliderValueVolume.round()} liters",
                              onChanged: (value) {
                                setState(() {
                                  bottomSliderValueVolume = value;
                                  double volume = topSliderValueVolume * 1000 +
                                      bottomSliderValueVolume;
                                  widget.updateVolumeBased(volume);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Checkbox(
                                    value: includeL1 == 1,
                                    onChanged: (value) {
                                      includeL1 = (value ?? false) ? 1 : 0;
                                      widget.updateSoilBased(
                                          topSliderValueSoil,
                                          bottomSliderValueSoil,
                                          includeL1,
                                          includeL2,
                                          includeL3,
                                          includeL4);
                                      setState(() {});
                                    }),
                                Text(
                                  'Include Level 1'.i18n,
                                  style: const TextStyle(color:
                                  cultBlack,fontSize: footerFont),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(
                                    value: includeL2 == 1,
                                    onChanged: (value) {
                                      includeL2 = (value ?? false) ? 1 : 0;
                                      widget.updateSoilBased(
                                          topSliderValueSoil,
                                          bottomSliderValueSoil,
                                          includeL1,
                                          includeL2,
                                          includeL3,
                                          includeL4);
                                      setState(() {});
                                    }),
                                Text(
                                  'Include Level 2'.i18n,
                                  style: const TextStyle(color:
                                  cultBlack,fontSize: footerFont),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(
                                    value: includeL3 == 1,
                                    onChanged: (value) {
                                      includeL3 = (value ?? false) ? 1 : 0;
                                      widget.updateSoilBased(
                                          topSliderValueSoil,
                                          bottomSliderValueSoil,
                                          includeL1,
                                          includeL2,
                                          includeL3,
                                          includeL4);
                                      setState(() {});
                                    }),
                                Text(
                                  'Include Level 3'.i18n,
                                  style: const TextStyle(color:
                                  cultBlack,fontSize: footerFont),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(
                                    value: includeL4 == 1,
                                    onChanged: (value) {
                                      includeL4 = (value ?? false) ? 1 : 0;
                                      widget.updateSoilBased(
                                          topSliderValueSoil,
                                          bottomSliderValueSoil,
                                          includeL1,
                                          includeL2,
                                          includeL3,
                                          includeL4);
                                      setState(() {});
                                    }),
                                Text(
                                  'Include Level 4'.i18n,
                                  style: const TextStyle(color:
                                  cultBlack,fontSize: footerFont),
                                )
                              ],
                            )
                          ]),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: SizedBox(
                                width: 45.w,
                                child: (Text(
                                  "From".i18n + " %",
                                  style: TextStyle(color:
                                  cultBlack,fontSize: footerFont.sp),
                                ))),
                          ),
                          SizedBox(
                            width: 290.w,
                            height: 30.h,
                            child: Slider(
                              min: 0,
                              max: 100,
                              divisions: 100,
                              value: topSliderValueSoil,
                              label: "${topSliderValueSoil.round()} %",
                              onChanged: (value) {
                                setState(() {
                                  topSliderValueSoil = value;
                                  if (bottomSliderValueSoil <
                                      topSliderValueSoil) {
                                    bottomSliderValueSoil = topSliderValueSoil;
                                  }
                                  widget.updateSoilBased(
                                      topSliderValueSoil,
                                      bottomSliderValueSoil,
                                      includeL1,
                                      includeL2,
                                      includeL3,
                                      includeL4);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.only(left: 10.w),
                              width: 45.w,
                              child: (Text(
                                "To".i18n + ' %',
                                style: TextStyle(color:
                                cultBlack,fontSize: footerFont.sp),
                              ))),
                          SizedBox(
                            width: 290.w,
                            height: 30.h,
                            child: Slider(
                              min: 0, // 0.25 hour
                              max: 100, // 3 hours
                              divisions: 100,
                              value: bottomSliderValueSoil,
                              label: "${bottomSliderValueSoil.round()} %",
                              onChanged: (value) {
                                setState(() {
                                  bottomSliderValueSoil = value;
                                  if (topSliderValueSoil >
                                      bottomSliderValueSoil) {
                                    topSliderValueSoil = bottomSliderValueSoil;
                                  }
                                  widget.updateSoilBased(
                                      topSliderValueSoil,
                                      bottomSliderValueSoil,
                                      includeL1,
                                      includeL2,
                                      includeL3,
                                      includeL4);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    ]);
  }
}

class Blocks extends StatefulWidget {
  const Blocks(
      {required this.allBlocks,
      required this.selectedBlocks,
      required this.updateSelectedList,
      Key? key})
      : super(key: key);
  final List<Block> allBlocks;
  final List<int> selectedBlocks;
  final Function updateSelectedList;
  @override
  State<Blocks> createState() => _BlocksState();
}

class _BlocksState extends State<Blocks> {
  List<Widget> blockContainers = [];
  Map<int, Block> blockMaps = {};
  List<int> selectedBlocksOrder = [];
  List<int> unSelectedBlocks = [];
  List<int> allOrderedBlocks = [];

  @override
  void initState() {
    super.initState();
    selectedBlocksOrder = widget.selectedBlocks;

    for (Block block in widget.allBlocks) {
      blockMaps[block.id] = block;
      if (!selectedBlocksOrder.contains(block.id)) {
        unSelectedBlocks.add(block.id);
      }
    }
    allOrderedBlocks.addAll(selectedBlocksOrder);
    allOrderedBlocks.addAll(unSelectedBlocks);
  }

  void buildBlockContainers() {
    blockContainers = [];

    for (int key in allOrderedBlocks) {
      Widget blockContainer = InkWell(
          onTap: () {
            if (selectedBlocksOrder.contains(key)) {
              selectedBlocksOrder.remove(key);
              unSelectedBlocks.add(key);
            } else {
              selectedBlocksOrder.add(key);
              unSelectedBlocks.remove(key);
            }
            allOrderedBlocks = [];
            allOrderedBlocks.addAll(selectedBlocksOrder);
            allOrderedBlocks.addAll(unSelectedBlocks);
            print('allOrderedBlocks:' +
                allOrderedBlocks[0].toString() +
                ':' +
                allOrderedBlocks[allOrderedBlocks.length - 1].toString());
            widget.updateSelectedList(selectedBlocksOrder);
            setState(() {});
          },
          child: Container(
            decoration: selectedBlocksOrder.contains(key)
                ? selectedDecoration
                : unSelectedDecoration,
            child: Center(
                child: Text(
                    language == 'en'
                        ? blockMaps[key]?.name ?? ''
                        : blockMaps[key]?.alias ?? '',
                    style: selectedBlocksOrder.contains(key)
                        ? const TextStyle(color:
                    cultBlack,fontWeight: FontWeight.bold)
                        : const TextStyle(color: cultSoftGrey))),
          ));
      blockContainers.add(blockContainer);
    }
  }

  @override
  Widget build(BuildContext context) {
    buildBlockContainers();
    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 15),
              child: SizedBox(
                width: double.infinity,
                child: Text('Choose blocks to irrigate'.i18n,
                    style: const TextStyle(color:
                    cultBlack,
                        fontSize: bodyFont, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
                right: 0,
                top: -10,
                child: IconButton(
                    onPressed: () {
                      unSelectedBlocks = [];
                      allOrderedBlocks = [];
                      selectedBlocksOrder = [];
                      for (Block block in widget.allBlocks) {
                        allOrderedBlocks.add(block.id);
                        unSelectedBlocks.add(block.id);
                      }
                      setState(() {});
                    },
                    icon: const Icon(Icons.restore)))
          ],
        ),
        (blockContainers.isNotEmpty)
            ? GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                padding: EdgeInsets.only(bottom: 10.h),
                childAspectRatio: 2,
                children: blockContainers,
              )
            : const SizedBox(),
      ],
    );
  }
}
