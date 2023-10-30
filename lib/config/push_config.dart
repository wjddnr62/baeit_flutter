import 'dart:io';

import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/common/push.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

PublishSubject<String?> selectNotificationSubject = PublishSubject<String?>();
String? selectedNotificationPayload;

class PushConfig {
  String? getAndRemovePushNotificationOnLaunch() {
    String? _selectedNotificationPayload = selectedNotificationPayload;
    selectedNotificationPayload = null;
    return _selectedNotificationPayload;
  }

  Future iosForegroundSet(
      int id, String? title, String? body, String? payload) async {
    debugPrint('notification ios payload: $payload');
    dataSaver.logout = false;
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  }

  Future<void> initializeLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: iosForegroundSet);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin?.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      debugPrint('notification payload: $payload');
      dataSaver.logout = false;
      selectedNotificationPayload = payload;
      selectNotificationSubject.add(payload);
    });

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'Baeit default notification channel',
      "배잇 기본 채널",
      "배잇 알림 채널입니다.",
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future showNotificationText(String? title, String? content,
      {dynamic payload}) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? androidInfo;
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        Push.fromJson(payload).messageType == 'CHATTING'
            ? "Baeit sound notification channel"
            : 'Baeit default notification channel',
        Push.fromJson(payload).messageType == 'CHATTING'
            ? "배잇 사운드 채널"
            : '배잇 기본 채널',
        "배잇 알림 채널입니다.",
        groupKey: Push.fromJson(payload).chatRoomUuid,
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.white,
        enableLights: Platform.isAndroid
            ? (androidInfo!.version.sdkInt! >= 26)
                ? true
                : false
            : false,
        ledColor: AppColors.primary,
        ledOffMs: 500,
        ledOnMs: 1000,
        sound: Push.fromJson(payload).messageType == 'CHATTING'
            ? RawResourceAndroidNotificationSound(
                Push.fromJson(payload).soundName?.split('.')[0])
            : null,
        channelShowBadge: Platform.isAndroid
            ? (androidInfo!.version.sdkInt! >= 26)
                ? true
                : false
            : false,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
        fullScreenIntent: false,
        icon: "app_icon");
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: Push.fromJson(payload).messageType == 'CHATTING'
          ? Push.fromJson(payload).soundName
          : null,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin?.show(
        Push.fromJson(payload).messageType == 'CHATTING'
            ? Push.fromJson(payload).fcmMessageId != null
                ? Push.fromJson(payload).fcmMessageId ?? 0
                : 0
            : DateTime.now().millisecond,
        title,
        content,
        platformChannelSpecifics,
        payload: jsonEncode(Push.fromJson(payload).toMap()));

    if (Push.fromJson(payload).messageType == 'CHATTING' &&
        Platform.isAndroid) {
      InboxStyleInformation inboxStyleInformation =
          InboxStyleInformation([], contentTitle: Push.fromJson(payload).title);

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'Baeit group notification channel', '배잇 그룹 채널', "배잇 알림 채널입니다.",
              styleInformation: inboxStyleInformation,
              groupKey: Push.fromJson(payload).chatRoomUuid,
              setAsGroupSummary: true,
              fullScreenIntent: false,
              icon: "app_icon");

      await flutterLocalNotificationsPlugin?.show(
          Push.fromJson(payload).seq ?? 0,
          title,
          '',
          NotificationDetails(
              android: androidNotificationDetails,
              iOS: iOSPlatformChannelSpecifics),
          payload: jsonEncode(Push.fromJson(payload).toMap()));
    }
  }

  Future showNotificationImage(
      String? title, String? content, String? image, String icon,
      {dynamic payload}) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? androidInfo;
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        Push.fromJson(payload).messageType == 'CHATTING'
            ? "Baeit sound notification channel"
            : 'Baeit default notification channel',
        Push.fromJson(payload).messageType == 'CHATTING'
            ? "배잇 사운드 채널"
            : '배잇 기본 채널',
        "배잇 알림 채널입니다.",
        groupKey: Push.fromJson(payload).chatRoomUuid,
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.white,
        enableLights: Platform.isAndroid
            ? (androidInfo!.version.sdkInt! >= 26)
                ? true
                : false
            : false,
        ledColor: AppColors.primary,
        ledOffMs: 500,
        ledOnMs: 1000,
        channelShowBadge: Platform.isAndroid
            ? (androidInfo!.version.sdkInt! >= 26)
                ? true
                : false
            : false,
        sound: Push.fromJson(payload).messageType == 'CHATTING'
            ? RawResourceAndroidNotificationSound(
                Push.fromJson(payload).soundName?.split('.')[0])
            : null,
        playSound: true,
        enableVibration: true,
        largeIcon:
            FilePathAndroidBitmap(await downloadAndSaveFile(icon, 'largeIcon')),
        styleInformation: image != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(
                    await downloadAndSaveFile(image, 'bigPicture')),
                hideExpandedLargeIcon: true,
                htmlFormatContentTitle: true,
                htmlFormatSummaryText: true,
                contentTitle: title,
                summaryText: content)
            : null,
        fullScreenIntent: false,
        icon: "app_icon");
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        attachments: image != null
            ? <IOSNotificationAttachment>[
                IOSNotificationAttachment(
                    await downloadAndSaveFile(image, 'bigPicture.jpg'))
              ]
            : null,
        sound: Push.fromJson(payload).messageType == 'CHATTING'
            ? Push.fromJson(payload).soundName
            : null,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin?.show(
        Push.fromJson(payload).messageType == 'CHATTING'
            ? Push.fromJson(payload).fcmMessageId != null
                ? Push.fromJson(payload).fcmMessageId ?? 0
                : 0
            : DateTime.now().millisecond,
        title,
        content,
        platformChannelSpecifics,
        payload: jsonEncode(Push.fromJson(payload).toMap()));

    if (Push.fromJson(payload).messageType! == 'CHATTING' &&
        Platform.isAndroid) {
      InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        [],
        contentTitle: Push.fromJson(payload).title,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'Baeit group notification channel', '배잇 그룹 채널', "배잇 알림 채널입니다.",
              styleInformation: inboxStyleInformation,
              groupKey: Push.fromJson(payload).chatRoomUuid,
              setAsGroupSummary: true,
              largeIcon: FilePathAndroidBitmap(
                  await downloadAndSaveFile(icon, 'largeIcon')),
              fullScreenIntent: false,
              icon: "app_icon");

      await flutterLocalNotificationsPlugin?.show(
          Push.fromJson(payload).seq ?? 0,
          title,
          '',
          NotificationDetails(
              android: androidNotificationDetails,
              iOS: iOSPlatformChannelSpecifics),
          payload: jsonEncode(Push.fromJson(payload).toMap()));
    }
  }
}
