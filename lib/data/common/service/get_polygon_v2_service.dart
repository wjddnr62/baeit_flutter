import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetPolygonV2Service extends BaseService {
  final int? addressSidoNo;
  final int? addressSigunguNo;
  final int? addressEupmyeondongNo;

  GetPolygonV2Service(
      {this.addressSidoNo, this.addressSigunguNo, this.addressEupmyeondongNo});

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
        'common/addressToGeoJson?addressSidoNo=$addressSidoNo&addressSigunguNo=${addressSigunguNo != null ? addressSigunguNo : ''}&addressEupmyeondongNo=${addressEupmyeondongNo != null ? addressEupmyeondongNo : ''}';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
