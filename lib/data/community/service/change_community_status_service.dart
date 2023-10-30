import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ChangeCommunityStatusService extends BaseService {
  final String communityUuid;
  final String status;

  ChangeCommunityStatusService(
      {required this.communityUuid, required this.status});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(
        body: jsonEncode({'communityUuid': communityUuid, 'status': status}));
  }

  @override
  setUrl() {
    return baseUrl + 'community/status';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
