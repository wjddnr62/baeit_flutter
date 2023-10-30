import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class MemberBlockService extends BaseService {
  final String memberUuid;

  MemberBlockService({required this.memberUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode({'memberUuid': memberUuid}));
  }

  @override
  setUrl() {
    return baseUrl + 'member/block';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
