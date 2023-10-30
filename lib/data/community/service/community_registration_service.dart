import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/community_create.dart';
import 'package:http/http.dart';

class CommunityRegistrationService extends BaseService {
  final CommunityCreate communityCreate;

  CommunityRegistrationService({required this.communityCreate});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode(communityCreate.toMap()));
  }

  @override
  setUrl() {
    return baseUrl + 'community';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
