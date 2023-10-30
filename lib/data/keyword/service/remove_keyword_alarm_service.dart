import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class RemoveKeywordAlarmService extends BaseService {
  final String memberClassKeywordUuid;

  RemoveKeywordAlarmService({required this.memberClassKeywordUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchDelete();
  }

  @override
  setUrl() {
    return baseUrl +
        "member/class/alarm/keyword?memberClassKeywordUuid=$memberClassKeywordUuid";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
