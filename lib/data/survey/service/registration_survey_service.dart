import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class RegistrationSurveyService extends BaseService {
  final String surveyUuid;

  RegistrationSurveyService({required this.surveyUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode({'surveyUuid': surveyUuid}));
  }

  @override
  setUrl() {
    return baseUrl + 'survey';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
