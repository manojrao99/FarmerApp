class CurrentWeatherModel {
  int id;
  DateTime currentDate;
  DateTime sunrise;
  DateTime sunset;
  double temperature;
  double humidity;

  double feels_like;
  double windSpeed;
  String main;
  String description;
  String icon;
  List<DailyWeatherModel> dailyWeather;
  CurrentWeatherModel({
    required this.id,
    required this.currentDate,
    required this.sunrise,
    required this.sunset,
    required this.humidity,
    required this.feels_like,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.main,
    required this.windSpeed,
    required this.dailyWeather,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    List<DailyWeatherModel> dailyWeatherList = [];

    for (int i = 0; i < 8; i++) {
      dailyWeatherList.add(DailyWeatherModel.fromJson(json['daily'][i]));
    }
    return CurrentWeatherModel(
      id: json['current']['weather'][0]['id'] ?? 0,
      currentDate:
          DateTime.fromMillisecondsSinceEpoch(json['current']['dt'] * 1000),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          json['current']['sunrise'] * 1000),
      sunset:
          DateTime.fromMillisecondsSinceEpoch(json['current']['sunset'] * 1000),
      humidity: double.parse(json['current']['humidity'].toString()),
      temperature: double.parse(json['current']['temp'].toString()),
      description: json['current']['weather'][0]['description'] ?? '',
      icon: json['current']['weather'][0]['icon'] ?? '',
      main: json['current']['weather'][0]['main'] ?? '',
      feels_like:  json['current']['feels_like'],
      windSpeed: double.parse(json['current']['wind_speed'].toString()),
      dailyWeather: dailyWeatherList,
    );
  }
}

class DailyWeatherModel {
  DateTime weatherDate;
  String description;
  double temperature;
  double min;
  double max;
  String icon;
  DailyWeatherModel(
      {required this.weatherDate,
      required this.description,
      required this.temperature,
      required this.min,
      required this.max,
      required this.icon});

  factory DailyWeatherModel.fromJson(Map<String, dynamic> json) =>
      DailyWeatherModel(
          weatherDate: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
          description: json['weather'][0]['description'],
          temperature: double.parse(json['temp']['day'].toString()),
          min: double.parse(json['temp']['min'].toString()),
          max: double.parse(json['temp']['max'].toString()),
          icon: json['weather'][0]['icon'] ?? '');
}
