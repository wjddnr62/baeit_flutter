import 'package:baeit/data/notice/service/get_notice_detail_service.dart';
import 'package:baeit/data/notice/service/get_notice_service.dart';

class NoticeRepository {
  static Future<dynamic> getNotice({String? nextCursor}) =>
      GetNoticeService(nextCursor: nextCursor).start();

  static Future<dynamic> getNoticeDetail(String noticeUuid) =>
      GetNoticeDetailService(noticeUuid: noticeUuid).start();
}
