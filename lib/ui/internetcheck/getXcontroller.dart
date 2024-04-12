import 'dart:async';
import 'dart:io';
import 'package:internet_check/internet_check.dart';
import 'package:cultyvate/ui/internetcheck/nointernet.dart';
import 'package:cultyvate/ui/internetcheck/serverdown.dart';
// import 'package:dart_ping/dart_ping.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {

  var ActiveConnection = true;
  var Activeserver = true;
  Timer? timer;

  @override
  void onClose() {
    timer!.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    CheckUserConnection();
    print("onInit");
    timer = Timer.periodic(
        Duration(seconds: 2), (Timer t) => CheckUserConnection());
  }


  Future CheckUserConnection() async {
    try {
      bool isOnline = await Internet().check();
            if(!isOnline) {
              ActiveConnection = false;
              Get.to(NoInternetConnection());
            }
            else{
              if (ActiveConnection == false) {
                Get.back();
                ActiveConnection = true;
              }
            }

    } on SocketException catch (_) {
      ActiveConnection = false;
      Get.to(NoInternetConnection());
      // print('not connected');
    }
  }
}
