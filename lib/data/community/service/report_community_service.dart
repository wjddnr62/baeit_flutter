import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ReportCommunityService extends BaseService {
  final String? communityUuid;
  final String? communityCommentUuid;
  final List<Data>? images;
  final String reportText;
  final int type;

  ReportCommunityService(
      {this.communityUuid,
      this.communityCommentUuid,
      this.images,
      required this.reportText,
      required this.type});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    if (type == 0) {
      data.addAll({'communityUuid': communityUuid});
    } else {
      data.addAll({'communityCommentUuid': communityCommentUuid});
    }
    if (images != null) {
      data.addAll({
        'images': images!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    data.addAll({'reportText': reportText});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    if (type == 0) {
      return baseUrl + 'community/report';
    } else {
      return baseUrl + 'community/comment/report';
    }
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
