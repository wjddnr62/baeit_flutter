import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class WithdrawalService extends BaseService {
  final String memberWithdrawalForm;

  WithdrawalService({this.memberWithdrawalForm = ''});

  @override
  Future<Response> request() {
    Map<String, dynamic> data = {};
    data.addAll({'reasonText': memberWithdrawalForm});
    return fetchPut(body: jsonEncode(data));
  }

  @override
  setUrl() {
    return baseUrl + "member/withdrawal";
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
