import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/reword/repository/reward_repository.dart';
import 'package:baeit/data/reword/reword.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/widgets.dart';

class SupportFundBloc extends BaseBloc {
  SupportFundBloc(BuildContext context) : super(BaseSupportFundState()) {
    on<SupportFundInitEvent>(onSupportFundInitEvent);
    on<ApplicantEvent>(onApplicantEvent);
  }

  bool loading = false;
  int applicantCheck = 0;

  onSupportFundInitEvent(SupportFundInitEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    applicantCheck =
        (await RewardRepository.getRewardApplicant(event.reward.rewardUuid))
            .data;

    loading = false;
    emit(SupportFundInitState());
  }

  onApplicantEvent(ApplicantEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    ReturnData applicantRes = await RewardRepository.applicantReward(
        account: event.account,
        bank: event.bank,
        name: event.name,
        phone: event.phone,
        rewardUuid: event.rewardUuid);

    if (applicantRes.code == 1) {
      amplitudeEvent('reward_completed', {});
      loading = false;
      emit(ApplicantState());
    } else {
      loading = false;
      emit(ErrorState());
    }
  }
}

class ApplicantEvent extends BaseBlocEvent {
  final String account;
  final String bank;
  final String name;
  final String phone;
  final String rewardUuid;

  ApplicantEvent(
      {required this.account,
      required this.bank,
      required this.name,
      required this.phone,
      required this.rewardUuid});
}

class ApplicantState extends BaseBlocState {}

class SupportFundInitEvent extends BaseBlocEvent {
  final Reward reward;

  SupportFundInitEvent({required this.reward});
}

class SupportFundInitState extends BaseBlocState {}

class BaseSupportFundState extends BaseBlocState {}
