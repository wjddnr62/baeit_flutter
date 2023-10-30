import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetClassThemeDetailService extends BaseService {
  final String curationThemeUuid;
  final String lati;
  final String longi;
  final int orderType;
  final int size;
  final String? cursor;

  GetClassThemeDetailService(
      {required this.curationThemeUuid,
      required this.lati,
      required this.longi,
      this.orderType = 1,
      this.size = 10,
      this.cursor});

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
    return baseUrl +
        "class/theme/class/list?curationThemeUuid=$curationThemeUuid&lati=$lati&longi=$longi&orderType=$orderType&size=$size${cursor != null ? '&nextCursor=$cursor' : ''}";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
