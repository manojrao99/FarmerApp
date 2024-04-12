// API helper class implements Get, Post, Patch, Delele methods

import 'package:dio/dio.dart';
import '../utils/constants.dart';

// Define base url constant (ideally kept in separate constants file)
// ignore: constant_identifier_names
// Postman mock server - refer first-app collection

class ApiHelper {
  static final ApiHelper _apihelper = ApiHelper._internal();

  factory ApiHelper() {
    return _apihelper;
  }
  ApiHelper._internal();
  // Common headers to be used across API methods
  Map<String, String> header = {
    "content-type": "application/json",
    "API_KEY": apiKey
  };
  final dio = Dio(); // Single instance var used across multiple calls

  // Path is expected to contain the complete url including parameters if any
  // for example http://abc.com/profile?id=123
  Future<Map<String, dynamic>> get(String path) async {
    Map<String, dynamic> returnData = {};
    try {
      print('path $path');
      Response response = await dio.get(path, options: Options(headers: header));

      // print('manoj notifications testing, $path ${response.data}');
      if (response.statusCode == 200) {
        returnData = response.data;
      }
    } catch (error) {
      throw error;
      print('GET Error: ${error.toString()}');
    }
    return returnData;
  }

  // Use to create data by calling respective dio method.
  // postData is the complete data set to be created by API
  Future<Map<String, dynamic>> post(
      {required String path, required Map<String, dynamic> postData}) async {
    Map<String, dynamic> returnMap = {};
    try {
      Response response = await dio.post(path,
          data: postData, options: Options(headers: header));
      if (response.statusCode == 200) {
        print("responce checking $response");
        returnMap = response.data;
      }
    } catch (error) {
        throw error;
      print('POST Error: ${error.toString()}');
    }
    return returnMap;
  }

  // Use to update data by calling respective dio method.
  // patchData is the complete data set to be updated by API
  Future<Map<String, dynamic>> patch(
      {required String path, required Map<String, dynamic> patchData}) async {
    Map<String, dynamic> returnMap = {};
    try {
      Response response = await dio.patch(path,
          data: patchData, options: Options(headers: header));
      if (response.statusCode == 200) {
        returnMap = response.data;
      }
    } catch (error) {
      print('PATCH Error: ${error.toString()}');
    }
    return returnMap;
  }

  Future<Map<String, dynamic>> put(
      {required String path, required Map<String, dynamic> putData}) async {
    Map<String, dynamic> returnMap = {};
    try {
      Response response =
          await dio.put(path, data: putData, options: Options(headers: header));
      if (response.statusCode == 200) {
        returnMap = response.data;
      }
    } catch (error) {
      print('PUT Error: ${error.toString()}');
    }
    return returnMap;
  }

  // Path contains parameters to uniqely identify the data to be deleted by API
  Future<Map<String, dynamic>> delete(String path) async {
    Map<String, dynamic> returnMap = {};
    try {
      Response response =
          await dio.delete(path, options: Options(headers: header));
      if (response.statusCode == 200) {
        returnMap = response.data;
      }
    } catch (error) {
      print('Delete Error: ${error.toString()}');
    }
    return returnMap;
  }
}
