import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/review/review.dart';
import 'package:http/http.dart';

class SaveCommentReviewService extends BaseService {
  final SaveReviewComment saveReviewComment;

  SaveCommentReviewService({required this.saveReviewComment});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(body: jsonEncode(saveReviewComment.toMap()));
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
