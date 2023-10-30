import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class CheeringMsgService extends BaseService {
  final String memberCheeringAreaUuid;
  final String messageText;

  CheeringMsgService(
      {required this.memberCheeringAreaUuid, required this.messageText});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'memberCheeringAreaUuid': memberCheeringAreaUuid});
    data.addAll({'messageText': messageText});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "cheering";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
