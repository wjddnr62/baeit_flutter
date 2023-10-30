import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetMemberClassService extends BaseService {
  final String memberUuid;
  final String? nextCursor;
  final String type;

  GetMemberClassService(
      {required this.memberUuid, this.nextCursor, required this.type});

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
        "class/other/list?nextCursor=${nextCursor != null ? nextCursor : ''}&size=20&memberUuid=$memberUuid&status=NORMAL&type=$type";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
