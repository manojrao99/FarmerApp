import 'package:cultyvate/ui/dashboard/dashboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './styles.dart';
import 'constants.dart';

class FlutterToastUtil {
  static Future<void> showErrorToast(String message) async {
    await showErrorDialog(message);
  }

  static Future<void> showSuccessToast(String message,context,excet) async {
    await showSuccessDialog(message,context,excet);
  }
  static Future<void> showSuccessToastExit(String message,excet) async {
    await showSuccessDialogexit(message,excet);
  }


  static Future<void> showSuccessDialog(String message,context,exit) async {
    await Get.defaultDialog(
      actions: [
        ElevatedButton(onPressed: (){
          if(exit==1) {
            Get.back();
            // Get.back();
            // Navigator.pop(context);
            // Navigator.pop(context);

          }
          else {
            Get.back();
            // Get.back();
         //    Navigator.pop(context);
         // Navigator.pop(context);
          }
        }, child:Text("OK"))
      ],
        title: "Cultyvate",
        middleText: message,
        backgroundColor: cultGreen,
        titleStyle: const TextStyle(color: Colors.white),
        middleTextStyle: const TextStyle(color: Colors.white),
        radius: 30);
  }

  static Future<void> showSuccessDialogexit(String message, exit) async {
    await Get.defaultDialog(
        actions: [
          ElevatedButton(onPressed: (){
            if(exit==1) {
              Get.back();
             Get.back();
              // Navigator.pop(context);

            }
            else {
              Get.back();
              Get.back();
              // Navigator.pop(context);
              // Navigator.pop(context);
            }
          }, child:Text("OK"))
        ],
        title: "Cultyvate",
        middleText: message,
        backgroundColor: cultGreen,
        titleStyle: const TextStyle(color: Colors.white),
        middleTextStyle: const TextStyle(color: Colors.white),
        radius: 30);
  }



  static Future<void> showErrorDialog(String message) async {
    await Get.defaultDialog(
        title: "Cultyvate",
        middleText: message,
        backgroundColor: cultLightGrey,
        titleStyle: const TextStyle(color: cultRed),
        middleTextStyle: const TextStyle(color: cultRed),
        radius: 30);
  }
}
