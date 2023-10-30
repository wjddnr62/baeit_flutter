import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class CommunityBookmarkService extends BaseService {
  final String communityUuid;

  CommunityBookmarkService({required this.communityUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(body: jsonEncode({'communityUuid': communityUuid}));
  }

  @override
  setUrl() {
    return baseUrl + 'community/like';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
