import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/review/review.dart';
import 'package:http/http.dart';

class SaveReviewService extends BaseService {
  final ReviewSaveForm reviewSaveForm;

  SaveReviewService({required this.reviewSaveForm});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode(reviewSaveForm.toMap()));
  }

  @override
  setUrl() {
    return baseUrl + 'class/review';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
