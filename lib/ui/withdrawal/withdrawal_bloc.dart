import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';

class WithdrawalBloc extends BaseBloc {
  WithdrawalBloc(BuildContext context) : super(BaseWithdrawalState());

  bool loading = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is WithdrawalInitEvent) {
      yield WithdrawalInitState();
    }

    if (event is WithdrawalEvent) {
      loading = true;
      yield LoadingState();

      await amplitudeEvent('user_withdrawal', {});

      ReturnData withdrawalRes = await CommonRepository.withdrawalUser(
          memberWithdrawalForm: event.reasonText);

      if (withdrawalRes.code == 1) {
        sharedClear();
        dataSaver.clear();
        identify.clearAll();
        amplitude.setUserId(null);
        FlutterUxcam.setUserIdentity('');
        FlutterUxcam.setUserProperty('email', '');
        Airbridge.state.setUser(User());
        Airbridge.state.updateUser(User());

        if (production == 'prod-release' && kReleaseMode)
        Airbridge.event.send(SignOutEvent(option: EventOption(
            label: 'withdrawal'
       )));
        selectedNotificationPayload = null;
        messaging.deleteToken();
        stompClient.deactivate();
        loading = false;
        yield WithdrawalFinishState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }
  }
}

class WithdrawalEvent extends BaseBlocEvent {
  final String reasonText;

  WithdrawalEvent({required this.reasonText});
}

class WithdrawalFinishState extends BaseBlocState {}

class WithdrawalInitEvent extends BaseBlocEvent {}

class WithdrawalInitState extends BaseBlocState {}

class BaseWithdrawalState extends BaseBlocState {}
