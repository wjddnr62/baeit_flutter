import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class DeleteReview extends BaseService {
  final String classReviewUuid;

  DeleteReview({required this.classReviewUuid});

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
    return baseUrl + 'class/review?classReviewUuid=$classReviewUuid';
  }

  @override
  success(body) {
    // TODO: implement success
    throw UnimplementedError();
  }

}