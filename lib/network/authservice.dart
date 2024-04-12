import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login.dart';

class AuthService {
  static const String lastActivityKey = 'last_activity';
  static const int maxInactivityDurationInDays = 15;

  final StreamController<bool> _authStateController = StreamController<bool>();

  Stream<bool> get authStateStream => _authStateController.stream;

  bool _isLoggedIn = false;
  late Timer _inactivityTimer;

  final _secureStorage = FlutterSecureStorage();

  UserModel? _userModel; // Store user data in-memory

  AuthService() {
    _initialize();
  }
  Future<bool> doesUserExist() async {
    final userData = await _secureStorage.read(key: 'user_data');

    // If user data is not null, consider the user exists
    return  userData != null;
  // return true;
  }
  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(lastActivityKey) ?? false;
    _authStateController.add(_isLoggedIn);

    if (_isLoggedIn) {
      // Retrieve user data when initializing
      await _getUserData();
      _startInactivityTimer();
    }
  }

  Future<void> login({required String username, required String password, required String id,required bool farmerdashboard,required bool polyhouse,required bool weaterstation}) async {
    // Save login state
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(lastActivityKey, true);
    _isLoggedIn = true;
    _authStateController.add(true);
    await _secureStorage.write(key: 'user_data', value: _userToJson(username, password, id,farmerdashboard,polyhouse,weaterstation));
    _userModel = UserModel(username: username, password: password, id: id,farmerDashboard:farmerdashboard ,polyhouse: polyhouse,weaterstation:weaterstation);

    _startInactivityTimer();
  }

  Future<void> logout() async {
    // Remove login state
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(lastActivityKey, false);
    _isLoggedIn = false;
    _authStateController.add(false);

    // Remove sensitive data
    await _secureStorage.delete(key: 'user_data');

    _cancelInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer = Timer(Duration(days: maxInactivityDurationInDays), () {
      logout();
    });
  }

  void _cancelInactivityTimer() {
    _inactivityTimer.cancel();
  }

  Future<void> _getUserData() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      print('print ${userData}');
      _userModel = _userFromJson(userData);
    }
  }

  Future<UserModel?> getUserModel() async{
    await _getUserData();
    return _userModel;
  }

  void userPerformedAction() {
    // Reset the inactivity timer when the user performs an action
    _cancelInactivityTimer();
    _startInactivityTimer();
  }

  // Convert UserModel to JSON String
  String _userToJson(String username, String password, String id, bool farmerDashboard, bool polyhouse,bool weaterstation) {
    final userModel = UserModel(username: username, password: password, id: id,farmerDashboard: farmerDashboard,polyhouse: polyhouse,weaterstation: weaterstation );
    return userModel.toJson().toString();
  }

  // Convert JSON String to UserModel
  UserModel _userFromJson(String jsonData) {
    JsonCodec codec = new JsonCodec();
    try {
      String name = jsonData;
      List<String> str = name.replaceAll("{","").replaceAll("}","").split(",");
      Map<String,dynamic> result = {};
      for(int i=0;i<str.length;i++){
        List<String> s = str[i].split(":");
        result.putIfAbsent(s[0].trim(), () => s[1].trim());
      }
      print(result);
      // String jsonString =jsonData;
      // // Map<String, dynamic> valueMap = json.decode(jsonData.trim());
      // // print(valueMap);
      // Map<String, dynamic> data = json.decode(jsonString);
      // print(data['username']);
      // Map<String, dynamic> valueMap = codec.decode(jsonData.toString());
      // print(valueMap);
      return UserModel.fromJson(result);
    } catch (e) {
      print("Error decoding JSON: $e");
      throw e; // Rethrow the exception or handle it as needed
    }
  }


  void dispose() {
    _authStateController.close();
  }
}
