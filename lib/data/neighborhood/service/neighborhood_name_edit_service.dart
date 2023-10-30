import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class NeighborHoodNameEditService extends BaseService {
  final String memberAreaUuid;
  final String townName;

  NeighborHoodNameEditService(
      {required this.memberAreaUuid, required this.townName});

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'memberAreaUuid': memberAreaUuid});
    data.addAll({'townName': townName});
    return fetchPut(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "member/area";
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
