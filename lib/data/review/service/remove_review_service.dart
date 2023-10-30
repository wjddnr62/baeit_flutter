import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class RemoveReviewService extends BaseService {
  final String classReviewUuid;

  RemoveReviewService({required this.classReviewUuid});

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
    return ReturnData.fromJson(body);
  }
}
