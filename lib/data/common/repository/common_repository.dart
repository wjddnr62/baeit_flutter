import 'package:baeit/data/common/service/access_token_service.dart';
import 'package:baeit/data/common/service/get_address_info_service.dart';
import 'package:baeit/data/common/service/get_polygon_service.dart';
import 'package:baeit/data/common/service/get_polygon_v2_service.dart';
import 'package:baeit/data/common/service/get_short_link.dart';
import 'package:baeit/data/common/service/get_version_service.dart';
import 'package:baeit/data/common/service/location_service.dart';
import 'package:baeit/data/common/service/member_block_service.dart';
import 'package:baeit/data/common/service/push_click_service.dart';
import 'package:baeit/data/common/service/update_token_service.dart';
import 'package:baeit/data/common/service/withdrawal_service.dart';

class CommonRepository {
  static Future<dynamic> locationUpdate(String lat, String lon) =>
      LocationService(lat: lat, lon: lon).start();

  static Future<dynamic> accessTokenUpdate(
          String memberUuid, String refreshToken) =>
      AccessTokenService(memberUuid: memberUuid, refreshToken: refreshToken)
          .start();

  static Future<dynamic> getVersion(String type, String versionText) =>
      GetVersionService(type: type, versionText: versionText).start();

  static Future<dynamic> withdrawalUser({String memberWithdrawalForm = ''}) =>
      WithdrawalService(memberWithdrawalForm: memberWithdrawalForm).start();

  static Future<dynamic> updateToken({required String token}) =>
      UpdateTokenService(token: token).start();

  static Future<dynamic> getShortLink() => GetShortLink().start();

  static Future<dynamic> getAddressInfo(String hangCode) =>
      GetAddressInfoService(hangCode: hangCode).start();

  static Future<dynamic> pushClick(String pushUuid) =>
      PushClickService(pushUuid: pushUuid).start();

  static Future<dynamic> getPolygon(String lat, String lon, int polygonLevel) =>
      GetPolygonService(lati: lat, longi: lon, polygonLevel: polygonLevel)
          .start();

  static Future<dynamic> getPolygonV2(int addressSidoNo, int? addressSigunguNo,
          int? addressEupmyeondongNo) =>
      GetPolygonV2Service(
              addressSidoNo: addressSidoNo,
              addressSigunguNo: addressSigunguNo,
              addressEupmyeondongNo: addressEupmyeondongNo)
          .start();

  static Future<dynamic> memberBlock({required String memberUuid}) =>
      MemberBlockService(memberUuid: memberUuid).start();
}
