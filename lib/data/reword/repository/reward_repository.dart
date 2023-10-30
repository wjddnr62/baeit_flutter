import 'package:baeit/data/reword/service/applicant_reward_service.dart';
import 'package:baeit/data/reword/service/get_reward_applicant_service.dart';
import 'package:baeit/data/reword/service/get_reward_detail_service.dart';

class RewardRepository {
  static Future<dynamic> getDetailReward() => GetRewardDetailService().start();

  static Future<dynamic> getRewardApplicant(String rewardUuid) =>
      GetRewardApplicantService(rewardUuid: rewardUuid).start();

  static Future<dynamic> applicantReward(
          {required String account,
          required String bank,
          required String name,
          required String phone,
          required String rewardUuid}) =>
      ApplicantRewardService(
              account: account,
              bank: bank,
              name: name,
              phone: phone,
              rewardUuid: rewardUuid)
          .start();
}
