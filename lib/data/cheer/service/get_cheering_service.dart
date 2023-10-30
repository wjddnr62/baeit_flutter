import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:http/http.dart';

class GetCheeringService extends BaseService {
  final int addressEupmyeondongNo;

  GetCheeringService({required this.addressEupmyeondongNo})
      : super(withAccessToken: dataSaver.nonMember != null && !dataSaver.nonMember ? true : false);

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        "cheering/details?addressEupmyeondongNo=$addressEupmyeondongNo";
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
