import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class KeywordAlarmCountReadService extends BaseService {
  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut();
  }

  @override
  setUrl() {
    return baseUrl + "member/class/alarm/read";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
