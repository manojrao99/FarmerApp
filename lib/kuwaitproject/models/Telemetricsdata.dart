class output {
  String? sensorDataPacketDateTime;
  String? createDate;
  String? deviceID;
  double? mAXHumidity;
  double? mAXTemeprature;
  double? mINTemperature;
  double? mINHumidity;
  double? temperature;
  double? humidity;

  output(
      {this.sensorDataPacketDateTime,
        this.createDate,
        this.deviceID,
        this.mAXHumidity,
        this.mAXTemeprature,
        this.mINTemperature,
        this.mINHumidity,
        this.temperature,
        this.humidity});

  output.fromJson(Map<String, dynamic> json) {
    sensorDataPacketDateTime = json['SensorDataPacketDateTime'];
    createDate = json['CreateDate'];
    deviceID = json['DeviceID'];
    mAXHumidity = json['MAXHumidity']==null?0.0:json['MAXHumidity'].toDouble();
    mAXTemeprature = json['MAXTemeprature']==null?0.0:json['MAXTemeprature'].toDouble();
    mINTemperature = json['MINTemperature']==null?0.0:json['MINTemperature'].toDouble();
    mINHumidity = json['MINHumidity']==null?0.0:json['MINHumidity'].toDouble();
    temperature = json['temperature']==null?0.0:json['temperature'].toDouble();
    humidity = json['Humidity']==null?0.0:json['Humidity'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SensorDataPacketDateTime'] = this.sensorDataPacketDateTime;
    data['CreateDate'] = this.createDate;
    data['DeviceID'] = this.deviceID;
    data['MAXHumidity'] = this.mAXHumidity;
    data['MAXTemeprature'] = this.mAXTemeprature;
    data['MINTemperature'] = this.mINTemperature;
    data['MINHumidity'] = this.mINHumidity;
    data['temperature'] = this.temperature;
    data['Humidity'] = this.humidity;
    return data;
  }
}