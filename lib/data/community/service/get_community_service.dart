import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetCommunityService extends BaseService {
  final String? category;
  final String lati;
  final String longi;
  final String? nextCursor;
  final int orderType;
  final int? size;
  final String? searchText;

  GetCommunityService(
      {this.category,
      required this.lati,
      required this.longi,
      this.nextCursor,
      required this.orderType,
      this.size = 20,
      this.searchText});

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
        'community/list?${category != null ? 'category=$category' : ''}&lati=$lati&longi=$longi${nextCursor == null ? '' : '&nextCursor=$nextCursor'}&orderType=$orderType&size=${size ?? 20}${searchText == null ? '' : '&searchText=$searchText'}';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
