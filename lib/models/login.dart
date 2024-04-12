import 'package:json_annotation/json_annotation.dart';

part 'login.g.dart';

@JsonSerializable()
class UserModel {
  late String username;
  late String password;
  late String id;
  late bool farmerDashboard;
  late bool polyhouse;
  late bool weaterstation;

  UserModel({required this.farmerDashboard,required this.polyhouse,required this.weaterstation,required this.username, required this.password, required this.id});

  // Factory method to create a UserModel from a Map
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}


// flutter pub run build_runner build