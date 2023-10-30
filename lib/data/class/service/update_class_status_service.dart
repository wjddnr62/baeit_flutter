import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class UpdateClassStatusService extends BaseService {
  final String classUuid;
  final String status;

  UpdateClassStatusService({required this.classUuid, required this.status});

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'classUuid': classUuid});
    data.addAll({'status': status});
    return fetchPut(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "class/status";
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
