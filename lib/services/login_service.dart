import 'package:fluttertoast/fluttertoast.dart';

import '../models/version.dart';
import '../utils/string_extension.dart';
import '../network/api_helper.dart';
import '../utils/constants.dart';
import '../utils/flutter_toast_util.dart';

class LoginService {
  Future<Map<String, dynamic>> generateOTP(String mobile) async {
    try {
      if (mobile.length != 10 || (int.tryParse(mobile) ?? 0) == 0) return {};
      Map<String, dynamic> response = await ApiHelper()
          .get('$cultyvateURL/farmer/otp/${int.parse(mobile)}');
      if (response["success"] ?? false) {
        Map<String, dynamic> data = response["data"];
        return data;
      } else {
        Fluttertoast.showToast(msg: response["message"].i18n);
      }
    } catch (e) {
      FlutterToastUtil.showErrorToast(
          'Cannot get requested data, please try later.'.i18n);
    }
    return {};
  }

  Future<Map<String, dynamic>> validateUser(
      String userName, String password) async {
    try {
      if (userName.isEmpty || password.isEmpty) return {};

      String postUrl = '$cultyvateURL/farmer/login';

      Map<String, dynamic> requestBody = {
        "userName": userName,
        "password": password
      };
      print("responmce is  url is ${postUrl}");
      Map<String, dynamic> response =
          await ApiHelper().post(path: postUrl, postData: requestBody);
print("responmce is ${response}");
      if (response["success"] ?? false) {
        Map<String, dynamic> data = response["data"];
        return data;
      } else {
        FlutterToastUtil.showErrorToast(
            response["message"] ?? 'Network Not available'.i18n);
      }
    } catch (e) {
      print(e);
      await FlutterToastUtil.showErrorToast(
          'Cannot get requested data, please try later.'
              .i18n); // : ${e.toString()}');
    }
    return {};
  }

  Future getversion() async {
    String path = '$watherstationURL/appversion/appversion';
    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['success'] ?? false) {
      print("responce $response");
      return response['data'][0]['MobileAPPVersion'];
    } else if (response.isNotEmpty) {
      FlutterToastUtil.showErrorToast(response['message'].i18n);
    }
    return null;
  }
}
