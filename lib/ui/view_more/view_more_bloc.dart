import 'dart:io';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/version.dart';
import 'package:baeit/data/signup/repository/signup_repository.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';

class ViewMoreBloc extends BaseBloc {
  ViewMoreBloc(BuildContext context) : super(BaseViewMoreState());

  bool loading = false;
  Version? version;
  int versionSet = 0;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is ViewMoreInitEvent) {
      loading = true;
      yield LoadingState();

      ReturnData res = await CommonRepository.getVersion(
          Platform.isAndroid ? 'ANDROID' : 'IOS',
          dataSaver.packageInfo!.version);

      if (res.code == 1) {
        version = Version.fromJson(res.data);
        versionSet = int.parse(version!.lastVersionText.replaceAll(".", ''));

        loading = false;
        yield ViewMoreInitState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is LogoutEvent) {
      loading = true;
      yield LoadingState();
      await amplitudeEvent('user_logout', {});
      identify.clearAll();
      if (production == 'prod-release' && kReleaseMode)
        Airbridge.event
            .send(SignOutEvent(option: EventOption(label: 'logout')));
      await SignUpRepository.logout();
      await sharedClear();
      dataSaver.clear();
      amplitude.setUserId(null);
      FlutterUxcam.setUserIdentity('');
      FlutterUxcam.setUserProperty('email', '');
      Airbridge.state.setUser(User());
      Airbridge.state.updateUser(User());
      loading = false;
      await selectNotificationSubject.close();
      selectedNotificationPayload = null;
      flutterLocalNotificationsPlugin = null;
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await PushConfig().initializeLocalNotification();
      await messaging.deleteToken();
      await messaging.getInitialMessage();
      stompClient.deactivate();
      yield LogoutState();
    }
  }
}

class LogoutEvent extends BaseBlocEvent {}

class LogoutState extends BaseBlocState {}

class ViewMoreInitEvent extends BaseBlocEvent {}

class ViewMoreInitState extends BaseBlocState {}

class BaseViewMoreState extends BaseBlocState {}
