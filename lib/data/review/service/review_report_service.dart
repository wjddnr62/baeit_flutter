import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ReviewReportService extends BaseService {
  final String classReviewUuid;
  final List<Data>? images;
  final String reportText;

  ReviewReportService(
      {required this.classReviewUuid, this.images, required this.reportText});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'classReviewUuid': classReviewUuid});
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
    return baseUrl + 'class/review/report';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
