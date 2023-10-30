import 'dart:async';
import 'dart:io';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/ui/splash/splash_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/widgets/disallow_glow.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

class SettingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

SharedPreferences? prefs;
FirebaseAnalytics analytics = FirebaseAnalytics();
FirebaseMessaging messaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: Platform.isIOS ? false : true, badge: true, sound: true);

  if (message.data['type'] == 'BADGE' &&
      int.parse(message.data['badge']) != 0) {
    if (Platform.isAndroid) {
      FlutterAppBadger.updateBadgeCount(int.parse(message.data['badge']));
      return;
    }
  } else if (message.data['type'] == 'BADGE' &&
      int.parse(message.data['badge']) == 0) {
    if (Platform.isAndroid) {
      FlutterAppBadger.removeBadge();
      return;
    }
  }

  if (message.data['type'] != '' && !Platform.isIOS) {
    if (message.data['type'] == 'icon') {
      PushConfig().showNotificationImage(message.data['title'],
          message.data['body'], null, message.data['largeIcon'],
          payload: message.data);
    } else if (message.data['type'] == 'image') {
      PushConfig().showNotificationImage(
          message.data['title'],
          message.data['body'],
          message.data['image'],
          message.data['largeIcon'],
          payload: message.data);
    } else {
      PushConfig().showNotificationText(
          message.data['title'], message.data['body'],
          payload: message.data);
    }
  }
}

Amplitude amplitude = Amplitude.getInstance(instanceName: 'baeit');

bool flutterDownloader = false;
bool startPush = false;
RemoteConfig? remoteConfig;
Timer? deviceIdTimer;
FacebookAppEvents facebookAppEvents = FacebookAppEvents();

common({String? flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = BlocSupervisor();

  // if (!kReleaseMode) {
  //   FlutterImageCompress.showNativeLog = true;
  // }

  await Firebase.initializeApp();
  remoteConfig = RemoteConfig.instance;
  prefs = await SharedPreferences.getInstance();
  if (!flutterDownloader) {
    flutterDownloader = true;

    FlutterDownloader.initialize(debug: false);
  }

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  debugPrint("APNSToken : ${await messaging.getAPNSToken()}");
  debugPrint("FCMToken : ${await messaging.getToken()}");

  if (!kReleaseMode) {
    if (prefs!.getString('FLAVOR') == '' ||
        prefs!.getString('FLAVOR') == null) {
      await prefs!.setString('FLAVOR', flavor!);
    }
  }

  // kakao.KakaoContext.clientId = '7b37ae9df646d33d208b87834ed3b949';
  kakao.KakaoSdk.init(nativeAppKey: '7b37ae9df646d33d208b87834ed3b949');

  if (!startPush) {
    HttpOverrides.global = SettingHttpOverrides();

    if (Platform.isIOS) {
      await facebookAppEvents.setAdvertiserTracking(enabled: true);
    }

    await remoteConfig!.fetchAndActivate();
    if (production == 'prod-release' && kReleaseMode) {
      await amplitude.init('3afe2b7d2b61bfec2a98ea7d10ca34a3');
      await amplitude.useAppSetIdForDeviceId();
      await amplitude.trackingSessionEvents(true);
      deviceIdTimer =
          Timer.periodic(Duration(milliseconds: 2000), (timer) async {
        String? deviceId = await amplitude.getDeviceId();
        if (deviceId != null && deviceId != '') {
          print("Amplitude Device Id : $deviceId");
          Airbridge.state
              .setUser(User(alias: {'amplitude_device_id': deviceId}));
          Airbridge.state.startTracking();
          deviceIdTimer!.cancel();
        }
      });
    }

    dataSaver.abTest = remoteConfig!.getString('t_value');
    await remoteConfig!.ensureInitialized();
    await remoteConfig!.fetchAndActivate();
    dataSaver.touring = remoteConfig!.getInt('touring') == 0 ? false : true;
    if (dataSaver.abTest != null && dataSaver.abTest != '') {
      // identifyAdd('ab_test_keyword', dataSaver.abTest);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await messaging.setForegroundNotificationPresentationOptions(
        alert: Platform.isIOS ? false : true, badge: true, sound: true);

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      // iOS 일 때만 들어옴
      dataSaver.logout = false;
      selectedNotificationPayload = jsonEncode(event.data);
      selectNotificationSubject.add(jsonEncode(event.data));
    });

    FirebaseMessaging.onMessage.listen((event) async {
      if (event.data['messageType'] == 'CHATTING' &&
          (event.data['chatRoomUuid'] == dataSaver.chatRoomUuid ||
              event.data['memberUuid'] ==
                  (dataSaver.userData == null
                      ? ''
                      : dataSaver.userData!.memberUuid))) {
        return;
      }

      if (!event.data['messageType'].toString().contains('CHATTING') &&
          event.data['type'] != 'BADGE') {
        if (!dataSaver.nonMember) {
          dataSaver.myBaeitBloc!.add(UpdateDataEvent());
        }
      }

      if (event.data['type'] == 'BADGE' &&
          int.parse(event.data['badge']) != 0) {
        if (Platform.isAndroid)
          FlutterAppBadger.updateBadgeCount(int.parse(event.data['badge']));
        return;
      } else if (event.data['type'] == "BADGE" &&
          int.parse(event.data['badge']) == 0) {
        if (Platform.isAndroid) FlutterAppBadger.removeBadge();
        return;
      }

      if (event.data['type'] != '') {
        if (event.data['type'] == 'icon') {
          PushConfig().showNotificationImage(event.data['title'],
              event.data['body'], null, event.data['largeIcon'],
              payload: event.data);
        } else if (event.data['type'] == 'image') {
          PushConfig().showNotificationImage(event.data['title'],
              event.data['body'], event.data['image'], event.data['largeIcon'],
              payload: event.data);
        } else {
          PushConfig().showNotificationText(
              event.data['title'], event.data['body'],
              payload: event.data);
        }
      }
    });
  }

  startPush = true;
  runApp(BootApp());
}

systemColorSetting() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Platform.isAndroid ? AppColors.white : AppColors.gray900,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      statusBarIconBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          Platform.isAndroid ? AppColors.white : AppColors.gray900,
      systemNavigationBarIconBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light));
}

class BootApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (production == 'prod-release' && kReleaseMode) {
      FlutterUxcam
          .optIntoSchematicRecordings(); // Confirm that you have user permission for screen recording
      FlutterUxcam.startWithKey("50mm9xznx5tscot");
    }
    systemColorSetting();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
      ],
      theme: ThemeData(
        fontFamily: fontFamily,
        primaryColor: AppColors.primary,
        errorColor: AppColors.error,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              animationDuration: Duration(milliseconds: 0),
              shadowColor: MaterialStateProperty.all<Color>(
                  AppColors.black20.withOpacity(0.2)),
              overlayColor: MaterialStateProperty.all<Color>(
                  AppColors.primaryLight30.withOpacity(0.4))),
        ),
        bottomAppBarColor: AppColors.primary,
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: AppColors.primary),
      ),
      initialRoute: '/',
      home: SplashPage(),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: DisallowGlow(),
          child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!),
        );
      },
    );
  }
}

class BlocSupervisor extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (transition.event is BaseBlocEvent) {
      print(
          'BLOC_EVENT : bloc = $bloc, transition.event = ${transition.event}');
    }

    if (transition.nextState is BaseBlocState) {
      print(
          'BLOC_STATE : bloc = $bloc, transition.nextState = ${transition.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print(
        'BLOC_ERROR : bloc = $bloc, error = $error, stacktrace = ${stackTrace.toString()}');
  }
}
