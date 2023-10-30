import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetClassViewService extends BaseService {
  final String? nextCursor;
  final String type;

  GetClassViewService({this.nextCursor, required this.type});

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        "class/view/list?nextCursor=${nextCursor == null ? '' : nextCursor}&type=$type";
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
