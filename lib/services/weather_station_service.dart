import 'package:cultyvate/models/weather_station_model.dart';
import 'package:cultyvate/utils/flutter_toast_util.dart';
import '../../utils/string_extension.dart';
import '../models/weater_station_v2.dart';
import '../utils/constants.dart';
import '../network/api_helper.dart';

import 'package:intl/intl.dart';

Dateformate(date) {
  DateTime parseDate = DateFormat("yyyy-MM-dd").parse(date);
  var inputDate = DateTime.parse(parseDate.toString());

  var outputFormat = DateFormat('MM/dd/yyyy hh:mm a');
  var outputDate = outputFormat.format(inputDate);
  return outputDate;
}

DateFormatexample() {
  DateTime time = DateTime.now();
  DateTime parse = DateFormat('yyyy-MM-dd').parse(time.toString());
  return parse;
}

class WeatherStationService {
  List<Weaterstation> data = [];
  List<Chart> chartdaya = [];
  Future<WeaterData2?> WeatherStationdata(String Deviceid) async {
    data = [];
    String path = '$watherstationURL/FarmerWatherStationdata/weatherdatav2/' +
        Deviceid.toString();
    print("path $path");
    Map<String, dynamic> response = await ApiHelper().get(path);

    if (response['susess'] ?? false) {
      print(response['data']);
      // for (int i = 0; i < response['data'].length; i++) {
        Dateformate(response['data'][0]['CreateDate']);
        Dateformate(response['data'][0]['CreateDate']);
        // data.add(WeaterData2.fromJson(response['data'][0]));
      // print(  Weaterstation.fromJson(response['data'][0]));

      return WeaterData2.fromJson(response);
    } else if (response.isNotEmpty) {
      return null;
    } else {
      FlutterToastUtil.showErrorToast(
          'Error while retrieving data. Please try again later.'.i18n);
    }
    return null;
  }

  Future<double?> onehorrain(deviceid) async {
    String path =
        '$watherstationURL/FarmerWatherStationdata/rainlastweeklasthour/${deviceid}';

    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['status'] ?? false) {
      return null;
    } else if (response.isNotEmpty) {
      return double.parse(response['data'].toString());
    } else {
      FlutterToastUtil.showErrorToast(
          'Error while retrieving data. Please try again later.'.i18n);
    }
    // return null;
  }

  Future<List<Chart>?> chartdara(deviceid, startdate, enddate, type) async {
    chartdaya = [];
    String path =
        '$watherstationURL/FarmerWatherStationdata/chartdatesbetween/$deviceid/$startdate/$enddate/$type';
    print("path $path");
    Map<String, dynamic> response = await ApiHelper().get(path);
    print("responce $response");
    if (response['status'] ?? false) {
      for (int i = 0; i < response['data'].length; i++) {
        chartdaya.add(Chart.fromJson(response['data'][i]));
      }
      return chartdaya;
    } else if (response.isNotEmpty) {
      return null;
    } else {
      FlutterToastUtil.showErrorToast(
          'Error while retrieving data. Please try again later.'.i18n);
    }
    return null;
  }

  Future<double?> lastday(deviceid) async {
    String path =
        '$watherstationURL/FarmerWatherStationdata/rainlastdayaverage/${deviceid}';

    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['status'] ?? false) {
      return null;
    } else if (response.isNotEmpty) {
      if (response['data'] != null) {
        return double.parse(response['data'].toString());
      }
      return 0.00;
    } else {
      FlutterToastUtil.showErrorToast(
          'Error while retrieving data. Please try again later.'.i18n);
    }
    // return null;
  }

  Future<double?> week(deviceid) async {
    String path =
        '$watherstationURL/FarmerWatherStationdata/rainlastweekaverage/${deviceid}';
    print("weekpath $path");
    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['status'] ?? false) {
      return null;
    } else if (response.isNotEmpty) {
      if (response['data'] != null) {
        return double.parse(response['data'].toString());
      }
      return 0.00;
    } else {
      FlutterToastUtil.showErrorToast(
          'Error while retrieving data. Please try again later.'.i18n);
    }
    // return null;
  }

  Future<double?> month(deviceid) async {
    String path =
        '$watherstationURL/FarmerWatherStationdata/rainlastweeklastmonth/${deviceid}';
    print("one month path$path");
    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['status'] ?? false) {
      return null;
    } else if (response.isNotEmpty) {
      if (response['data'] != null) {
        return double.parse(response['data'].toString());
      }
      return 0.0;
    } else {
      FlutterToastUtil.showErrorToast(
          'Error while retrieving data. Please try again later.'.i18n);
    }
    // return null;
  }

  Future<double?> total(deviceid) async {
    String path =
        '$watherstationURL/FarmerWatherStationdata/rainaveragetotall/${deviceid}';
    print("total path $path");
    Map<String, dynamic> response = await ApiHelper().get(path);
    if (response['status'] ?? false) {
      return null;
    } else if (response.isNotEmpty) {
      return response['data'] != null
          ? double.parse(response['data'].toString())
          : 0;
    } else {
      FlutterToastUtil.showErrorToast(
          'Error while retrieving data. Please try again later.'.i18n);
    }
    // return null;
  }
}
