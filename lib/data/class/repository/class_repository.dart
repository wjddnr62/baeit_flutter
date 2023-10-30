import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/service/bookmark_class_service.dart';
import 'package:baeit/data/class/service/class_departure_service.dart';
import 'package:baeit/data/class/service/class_variations_service.dart';
import 'package:baeit/data/class/service/get_category_service.dart';
import 'package:baeit/data/class/service/get_class_area_service.dart';
import 'package:baeit/data/class/service/get_class_bookmark_service.dart';
import 'package:baeit/data/class/service/get_class_count_service.dart';
import 'package:baeit/data/class/service/get_class_detail_service.dart';
import 'package:baeit/data/class/service/get_class_service.dart';
import 'package:baeit/data/class/service/get_class_theme_detail_service.dart';
import 'package:baeit/data/class/service/get_class_theme_service.dart';
import 'package:baeit/data/class/service/get_class_view_service.dart';
import 'package:baeit/data/class/service/get_map_class_service.dart';
import 'package:baeit/data/class/service/get_map_marker_service.dart';
import 'package:baeit/data/class/service/get_map_service.dart';
import 'package:baeit/data/class/service/get_member_class_service.dart';
import 'package:baeit/data/class/service/get_mine_class_service.dart';
import 'package:baeit/data/class/service/get_share_link_service.dart';
import 'package:baeit/data/class/service/made_class_check_service.dart';
import 'package:baeit/data/class/service/update_class_status_service.dart';
import 'package:baeit/data/class/service/update_kakao_link_count_service.dart';
import 'package:baeit/data/class/variations_class.dart';

class ClassRepository {
  static Future<dynamic> getClassList(GetClass getClass) =>
      GetClassService(getClass: getClass).start();

  static Future<dynamic> getClassCount() => GetClassCountService().start();

  static Future<dynamic> classVariations(VariationsClass variationsClass) =>
      ClassVariationsService(variationsClass: variationsClass).start();

  static Future<dynamic> getMineClassList(
          {String? nextCursor, String? status, required String type}) =>
      GetMineClassService(nextCursor: nextCursor, status: status, type: type)
          .start();

  static Future<dynamic> getClassDetail(
          String classUuid, String lati, String longi, {int readFlag = 1}) =>
      GetClassDetailService(
              classUuid: classUuid,
              lati: lati,
              longi: longi,
              readFlag: readFlag)
          .start();

  static Future<dynamic> getCategory() => GetCategoryService().start();

  static Future<dynamic> bookmarkClass(String classUuid) =>
      BookmarkClassService(classUuid: classUuid).start();

  static Future<dynamic> getBookmarkClassList(
          {String? nextCursor, required String type, int? size}) =>
      GetClassBookmarkService(nextCursor: nextCursor, type: type, size: size)
          .start();

  static Future<dynamic> getClassViewList(
          {String? nextCursor, required String type}) =>
      GetClassViewService(nextCursor: nextCursor, type: type).start();

  static Future<dynamic> updateClassStatus(String classUuid, String status) =>
      UpdateClassStatusService(classUuid: classUuid, status: status).start();

  static Future<dynamic> getShareLink(String classUuid) =>
      GetShareLinkService(classUuid: classUuid).start();

  static Future<dynamic> classDeparture(int step, String type) =>
      ClassDepartureService(step: step, type: type).start();

  static Future<dynamic> getMap(String lati, String longi, double mapLevel,
          {String? type, String? categories}) =>
      GetMapService(
              lati: lati,
              longi: longi,
              mapLevel: mapLevel,
              categories: categories)
          .start();

  static Future<dynamic> getMapMarker(String lati, String longi, int mapLevel,
          {String? type, String? categories}) =>
      GetMapMarkerService(
              lati: lati,
              longi: longi,
              mapLevel: mapLevel,
              categories: categories)
          .start();

  static Future<dynamic> getMapClass(
          {String? addressEupmyeondongNo,
          String? addressSigunguNo,
          String? addressSidoNo,
          String? categories,
          required String lati,
          required String longi,
          String? nextCursor,
          int? orderType,
          String? searchText,
          String? type}) =>
      GetMapClassService(
              addressEupmyeondongNo: addressEupmyeondongNo,
              addressSigunguNo: addressSigunguNo,
              addressSidoNo: addressSidoNo,
              categories: categories,
              lati: lati,
              longi: longi,
              nextCursor: nextCursor,
              orderType: orderType,
              searchText: searchText,
              type: type)
          .start();

  static Future<dynamic> getMemberClass(
          {required String memberUuid,
          String? nextCursor,
          required String type}) =>
      GetMemberClassService(
              memberUuid: memberUuid, type: type, nextCursor: nextCursor)
          .start();

  static Future<dynamic> madeClassCheck() => MadeClassCheckService().start();

  static Future<dynamic> getClassTheme(
          {required String lati, required String longi, int size = 10}) =>
      GetClassThemeService(lati: lati, longi: longi, size: size).start();

  static Future<dynamic> getClassThemeDetail(
          {required String curationThemeUuid,
          required String lati,
          required String longi,
          String? cursor}) =>
      GetClassThemeDetailService(
              curationThemeUuid: curationThemeUuid,
              lati: lati,
              longi: longi,
              cursor: cursor)
          .start();

  static Future<dynamic> updateKakaoLinkCount({required String classUuid}) =>
      UpdateKakaoLinkCountService(classUuid: classUuid).start();

  static Future<dynamic> getClassArea(
          {required String classUuid,
          required String lati,
          required String longi}) =>
      GetClassAreaService(classUuid: classUuid, lati: lati, longi: longi)
          .start();
}
