import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class AccessTokenService extends BaseService {
  final String memberUuid;
  final String refreshToken;

  AccessTokenService({required this.memberUuid, required this.refreshToken})
      : super(withAccessToken: false);

  @override
  Future<Response> request() {
    Map<String, Object> data = {};
    data.addAll({'memberUuid': memberUuid});
    data.addAll({'refreshToken': refreshToken});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "accessToken";
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
