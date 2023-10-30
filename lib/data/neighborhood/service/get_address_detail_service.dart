import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_add.dart';
import 'package:http/http.dart';

class GetAddressDetailService extends BaseService {
  final String address;

  GetAddressDetailService({required this.address});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}common/address/detail?address=$address';
  }

  @override
  success(body) {
    return AddressDetailData.fromJson(body);
  }

  @override
  expiration(body) {
    return body;
  }
}
