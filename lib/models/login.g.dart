// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************
bool stringToBool(String value) {
      return value.toLowerCase() == 'true';
}
UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      farmerDashboard: stringToBool(json['farmerDashboard']) as bool,
      polyhouse: stringToBool(json['polyhouse'] )as bool,
      weaterstation: stringToBool(json['weaterstation']) as bool,
      username: json['username'] as String,
      password: json['password'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'id': instance.id,
      'farmerDashboard': instance.farmerDashboard,
      'polyhouse': instance.polyhouse,
      'weaterstation': instance.weaterstation,
    };
