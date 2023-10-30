import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetCommunityMemberService extends BaseService {
  final String memberUuid;
  final String? nextCursor;
  final String? status;

  GetCommunityMemberService(
      {required this.memberUuid, this.nextCursor, this.status});

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
    return baseUrl +
        'community/other/list?memberUuid=$memberUuid${nextCursor != null ? '&nextCursor=$nextCursor' : ''}${status != null ? '&status=$status' : ''}';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
