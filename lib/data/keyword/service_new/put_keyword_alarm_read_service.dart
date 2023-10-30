import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class PutKeywordAlarmReadService extends BaseService {
  final String type;

  PutKeywordAlarmReadService({required this.type});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(body: jsonEncode({'type': type}));
  }

  @override
  setUrl() {
    return baseUrl + 'member/keyword/alarm/read';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
