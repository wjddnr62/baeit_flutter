import 'dart:convert';
import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/signup/login.dart';
import 'package:baeit/data/signup/repository/signup_repository.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ManagerBloc extends BaseBloc {
  ManagerBloc(BuildContext context) : super(BaseManagerState()) {
    on<ManagerInitEvent>(onManagerInitEvent);
    on<ManagerLoginEvent>(onManagerLoginEvent);
  }

  onManagerInitEvent(ManagerInitEvent event, emit) {
    emit(ManagerInitState());
  }

  onManagerLoginEvent(ManagerLoginEvent event, emit) async {
    Device device = Device(
        token: await messaging.getToken(),
        type: Platform.isAndroid ? 'ANDROID' : 'IOS');
    Login login =
        Login(accessId: event.accessId, device: device, type: 'MANAGER');
    ReturnData loginRes = await SignUpRepository.login(login);
    if (loginRes.code == -100) {
      emit(ManagerLoginFailState(msg: loginRes.message!));
      return;
    } else {
      dataSaver.clear();
      sharedClear();
      await prefs!.setString(
          'userData', jsonEncode(UserData.fromJson(loginRes.data).toMap()));
      dataSaver.userData = UserData.fromJson(
          jsonDecode(prefs!.getString('userData').toString()));
      await prefs!.setString('accessId', event.accessId);
      await prefs!.setString(
          'accessToken', UserData.fromJson(loginRes.data).accessToken);
      await prefs!.setString(
          'refreshToken', UserData.fromJson(loginRes.data).refreshToken);
      if (await Permission.location.isGranted) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((value) {
          CommonRepository.locationUpdate(
              value.latitude.toString(), value.longitude.toString());
        });
      }

      emit(ManagerLoginState());
    }
  }
}

class ManagerLoginFailState extends BaseBlocState {
  final String msg;

  ManagerLoginFailState({required this.msg});
}

class ManagerLoginEvent extends BaseBlocEvent {
  final String accessId;

  ManagerLoginEvent({required this.accessId});
}

class ManagerLoginState extends BaseBlocState {}

class ManagerInitEvent extends BaseBlocEvent {}

class ManagerInitState extends BaseBlocState {}

class BaseManagerState extends BaseBlocState {}
