import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetChatRoomService extends BaseService {
  final String chatRoomUuid;

  GetChatRoomService({required this.chatRoomUuid});

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
    return baseUrl + "chat/chatRoom?chatRoomUuid=$chatRoomUuid";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
