import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class KeywordAlarmNotiChangeService extends BaseService {
  final int alarmFlag;
  final String memberAreaUuid;
  final String type;

  KeywordAlarmNotiChangeService(
      {required this.alarmFlag,
      required this.memberAreaUuid,
      required this.type});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(
        body: jsonEncode({
      'alarmFlag': alarmFlag,
      'memberAreaUuid': memberAreaUuid,
      'type': type
    }));
  }

  @override
  setUrl() {
    return baseUrl + "member/class/alarm/area";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
