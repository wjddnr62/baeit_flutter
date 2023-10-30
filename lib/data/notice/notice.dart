import 'package:baeit/data/common/image_value.dart';
import 'package:html/parser.dart' show parse;

class NoticeData {
  final List<Notice> notice;
  final int totalRow;

  NoticeData({required this.totalRow, required this.notice});

  factory NoticeData.fromJson(data) {
    return NoticeData(
        notice: (data['list'] as List).map((e) => Notice.fromJson(e)).toList(),
        totalRow: data['totalRow']);
  }
}

class Notice {
  final String noticeUuid;
  final String type;
  final String title;
  final String text;
  final DateTime createDate;
  final DateTime updateDate;
  final int viewFlag;
  final int topFixedFlag;
  final Data? image;
  final String? cursor;

  Notice(
      {required this.noticeUuid,
      required this.type,
      required this.title,
      required this.text,
      required this.createDate,
      required this.updateDate,
      required this.viewFlag,
      required this.topFixedFlag,
      this.image,
      this.cursor});

  factory Notice.fromJson(data) {
    return Notice(
        noticeUuid: data['noticeUuid'],
        type: data['type'],
        title: data['title'],
        // text: parse(parse(data['text']).body!.text).documentElement!.text,
        text: data['text'],
        createDate: DateTime.parse(data['createDate']),
        updateDate: DateTime.parse(data['updateDate']),
        viewFlag: data['viewFlag'],
        topFixedFlag: data['topFixedFlag'],
        image: data['image'] != null ? Data.fromJson(data['image']) : null,
        cursor: data['cursor']);
  }
}
