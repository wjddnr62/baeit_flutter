import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class AddKeywordAddAlarmService extends BaseService {
  final String keywordText;
  final String type;

  AddKeywordAddAlarmService({required this.keywordText, required this.type});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(
        body: jsonEncode({'keywordText': keywordText, 'type': type}));
  }

  @override
  setUrl() {
    return baseUrl + "member/class/alarm/keyword";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
