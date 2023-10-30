import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class NeighborHoodRemoveService extends BaseService {
  final String memberAreaUuid;

  NeighborHoodRemoveService({required this.memberAreaUuid});

  @override
  Future<Response> request() {
    return fetchDelete();
  }

  @override
  setUrl() {
    return baseUrl + "member/area?memberAreaUuid=$memberAreaUuid";
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
