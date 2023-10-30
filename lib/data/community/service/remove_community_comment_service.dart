import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class RemoveCommunityCommentService extends BaseService {
  final String communityCommentUuid;

  RemoveCommunityCommentService({required this.communityCommentUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchDelete();
  }

  @override
  setUrl() {
    return baseUrl +
        'community/comment/status?communityCommentUuid=$communityCommentUuid';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
