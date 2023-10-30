import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/src/response.dart';

class UpdateSettingService extends BaseService {
  final int chattingFlag;
  final int marketingReceptionFlag;
  final int prohibitFlag;
  final int classMadeKeywordAlarmFlag;
  final int classRequestKeywordAlarmFlag;
  final int communityCommentAlarmFlag;

  UpdateSettingService(
      {required this.chattingFlag,
      required this.marketingReceptionFlag,
      required this.prohibitFlag,
      required this.classMadeKeywordAlarmFlag,
      required this.classRequestKeywordAlarmFlag,
      required this.communityCommentAlarmFlag});

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'chattingFlag': chattingFlag});
    data.addAll({'marketingReceptionFlag': marketingReceptionFlag});
    data.addAll({'prohibitFlag': prohibitFlag});
    data.addAll({'classMadeKeywordAlarmFlag': classMadeKeywordAlarmFlag});
    data.addAll({'classRequestKeywordAlarmFlag': classRequestKeywordAlarmFlag});
    data.addAll({'communityCommentAlarmFlag': communityCommentAlarmFlag});
    return fetchPut(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "notification/setting";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }
}
