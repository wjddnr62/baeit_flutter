import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetReviewService extends BaseService {
  final String classUuid;
  final String? nextCursor;
  final int? orderType;

  GetReviewService(
      {required this.classUuid, this.nextCursor, this.orderType = 2});

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
        'class/review?classUuid=$classUuid${nextCursor == null ? '' : '&nextCursor=$nextCursor'}&size=20';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
