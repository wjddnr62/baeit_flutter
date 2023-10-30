import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:http/http.dart';

class SignupService extends BaseService {
  final SignUp signUp;

  SignupService({required this.signUp}) : super(withAccessToken: false);

  @override
  Future<Response> request() {
    Map<String, Object> data = {};
    data.addAll({'accessId': signUp.accessId});
    if (signUp.kakaoInfo != null) {
      data.addAll({'kakaoInfo': signUp.kakaoInfo!.toMap()});
    }
    if (signUp.appleInfo != null) {
      data.addAll({'appleInfo': signUp.appleInfo!.toMap()});
    }
    if (signUp.image != null) {
      data.addAll({'image': signUp.image!.toMap()});
    }
    data.addAll({'device': signUp.device.toMap()});
    data.addAll({'email': signUp.email});
    if (signUp.birthDate != null) {
      data.addAll({'birthDate': signUp.birthDate!});
    }
    if (signUp.gender != null) {
      data.addAll({'gender': signUp.gender!});
    }
    if (signUp.nickName != null) {
      data.addAll({'nickName': signUp.nickName!});
    }
    if (signUp.phone != null) {
      data.addAll({'phone': signUp.phone!});
    }
    data.addAll({'type': signUp.type});
    return fetchPost(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl.substring(0, baseUrl.length - 1);
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
