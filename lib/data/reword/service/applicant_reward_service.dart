import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ApplicantRewardService extends BaseService {
  final String account;
  final String bank;
  final String name;
  final String phone;
  final String rewardUuid;

  ApplicantRewardService(
      {required this.account,
      required this.bank,
      required this.name,
      required this.phone,
      required this.rewardUuid});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(
        body: jsonEncode({
      'account': account,
      'bank': bank,
      'name': name,
      'phone': phone,
      'rewardUuid': rewardUuid
    }));
  }

  @override
  setUrl() {
    return baseUrl + 'reward/applicant';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
