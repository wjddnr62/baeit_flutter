import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:http/http.dart';

class GetClassService extends BaseService {
  final GetClass getClass;

  GetClassService({required this.getClass})
      : super(
            withAccessToken: dataSaver.nonMember != null && dataSaver.nonMember
                ? false
                : true);

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        "class/list?categories=${getClass.categories == null ? '' : getClass.categories}&lati=${getClass.lati}&longi=${getClass.longi}&nextCursor=${getClass.nextCursor != null ? getClass.nextCursor : ''}&orderType=${getClass.orderType}&searchText=${getClass.searchText != null ? getClass.searchText : ''}&size=${getClass.size}&type=${getClass.type}&days=${getClass.days != null ? getClass.days : ''}";
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
