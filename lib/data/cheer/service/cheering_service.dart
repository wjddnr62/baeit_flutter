import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class CheeringService extends BaseService {
  final String cheeringAreaUuid;

  CheeringService({required this.cheeringAreaUuid});

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
    return baseUrl + "cheering?cheeringAreaUuid=$cheeringAreaUuid";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
