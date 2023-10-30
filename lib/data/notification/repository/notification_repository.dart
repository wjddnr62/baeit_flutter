import 'package:baeit/data/notification/service/get_notification_all_count_service.dart';
import 'package:baeit/data/notification/service/get_notification_count_service.dart';
import 'package:baeit/data/notification/service/get_notification_service.dart';
import 'package:baeit/data/notification/service/get_setting_service.dart';
import 'package:baeit/data/notification/service/read_notification_service.dart';
import 'package:baeit/data/notification/service/update_setting_service.dart';

class NotificationRepository {
  static Future<dynamic> getNotificationCount() =>
      GetNotificationCountService().start();

  static Future<dynamic> getSetting() => GetSettingService().start();

  static Future<dynamic> updateSetting(
          {required int chattingFlag,
          required int marketingReceptionFlag,
          required int prohibitFlag,
          required int classMadeKeywordAlarmFlag,
          required int classRequestKeywordAlarmFlag,
          required int communityCommentAlarmFlag}) =>
      UpdateSettingService(
              chattingFlag: chattingFlag,
              marketingReceptionFlag: marketingReceptionFlag,
              prohibitFlag: prohibitFlag,
              classMadeKeywordAlarmFlag: classMadeKeywordAlarmFlag,
              classRequestKeywordAlarmFlag: classRequestKeywordAlarmFlag,
              communityCommentAlarmFlag: communityCommentAlarmFlag)
          .start();

  static Future<dynamic> getNotification({String? nextCursor}) =>
      GetNotificationService(nextCursor: nextCursor).start();

  static Future<dynamic> readNotification() =>
      ReadNotificationService().start();

  static Future<dynamic> getNotificationAllCount() =>
      GetNotificationAllCountService().start();
}
