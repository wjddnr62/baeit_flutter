import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetReviewDetailsService extends BaseService {
  final String classReviewUuid;

  GetReviewDetailsService({required this.classReviewUuid});

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
    return baseUrl + 'class/review/details?classReviewUuid=$classReviewUuid';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
