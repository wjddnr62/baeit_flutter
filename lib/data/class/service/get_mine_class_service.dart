import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetMineClassService extends BaseService {
  final String? nextCursor;
  final String? status;
  final String type;

  GetMineClassService({this.nextCursor, this.status, required this.type});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        "class/mine/list?nextCursor=${nextCursor != null ? nextCursor : ''}&size=20&status=${status != null ? status : ''}&type=$type";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }
}
