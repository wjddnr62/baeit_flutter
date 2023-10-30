import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:http/http.dart';

class ProfileUpdateService extends BaseService {
  final Profile profile;

  ProfileUpdateService({required this.profile});

  @override
  Future<Response> request() {
    return fetchPut(body: jsonEncode(profile.toMap()));
  }

  @override
  setUrl() {
    return baseUrl + "member/info";
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
