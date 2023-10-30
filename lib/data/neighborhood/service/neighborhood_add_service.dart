import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:http/http.dart';

class NeighborHoodAddService extends BaseService {
  final NeighborHood neighborHood;

  NeighborHoodAddService({required this.neighborHood});

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode(neighborHood.toMap()));
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
