import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetClassThemeService extends BaseService {
  final String lati;
  final String longi;
  final int size;

  GetClassThemeService(
      {required this.lati, required this.longi, this.size = 10});

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
    return baseUrl + "class/theme/list?lati=$lati&longi=$longi&size=$size";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
