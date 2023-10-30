import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/signup/login.dart';
import 'package:http/http.dart';

class LoginService extends BaseService {
  final Login login;

  LoginService({required this.login}) : super(withAccessToken: false);

  @override
  Future<Response> request() {
    Map<String, Object> data = {};
    data.addAll({'accessId': login.accessId});
    data.addAll({'device': login.device.toMap()});
    data.addAll({'type': login.type});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "log-in";
  }

  @override
  success(body) async {
    if (ReturnData.fromJson(body).code == 1) {
      await prefs!.setBool('guest', false);
    }
    return ReturnData.fromJson(body);
  }

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }
}
