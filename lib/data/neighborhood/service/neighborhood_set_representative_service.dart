import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class NeighborHoodSetRepresentativeService extends BaseService {
  final String memberAreaUuid;

  NeighborHoodSetRepresentativeService({required this.memberAreaUuid});

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'memberAreaUuid': memberAreaUuid});
    return fetchPut(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "member/area/representative";
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
