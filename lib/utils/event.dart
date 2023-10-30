import 'dart:io';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/profile/amplitude.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'data_saver.dart';

Identify identify = Identify();

identifyInit() async {
  if (prefs!.getString('accessToken') != null && !dataSaver.nonMember) {
    ReturnData? returnData = await ProfileRepository.getAmplitude();
    if (returnData != null) {
      Amplitude amplitudeUserData = Amplitude.fromJson(returnData.data);
      dataSaver.amplitudeUserData = amplitudeUserData;
      await amplitude.setUserProperties(amplitudeUserData.toMap());
      if (Platform.isIOS) {
        Future<PermissionStatus> permission =
            NotificationPermissions.getNotificationPermissionStatus();

        await permission.then((value) {
          String permissionStatus = value.toString();
          if (permissionStatus != 'PermissionStatus.granted') {
            identifyAdd('push_ios_allowed', false);
          } else {
            identifyAdd('push_ios_allowed', true);
          }
        });
      }

      if (await ph.Permission.location.isGranted) {
        identifyAdd('location_permission_allowed', true);
      } else {
        identifyAdd('location_permission_allowed', false);
      }

      if (dataSaver.userData != null)
        identifyAdd('login_type', dataSaver.userData!.type);
    }
  }
}

neighborHoodIdentify() {
  List<NeighborHood> neighborHood = dataSaver.neighborHood;
  for (int i = 0; i < neighborHood.length; i++) {
    identifyAdd('town_${i + 1}', neighborHood[i].hangName);
    if (neighborHood[i].representativeFlag == 1) {
      identifyAdd('town_recent', neighborHood[i].hangName);
    }
  }
}

installIdentify() async {
  if (prefs!.getString('installDate') != null) {
    identifyAdd('app_install_year',
        DateTime.parse(prefs!.getString('installDate')!).year);
    identifyAdd('app_install_month',
        DateTime.parse(prefs!.getString('installDate')!).month);
    identifyAdd('app_install_day',
        DateTime.parse(prefs!.getString('installDate')!).day);
    identifyAdd('app_install_date',
        DateTime.parse(prefs!.getString('installDate')!).yearMonthDay);
  } else {
    await prefs!.setString('installDate', DateTime.now().yearMonthDay);
    installIdentify();
  }
}

identifyAdd(String key, dynamic value) async {
  identify.set(key, value);
  await amplitude.identify(identify);
}

identifyRemove(String key) {
  identify.unset(key);
  amplitude.identify(identify);
}

amplitudeEvent(String eventType, Map<String, dynamic> data,
    {bool init = true}) async {
  if (production == 'prod-release' && kReleaseMode) {
    if (init) {
      await identifyInit();
    }
    // if (!dataSaver.nonMember) {
    amplitude.logEvent(eventType, eventProperties: data);
    amplitude.uploadEvents();
    // }
  }
}

amplitudeRevenue({productId, required double price}) async {
  if (production == 'prod-release' && kReleaseMode) {
    await identifyInit();

    amplitude.logRevenue(productId, 1, price.toDouble());
  }
}

airbridgeEvent(String eventType) async {
  if (production == 'prod-release' && kReleaseMode) {
    Airbridge.event.send(Event(eventType));
  }
}

classEvent(String eventName, String classUuid, String lat, String lon,
    String sidoName, String sigunguName, String eupmyeondongName,
    {bool firstFree = false,
    bool group = false,
    String groupCost = '0',
    int reviewCount = 0}) {
  if (!dataSaver.nonMember) {
    ClassRepository.getClassDetail(classUuid, lat, lon, readFlag: 0)
        .then((value) {
      Class classData = Class.fromJson(value.data);
      ProfileRepository.getProfile().then((value) {
        ProfileGet members = ProfileGet.fromJson(value.data);
        ClassEventData eventData = ClassEventData(
            townSido: sidoName,
            townSigungu: sigunguName,
            townDongeupmyeon: eupmyeondongName,
            costMin: classData.content.minCost!,
            costType: classData.content.costType == 'HOUR' ? 0 : 1,
            costSharing: classData.content.shareType ?? '',
            category:
                classData.content.category!.classCategoryId!.toLowerCase(),
            profileCount: 0,
            viewCount: classData.readCnt,
            chatCount: classData.chatCnt,
            bookmarkCount: classData.likeCnt,
            shareCount: classData.shareCnt,
            distance:
                double.parse(classData.content.distance.toString()).toInt(),
            classId: classData.classUuid,
            className: classData.content.title!,
            userId: dataSaver.userData!.memberUuid,
            userName: members.nickName,
            firstFree: firstFree,
            group: group,
            groupCost: groupCost,
            reviewCount: reviewCount);
        amplitudeEvent(eventName, eventData.toMap());
      });
    });
  } else {
    ClassRepository.getClassDetail(classUuid, lat, lon, readFlag: 0)
        .then((value) {
      Class classData = Class.fromJson(value.data);

      ClassEventData eventData = ClassEventData(
          townSido: sidoName,
          townSigungu: sigunguName,
          townDongeupmyeon: eupmyeondongName,
          costMin: classData.content.minCost!,
          costType: classData.content.costType == 'HOUR' ? 0 : 1,
          costSharing: classData.content.shareType ?? '',
          category: classData.content.category!.classCategoryId!.toLowerCase(),
          profileCount: 0,
          viewCount: classData.readCnt,
          chatCount: classData.chatCnt,
          bookmarkCount: classData.likeCnt,
          shareCount: classData.shareCnt,
          distance: double.parse(classData.content.distance.toString()).toInt(),
          classId: classData.classUuid,
          className: classData.content.title!,
          userId: '',
          userName: '',
          firstFree: firstFree,
          group: group,
          groupCost: groupCost,
          reviewCount: reviewCount);
      amplitudeEvent(eventName, eventData.toMap());
    });
  }
}

