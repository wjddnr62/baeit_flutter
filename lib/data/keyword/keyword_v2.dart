import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/common/image_value.dart';

class KeywordList {
  final List<KeywordV2> keyword;
  final int totalRow;

  KeywordList({required this.keyword, required this.totalRow});

  factory KeywordList.fromJson(json) {
    return KeywordList(
        keyword: json['list'] != null || json['list'].length == 0
            ? (json['list'] as List).map((e) => KeywordV2.fromJson(e)).toList()
            : [],
        totalRow: json['totalRow']);
  }
}

class KeywordV2 {
  final String cursor;
  final String memberKeywordAlarmUuid;
  final String type;
  final String eupmyeondongName;
  final String keyword;
  final DateTime createDate;
  final DateTime updateDate;
  final int readFlag;
  final KeywordClassInfo? classInfo;
  final KeywordCommunityInfo? communityInfo;

  KeywordV2(
      {required this.cursor,
      required this.memberKeywordAlarmUuid,
      required this.type,
      required this.eupmyeondongName,
      required this.keyword,
      required this.createDate,
      required this.updateDate,
      required this.readFlag,
      this.classInfo,
      this.communityInfo});

  factory KeywordV2.fromJson(json) {
    return KeywordV2(
        cursor: json['cursor'],
        memberKeywordAlarmUuid: json['memberKeywordAlarmUuid'],
        type: json['type'],
        eupmyeondongName: json['eupmyeondongName'],
        keyword: json['keyword'],
        createDate: DateTime.parse(json['createDate']),
        updateDate: DateTime.parse(json['updateDate']),
        readFlag: json['readFlag'],
        classInfo: json['classInfo'] != null
            ? KeywordClassInfo.fromJson(json['classInfo'])
            : null,
        communityInfo: json['communityInfo'] != null
            ? KeywordCommunityInfo.fromJson(json['communityInfo'])
            : null);
  }
}

class KeywordClassInfo {
  final String classUuid;
  final String status;
  final String title;
  final int costConsultFlag;
  final int minCost;
  final Data image;
  final String type;
  final String costType;
  final String shareType;
  final int firstFreeFlag;
  final int groupFlag;
  final int costOfPerson;
  final String keywordString;
  final Category? category;

  KeywordClassInfo(
      {required this.classUuid,
      required this.status,
      required this.title,
      required this.costConsultFlag,
      required this.minCost,
      required this.image,
      required this.type,
      required this.costType,
      required this.shareType,
      this.firstFreeFlag = 0,
      this.groupFlag = 0,
      this.costOfPerson = 0,
      required this.keywordString,
      this.category});

  factory KeywordClassInfo.fromJson(json) {
    return KeywordClassInfo(
        classUuid: json['classUuid'],
        status: json['status'],
        title: json['title'],
        costConsultFlag: json['costConsultFlag'],
        minCost: json['minCost'],
        image: Data.fromJson(json['image']),
        type: json['type'],
        costType: json['costType'],
        shareType: json['shareType'],
        groupFlag: json['groupFlag'] ?? 0,
        firstFreeFlag: json['firstFreeFlag'] ?? 0,
        costOfPerson: json['costOfPerson'] ?? 0,
        keywordString: json['keywordString'],
        category: json['category'] != null
            ? Category.fromJson(json['category'])
            : null);
  }
}

class KeywordCommunityInfo {
  final String communityUuid;
  final String status;
  final String contentText;
  final String category;
  final String learnKeywordString;
  final String teachKeywordString;
  final String meetKeywordString;

  KeywordCommunityInfo(
      {required this.communityUuid,
      required this.status,
      required this.contentText,
      required this.category,
      required this.learnKeywordString,
      required this.teachKeywordString,
      required this.meetKeywordString});

  factory KeywordCommunityInfo.fromJson(json) {
    return KeywordCommunityInfo(
        communityUuid: json['communityUuid'],
        status: json['status'],
        contentText: json['contentText'],
        category: json['category'],
        learnKeywordString: json['learnKeywordString'],
        teachKeywordString: json['teachKeywordString'],
        meetKeywordString: json['meetKeywordString']);
  }
}
