import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class LogoutService extends BaseService {
  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost();
  }

  @override
  setUrl() {
    return baseUrl + 'log-out';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
