import 'package:flutter_dotenv/flutter_dotenv.dart';

const assetImagePath = 'assets/images/';
const weatherAPIURL = 'https://api.openweathermap.org/data/2.5';
const weatherIconURL = 'https://openweathermap.org/img/wn';
String action_check='Action';
var farmerIDname;
// var selectedID;
String cultyvateURL = dotenv.env['CULTYVATE_URL'] ?? "";
String watherstationURL = dotenv.env['WEATHER_STATION_URL'] ?? "";
String downlinkURL = dotenv.env['DOWNLINK_URL'] ?? "";
String apiKey = dotenv.env['API_KEY'] ?? "";
String downlinkPayloadOn = 'AwER';
String downlinkPayloadOff = 'AwAR';
String downlinkBearer = dotenv.env['BEARER_TOKEN'] ?? "";
const localeKey = 'locale';
String homeURL = "https://www.cultyvate.com/";
String irrigationAdvisoryURL = "https://www.cultyvate.com/";
String howITWorksURL = 'https://www.cultyvate.com/research/';
String offersSolutionsURL = 'https://www.cultyvate.com/#solutions';
String termsAndConditionsURL = 'https://www.cultyvate.com';
String updateApp = 'A new version of cultYvate app is available';
String language = "en";
String userToken = '';
String versionglobaly='';
