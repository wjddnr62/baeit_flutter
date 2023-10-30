import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetShareLinkService extends BaseService {
  final String classUuid;

  GetShareLinkService({required this.classUuid});

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
    return baseUrl + 'class/shortLink?classUuid=$classUuid';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}