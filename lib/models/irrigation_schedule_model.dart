import 'package:flutter/material.dart';

class IrrigationScheduleModel {
  int? id;
  String? name;
  late int farmerFarmLandDetailsID;
  String? farmerBlockLinkedIDs;
  String? farmerBlockLinkedNames;
  DateTime? scheduleFromDate;
  TimeOfDay? scheduleTime;
  DateTime? scheduleToDate;
  bool ?ScheduleActiveYN;

 String? CreatDate;
  String ?AlterDate;
  DateTime ?DeleteDate;

 bool? DeleteYN;
  String? scheduleWeeks;
  String? scheduleType;
  String? scheduleIrrigationType;
  double? scheduleIrrigationValue;
  DateTime? schedulePreviousSuccessDateTime;
  DateTime? scheduleNextRunDateTime;
  double? scheduleSoilMoistureLow;
  double? scheduleSoilMoistureHigh;
  int soilL1 = 0;
  int soilL2 = 0;
  int soilL3 = 0;
  int soilL4 = 0;

  IrrigationScheduleModel(
      {required this.farmerFarmLandDetailsID,
      this.id,
      this.farmerBlockLinkedIDs,
      this.farmerBlockLinkedNames,
      this.scheduleFromDate,
      this.scheduleToDate,
      this.scheduleWeeks,
      this.name,
      this.scheduleIrrigationType,
      this.scheduleIrrigationValue,
      this.scheduleNextRunDateTime,
      this.schedulePreviousSuccessDateTime,
      this.scheduleType,
      this.scheduleTime,
      this.scheduleSoilMoistureHigh,
      this.scheduleSoilMoistureLow,
      this.soilL1 = 0,
      this.soilL2 = 0,
      this.soilL3 = 0,
      this.soilL4 = 0,
      this.AlterDate,this.CreatDate,
        this.DeleteDate,
        this.DeleteYN,
        this.ScheduleActiveYN=false,

      });

  factory IrrigationScheduleModel.fromJson(Map<String, dynamic> json) {
    String temp = (json['ScheduleTime']).toString().substring(11, 16);
    TimeOfDay scheduleTime = TimeOfDay(
        hour: int.parse(temp.split(":")[0]),
        minute: int.parse(temp.split(":")[1]));
    print(json);
    print("checking delete yn ${ json["DeleteYN"]}");

    return IrrigationScheduleModel(
        id: json['ID'] ?? 0,
        name: json['Name'],
        farmerFarmLandDetailsID: json['FarmerFarmLandDetailsID'] ?? 0,
        farmerBlockLinkedIDs: json['FarmerBlockLinkedIDs'],
        farmerBlockLinkedNames: json['FarmerBlockLinkedNames'],
        scheduleFromDate: ((json['ScheduleFromDate'] ?? '') != '')
            ? DateTime.tryParse(json['ScheduleFromDate'])
            : null,
        scheduleToDate: ((json['ScheduleToDate'] ?? '') != '')
            ? DateTime.tryParse(json['ScheduleToDate'])
            : null,
        scheduleWeeks: json['ScheduleWeeks'],
        scheduleIrrigationType: json['ScheduleIrrigationType'],
        scheduleIrrigationValue: json['ScheduleIrrigationValue'] + 0.0,
        scheduleNextRunDateTime: (json['ScheduleNextRunDateTime'] != null)
            ? DateTime.tryParse(json['ScheduleNextRunDateTime'])
            : null,
        schedulePreviousSuccessDateTime:
            (json['ScheduleNextRunDateTime'] != null)
                ? DateTime.tryParse(json['ScheduleNextRunDateTime'])
                : null,
        scheduleType: json['ScheduleType'],
        scheduleTime: scheduleTime,
        scheduleSoilMoistureLow: (json["ScheduleSoilMoistureLow"] ?? 0) + 0.0,
        scheduleSoilMoistureHigh: (json["ScheduleSoilMoistureHigh"] ?? 0) + 0.0,
        soilL1: (json["SoilL1"] ?? 0),
        soilL2: (json["SoilL2"] ?? 0),
        soilL3: (json["SoilL3"] ?? 0),
        soilL4: (json["SoilL4"] ?? 0),
    AlterDate: json["AlterDate"],
      CreatDate:json["CreatDate"],
      DeleteDate: ((json['DeleteDate'] ?? '') != '')
          ? DateTime.tryParse(json['DeleteDate'])
          : null,
      DeleteYN: json["DeleteYN"]??false,
      ScheduleActiveYN: json["ScheduleActiveYN"]??false,

    );
  }

  Map<String, dynamic> toMap(IrrigationScheduleModel scheduleModel) {
    return {
      "ID": scheduleModel.id,
      "FarmerFarmLandDetailsID": scheduleModel.farmerFarmLandDetailsID,
      "FarmerBlockLinkedIDs": scheduleModel.farmerBlockLinkedIDs,
      "ScheduleFromDate": (scheduleModel.scheduleFromDate ?? DateTime.now())
          .toIso8601String()
          .substring(0, 10),
      "ScheduleToDate": (scheduleModel.scheduleToDate != null)
          ? scheduleModel.scheduleToDate!.toIso8601String().substring(0, 10)
          : DateTime.now().toIso8601String().substring(0, 10),
      "ScheduleWeeks": scheduleModel.scheduleWeeks,
      "Name": scheduleModel.name,
      "ScheduleIrrigationType": scheduleModel.scheduleIrrigationType,
      "ScheduleIrrigationValue": scheduleModel.scheduleIrrigationValue,
      "ScheduleNextRunDateTime": scheduleModel.scheduleNextRunDateTime != null
          ? scheduleModel.scheduleNextRunDateTime!
              .toIso8601String()
              .substring(0, 10)
          : '',
      "SchedulePreviousSuccessDateTime":
          (scheduleModel.schedulePreviousSuccessDateTime ?? DateTime.now())
              .toIso8601String()
              .substring(0, 10),
      "ScheduleType": scheduleModel.scheduleType,
      "ScheduleTime": scheduleTime != null
          ? ((scheduleTime!.hour == 0)
                  ? '00'
                  : (scheduleTime!.hour < 10)
                      ? '0' + (scheduleTime!.hour).toString()
                      : scheduleTime!.hour.toString()) +
              ':' +
              ((scheduleTime!.minute == 0)
                  ? '00'
                  : scheduleTime!.minute < 10
                      ? '0' + scheduleTime!.minute.toString()
                      : scheduleTime!.minute.toString())
          : '',
      "ScheduleSoilMoistureLow": scheduleSoilMoistureLow,
      "ScheduleSoilMoistureHigh": scheduleSoilMoistureHigh,
      "SoilL1": soilL1,
      "SoilL2": soilL2,
      "SoilL3": soilL3,
      "SoilL4": soilL4,
      "AlterDate": AlterDate,
      "CreatDate":CreatDate,
      "DeleteDate": DeleteDate,
      "DeleteYN":DeleteYN??false,
      "ScheduleActiveYN": ScheduleActiveYN??false,
    };
  }
}
