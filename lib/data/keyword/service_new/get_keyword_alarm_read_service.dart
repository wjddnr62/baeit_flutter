import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetKeywordAlarmReadService extends BaseService {
  final String type;

  GetKeywordAlarmReadService({required this.type});

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
    return baseUrl + 'member/keyword/alarm/read?type=$type';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }

}