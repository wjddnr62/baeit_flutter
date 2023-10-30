import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ChatExitService extends BaseService {
  final String chatRoomUuid;

  ChatExitService({required this.chatRoomUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(body: jsonEncode({'chatRoomUuid': chatRoomUuid}));
  }

  @override
  setUrl() {
    return baseUrl + 'chat/chatRoom/exit';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
