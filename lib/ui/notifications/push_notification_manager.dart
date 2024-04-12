import 'package:cultyvate/utils/flutter_toast_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/api_helper.dart';
import '../../utils/constants.dart';
import '../../utils/string_extension.dart';

enum AppState {
  foreground,
  background,
  terminated,
}

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  /// Function to setup up push notifications and its configurations
  Future<void> init() async {
    await _setFCMToken();
    _configure();
  }

  /// Function to ask user for push notification permissions and if provided, save FCM Token in persisted local storage.
  Future<void> _setFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      /// requesting permission for [alert], [badge] & [sound]. Only for iOS
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      /// saving token only if user granted access.
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        print('FirebaseMessaging token: $token');
      }
    } catch (e) {
      print('FirebaseMessaging error: ' + e.toString());
    }
  }

  /// Function to configure the functionality of displaying and tapping on notifications.
  void _configure() async {
    /// For iOS only, setting values to show the notification when the app is in foreground state.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    /// handler when notification arrives. This handler is executed only when notification arrives in foreground state.
    /// For iOS, OS handles the displaying of notification
    /// For Android, we push local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showForegroundNotificationInAndroid(message);
    });

    /// handler when user taps on the notification.
    /// For iOS, it gets executed when the app is in [foreground] / [background] state.
    /// For Android, it gets executed when the app is in [background] state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotification(message: message.data, appState: AppState.foreground);
    });

    /// If the app is launched from terminated state by tapping on a notification, [getInitialMessage] function will return the
    /// [RemoteMessage] only once.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    /// if [RemoteMessage] is not null, this means that the app is launched from terminated state by tapping on the notification.
    if (initialMessage != null) {
      _handleNotification(
          message: initialMessage.data, appState: AppState.terminated);
    }
  }

  void _showForegroundNotificationInAndroid(RemoteMessage message) async {
    // FlutterToastUtil.showSuccessToast("New Notification: ".i18n +
    //     (message.notification?.title ?? '') +
    //     (message.notification?.body ?? ''),"",1);
    FlutterToastUtil.showSuccessToast(
        (message.notification?.title ?? '') +
        (message.notification?.body ?? ''),"",1);
    print('here');
  }

  void _handleNotification({
    Map<String, dynamic>? message,
    AppState? appState,
  }) async {
    print(
        'PushNotificationsManager: _handleNotification ${message.toString()} ${appState.toString()}');
  }

  Future<void> saveFCMToken(String token, int id) async {
   print("user save list");
    var result;

    Map<String, dynamic> data = {"userToken": token, "farmerID": id};
    print(cultyvateURL+'/farmer/farmertoken');
   print(data);
    result = await ApiHelper().post(path: cultyvateURL+'/farmer/farmertoken', postData: data);
    print("result all data result all data ${result}");
    if (result["success"] ?? false) {
      final SharedPreferences _prefs = await SharedPreferences.getInstance();
      await _prefs.setBool("TOKENSAVED", true);
    }
    return result;
  }
}
