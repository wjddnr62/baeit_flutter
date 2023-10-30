import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/feedback/feedback.dart';
import 'package:http/http.dart';

class FeedbackService extends BaseService {
  final FeedbackSend feedbackSend;

  FeedbackService({required this.feedbackSend});

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode(feedbackSend.toMap()));
  }

  @override
  setUrl() {
    return baseUrl + "feedback/feedback";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }
}
