import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetPolygonService extends BaseService {
  final String lati;
  final String longi;
  final int polygonLevel;

  GetPolygonService(
      {required this.lati, required this.longi, required this.polygonLevel});

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
    return baseUrl + 'common/geoJson?lati=$lati&longi=$longi&polygonLevel=$polygonLevel';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
