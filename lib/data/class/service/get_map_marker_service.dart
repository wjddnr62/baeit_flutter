import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetMapMarkerService extends BaseService {
  final String lati;
  final String longi;
  final int mapLevel;
  final String type;
  final String? categories;

  GetMapMarkerService(
      {required this.lati,
      required this.longi,
      required this.mapLevel,
      this.type = 'MADE',
      this.categories});

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
    return baseUrl + "class/map/markers?lati=$lati&longi=$longi&mapLevel=$mapLevel&type=$type${categories != null ? '&categories=$categories' : ''}";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
