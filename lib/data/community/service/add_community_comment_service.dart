import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class AddCommunityCommentService extends BaseService {
  final String? communityCommentUuid;
  final String communityUuid;
  final String? parentCommentUuid;
  final String? rootCommentUuid;
  final String text;

  AddCommunityCommentService(
      {this.communityCommentUuid,
      required this.communityUuid,
      this.parentCommentUuid,
      this.rootCommentUuid,
      required this.text});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'communityUuid': communityUuid});
    if (communityCommentUuid != null) {
      data.addAll({'communityCommentUuid': communityCommentUuid});
    }
    if (parentCommentUuid != null) {
      data.addAll({'parentCommentUuid': parentCommentUuid});
    }
    if (rootCommentUuid != null) {
      data.addAll({'rootCommentUuid': rootCommentUuid});
    }
    data.addAll({'text': text});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + 'community/comment';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
