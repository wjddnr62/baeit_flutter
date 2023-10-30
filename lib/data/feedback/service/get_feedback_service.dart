import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetFeedbackService extends BaseService {
  final String? nextCursor;
  final int? answerFlag;

  GetFeedbackService({this.nextCursor, this.answerFlag});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        "feedback/list?answerFlag=${answerFlag == null ? '' : answerFlag}&nextCursor=${nextCursor == null ? '' : nextCursor}&size=20";
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
