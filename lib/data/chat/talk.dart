import 'dart:io';

import 'package:baeit/data/common/image_value.dart';

class Talk {
  String chatRoomMessageUuid;
  final String chatRoomUuid;
  final String type;
  final String? message;
  final List<Data> files;
  DateTime createDate;
  int unreadCnt;
  final String memberUuid;
  String nextCursor;
  String? path;
  bool send;
  bool loading;
  final String? sendUuid;
  String? status;

  Talk(
      {required this.chatRoomMessageUuid,
      required this.chatRoomUuid,
      required this.type,
      this.message,
      required this.createDate,
      required this.unreadCnt,
      required this.memberUuid,
      required this.files,
      required this.nextCursor,
      this.path,
      this.send = true,
      this.loading = false,
      required this.sendUuid,
      this.status});

  factory Talk.fromJson(data) {
    return Talk(
        chatRoomMessageUuid: data['chatRoomMessageUuid'],
        chatRoomUuid: data['chatRoomUuid'],
        type: data['type'],
        message: data['message'],
        files: data['files'] != null
            ? (data['files'] as List).map((e) => Data.fromJson(e)).toList()
            : [],
        createDate: DateTime.parse(data['createDate']),
        unreadCnt: data['unreadCnt'],
        memberUuid: data['memberUuid'],
        nextCursor: data['cursor'],
        sendUuid: data['sendUuid'],
        loading: data['loading'] ?? false,
        send: data['send'] ?? true,
        path: data['path'],
        status: data['status']);
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'chatRoomMessageUuid': chatRoomMessageUuid});
    data.addAll({'chatRoomUuid': chatRoomUuid});
    data.addAll({'type': type});
    data.addAll({'message': message ?? null});
    data.addAll({'createDate': createDate.toString()});
    data.addAll({'unreadCnt': unreadCnt});
    data.addAll({'memberUuid': memberUuid});
    data.addAll({
      'files': files.length == 0 ? [] : files.map((e) => e.toDecode()).toList()
    });
    data.addAll({'cursor': nextCursor});
    if (path != null) {
      data.addAll({'path': path});
    }
    data.addAll({'sendUuid': sendUuid});
    data.addAll({'loading': loading});
    data.addAll({'send': send});
    data.addAll({'status': status});
    return data;
  }
}

class TalkSend {
  final String chatRoomUuid;
  final String type;
  final String? message;
  final String nickName;
  final String? profile;
  final List<dynamic>? files;
  final String memberUuid;
  final int seq;
  final String sendUuid;
  DateTime sendDate;
  final String? subType;

  TalkSend(
      {required this.chatRoomUuid,
      required this.type,
      this.message,
      required this.nickName,
      this.profile,
      this.files,
      required this.memberUuid,
      required this.seq,
      required this.sendUuid,
      required this.sendDate,
      this.subType});

  factory TalkSend.fromJson(data) {
    return TalkSend(
        chatRoomUuid: data['chatRoomUuid'],
        type: data['type'],
        message: data['message'],
        nickName: data['nickName'],
        profile: data['profile'],
        files: data['files'],
        memberUuid: data['memberUuid'],
        seq: data['seq'],
        sendUuid: data['sendUuid'],
        sendDate: DateTime.parse(data['sendDate']),
        subType: data['subType']);
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'chatRoomUuid': chatRoomUuid});
    data.addAll({'type': type});
    if (message != null) {
      data.addAll({'message': message});
    }
    data.addAll({'nickName': nickName});
    if (profile != null) {
      data.addAll({'profile': profile});
    }
    if (files != null) {
      data.addAll({'files': files});
    }
    data.addAll({'memberUuid': memberUuid});
    data.addAll({'seq': seq});
    data.addAll({'osType': Platform.isAndroid ? 'Android' : 'iOS'});
    data.addAll({'sendUuid': sendUuid});
    data.addAll({'sendDate': sendDate.toIso8601String()});
    if (subType != null) {
      data.addAll({'subType': subType});
    }
    return data;
  }
}
