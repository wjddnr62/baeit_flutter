import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetCommunityDetailService extends BaseService {
  final String communityUuid;
  final String lati;
  final String longi;
  final int readFlag;

  GetCommunityDetailService(
      {required this.communityUuid,
      required this.lati,
      required this.longi,
      this.readFlag = 1});

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
        'community/details?communityUuid=$communityUuid&lati=$lati&longi=$longi&readFlag=$readFlag';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
