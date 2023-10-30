import 'dart:io';

import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class UpdateTokenService extends BaseService {
  final String? token;

  UpdateTokenService({required this.token});

  @override
  Future<Response> request() {
    Map<String, Object> data = {};
    data.addAll({'token': token!});
    data.addAll({'type': Platform.isAndroid ? 'ANDROID' : 'IOS'});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "member/device";
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
