import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetCategoryService extends BaseService {
  GetCategoryService() : super(withAccessToken: false);

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + "class/category";
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
