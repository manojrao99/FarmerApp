import 'package:dio/dio.dart';

import '../utils/constants.dart';
// import 'package:scanner/models/devicequery.dart';

class Repositry {
  static final String baseUrl = '$cultyvateURL';
  static final Dio _dio = Dio();
  static final Map<String, String> header = {
    "content-type": "application/json",
    "API_KEY": "12345678"
  };
  static Future getapis({required dynamic passid,required String subpath})async {
    var  path="$baseUrl/$subpath/$passid";
    // 'http://aquaf.centralindia.cloudapp.azure.com/servicesF2Fapp/api/farm2fork/devicedata/devices/$devicid';
    print(path);
    final dio = Dio();
    Map<String, dynamic> returnData = {};
    try {
      final response =
      await dio.get(path,  options: Options(headers: header),queryParameters: {});
      print(response);
      if (response.statusCode == 200) {
        returnData = response.data;
        print(returnData);
      }
    } catch (e) {
      throw e;

    }
    return returnData;
  }
  static Future Postapis({required dynamic passid,required String subpath})async {
    var  path="$baseUrl/$subpath";
    // 'http://aquaf.centralindia.cloudapp.azure.com/servicesF2Fapp/api/farm2fork/devicedata/devices/$devicid';
    print(path);
    final dio = Dio();
    Map<String, dynamic> returnData = {};
    try {
      final response =await dio.post(path, data: passid, options: Options(headers: header));
      print(response);
      if (response.statusCode == 200) {
        returnData = response.data;
        print(returnData);
      }
    } catch (e) {
      throw e;

    }
    return returnData;
  }


}