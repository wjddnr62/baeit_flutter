import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class BookmarkClassService extends BaseService {
  final String classUuid;

  BookmarkClassService({required this.classUuid});

  @override
  Future<Response> request() async {
    Map<String, dynamic> data = {};
    data.addAll({'classUuid': classUuid});
    return await fetchPut(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "class/like";
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
