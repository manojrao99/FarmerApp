class WeaterData2 {
  bool? susess;
  List<Data>? data;
  String? message;

  WeaterData2({this.susess, this.data, this.message});

  WeaterData2.fromJson(Map<String, dynamic> json) {
    susess = json['susess'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['susess'] = this.susess;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? createDate;
  double? currentTemperature;
  double? currentHumidity;
  double? currentWindDirectionDegree;
  double? currentWindSpeedKmHr;
  double? currentRadiationWM2;
  String ?HardwareSerialnumber;
  double? currentRain;
  String? deviceID;
  double? highfHumidity;
  double? lowfHumidity;
  double? highfTemperature;
  double? lowfTemperature;
  double? highRadiationWM2;
  double? lowRadiationWM2;
  double? highWindSpeedKmHr;
  double? lowWindSpeedKmHr;
  double? sumRainmmComputedLastHour;
  double? sumRainmmComputedLastDay;
  double? sumRainmmComputedLastWeek;
  double? sumRainmmComputedLastMonth;
  double? totalrainmm;

  Data(
      {this.createDate,
        this.currentTemperature,
        this.currentHumidity,
        this.currentWindDirectionDegree,
        this.currentWindSpeedKmHr,
        this.currentRadiationWM2,
        this.currentRain,
        this.deviceID,
        this.highfHumidity,
        this.lowfHumidity,
        this.highfTemperature,
        this.lowfTemperature,
        this.highRadiationWM2,
        this.lowRadiationWM2,
        this.HardwareSerialnumber,
        this.highWindSpeedKmHr,
        this.lowWindSpeedKmHr,
        this.sumRainmmComputedLastHour,
        this.sumRainmmComputedLastDay,
        this.sumRainmmComputedLastWeek,
        this.sumRainmmComputedLastMonth,
        this.totalrainmm});

  Data.fromJson(Map<String, dynamic> json) {
    createDate = json['CreateDate'];
    currentTemperature = (json['currentTemperature']??0).toDouble();;
    currentHumidity = (json['currentHumidity']??0).toDouble();
    currentWindDirectionDegree = (json['currentWindDirectionDegree']??0).toDouble();;
    currentWindSpeedKmHr = (json['currentWindSpeedKmHr']??0).toDouble();;
    currentRadiationWM2 = (json['currentRadiationWM2']??0).toDouble();;
    currentRain = (json['currentRain']??0).toDouble();;
    deviceID = json['DeviceID'];
    highfHumidity = (json['highfHumidity']??0).toDouble();
    lowfHumidity = (json['lowfHumidity']??0).toDouble();
    HardwareSerialnumber=json['HardwareSerialnumber'];
    highfTemperature = (json['highfTemperature']??0).toDouble();
    lowfTemperature = (json['lowfTemperature']??0).toDouble();
    highRadiationWM2 = (json['highRadiationWM2']??0).toDouble();
    lowRadiationWM2 = (json['lowRadiationWM2']??0).toDouble();
    highWindSpeedKmHr = (json['highWindSpeedKmHr']??0).toDouble();
    lowWindSpeedKmHr = (json['lowWindSpeedKmHr']??0).toDouble();
    sumRainmmComputedLastHour = (json['SumRainmmComputedLastHour']??0).toDouble();
    sumRainmmComputedLastDay = (json['SumRainmmComputedLastDay']??0).toDouble();
    sumRainmmComputedLastWeek = (json['SumRainmmComputedLastWeek']??0).toDouble();
    sumRainmmComputedLastMonth = (json['SumRainmmComputedLastMonth']??0).toDouble();
    totalrainmm = (json['Totalrainmm']??0).toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CreateDate'] = this.createDate;
    data['currentTemperature'] = this.currentTemperature;
    data['currentHumidity'] = this.currentHumidity;
    data['currentWindDirectionDegree'] = this.currentWindDirectionDegree;
    data['currentWindSpeedKmHr'] = this.currentWindSpeedKmHr;
    data['currentRadiationWM2'] = this.currentRadiationWM2;
    data['currentRain'] = this.currentRain;
    data['DeviceID'] = this.deviceID;
    data['highfHumidity'] = this.highfHumidity;
    data['lowfHumidity'] = this.lowfHumidity;
    data['highfTemperature'] = this.highfTemperature;
    data['lowfTemperature'] = this.lowfTemperature;
    data['highRadiationWM2'] = this.highRadiationWM2;
    data['lowRadiationWM2'] = this.lowRadiationWM2;
    data['highWindSpeedKmHr'] = this.highWindSpeedKmHr;
    data['lowWindSpeedKmHr'] = this.lowWindSpeedKmHr;
    data['SumRainmmComputedLastHour'] = this.sumRainmmComputedLastHour;
    data['SumRainmmComputedLastDay'] = this.sumRainmmComputedLastDay;
    data['SumRainmmComputedLastWeek'] = this.sumRainmmComputedLastWeek;
    data['SumRainmmComputedLastMonth'] = this.sumRainmmComputedLastMonth;
    data['Totalrainmm'] = this.totalrainmm;
    return data;
  }
}

