import 'package:cultyvate/utils/flutter_toast_util.dart';
import 'package:flutter/material.dart';
import '../../utils/string_extension.dart';
import '../utils/constants.dart';
import '../network/api_helper.dart';
import '../models/irrigation_schedule_model.dart';

class IrrigationService {
  Future<Map<String, dynamic>> createIrrigationSchedule(
      IrrigationScheduleModel irrigationSchedule) async {
    if ((irrigationSchedule.farmerBlockLinkedIDs != null &&
            irrigationSchedule.farmerBlockLinkedIDs == "") ||
        (irrigationSchedule.farmerFarmLandDetailsID != 0)) {
      var postData = irrigationSchedule.toMap(irrigationSchedule);

      Map<String, dynamic> response = await ApiHelper()
          .post(path: '$cultyvateURL/irrigation/schedule', postData: postData);
      if (response['success']) {
        await FlutterToastUtil.showSuccessToast(
            'Irrigation schedule created.'.i18n,"",1);
        return response['data'];
      }

      await FlutterToastUtil.showErrorToast(response['message']);
    }
    return {};
  }

  Future<void> updateIrrigationSchedule(
      IrrigationScheduleModel irrigationSchedule, scheduleId) async {
    if ((irrigationSchedule.farmerBlockLinkedIDs != null &&
            irrigationSchedule.farmerBlockLinkedIDs == "") ||
        (irrigationSchedule.farmerFarmLandDetailsID != 0)) {
      irrigationSchedule.id = scheduleId;
      var putData = irrigationSchedule.toMap(irrigationSchedule);

      Map<String, dynamic> response = await ApiHelper().put(
          path: '$cultyvateURL/irrigation/schedule/$scheduleId',
          putData: putData);
      if (response['success']) {
        await FlutterToastUtil.showSuccessToast(
            'Irrigation schedule updated.'.i18n,"",1);
      } else {
        FlutterToastUtil.showErrorToast(response['message']);
      }
    }
    return;
  }
  Future<List<IrrigationScheduleModel>> getSchedules(int farmLandID) async {
    List<IrrigationScheduleModel> schedules = [];
    IrrigationScheduleModel irrigationScheduleModel;

    Map<String, dynamic> response =
        await ApiHelper().get('$cultyvateURL/irrigation/schedule/$farmLandID');

    if (response['success'] ?? false) {
      var responseData = response['data'];
      print(response['data']);
      if (responseData is List<dynamic>) {
        for (var i = 0; i < responseData.length; i++) {
          irrigationScheduleModel =
              IrrigationScheduleModel.fromJson(responseData[i]);
          schedules.add(irrigationScheduleModel);
        }
        return (schedules);
      }
    }
    return ([]);
  }
  Future<List<IrrigationScheduleModel>> getactiveshadule(int farmLandID) async {
    List<IrrigationScheduleModel> schedules = [];
    IrrigationScheduleModel irrigationScheduleModel;

    Map<String, dynamic> response =
    await ApiHelper().get('$cultyvateURL/irrigation/activeschedule/$farmLandID');

    if (response['success'] ?? false) {
      var responseData = response['data'];
      if (responseData is List<dynamic>) {
        for (var i = 0; i < responseData.length; i++) {
          irrigationScheduleModel =
              IrrigationScheduleModel.fromJson(responseData[i]);
          schedules.add(irrigationScheduleModel);
        }
        return (schedules);
      }
    }
    return ([]);
  }
  Future<void> deleteSchedule(int id) async {
    var response = await ApiHelper().delete('$cultyvateURL/irrigation/schedule/$id');
    print(response['message']);
    if (response["success"] ?? false) {
      FlutterToastUtil.showSuccessToast('Schedule deleted successfully.'.i18n,"",1);
    } else {
      FlutterToastUtil.showErrorToast(response['message']);
    }
  }
  Future<bool> Terminateschdule({farmerFarmlandid,Iopdevice,blockPlotDevices,contxt}) async {

    Map<String, dynamic> body = {
      'farmlandDevice': Iopdevice,
      'valveDevices': blockPlotDevices,
      'farmlandID': farmerFarmlandid
    };
    var response = await ApiHelper().post(path: '$cultyvateURL/irrigation/terminateschdule', postData: body);
    print(response['message']);
    if (response["status"] ?? false) {
return true;
      _showFullScreenDialog(contxt,response["message"]);

      FlutterToastUtil.showSuccessToast('Schedule deleted successfully.'.i18n,"",1);
    } else {
      FlutterToastUtil.showErrorToast(response['message']);
      return false;
    }
  }

  void _showFullScreenDialog(BuildContext context,message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return    AlertDialog(
          content: Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.warning, // You can use any desired icon
                    color: Colors.orange,
                    size: 50.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(message,
                    style: TextStyle(fontSize: 20),
                  ),
SizedBox(height: 30,),

                  // Add other content here as needed
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle the "No" button action here
                Navigator.of(context).pop(false); // Close the dialog and return false
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );

  }

}
