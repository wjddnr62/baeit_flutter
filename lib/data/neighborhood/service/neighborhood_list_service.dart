import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class NeighborHoodListService extends BaseService {
  final bool check;

  NeighborHoodListService({this.check = false});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}member/area/list';
  }

  @override
  success(body) {
    if (!check) {
      return ReturnData.fromJson(body);
    } else {
      return body;
    }
  }

  @override
  expiration(body) {
    return body;
  }
}
