class TelematicModel {
  int id;
  String? deviceID;
  bool? online;
  DateTime? lastOperatingDateTime;
  DateTime? operatingSinceDateTime;
  double? l1;
  double? l2;
  double? l3;
  double? l4;
  bool ?Activescheduler;
  bool ?scheduletypesensor;
  int ?l1triger;
  int?l2triger;
  int ?l3triger;
  int ?l4triger;
  String? l1Color;
  String? l2Color;
  String? l3Color;
  String? l4Color;
  double emVolatgeB;
  double emVolatgeR;
  double emVolatgeY;
  double? emCurrentB;
  double? emCurrentR;
  double? emCurrentY;
  bool?activeschduleDevive;
  double ?GateWaySNR;
  double ? GateWayRSSI;
  String?tempurature;
  String ?humidity;
  int ?InterruptFlag;
  double? batteryMV;
  DateTime? sensorDataPacketDateTime;
  int ?ro2status;
  int? operatingMode;

  TelematicModel(
      {required this.id,
      this.deviceID,
        this.GateWaySNR,
      this.sensorDataPacketDateTime,
      this.online,
      this.lastOperatingDateTime,
      this.operatingSinceDateTime,
      this.l1,
      this.l2,
        this.InterruptFlag,
      this.l3,
      this.l4,
        this.humidity,
        this.tempurature,
        this.activeschduleDevive,
      this.l1Color,
      this.l2Color,
      this.l3Color,
      this.l4Color,
      this.batteryMV,
      this.emCurrentB,
      this.emCurrentR,
      this.emCurrentY,
      required this.emVolatgeB,
      required this.emVolatgeR,
      required this.emVolatgeY,
        this.ro2status,
      this.operatingMode,
      this.Activescheduler,
        this.l1triger,
        this.l2triger,
        this.l3triger,
        this.l4triger,
        this.scheduletypesensor,
        this.GateWayRSSI

      });

  factory TelematicModel.fromJson(Map<String, dynamic> json) {
    print("json values ${json}");
    if ((json['ID'] ?? 0) == 0) {
      return TelematicModel(id: 0, deviceID: json['deviceID'], emVolatgeB: 0, emVolatgeR: 0, emVolatgeY: 0);
    } else {
      return TelematicModel(
        id: (json['ID'] ?? 0),
        deviceID: json['DeviceID'],
        online: json['Online'],
        lastOperatingDateTime: (json['LastOperatingDateTime'] != null)
            ? DateTime.tryParse(json['LastOperatingDateTime'])
            : null,
        operatingSinceDateTime: json['OperatingSinceDateTime'] != null
            ? DateTime.tryParse(json['OperatingSinceDateTime'] ?? '')
            : null,
        l1Color: (json['L1Color'] ?? ''),
        l2Color: (json['L2Color'] ?? ''),
        l3Color: (json['L3Color'] ?? ''),
        l4Color: (json['L4Color'] ?? ''),
        GateWayRSSI: (json['GateWayRSSI'].toDouble()),
        GateWaySNR: (json['GateWaySNR'].toDouble()),
        tempurature: (json['Tempurature'].toString()??'0.0'),
        humidity:(json['Humidity'].toString()??'0.0'),
        l1: (json['L1'] ?? 0) + 0.0,
        l2: (json['L2'] ?? 0) + 0.0,
        l3: (json['L3'] ?? 0) + 0.0,
        l4: (json['L4'] ?? 0) + 0.0,
        Activescheduler:(json['Activescheduler'] ?? false) ,
          activeschduleDevive:(json['activeschduleDevive'] ?? false) ,
        l1triger:(json['l1triger'] ?? 0),
        scheduletypesensor: json['scheduletypesensor'],
        l2triger:(json['l2triger'] ?? 0),
        l3triger: (json['l3triger'] ?? 0),
        InterruptFlag: (json['InterruptFlag']??0),
        l4triger:(json['l4triger'] ?? 0),
        batteryMV: (json['BatteryMV'] ?? 0) + 0.0,
        emCurrentB: (json['EMCurrentB'] ?? 0) + 0.0,
        emCurrentR: (json['EMCurrentR'] ?? 0) + 0.0,
        emCurrentY: (json['EMCurrentY'] ?? 0) + 0.0,
        emVolatgeB: (json['EMVoltageB'] ?? 0) + 0.0,
        emVolatgeR: (json['EMVoltageR'] ?? 0) + 0.0,
        emVolatgeY: (json['EMVoltageY'] ?? 0) + 0.0,

        operatingMode: json['OperatingMode'].runtimeType==bool?json['OperatingMode']==true?1:0: json['OperatingMode'],
        ro2status: json['Ro2status'].runtimeType==bool?json['Ro2status']==true?1:0: json['Ro2status'],
        sensorDataPacketDateTime:
            DateTime.tryParse(json['SensorDataPacketDateTime']),
      );
    }
  }
}
