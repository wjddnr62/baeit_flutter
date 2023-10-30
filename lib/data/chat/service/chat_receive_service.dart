import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ChatReceiveService extends BaseService {
  final String chatRoomUuid;
  final int noticeReceiveFlag;

  ChatReceiveService(
      {required this.chatRoomUuid, required this.noticeReceiveFlag});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPut(
        body: jsonEncode({
      'chatRoomUuid': chatRoomUuid,
      'noticeReceiveFlag': noticeReceiveFlag
    }));
  }

  @override
  setUrl() {
    return baseUrl + "chat/chatRoom";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
