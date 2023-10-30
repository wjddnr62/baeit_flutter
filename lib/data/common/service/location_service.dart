import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class LocationService extends BaseService {
  final String lat;
  final String lon;

  LocationService({required this.lat, required this.lon});

  @override
  Future<Response> request() {
    Map<String, Object> data = {};
    data.addAll({'lati': lat});
    data.addAll({'longi': lon});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "location";
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