class ClassEventData {
  String townSido;
  String townSigungu;
  String townDongeupmyeon;
  int costMin;
  int costType;
  String costSharing;
  String category;
  int profileCount;
  int viewCount;
  int chatCount;
  int bookmarkCount;
  int shareCount;
  int distance;
  String classId;
  String className;
  String userId;
  String userName;
  bool firstFree;
  bool group;
  String groupCost;
  int reviewCount;

  ClassEventData(
      {required this.townSido,
      required this.townSigungu,
      required this.townDongeupmyeon,
      required this.costMin,
      required this.costType,
      required this.costSharing,
      required this.category,
      required this.profileCount,
      required this.viewCount,
      required this.chatCount,
      required this.bookmarkCount,
      required this.shareCount,
      required this.distance,
      required this.classId,
      required this.className,
      required this.userId,
      required this.userName,
      this.firstFree = false,
      this.group = false,
      this.groupCost = '0',
      this.reviewCount = 0});

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'town_sido': townSido});
    data.addAll({'town_sigungu': townSigungu});
    data.addAll({'town_dongeupmyeon': townDongeupmyeon});
    data.addAll({'cost_min': costMin});
    data.addAll({'cost_type': costType});
    data.addAll({'cost_sharing': costSharing});
    data.addAll({'category': category});
    data.addAll({'profile_count': profileCount});
    data.addAll({'view_count': viewCount});
    data.addAll({'chat_count': chatCount});
    data.addAll({'bookmark_count': bookmarkCount});
    data.addAll({'share_count': shareCount});
    data.addAll({'distance': distance});
    data.addAll({'class_id': classId});
    data.addAll({'class_name': className});
    data.addAll({'user_id': userId});
    data.addAll({'user_name': userName});
    data.addAll({'first_free': firstFree});
    data.addAll({'group': group});
    data.addAll({'group_cost': groupCost});
    data.addAll({'review_count': reviewCount});
    return data;
  }
}

class RequestEventData {
  String townSido;
  String townSigungu;
  String townDongeupmyeon;
  int costMin;
  int costMax;
  int costAvg;
  String category;
  int profileCount;
  int viewCount;
  int chatCount;
  int bookmarkCount;
  int shareCount;
  String studentsLevel;
  String hopeWeek;
  int distance;
  String requestId;
  String requestName;
  String userId;
  String userName;

  RequestEventData(
      {required this.townSido,
      required this.townSigungu,
      required this.townDongeupmyeon,
      required this.costMin,
      required this.costMax,
      required this.costAvg,
      required this.category,
      required this.profileCount,
      required this.viewCount,
      required this.chatCount,
      required this.bookmarkCount,
      required this.shareCount,
      required this.studentsLevel,
      required this.hopeWeek,
      required this.distance,
      required this.requestId,
      required this.requestName,
      required this.userId,
      required this.userName});

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'town_sido': townSido});
    data.addAll({'town_sigungu': townSigungu});
    data.addAll({'town_dongeupmyeon': townDongeupmyeon});
    data.addAll({'cost_min': costMin});
    data.addAll({'category': category});
    data.addAll({'profile_count': profileCount});
    data.addAll({'view_count': viewCount});
    data.addAll({'chat_count': chatCount});
    data.addAll({'bookmark_count': bookmarkCount});
    data.addAll({'share_count': shareCount});
    data.addAll({'students_level': studentsLevel});
    data.addAll({'hope_week': hopeWeek});
    data.addAll({'distance': distance});
    data.addAll({'request_id': requestId});
    data.addAll({'request_name': requestName});
    data.addAll({'user_id': userId});
    data.addAll({'user_name': userName});
    return data;
  }
}
