import 'package:baeit/data/common/image_value.dart';

import 'members.dart';

class ChatRoom {
  final String memberUuid;
  final int totalUnreadCnt;
  final List<RoomData> roomData;

  ChatRoom(
      {required this.memberUuid,
      required this.totalUnreadCnt,
      required this.roomData});

  factory ChatRoom.fromJson(data) {
    return ChatRoom(
        memberUuid: data['memberUuid'],
        totalUnreadCnt: data['totalUnreadCnt'],
        roomData: (data['list'] as List).map((e) {
          return RoomData.fromJson(e);
        }).toList());
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'memberUuid': memberUuid});
    data.addAll({'totalUnreadCnt': totalUnreadCnt});
    data.addAll({'list': roomData.map((e) => e.toMap()).toList()});
    return data;
  }
}

class RoomDatas {
  final String chatRoomUuid;
  final String chatRoomHash;
  final String status;
  final DateTime createDate;
  final DateTime updateDate;
  final DateTime? lastMessageDate;
  final String? lastMessage;
  final int unreadCnt;
  final List<Members> chatRoomMember;
  final ClassInfo? classInfo;
  final CommunityInfo? communityInfo;
  int classReviewSaveFlag;
  final DateTime? classReviewSaveDate;
  int classReviewNotiFlag;
  final DateTime? classReviewNotiDate;

  RoomDatas(
      {required this.chatRoomUuid,
      required this.chatRoomHash,
      required this.status,
      required this.createDate,
      required this.updateDate,
      required this.lastMessageDate,
      required this.lastMessage,
      required this.unreadCnt,
      required this.chatRoomMember,
      required this.classInfo,
      required this.communityInfo,
      required this.classReviewSaveFlag,
      this.classReviewSaveDate,
      required this.classReviewNotiFlag,
      this.classReviewNotiDate});

  factory RoomDatas.fromJson(data) {
    return RoomDatas(
        chatRoomUuid: data['chatRoomUuid'],
        chatRoomHash: data['chatRoomHash'],
        status: data['status'],
        createDate: DateTime.parse(data['createDate']),
        updateDate: DateTime.parse(data['updateDate']),
        lastMessageDate: data['lastMessageDate'] == null
            ? null
            : DateTime.parse(data['lastMessageDate']),
        lastMessage: data['lastMessage'],
        unreadCnt: data['unreadCnt'],
        chatRoomMember:
            (data['members'] as List).map((e) => Members.fromJson(e)).toList(),
        classInfo: data['classInfo'] == null
            ? null
            : ClassInfo.fromJson(data['classInfo']),
        communityInfo: data['communityInfo'] == null
            ? null
            : CommunityInfo.fromJson(data['communityInfo']),
        classReviewSaveFlag: data['classReviewSaveFlag'],
        classReviewSaveDate: data['classReviewSaveData'] == null
            ? null
            : DateTime.parse(data['classReviewSaveData']),
        classReviewNotiFlag: data['classReviewNotiFlag'],
        classReviewNotiDate: data['classReviewNotiDate'] == null
            ? null
            : DateTime.parse(data['classReviewNotiDate']));
  }
}

class RoomData {
  final String chatRoomUuid;
  final String chatRoomHash;
  final String status;
  final DateTime createDate;
  final DateTime updateDate;
  final DateTime lastMessageDate;
  final String lastMessage;
  final int unreadCnt;
  final ChatRoomMember? chatRoomMember;
  final ClassInfo? classInfo;
  final CommunityInfo? communityInfo;
  final int seq;
  int noticeReceiveFlag;

  RoomData(
      {required this.chatRoomUuid,
      required this.chatRoomHash,
      required this.status,
      required this.createDate,
      required this.updateDate,
      required this.lastMessageDate,
      required this.lastMessage,
      required this.unreadCnt,
      required this.chatRoomMember,
      required this.classInfo,
      required this.communityInfo,
      required this.seq,
      required this.noticeReceiveFlag});

