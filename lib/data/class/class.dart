import 'package:baeit/data/common/image_value.dart';

class ClassList {
  final List<Class> classData;
  int totalRow;

  ClassList({required this.classData, required this.totalRow});

  factory ClassList.fromJson(data) {
    return ClassList(
        classData: data['list'] != null || data['list'].length == 0
            ? (data['list'] as List).map((e) => Class.fromJson(e)).toList()
            : [],
        totalRow: data['totalRow']);
  }
}

class Class {
  final String? cursor;
  final String classUuid;
  final String type;
  String status;
  final int readCnt;
  int likeCnt;
  final int chatCnt;
  final int shareCnt;
  final int reviewCnt;
  int likeFlag;
  final int mineFlag;
  final Content content;
  final Member member;
  final int managerStopFlag;
  final DateTime? managerStopDate;
  final String? managerStopReasonText;
  bool hide;
  final String? shareLink;

  Class(
      {this.cursor,
      required this.classUuid,
      required this.type,
      required this.status,
      required this.readCnt,
      required this.likeCnt,
      required this.chatCnt,
      required this.shareCnt,
      required this.reviewCnt,
      required this.likeFlag,
      required this.mineFlag,
      required this.content,
      required this.member,
      required this.managerStopFlag,
      this.managerStopDate,
      this.managerStopReasonText,
      this.hide = false,
      this.shareLink});

  factory Class.fromJson(data) {
    return Class(
        cursor: data['cursor'],
        classUuid: data['classUuid'],
        type: data['type'],
        status: data['status'],
        readCnt: data['readCnt'],
        likeCnt: data['likeCnt'],
        chatCnt: data['chatCnt'],
        shareCnt: data['shareCnt'],
        reviewCnt: data['reviewCnt'],
        likeFlag: data['likeFlag'],
        mineFlag: data['mineFlag'],
        content: Content.fromJson(data['content']),
        member: Member.fromJson(data['member']),
        managerStopFlag: data['managerStopFlag'],
        managerStopDate: data['managerStopDate'] == null
            ? null
            : DateTime.parse(data['managerStopDate']),
        managerStopReasonText: data['managerStopReasonText'],
        shareLink: data['shareLink']);
  }
}

class Content {
  final String classContentUuid;
  final Category? category;
  final String? title;
  final int? minCost;
  final int? maxCost;
  final int costConsultFlag;
  final int? dayConsultFlag;
  final DateTime createDate;
  final String keywordString;
  final String hangNames;
  final String dayNames;
  final String distance;
  Data? image;
  final Data? representativeOriginFile;
  final String? level;
  final DateTime? updateDate;
  final String? classIntroText;
  final String? tutorIntroText;
  final String? classContentText;
  final List<Areas>? areas;
  final List<Data>? images;
  final List<String>? keywords;
  final String costType;
  final String? shareType;
  final int firstFreeFlag;
  final int groupFlag;
  final int costOfPerson;

  Content(
      {required this.classContentUuid,
      required this.category,
      required this.title,
      required this.minCost,
      required this.maxCost,
      required this.costConsultFlag,
      this.dayConsultFlag,
      required this.createDate,
      required this.keywordString,
      required this.hangNames,
      required this.dayNames,
      required this.distance,
      this.image,
      this.representativeOriginFile,
      this.level,
      this.updateDate,
      this.classIntroText,
      this.tutorIntroText,
      this.classContentText,
      this.areas,
      this.images,
      this.keywords,
      required this.costType,
      this.shareType,
      required this.firstFreeFlag,
      required this.groupFlag,
      required this.costOfPerson});

