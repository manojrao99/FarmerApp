import 'package:cultyvate/utils/string_extension.dart';

import '../models/notifications_model.dart';
import '../network/api_helper.dart';
import '../utils/constants.dart';
import '../utils/flutter_toast_util.dart';

class NotificationsService {
  List<NotificationsAll> telematicDataMap = [];
  Future<List<NotificationsAll>> getNotifications(int farmerID) async {
    String path = '$cultyvateURL/farmer/notifications/'+farmerID.toString();

    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['success'] ?? false) {
      if (response["data"] is List<dynamic>) {
        for (int i = 0; i < response['data'].length; i++) {

          print(response['data']);
          NotificationsAll notificationsAll =
              NotificationsAll.fromJson(response['data'][i]);
          print("notifications ${notificationsAll.criticality.toString()}");

          telematicDataMap.add(notificationsAll);
        }
      }

      // return NotificationsAll.fromJson(response['data']);
    } else if (response.isNotEmpty) {
      FlutterToastUtil.showErrorToast(response['message'].i18n);
    }
    return telematicDataMap;
  }
}