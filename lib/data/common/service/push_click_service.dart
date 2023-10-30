import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class PushClickService extends BaseService {
  final String pushUuid;

  PushClickService({required this.pushUuid});

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
    return baseUrl + "push/click?pushUuid=$pushUuid";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
