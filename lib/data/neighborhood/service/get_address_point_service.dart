import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/neighborhood/neighborhood_add.dart';
import 'package:http/http.dart';

class GetAddressPointService extends BaseService {
  final String lat;
  final String lon;

  GetAddressPointService({required this.lat, required this.lon});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}common/point/detail?lati=$lat&longi=$lon';
  }

  @override
  success(body) {
    return AddressPointData.fromJson(body);
  }

  @override
  expiration(body) {
    return body;
  }
}
