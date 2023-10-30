import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/neighborhood/neighborhood_add.dart';
import 'package:http/http.dart';

class GetAddressService extends BaseService {
  final String keyword;
  final int page;

  GetAddressService({required this.keyword, this.page = 1});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}common/address?keyword=$keyword&page=$page&size=20';
  }

  @override
  success(body) {
    return AddressData.fromJson(body);
  }

  @override
  expiration(body) {
    return body;
  }
}
