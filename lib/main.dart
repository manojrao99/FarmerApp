import 'package:cultyvate/ui/internetcheck/getXcontroller.dart';
import 'package:flutter/material.dart';
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';
import './utils/constants.dart';
import './utils/string_extension.dart';
import './ui/login/choose_language.dart';
import './ui/notifications/push_notification_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
void main() async {
  await dotenv.load(fileName: ".env");
  // WidgetsFlutterBinding.ensureInitialized();
  // await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await Firebase.initializeApp();
  PushNotificationsManager().init();
  final status = await Permission.notification.request();
  runApp(const MyApp());

  // RemoteMessage? initialMessage =
  //     await FirebaseMessaging.instance.getInitialMessage();
  // if (initialMessage != null) {
  //   // App received a notification when it was killed
  // }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void>? loadAsync;

  @override
  void initState() {
    super.initState();
    loadAsync = MyI18n.loadTranslations();
    getFCMToken();
  }

  Future getFCMToken() async {
    try {
      String fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      await FirebaseMessaging.instance.subscribeToTopic("users");
      if (fcmToken != '') {
        userToken = fcmToken;
      }
    } catch (e) {
      userToken = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('kn'),
            Locale('pa'),
            Locale('te'),
            Locale('mr'),
            Locale('hi'),
          ],
          theme: _buildTheme(Brightness.light),
          home: FutureBuilder(
            future: loadAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return I18n(
                  child: const SplashScreen(),
                );
              }
              return (const Image(
                  image: AssetImage('${assetImagePath}splash.png')));
            },
          ),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(
      primarySwatch: Colors.green,
      brightness: brightness,
      textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  I18n(child: const ChooseLanguage())));
    });

    return const SizedBox(
        child: Image(image: AssetImage('${assetImagePath}splash.png')));
  }
}
