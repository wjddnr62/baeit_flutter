import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetMapClassService extends BaseService {
  final String? addressEupmyeondongNo;
  final String? addressSigunguNo;
  final String? addressSidoNo;
  final String? categories;
  final String lati;
  final String longi;
  final String? nextCursor;
  final int? orderType;
  final String? searchText;
  final String? type;

  GetMapClassService(
      {this.addressEupmyeondongNo,
      this.addressSigunguNo,
      this.addressSidoNo,
      this.categories,
      required this.lati,
      required this.longi,
      this.nextCursor,
      this.orderType = 1,
      this.searchText,
      this.type = 'MADE'});

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
        "class/map/mapList?size=10${addressSidoNo != null && addressSidoNo != 'null' ? '&addressSidoNo=$addressSidoNo' : ''}${addressEupmyeondongNo != null && addressEupmyeondongNo != 'null' ? '&addressEupmyeondongNo=$addressEupmyeondongNo' : ''}${addressSigunguNo != null && addressSigunguNo != 'null' ? '&addressSigunguNo=$addressSigunguNo' : ''}${categories != null ? '&categories=$categories' : ''}&lati=$lati&longi=$longi${nextCursor != null ? '&nextCursor=$nextCursor' : ''}&orderType=$orderType${searchText != null && searchText != '' ? '&searchText=$searchText' : ''}&type=$type";
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
