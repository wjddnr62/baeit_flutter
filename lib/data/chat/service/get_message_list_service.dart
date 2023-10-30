import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetMessageListService extends BaseService {
  final String chatRoomUuid;
  final String? nextCursor;
  final int? size;

  GetMessageListService({required this.chatRoomUuid, this.nextCursor, this.size = 40});

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
        "chat/message/list?chatRoomUuid=$chatRoomUuid&size=${size ?? 40}&nextCursor=${nextCursor == null ? '' : nextCursor}";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
