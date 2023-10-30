import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetAddressInfoService extends BaseService {
  final String hangCode;

  GetAddressInfoService({required this.hangCode});

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
    return baseUrl + 'common/addressInfo?hangCode=$hangCode';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
