import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ChatOpenService extends BaseService {
  final String? classUuid;
  final String? communityUuid;
  final bool classCheck;
  final bool communityCheck;
  final int introFlag;

  ChatOpenService(
      {this.classUuid = '',
      this.communityUuid = '',
      this.classCheck = false,
      this.communityCheck = false,
      this.introFlag = 0});

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
    if (classCheck) {
      return baseUrl + "chat/classChatRoom?classUuid=$classUuid&introFlag=$introFlag";
    }
    if (communityCheck) {
      return baseUrl + "chat/communityChatRoom?communityUuid=$communityUuid";
    }
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