  factory RoomData.fromJson(data) {
    return RoomData(
        chatRoomUuid: data['chatRoomUuid'],
        chatRoomHash: data['chatRoomHash'],
        status: data['status'],
        createDate: DateTime.parse(data['createDate'].toString()),
        updateDate: DateTime.parse(data['updateDate'].toString()),
        lastMessageDate: DateTime.parse(data['lastMessageDate'].toString()),
        lastMessage: data['lastMessage'],
        unreadCnt: data['unreadCnt'],
        chatRoomMember: ChatRoomMember.fromJson(data['chatRoomMember']),
        classInfo: data['classInfo'] == null
            ? null
            : ClassInfo.fromJson(data['classInfo']),
        communityInfo: data['communityInfo'] == null
            ? null
            : CommunityInfo.fromJson(data['communityInfo']),
        seq: data['seq'],
        noticeReceiveFlag: data['noticeReceiveFlag']);
  }

  toMap() {
    Map<String, Object> data = {};
    data.addAll({'chatRoomUuid': chatRoomUuid});
    data.addAll({'chatRoomHash': chatRoomHash});
    data.addAll({'status': status});
    data.addAll({'createDate': createDate.toIso8601String()});
    data.addAll({'updateDate': updateDate.toIso8601String()});
    data.addAll({'lastMessageDate': lastMessageDate.toIso8601String()});
    data.addAll({'lastMessage': lastMessage});
    data.addAll({'unreadCnt': unreadCnt});
    data.addAll({'chatRoomMember': chatRoomMember!.toMap()});
    if (classInfo != null) {
      data.addAll({'classInfo': classInfo!.toMap()});
    }
    if (communityInfo != null) {
      data.addAll({'communityInfo': communityInfo!.toMap()});
    }
    data.addAll({'seq': seq});
    data.addAll({'noticeReceiveFlag': noticeReceiveFlag});
    return data;
  }
}

class ChatRoomMember {
  final String memberUuid;
  final String? nickName;
  final String? profile;

  ChatRoomMember({required this.memberUuid, this.nickName, this.profile});

  factory ChatRoomMember.fromJson(data) {
    return ChatRoomMember(
        memberUuid: data['memberUuid'],
        nickName: data['nickName'],
        profile: data['profile']);
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'memberUuid': memberUuid});
    if (nickName != null) {
      data.addAll({'nickName': nickName});
    }
    if (profile != null) {
      data.addAll({'profile': profile});
    }
    return data;
  }
}

class ClassInfo {
  final String classUuid;
  final String type;
  final String title;
  final String costType;
  final int costConsultFlag;
  final int minCost;
  final String hangNames;
  final Data? image;

  ClassInfo(
      {required this.classUuid,
      required this.type,
      required this.title,
      required this.costType,
      required this.costConsultFlag,
      required this.minCost,
      required this.hangNames,
      this.image});

  factory ClassInfo.fromJson(data) {
    return ClassInfo(
        classUuid: data['classUuid'],
        type: data['type'],
        title: data['title'],
        costType: data['costType'],
        costConsultFlag: data['costConsultFlag'],
        minCost: data['minCost'],
        hangNames: data['hangNames'],
        image: (data == null ||
                data['image'] == null ||
                data['image'].toString().contains('null'))
            ? null
            : Data.fromJson(data['image']));
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'classUuid': classUuid});
    data.addAll({'type': type});
    data.addAll({'title': title});
    data.addAll({'costConsultFlag': costConsultFlag});
    data.addAll({'minCost': minCost});
    data.addAll({'hangNames': hangNames});
    if (image != null && image!.prefixUrl != null) {
      data.addAll({'image': image!.toMap()});
    }
    return data;
  }
}

class CommunityInfo {
  final String communityUuid;
  final String? status;
  final String contentText;
  final String hangNames;
  final Data? image;
  final String category;

  CommunityInfo(
      {required this.communityUuid,
      this.status,
      required this.contentText,
      required this.hangNames,
      this.image,
      required this.category});

  factory CommunityInfo.fromJson(data) {
    return CommunityInfo(
        communityUuid: data['communityUuid'],
        contentText: data['contentText'],
        hangNames: data['hangNames'],
        category: data['category'],
        image: data['image'] != null ? Data.fromJson(data['image']) : null,
        status: data['status']);
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'communityUuid': communityUuid});
    if (status != null) {
      data.addAll({'status': status});
    }
    data.addAll({'hangNames': hangNames});
    data.addAll({'contentText': contentText});
    if (image != null) {
      data.addAll({'image': image!.toMap()});
    }
    data.addAll({'category': category});
    return data;
  }
}
