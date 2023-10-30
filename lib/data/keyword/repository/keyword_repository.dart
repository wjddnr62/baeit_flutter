import 'package:baeit/data/keyword/service/add_keyword_alarm_service.dart';
import 'package:baeit/data/keyword/service/get_keyword_alarm_class_service.dart';
import 'package:baeit/data/keyword/service/get_keyword_alarm_count_service.dart';
import 'package:baeit/data/keyword/service/get_keyword_alarm_service.dart';
import 'package:baeit/data/keyword/service/keyword_alarm_count_read_service.dart';
import 'package:baeit/data/keyword/service/keyword_alarm_noti_change_service.dart';
import 'package:baeit/data/keyword/service/remove_keyword_alarm_service.dart';
import 'package:baeit/data/keyword/service_new/get_keyword_alarm_list_service.dart';
import 'package:baeit/data/keyword/service_new/get_keyword_alarm_read_service.dart';
import 'package:baeit/data/keyword/service_new/put_keyword_alarm_read_service.dart';

class KeywordRepository {
  static Future<dynamic> getKeywordAlarm({required String type}) =>
      GetKeywordAlarmService(type: type).start();

  static Future<dynamic> keywordAlarmNotiChange(
          {required int alarmFlag,
          required String memberAreaUuid,
          required String type}) =>
      KeywordAlarmNotiChangeService(
              alarmFlag: alarmFlag, memberAreaUuid: memberAreaUuid, type: type)
          .start();

  static Future<dynamic> addKeywordAlarm(
          {required String keywordText, required String type}) =>
      AddKeywordAddAlarmService(keywordText: keywordText, type: type).start();

  static Future<dynamic> removeKeywordAlarm(
          {required String memberClassKeywordUuid}) =>
      RemoveKeywordAlarmService(memberClassKeywordUuid: memberClassKeywordUuid)
          .start();

  static Future<dynamic> getKeywordAlarmClass({String? nextCursor}) =>
      GetKeywordAlarmClassService(nextCursor: nextCursor).start();

  static Future<dynamic> getKeywordAlarmCount({required String type}) =>
      GetKeywordAlarmCountService(type: type).start();

  static Future<dynamic> keywordAlarmCountRead() =>
      KeywordAlarmCountReadService().start();

  static Future<dynamic> getKeywordAlarmList(
          {String? cursor, required String type}) =>
      GetKeywordAlarmListService(cursor: cursor, type: type).start();

  static Future<dynamic> putKeywordAlarmRead(String type) =>
      PutKeywordAlarmReadService(type: type).start();

  static Future<dynamic> getKeywordAlarmRead(String type) =>
      GetKeywordAlarmReadService(type: type).start();
}
