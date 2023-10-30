import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetClassAreaService extends BaseService {
  final String classUuid;
  final String lati;
  final String longi;

  GetClassAreaService(
      {required this.classUuid, required this.lati, required this.longi});

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
    return baseUrl + 'class/areas?classUuid=$classUuid&lati=$lati&longi=$longi';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
