import 'package:baeit/data/chat/report.dart';
import 'package:baeit/data/chat/service/chat_block_service.dart';
import 'package:baeit/data/chat/service/chat_exit_service.dart';
import 'package:baeit/data/chat/service/chat_open_service.dart';
import 'package:baeit/data/chat/service/chat_receive_service.dart';
import 'package:baeit/data/chat/service/chat_report_service.dart';
import 'package:baeit/data/chat/service/class_block_check_service.dart';
import 'package:baeit/data/chat/service/get_chat_room_service.dart';
import 'package:baeit/data/chat/service/get_message_list_service.dart';
import 'package:baeit/data/chat/service/get_unread_message_list_service.dart';

class ChatRepository {
  static Future<dynamic> chatOpen(
          {bool classCheck = false,
          bool communityCheck = false,
          String? classUuid = '',
          String? communityUuid = '',
          int introFlag = 0}) =>
      ChatOpenService(
              classUuid: classUuid,
              communityUuid: communityUuid,
              classCheck: classCheck,
              communityCheck: communityCheck,
              introFlag: introFlag)
          .start();

  static Future<dynamic> getChatRoom(String chatRoomUuid) =>
      GetChatRoomService(chatRoomUuid: chatRoomUuid).start();

  static Future<dynamic> getMessageListService(String chatRoomUuid,
          {String? nextCursor, int? size}) =>
      GetMessageListService(
              chatRoomUuid: chatRoomUuid, nextCursor: nextCursor, size: size)
          .start();

  static Future<dynamic> getUnreadMessageListService(String chatRoomUuid,
          {String? chatRoomMessageUuid}) =>
      GetUnreadMessageListService(
              chatRoomUuid: chatRoomUuid,
              chatRoomMessageUuid: chatRoomMessageUuid)
          .start();

  static Future<dynamic> chatBlock(String chatRoomUuid) =>
      ChatBlockService(chatRoomUuid: chatRoomUuid).start();

  static Future<dynamic> chatExit(String chatRoomUuid) =>
      ChatExitService(chatRoomUuid: chatRoomUuid).start();

  static Future<dynamic> chatReceive(
          String chatRoomUuid, int noticeReceiveFlag) =>
      ChatReceiveService(
              chatRoomUuid: chatRoomUuid, noticeReceiveFlag: noticeReceiveFlag)
          .start();

  static Future<dynamic> chatReport(Report report) =>
      ChatReportService(report: report).start();

  static Future<dynamic> classBlockCheck(String classUuid) =>
      ClassBlockCheckService(classUuid: classUuid).start();
}
