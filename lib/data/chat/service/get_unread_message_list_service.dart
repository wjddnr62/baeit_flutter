import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetUnreadMessageListService extends BaseService {
  final String chatRoomUuid;
  final String? chatRoomMessageUuid;

  GetUnreadMessageListService(
      {required this.chatRoomUuid, this.chatRoomMessageUuid});

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
        "chat/message/list/unread?chatRoomUuid=$chatRoomUuid${chatRoomMessageUuid == null ? '' : '&chatRoomMessageUuid=$chatRoomMessageUuid'}";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
