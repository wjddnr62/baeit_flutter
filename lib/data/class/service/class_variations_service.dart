import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/variations_class.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ClassVariationsService extends BaseService {
  final VariationsClass variationsClass;

  ClassVariationsService({required this.variationsClass});

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode(variationsClass.toMap()));
  }

  @override
  setUrl() {
    return baseUrl + "class";
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
