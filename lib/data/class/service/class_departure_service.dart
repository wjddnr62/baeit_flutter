import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ClassDepartureService extends BaseService {
  final int step;
  final String type;

  ClassDepartureService({required this.step, required this.type});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(body: jsonEncode({'step': step, 'type': type}));
  }

  @override
  setUrl() {
    return baseUrl + "class/departure";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
  
}