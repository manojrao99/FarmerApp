class Weaterstation {
  String? createDate;
  String? deviceID;
  String? hardwareSerialNumber;
  String? currentTemperature;
  String? currentHumidity;
  String? currentWindDirectionDegree;
  String? currentWindSpeedKmHr;
  String? currentRadiationWM2;
  String? currentRain;
  String? highfHumidity;
  String? lowfHumidity;
  String? highfTemperature;
  String? lowfTemperature;
  String? highRadiationWM2;
  String? lowRadiationWM2;
  String? highWindSpeedKmHr;
  String? lowWindSpeedKmHr;

  Weaterstation(
      {this.createDate,
        this.deviceID,
        this.hardwareSerialNumber,
        this.currentTemperature,
        this.currentHumidity,
        this.currentWindDirectionDegree,
        this.currentWindSpeedKmHr,
        this.currentRadiationWM2,
        this.currentRain,
        this.highfHumidity,
        this.lowfHumidity,
        this.highfTemperature,
        this.lowfTemperature,
        this.highRadiationWM2,
        this.lowRadiationWM2,
        this.highWindSpeedKmHr,
        this.lowWindSpeedKmHr});

  factory Weaterstation.fromJson(Map<String, dynamic> json) {
    return Weaterstation(

        deviceID : json['DeviceID'].toString(),
        hardwareSerialNumber : json['HardwareSerialNumber'].toString(),
        currentHumidity : json['currentHumidity'].toString(),
      createDate: json['CreateDate'].toString(),
        currentTemperature : json['currentTemperature'].toString(),
        currentRain: json['currentRain'].toString(),
        currentRadiationWM2: json['currentRadiationWM2'].toString(),
        currentWindDirectionDegree:json['currentWindDirectionDegree'].toString(),
        currentWindSpeedKmHr:json['currentWindSpeedKmHr'].toString(),
        highfHumidity: json['highfHumidity'].toString(),
        highfTemperature: json['highfTemperature'].toString(),
        highRadiationWM2: json['highRadiationWM2'].toString(),
        lowRadiationWM2: json['lowRadiationWM2'].toString(),
   highWindSpeedKmHr: json['highWindSpeedKmHr'].toString(),
      lowfHumidity:  json['lowfHumidity'].toString(),
      lowfTemperature: json['lowfTemperature'].toString(),
      lowWindSpeedKmHr: json['lowWindSpeedKmHr'].toString(),
    );

  }

}


class Chart {
  String? forDate;
  int? onHour;
  double? temperature;
  double? humidity;

  Chart({this.forDate, this.onHour, this.temperature, this.humidity});
   factory Chart.fromJson(Map<String, dynamic> json) {
     return Chart(
    forDate : json['ForDate'],
    onHour :json['OnHour'],
    temperature : json['Temperature'].toDouble(),
    humidity : json['Humidity'].toDouble(),
     );
     }

}