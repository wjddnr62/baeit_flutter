import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetProfileOtherService extends BaseService {
  final String memberUuid;

  GetProfileOtherService({required this.memberUuid});

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
    return baseUrl + "member/info/other?memberUuid=$memberUuid";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
