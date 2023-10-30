import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ChatBlockService extends BaseService {
  final String chatRoomUuid;

  ChatBlockService({required this.chatRoomUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode({'chatRoomUuid': chatRoomUuid}));
  }

  @override
  setUrl() {
    return baseUrl + "chat/block";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
