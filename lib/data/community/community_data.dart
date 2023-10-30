import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/common/image_value.dart';

class CommunityList {
  final List<CommunityData> communityData;
  int totalRow;

  CommunityList({required this.communityData, required this.totalRow});

  factory CommunityList.fromJson(data) {
    return CommunityList(
        communityData: data['list'] != null || data['list'].length == 0
            ? (data['list'] as List)
                .map((e) => CommunityData.fromJson(e))
                .toList()
            : [],
        totalRow: data['totalRow']);
  }
}

class CommunityData {
  final String cursor;
  final String communityUuid;
  final String status;
  final int managerStopFlag;
  final DateTime? managerStopDate;
  final String? managerStopReasonText;
  final int readCnt;
  final int likeCnt;
  final int chatCnt;
  final int shareCnt;
  final int likeFlag;
  final int mineFlag;
  final CommunityContent content;
  final Member member;
  final int commentCnt;

  CommunityData(
      {required this.cursor,
      required this.communityUuid,
      required this.status,
      required this.managerStopFlag,
      this.managerStopDate,
      this.managerStopReasonText,
      required this.readCnt,
      required this.likeCnt,
      required this.chatCnt,
      required this.shareCnt,
      required this.likeFlag,
      required this.mineFlag,
      required this.content,
      required this.member,
      required this.commentCnt});

  factory CommunityData.fromJson(data) {
    return CommunityData(
        cursor: data['cursor'],
        communityUuid: data['communityUuid'],
        status: data['status'],
        managerStopFlag: data['managerStopFlag'],
        managerStopDate: data['managerStopDate'] != null
            ? DateTime.parse(data['managerStopDate'])
            : null,
        managerStopReasonText: data['managerStopReasonText'] ?? '',
        readCnt: data['readCnt'],
        likeCnt: data['likeCnt'],
        chatCnt: data['chatCnt'],
        shareCnt: data['shareCnt'],
        likeFlag: data['likeFlag'],
        mineFlag: data['mineFlag'],
        content: CommunityContent.fromJson(data['content']),
        member: Member.fromJson(data['member']),
        commentCnt: data['commentCnt']);
  }
}

class CommunityContent {
  final String communityContentUuid;
  final String category;
  final DateTime createDate;
  final String? contentText;
  final String hangNames;
  final String distance;
  final String? teachKeywordString;
  final String? learnKeywordString;
  final String? meetKeywordString;

  CommunityContent(
      {required this.communityContentUuid,
      required this.category,
      required this.createDate,
      this.contentText,
      required this.hangNames,
      required this.distance,
      this.teachKeywordString,
      this.learnKeywordString,
      this.meetKeywordString});

  factory CommunityContent.fromJson(data) {
    return CommunityContent(
        communityContentUuid: data['communityContentUuid'],
        category: data['category'],
        createDate: DateTime.parse(data['createDate']),
        contentText: data['contentText'] ?? '',
        hangNames: data['hangNames'],
        distance: data['distance'].toString(),
        teachKeywordString: data['teachKeywordString'],
        learnKeywordString: data['learnKeywordString'],
        meetKeywordString: data['meetKeywordString']);
  }
}

class CommunityDetail {
  final String communityUuid;
  String status;
  final int managerStopFlag;
  final DateTime? managerStopDate;
  final String? managerStopReasonText;
  final int readCnt;
  final int likeCnt;
  final int chatCnt;
  final int shareCnt;
  int likeFlag;
  final int mineFlag;
  final CommunityDetailContent content;
  final Member member;
  final int blockFlag;
  final int commentCnt;
  int reportFlag;

  CommunityDetail(
      {required this.communityUuid,
      required this.status,
      required this.managerStopFlag,
      this.managerStopDate,
      this.managerStopReasonText,
      required this.readCnt,
      required this.likeCnt,
      required this.chatCnt,
      required this.shareCnt,
      required this.likeFlag,
      required this.mineFlag,
      required this.content,
      required this.member,
      required this.blockFlag,
      required this.commentCnt,
      required this.reportFlag});

  factory CommunityDetail.fromJson(data) {
    return CommunityDetail(
        communityUuid: data['communityUuid'],
        status: data['status'],
        managerStopFlag: data['managerStopFlag'],
        managerStopDate: data['managerStopDate'] != null
            ? DateTime.parse(data['managerStopDate'])
            : null,
        managerStopReasonText: data['managerStopReasonText'] ?? '',
        readCnt: data['readCnt'],
        likeCnt: data['likeCnt'],
        chatCnt: data['chatCnt'],
        shareCnt: data['shareCnt'],
        likeFlag: data['likeFlag'],
        mineFlag: data['mineFlag'],
        content: CommunityDetailContent.fromJson(data['content']),
        member: Member.fromJson(data['member']),
        blockFlag: data['blockFlag'],
        commentCnt: data['commentCnt'],
        reportFlag: data['reportFlag']);
  }
}

class CommunityDetailContent {
  final String category;
  final DateTime createDate;
  final DateTime? updateDate;
  final String? contentText;
  final List<Areas> areas;
  final List<Data>? images;
  final String distance;
  final List<CommunityKeywords>? teachKeywords;
  final List<CommunityKeywords>? learnKeywords;
  final List<CommunityKeywords>? meetKeywords;
  final String? teachKeywordString;
  final String? learnKeywordString;
  final String? meetKeywordString;

  CommunityDetailContent(
      {required this.category,
      required this.createDate,
      required this.updateDate,
      this.contentText,
      required this.areas,
      this.images,
      required this.distance,
      this.teachKeywords,
      this.learnKeywords,
      this.meetKeywords,
      this.teachKeywordString,
      this.learnKeywordString,
      this.meetKeywordString});

  factory CommunityDetailContent.fromJson(data) {
    return CommunityDetailContent(
        category: data['category'],
        createDate: DateTime.parse(data['createDate']),
        updateDate: data['updateDate'] != null
            ? DateTime.parse(data['updateDate'])
            : null,
        contentText: data['contentText'] ?? '',
        areas: (data['areas'] as List).map((e) => Areas.fromJson(e)).toList(),
        images: data['images'] == null
            ? []
            : (data['images'] as List).map((e) => Data.fromJson(e)).toList(),
        distance: data['distance'].toString(),
        teachKeywords: data['teachKeywords'].length == 0
            ? []
            : (data['teachKeywords'] as List)
                .map((e) => CommunityKeywords.fromJson(e))
                .toList(),
        learnKeywords: data['learnKeywords'].length == 0
            ? []
            : (data['learnKeywords'] as List)
                .map((e) => CommunityKeywords.fromJson(e))
                .toList(),
        meetKeywords: data['meetKeywords'].length == 0
            ? []
            : (data['meetKeywords'] as List)
                .map((e) => CommunityKeywords.fromJson(e))
                .toList(),
        teachKeywordString: data['teachKeywordString'],
        learnKeywordString: data['learnKeywordString'],
        meetKeywordString: data['meetKeywordString']);
  }
}

class CommunityKeywords {
  final String communityKeywordUuid;
  final String type;
  final String text;
  final int seq;

  CommunityKeywords(
      {required this.communityKeywordUuid,
      required this.type,
      required this.text,
      required this.seq});

  factory CommunityKeywords.fromJson(json) {
    return CommunityKeywords(
        communityKeywordUuid: json['communityKeywordUuid'],
        type: json['type'],
        text: json['text'],
        seq: json['seq']);
  }
}
