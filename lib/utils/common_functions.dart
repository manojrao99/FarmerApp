import 'package:cultyvate/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/string_extension.dart';

const kBoldTextStyle = TextStyle(
    fontWeight: FontWeight.bold, color: kTextColor, fontFamily: 'Poppins');
const kSmallTextStyle =
    TextStyle(fontSize: 12, color: kTextColor, fontFamily: 'Poppins');
const kTextStyle = TextStyle(color: kTextColor, fontFamily: 'Poppins');

double getValue( value) {
  if (value >= 2000 && value <= 3099) {
    return 0.20;
  } else if (value >= 3100 && value <= 3299) {
    return 0.50;
  } else if (value >= 3300 && value <= 4300) {
    return 0.99;
  } else {
    // Return a default value or throw an exception for values outside the specified ranges
    return -1.0; // Default value
    // throw Exception('Value outside specified ranges');
  }
}
double getrssi_signal_Value(double value) {
  if (value >= -200 && value <= -91) {
    return 0.25;
  } else if (value >= -90 && value <= -61) {
    return 0.50;
  } else if (value >= -60 && value <= -31) {
    return 0.75;
  } else {
    // Return a default value or throw an exception for values outside the specified ranges
    return 1.0; // Default value
    // throw Exception('Value outside specified ranges');
  }
}
int get_GateWaySNR_signal(double value) {
  if (value >= 0 && value <= 50) {
    return 0;
  } else if (value > -10 && value <= 0) {
    return 2;
  } else if (value > -21 && value <= -10) {
    return 3;
  } else  if (value < -21 ){
    return 4; // Default value
  }
  else {
    return 0;
  }
}

String getPumpduration(DateTime ?timeSinceLastTick){
  String cleanedDateTimeString = timeSinceLastTick!.toIso8601String().replaceFirst("Z", "");
  DateTime timeparce=DateTime.parse(cleanedDateTimeString);
  print("pumpduration ${timeparce}");
  print("pumpduration ${DateTime.now()}");

  if (timeSinceLastTick == null) return '';
  Duration durationToSubtract = Duration(minutes: 0);
  print("actually date ${timeparce.add(durationToSubtract)}");

  Duration duration = DateTime.now().difference(timeparce);
 print("duration in seconds ${duration.inMinutes}");
  int durationInSeconds = duration.inSeconds;
  // int difference = DateTime.now().difference(timeparce.add(durationToSubtract)).inSeconds.abs();
 // print("defierence ${difference}");
  if (duration.inMinutes < 0) return "";
  if (duration.inMinutes < 0) return duration.inMinutes.toString() + ' sec ago'.i18n;
  if (duration.inMinutes < 60) {
    return (duration.inMinutes).floor().toString() + ' mins ago'.i18n;
  }
  // int hourDiff = DateTime.now().difference(timeSinceLastTick).inHours;
  if (duration.inHours < 24) return duration.inHours.toString() + ' hours ago'.i18n;
  return duration.inDays.toString() + 'days ago'.i18n;
}

String getDuration(DateTime? timeSinceLastTick) {
  print("time diff${DateTime.now()}");

  print('diffff' + ":git" + timeSinceLastTick!.toIso8601String());

  if (timeSinceLastTick == null) return '';


  Duration durationToSubtract = Duration(hours: 5, minutes: 30);
  print('clock ${timeSinceLastTick.add(durationToSubtract)}');
  DateTime timeparce=DateTime.parse(timeSinceLastTick!.toIso8601String());
  print("actualdate ${ DateTime.now().difference(timeparce).inSeconds}");
  int difference = DateTime.now().difference(timeparce).inSeconds;
  print(DateTime.now());
  print('diffff' + difference.toString());
  print('diffff' +(difference < 60).toString());
  if (difference < 0) return "";
  if (difference < 60) return difference.toString() + ' sec '.i18n;
  if (difference < 3600) {
    return (difference / 60).floor().toString() + ' mins '.i18n;
  }
  int hourDiff = DateTime.now().difference(timeSinceLastTick).inHours;
  if (hourDiff < 24) return hourDiff.toString() + ' hours '.i18n;
  return DateTime.now().difference(timeSinceLastTick).inDays.toString() + 'days '.i18n;
}



Dateformatschduler({required String datetime}){
if(datetime !=null ||datetime.isNotEmpty) {
  // String cleanedDateString = datetime.replaceAll("T", " ").replaceAll("Z", "");
  DateTime date = DateTime.parse(datetime);

  // DateFormat dateFormat = DateFormat('dd-MM-yy h:mm a');
  // // DateFormat dateFormat = DateFormat('MMM dd, yyyy');
  //
  // // Parse the date string into a DateTime object
  // DateTime datefo = dateFormat.parse(date.toString());
  String formattedDate = DateFormat('dd-MMM-yyyy h:mm a').format(date);
  return formattedDate;
}
else {
  return " ";
}
}