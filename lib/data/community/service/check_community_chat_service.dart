import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class CheckCommunityChatService extends BaseService {
  final String communityUuid;

  CheckCommunityChatService({required this.communityUuid});

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
        'chat/communityChatRoom/block?communityUuid=$communityUuid';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
