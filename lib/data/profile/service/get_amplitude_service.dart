import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetAmplitudeService extends BaseService {
  @override
  expiration(body) {
    if (body != null)
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + "member/amplitude";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
