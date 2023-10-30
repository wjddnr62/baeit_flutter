import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetKeywordAlarmService extends BaseService {
  final String type;

  GetKeywordAlarmService({required this.type});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + "member/class/alarm?type=$type";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
