import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class GetRewardApplicantService extends BaseService {
  final String rewardUuid;

  GetRewardApplicantService({required this.rewardUuid});

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
    return baseUrl + 'reward/applicant?rewardUuid=$rewardUuid';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
