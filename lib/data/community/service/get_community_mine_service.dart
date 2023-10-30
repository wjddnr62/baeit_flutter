import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetCommunityMineService extends BaseService {
  final String? nextCursor;
  final String? status;

  GetCommunityMineService({this.nextCursor, this.status});

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
        'community/mine/list?size=20${nextCursor != null ? '&nextCursor=$nextCursor' : ''}${status != null ? '&status=$status' : ''}';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