  factory Content.fromJson(data) {
    return Content(
        classContentUuid: data['classContentUuid'],
        category: data['category'] == null
            ? null
            : Category.fromJson(data['category']),
        title: data['title'],
        minCost: data['minCost'],
        maxCost: data['maxCost'],
        costConsultFlag: data['costConsultFlag'],
        dayConsultFlag: data['dayConsultFlag'],
        createDate: DateTime.parse(data['createDate']),
        keywordString: data['keywordString'],
        hangNames: data['hangNames'],
        dayNames: data['dayNames'],
        distance: data['distance'].toString(),
        image: data['image'] == null ? null : Data.fromJson(data['image']),
        level: data['level'] != null ? data['level'] : null,
        updateDate: data['updateDate'] == null
            ? null
            : DateTime.parse(data['updateDate']),
        classIntroText: data['classIntroText'],
        tutorIntroText: data['tutorIntroText'],
        classContentText: data['classContentText'],
        areas: data['areas'] == null
            ? null
            : (data['areas'] as List).map((e) => Areas.fromJson(e)).toList(),
        images: data['images'] == null
            ? null
            : (data['images'] as List).map((e) => Data.fromJson(e)).toList(),
        representativeOriginFile: data['representativeOriginFile'] == null
            ? null
            : Data.fromJson(data['representativeOriginFile']),
        keywords: data['keywords'] == null
            ? null
            : (data['keywords'] as List)
                .map((e) => e['text'].toString())
                .toList(),
        costType: data['costType'],
        shareType: data['shareType'],
        firstFreeFlag: data['firstFreeFlag'] ?? 0,
        groupFlag: data['groupFlag'] ?? 0,
        costOfPerson: data['costOfPerson'] ?? 0);
  }
}

class Areas {
  String hangName;
  final String buildingName;
  final String hangCode;
  final String lati;
  final String longi;
  final String? roadAddress;
  final String zipAddress;
  final String? sidoName;
  final String? sigunguName;
  final String? eupmyeondongName;

  Areas(
      {required this.hangName,
      required this.buildingName,
      required this.hangCode,
      required this.lati,
      required this.longi,
      this.roadAddress,
      required this.zipAddress,
      this.sidoName,
      this.sigunguName,
      this.eupmyeondongName});

  factory Areas.fromJson(data) {
    return Areas(
        hangName: data['hangName'],
        buildingName: data['buildingName'],
        hangCode: data['hangCode'].toString(),
        lati: data['lati'].toString(),
        longi: data['longi'].toString(),
        zipAddress: data['zipAddress'],
        roadAddress: data['roadAddress'] != null ? data['roadAddress'] : null,
        sidoName: data['sidoName'],
        sigunguName: data['sigunguName'],
        eupmyeondongName: data['eupmyeondongName']);
  }
}

class Category {
  final String? classCategoryId;
  final String? name;

  Category({required this.classCategoryId, required this.name});

  factory Category.fromJson(data) {
    return Category(
        classCategoryId: data['classCategoryId'] ?? null,
        name: data['name'] ?? null);
  }
}

class Member {
  final String memberUuid;
  final String nickName;
  final String phone;
  final String? profile;
  final String? type;
  final String? status;
  final String? email;
  final String? gender;
  final String? birthDate;
  final String? introText;

  Member(
      {required this.memberUuid,
      required this.nickName,
      required this.phone,
      this.profile,
      this.type,
      this.status,
      this.email,
      this.gender,
      this.birthDate,
      this.introText});

  factory Member.fromJson(data) {
    return Member(
        memberUuid: data['memberUuid'],
        nickName: data['nickName'],
        phone: data['phone'],
        profile: data['profile'] != null ? data['profile'] : null,
        type: data['type'],
        status: data['status'],
        email: data['email'],
        gender: data['gender'],
        birthDate: data['birthDate'],
        introText: data['introText']);
  }
}

class GetClass {
  final String? categories;
  final String lati;
  final String longi;
  final String? days;
  final String? nextCursor;
  final int orderType;
  final String? searchText;
  final int size;
  final String type;

  GetClass(
      {this.categories,
      required this.lati,
      required this.longi,
      this.days,
      this.nextCursor,
      required this.orderType,
      this.searchText,
      this.size = 20,
      required this.type}); // MADE, REQUEST

  toMap() {
    Map<String, Object> data = {};
    if (categories != null) {
      data.addAll({'categories': categories!});
    }
    data.addAll({'lati': lati});
    data.addAll({'longi': longi});
    if (days != null) {
      data.addAll({'days': days!});
    }
    if (nextCursor != null) {
      data.addAll({'nextCursor': nextCursor!});
    }
    data.addAll({'orderType': orderType});
    if (searchText != null) {
      data.addAll({'searchText': searchText!});
    }
    data.addAll({'size': size});
    data.addAll({'type': type});
    return data;
  }
}
