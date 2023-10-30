import 'dart:async';
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
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashBloc extends BaseBloc {
  SplashBloc(BuildContext context) : super(BaseSplashState());

  bool isLoading = false;
  Version? version;
  List<int> versionData = [];
  List<int> currentData = [];

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();

    if (event is SplashCheckEvent) {
      if (production != 'prod-release' && !kReleaseMode) {
        await common(flavor: flavor == Flavor.PROD ? 'PROD' : 'DEV');
        if (prefs!.getString('FLAVOR') == 'PROD') {
          flavor = Flavor.PROD;
          common(flavor: flavor == Flavor.PROD ? 'PROD' : 'DEV');
        } else {
          flavor = Flavor.DEV;
          common(flavor: flavor == Flavor.PROD ? 'PROD' : 'DEV');
        }
      }
      yield SplashCheckState();
    }

    if (event is SplashInitEvent) {
      isLoading = true;
      yield LoadingState();

      dataSaver.packageInfo = await PackageInfo.fromPlatform();

      installIdentify();

      ReturnData res = await CommonRepository.getVersion(
          Platform.isAndroid ? 'ANDROID' : 'IOS',
          dataSaver.packageInfo!.version);

      if (res.code == 1) {
        version = Version.fromJson(res.data);
        versionData = version!.lastVersionText
            .split('.')
            .map((e) => int.parse(e))
            .toList();
        currentData = dataSaver.packageInfo!.version
            .split('.')
            .map((e) => int.parse(e))
            .toList();

        dataSaver.updatePass = version!.passFlag == 0 ? false : true;

        // if (version!.forceFlag == 1) {
        if (versionData[0] > currentData[0]) {
          dataSaver.forceUpdate = true;
        } else {
          if (versionData[0] >= currentData[0] &&
              versionData[1] > currentData[1]) {
            dataSaver.forceUpdate = true;
          } else {
            if (versionData[0] >= currentData[0] &&
                versionData[1] >= currentData[1] &&
                versionData[2] > currentData[2]) {
              dataSaver.forceUpdate = true;
            }
          }
        }

        if (version!.passFlag == 1 || version!.forceFlag == 1) {
          await prefs!.remove('forceUpdateData');
        }

        if (!(prefs!.getString('forceUpdateData') ==
            dataSaver.packageInfo!.version)) {
          if (dataSaver.forceUpdate) {
            yield ForceUpdateState();
            return;
          } else {
            if (Platform.isAndroid) {
              PushConfig().initializeLocalNotification();
            } else {
              if (prefs!.getBool('iosNotification') ?? false) {
                PushConfig().initializeLocalNotification();
              }
            }

            yield SplashInitState();
          }
        } else {
          if (Platform.isAndroid) {
            PushConfig().initializeLocalNotification();
          } else {
            if (prefs!.getBool('iosNotification') ?? false) {
              PushConfig().initializeLocalNotification();
            }
          }

          yield SplashInitState();
        }
        // } else {
        //   if (Platform.isAndroid) {
        //     PushConfig().initializeLocalNotification();
        //   } else {
        //     if (prefs!.getBool('iosNotification') ?? false) {
        //       PushConfig().initializeLocalNotification();
        //     }
        //   }
        //
        //   yield SplashInitState();
        // }
      } else {
        if (Platform.isAndroid) {
          PushConfig().initializeLocalNotification();
        } else {
          if (prefs!.getBool('iosNotification') ?? false) {
            PushConfig().initializeLocalNotification();
          }
        }

        yield SplashInitState();
      }
    }

    if (event is AutoLoginEvent) {
      isLoading = true;
      yield LoadingState();
      await dataSaver.clear();

      ReturnData res = await ProfileRepository.getProfile();
      if (res != null && res.data != null) {
        dataSaver.profileGet = ProfileGet.fromJson(res.data);
        dataSaver.userData = UserData.fromJson(
            jsonDecode(prefs!.getString('userData').toString()));

        // try {
        //   await ChannelTalk.setDebugMode(flag: false);
        //   await ChannelTalk.boot(
        //       pluginKey: '641678df-f344-4037-b309-44b3bb05bc59',
        //       memberHash: '.',
        //       memberId: dataSaver.userData!.memberUuid,
        //       language: 'korean');
        // } on PlatformException catch (error) {
        //   debugPrint('channel talk error : $error');
        // } catch (err) {}

        ReturnData? returnData =
            await NeighborHoodSelectRepository.getNeighborHoodList();
        if (returnData != null) {
          for (dynamic data in returnData.data) {
            dataSaver.neighborHood.add(NeighborHood.fromJson(data));
          }
          amplitude.setUserId(dataSaver.userData!.memberUuid);
          await FlutterUxcam.setUserIdentity(dataSaver.userData!.memberUuid);
          await FlutterUxcam.setUserProperty(
              'email', dataSaver.userData!.email);
          await FlutterUxcam.startNewSession();
          await await identifyInit();
        } else if (returnData == null) {
          sharedClear();
          dataSaver.clear();
          yield AutoLoginFailState();
          return;
        }

        if (production == 'prod-release' && kReleaseMode) {
          Airbridge.state.setUser(User(
              id: dataSaver.userData!.memberUuid,
              phone: dataSaver.profileGet!.phone));
          Airbridge.state.updateUser(User(id: dataSaver.userData!.memberUuid));
          Airbridge.event.send(SignInEvent(
              option: EventOption(label: dataSaver.userData!.type),
              user: User(id: dataSaver.userData!.memberUuid)));
        }

        String? token = await messaging.getToken();
        await CommonRepository.updateToken(token: token!);

        if (await Permission.location.isGranted) {
          Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.medium)
              .then((value) {
            CommonRepository.locationUpdate(
                value.latitude.toString(), value.longitude.toString());
          });
          isLoading = false;
          if (!stompClient.connected) {
            stompClient.activate();
          }
          if (dataSaver.profileGet!.goalFlag == 0) {
            yield NonSetGoalState();
            return;
          }

          if (returnData.data.length == 0) {
            yield AutoLoginNeighborHoodState();
          } else {
            yield AutoLoginState(
                neighborHood: dataSaver.neighborHood.length != 0
                    ? dataSaver.neighborHood
                    : null);
          }
        } else {
          isLoading = false;
          if (!stompClient.connected) {
            stompClient.activate();
          }
          if (dataSaver.profileGet!.goalFlag == 0) {
            yield NonSetGoalState();
            return;
          }

          if (returnData.data.length == 0) {
            yield AutoLoginNeighborHoodState();
          } else {
            yield AutoLoginState(
                neighborHood: dataSaver.neighborHood.length != 0
                    ? dataSaver.neighborHood
                    : null);
          }
        }
      } else {
        yield AutoLoginFailState();
      }
    }

    if (event is LoginFailEvent) {
      yield AutoLoginFailState();
    }
  }
}

class NonSetGoalState extends BaseBlocState {}

class LoginFailEvent extends BaseBlocEvent {}

class ForceUpdateState extends BaseBlocState {}

class AutoLoginEvent extends BaseBlocEvent {}

class AutoLoginState extends BaseBlocState {
  final List<NeighborHood>? neighborHood;

  AutoLoginState({this.neighborHood});
}

class AutoLoginNeighborHoodState extends BaseBlocState {}

class AutoLoginFailState extends BaseBlocState {}

class SplashCheckEvent extends BaseBlocEvent {}

class SplashCheckState extends BaseBlocState {}

class SplashInitEvent extends BaseBlocEvent {}

class SplashInitState extends BaseBlocState {}

class BaseSplashState extends BaseBlocState {}
