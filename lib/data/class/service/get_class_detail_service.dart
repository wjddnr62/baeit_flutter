import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:http/http.dart';

class GetClassDetailService extends BaseService {
  final String classUuid;
  final String lati;
  final String longi;
  final int readFlag;

  GetClassDetailService(
      {required this.classUuid, required this.lati, required this.longi, this.readFlag = 1})
      : super(withAccessToken: dataSaver.nonMember != null && dataSaver.nonMember ? false : true);

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        "class/details?classUuid=$classUuid&lati=$lati&longi=$longi&readFlag=$readFlag";
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
