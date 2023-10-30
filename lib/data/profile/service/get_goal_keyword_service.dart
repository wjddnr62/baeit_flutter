import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetGoalKeywordService extends BaseService {
  final String? type;
  final String? cursor;

  GetGoalKeywordService({this.type = 'LEARN', this.cursor});

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
        "member/goal/keyword?goalKeywordType=${type == null ? 'LEARN' : type}${cursor == null ? '' : '&nextCursor=$cursor'}&size=60";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
