import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetKeywordAlarmCountService extends BaseService {
  final String type;

  GetKeywordAlarmCountService({required this.type});

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
    return baseUrl + "member/class/alarm/read?type=$type";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
