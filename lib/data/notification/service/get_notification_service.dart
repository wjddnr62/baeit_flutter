import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetNotificationService extends BaseService {
  final String? nextCursor;

  GetNotificationService({this.nextCursor});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        "notification?size=20&nextCursor=${nextCursor == null ? '' : nextCursor}";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }
}
