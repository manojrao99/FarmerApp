import 'dart:convert';
import 'package:time_machine/time_machine.dart' as tz;
import 'package:time_machine/time_machine_text_patterns.dart';
import 'package:cultyvate/savedata/sharedpref.dart';
import 'package:flutter/services.dart';
import 'package:cultyvate/services/irrigation_service.dart';
import 'package:cultyvate/utils/flutter_toast_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import '../../utils/string_extension.dart';
import '../utils/constants.dart';
import '../network/api_helper.dart';
import '../models/farmer_profile.dart';
import '../models/telematic_model.dart';
import '../models/irrigation_schedule_model.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';
class DashboardService {
  Future<Farmer?> getFarmer(int farmerID) async {
    String path = '${cultyvateURL}/farmer/profilev2/' + farmerID.toString();
    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['success'] ?? false) {
    // try{
      print("responce manoj ${response['data']}");
      return Farmer.fromJson(response['data']);

    // }
    // catch(e){

      // print("error manoj ine  $e");
    // }
    }
    return null;
  }

  Future getFarmerTemphumddetails(int farmerID) async {
  String path = '${cultyvateURL}/farmer/kuwaitproject/'+ farmerID.toString();
  Map<String, dynamic> response = await ApiHelper().get(path);
  if (response['success'] ?? false) {
  try{
  return response;

  }
  catch(e){
    throw e;
  print("error manoj ine  $e");
  }
  }
  return null;
  }

  Future getTelematicsTempHumd(String deviceList) async {
    try {
      // await TimeMachine.initialize();
      await tz.TimeMachine.initialize({
        'rootBundle': rootBundle,
      });
      print('Hello, ${DateTimeZone.local} from the Dart Time Machine!\n');

      var tzdb = await DateTimeZoneProviders.tzdb;


      var now = Instant.now();




      Map<String, TelematicModel> telematicDataMap = {};
      print('device list ${deviceList}');
      // if()
      var paris = await tzdb["Asia/Kolkata"];
      var convertedtime = now.inZone(paris).toString('yyyy-MM-dd');
      var convertedenddate = now.inZone(paris).toString('yyyy-MM-dd HH:mm');


      Map<String, dynamic> body = {
        'deviceList': deviceList,
        "starttime": convertedtime.toString(),
        "Endtime": convertedenddate.toString()
      };
      print("bodu is ${body}");
      String path = '$cultyvateURL/telematic/temphub';



      Map<String, dynamic> response =
      await ApiHelper().post(path: path, postData: body);

      if (response.isNotEmpty) {
        return response;
      } else {
        return [];
        // FlutterToastUtil.showErrorToast((response['message'] ?? ''));
      }
      return telematicDataMap;
    } catch (e) {
      throw e;
      print("error  time zone $e");
    }
  }
  Future<Map<String, TelematicModel>> getTelematics({String ? deviceList,int ? farmlandid}) async {
  try{
    Map<String, TelematicModel> telematicDataMap = {};
    print('device list ${deviceList}');
    Map<String, dynamic> body = {'deviceList': deviceList,"farmlandId":farmlandid};
    String path = '$cultyvateURL/telematic/devices';
    Map<String, dynamic> response =
    await ApiHelper().post(path: path, postData: body);

    if (response.isNotEmpty && (response['success'] ?? false)) {
      print('manoj telemetrics ${response["data"]}' );
      if (response["data"] is List<dynamic>) {
        print(response['data'].length);
        for (int i = 0; i < response['data'].length; i++) {
          print(response['data'][i]);
          TelematicModel telematicModel = TelematicModel.fromJson(response['data'][i]);
          print(telematicModel.operatingMode.toString());
          print("telemetric model ${telematicModel.deviceID}");
          telematicDataMap[telematicModel.deviceID!] = telematicModel;
          print(telematicDataMap[telematicModel.deviceID!]!.deviceID.toString());
        }
        return telematicDataMap;
      }
    } else {
      FlutterToastUtil.showErrorToast((response['message'] ?? ''));
      return throw response['message'];
    }
    return telematicDataMap;
  }catch(e){
    return throw e;
  }
  }
  Future<bool> getValveopenCheck(String deviceList) async {
    Map<String, TelematicModel> telematicDataMap = {};

    Map<String, dynamic> body = {'deviceList': deviceList};
    String path = '$cultyvateURL/telematic/valveopencheck';
    Map<String, dynamic> response =
    await ApiHelper().post(path: path, postData: body);

    if (response.isNotEmpty && (response['success'] ?? false)) {
      return true;

    } else {
      return false;
      // FlutterToastUtil.showErrorToast((response['message'] ?? ''));
    }
    return false;
  }
  Future<String> getScheduleType(int farmlandID) async {
    List<IrrigationScheduleModel> schedules =await IrrigationService().getSchedules(farmlandID);
    if (schedules.isNotEmpty) {
      return schedules[0].scheduleIrrigationType ?? "";
    }
    return "";
  }

  Future<Map<String, dynamic>> getWaterflow(String farmlandWaterMeter,
      List<String> blockPlotDevices, int farmlandID) async {
    Map<String, dynamic> returnValue = {};

    Map<String, dynamic> body = {
      'farmlandDevice': farmlandWaterMeter,
      'valveDevices': blockPlotDevices,
      'farmlandID': farmlandID
    };

    Map<String, dynamic> flowData = await ApiHelper()
        .post(path: '$cultyvateURL/telematic/waterflow', postData: body);
    if (flowData.isNotEmpty && (flowData['success'] ?? false)) {
      returnValue = (flowData['data']);
    }
    return returnValue;
  }

  Future<Map<String, dynamic>> getHistoricData(String duration, Map<String, dynamic> postData) async {
    Map<String, dynamic> result = await ApiHelper().post(path: '$cultyvateURL/telematic/history', postData: postData);
    if (result.isNotEmpty && (result['success'] ?? false)) {
      return result['data']['flowValues'];
    } else {
      FlutterToastUtil.showErrorToast(result['message'] ?? '');
    }
    return {};
  }

  Future<bool> deviceTurnOnOff(String deviceID, String deviceType,
      String iopDeviceId, List<String> valveDevices, bool switchOnOff) async {
    Map<String, dynamic> body = {
      "deviceID": deviceID,
      "deviceType": deviceType,
      "iopDeviceID": iopDeviceId,
      "switchOn": switchOnOff,
      "valveDeviceList": valveDevices
    };
    var isonoff=switchOnOff?0:1;
    ApiHelper apiHelper = ApiHelper();
    var postResult = await apiHelper.post(
        path: '$cultyvateURL/irrigation/switchdevice', postData: body);
    if (postResult["status"]) {

      String ?value = await SharedPreferencesService.getString(deviceID!);
      print("value ${value}");
      if(value==null) {
       if (value !=null) {
         // Update existing value
         var data = await SharedPreferencesService.remove(deviceID);
         await SharedPreferencesService.setString(deviceID!, '$isonoff');
         // Add new value
         await SharedPreferencesService.setString(action_check, '1');
         // prefs.setString(deviceId!, value!);
       } else {
         // Add new value
         await SharedPreferencesService.setString(action_check, '1');
         await SharedPreferencesService.setString(deviceID!, '$isonoff');
         // prefs.setString(deviceId!, value!);
       }
     }
     else{
       await SharedPreferencesService.setString(action_check, '1');
       await SharedPreferencesService.setString(deviceID!, '$isonoff');
     }
      FlutterToastUtil.showSuccessToastExit('Device turned '.i18n +
          (switchOnOff ? 'on'.i18n : 'off'.i18n) +
          ' command sent'
              .i18n,2);
      return true;
    } else {
      FlutterToastUtil.showErrorToast(
          'Operation failed: Please try later.'.i18n +
              postResult["message"].toString().i18n);
      return false;
    }
  }
}
