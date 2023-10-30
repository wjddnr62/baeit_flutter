import 'dart:io';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/service/image_upload_service.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/data/signup/login.dart';
import 'package:baeit/data/signup/repository/signup_repository.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileBloc extends BaseBloc {
  ProfileBloc(BuildContext context) : super(BaseProfileState());

  bool signUp = false;

  bool loading = false;
  ProfileGet? profileGet;

  XFile? imageFile;
  File? cropImageFile;

  int genderSelect = 0;

  bool imageDefault = false;
  bool imageChange = false;

  bool editProfileImage = false;
  bool editProfileEmail = false;
  bool editProfilePhone = false;
  bool editProfileNickName = false;
  bool editProfileGender = false;
  bool editProfileContent = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is ProfileInitEvent) {
      signUp = event.signUp;

      if (!signUp) {
        profileGet = event.profile;
      }

      if (event.image == null && profileGet!.profile == null) {
        imageDefault = true;
      }
      yield ProfileInitState();
    }

    if (event is GetFileEvent) {
      yield GetFileState();
    }

    if (event is ProfileSaveEvent) {
      loading = true;
      yield LoadingState();
      var imageData;
      late Profile profile;
      if (cropImageFile != null) {
        imageData = ReturnData.fromJson(jsonDecode(
            await ImageUploadService(imageFile: cropImageFile!).start()));
      }
      if (!signUp) {
        if (cropImageFile != null) {
          profile = Profile(
              introText: event.introText,
              nickName: event.nickName,
              image: imageDefault
                  ? null
                  : imageData.code == 1
                      ? Data.fromJson(imageData.data)
                      : null,
              email: event.email,
              gender: event.gender,
              birthDate: event.birthDate,
              phone: event.phone,
              type: UserData.fromJson(
                      jsonDecode(prefs!.getString('userData').toString()))
                  .type);
        } else {
          if (imageDefault) {
            profile = Profile(
                introText: event.introText,
                nickName: event.nickName,
                email: event.email,
                gender: event.gender,
                image: null,
                birthDate: event.birthDate,
                phone: event.phone,
                type: UserData.fromJson(
                        jsonDecode(prefs!.getString('userData').toString()))
                    .type);
          } else {
            profile = Profile(
                introText: event.introText,
                nickName: event.nickName,
                email: event.email,
                gender: event.gender,
                birthDate: event.birthDate,
                phone: event.phone,
                type: UserData.fromJson(
                        jsonDecode(prefs!.getString('userData').toString()))
                    .type,
                updateImageFlag: 0);
          }
        }

        ReturnData res = await ProfileRepository.updateProfile(profile);
        if (res.code == 1) {
          loading = false;
          yield ProfileSaveState();
        } else {
          loading = false;
          yield ErrorState();
        }
      } else {
        if (event.type == "KAKAO") {
          SignUp signUp = SignUp(
              accessId: event.accessId!,
              kakaoInfo: event.kakaoInfo,
              image: imageDefault
                  ? null
                  : cropImageFile != null
                      ? Data.fromJson(imageData.data)
                      : event.image,
              device: event.device!,
              email: event.email!,
              birthDate: event.birthDate,
              gender: event.gender,
              nickName: event.nickName,
              phone: event.phone,
              type: 'KAKAO');

          ReturnData response = await SignUpRepository.signUp(signUp);
          if (response.code == 1) {
            if (production == 'prod-release' && kReleaseMode) {
              Airbridge.event
                  .send(SignUpEvent(option: EventOption(label: 'kakao')));
              Airbridge.event
                  .send(Event('sign_up', option: EventOption(label: 'kakao')));
              if (Platform.isIOS) {
                await facebookAppEvents.logCompletedRegistration();
              }
            }
            print(
                "SignUpSuccess : ${response.code}, ${response.message}, ${response.data}");
            Login login = Login(
                accessId: event.accessId!,
                device: event.device!,
                type: 'KAKAO');
            ReturnData loginRes = await SignUpRepository.login(login);
            if (loginRes.code == 1) {
              if (production == 'prod-release' && kReleaseMode) {
                Airbridge.state.setUser(
                    User(id: UserData.fromJson(loginRes.data).memberUuid));
                Airbridge.state.updateUser(
                    User(id: UserData.fromJson(loginRes.data).memberUuid));
                Airbridge.event.send(SignInEvent(
                    option: EventOption(label: 'kakao'),
                    user:
                        User(id: UserData.fromJson(loginRes.data).memberUuid)));
                Airbridge.event.send(
                    Event('sign_in', option: EventOption(label: 'kakao')));
              }

              print(
                  "LoginSuccess : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
              await prefs!.setString('userData',
                  jsonEncode(UserData.fromJson(loginRes.data).toMap()));
              await prefs!.setString('accessId', event.accessId!);
              await prefs!.setString(
                  'accessToken', UserData.fromJson(loginRes.data).accessToken);
              await prefs!.setString('refreshToken',
                  UserData.fromJson(loginRes.data).refreshToken);
              if (await Permission.location.isGranted) {
                Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.medium)
                    .then((value) {
                  CommonRepository.locationUpdate(
                      value.latitude.toString(), value.longitude.toString());
                });
              }
              UserData userData = UserData.fromJson(
                  jsonDecode(prefs!.getString('userData').toString()));
              amplitude.setUserId(userData.memberUuid);
              FlutterUxcam.setUserIdentity(userData.memberUuid);
              FlutterUxcam.setUserProperty('email', userData.email);
              Airbridge.state.setUser(User(id: userData.memberUuid));
              Airbridge.state.updateUser(User(id: userData.memberUuid));
              yield SignUpFinishState();
            } else {
              print(
                  "LoginError : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
              loading = false;
              yield CheckState();
            }
          } else {
            print(
                "SignUpError : ${response.code}, ${response.message}, ${response.data}");
            loading = false;
            yield CheckState();
          }
        } else {
          SignUp signUp = SignUp(
              accessId: event.accessId!,
              appleInfo: event.appleInfo,
              image: imageDefault
                  ? null
                  : cropImageFile != null
                      ? Data.fromJson(imageData.data)
                      : null,
              device: event.device!,
              email: event.email!,
              birthDate: event.birthDate,
              gender: event.gender,
              nickName: event.nickName,
              phone: event.phone,
              type: 'APPLE');

          ReturnData response = await SignUpRepository.signUp(signUp);
          if (response.code == 1) {
            if (production == 'prod-release' && kReleaseMode) {
              Airbridge.event
                  .send(SignUpEvent(option: EventOption(label: 'apple')));
              Airbridge.event
                  .send(Event('sign_up', option: EventOption(label: 'apple')));
              await facebookAppEvents.logCompletedRegistration();
            }
            print(
                "SignUpSuccess : ${response.code}, ${response.message}, ${response.data}");
            Login login = Login(
                accessId: event.accessId!,
                device: event.device!,
                type: 'APPLE');
            ReturnData loginRes = await SignUpRepository.login(login);
            if (loginRes.code == 1) {
              if (production == 'prod-release' && kReleaseMode) {
                Airbridge.state.setUser(
                    User(id: UserData.fromJson(loginRes.data).memberUuid));
                Airbridge.state.updateUser(
                    User(id: UserData.fromJson(loginRes.data).memberUuid));
                Airbridge.event.send(SignInEvent(
                    option: EventOption(label: 'apple'),
                    user:
                        User(id: UserData.fromJson(loginRes.data).memberUuid)));
                Airbridge.event.send(
                    Event('sign_in', option: EventOption(label: 'apple')));
              }
              print(
                  "LoginSuccess : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
              await prefs!.setString('userData',
                  jsonEncode(UserData.fromJson(loginRes.data).toMap()));
              await prefs!.setString('accessId', event.accessId!);
              await prefs!.setString(
                  'accessToken', UserData.fromJson(loginRes.data).accessToken);
              await prefs!.setString('refreshToken',
                  UserData.fromJson(loginRes.data).refreshToken);
              if (await Permission.location.isGranted) {
                Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.medium)
                    .then((value) {
                  CommonRepository.locationUpdate(
                      value.latitude.toString(), value.longitude.toString());
                });
              }
              UserData userData = UserData.fromJson(
                  jsonDecode(prefs!.getString('userData').toString()));
              amplitude.setUserId(userData.memberUuid);
              FlutterUxcam.setUserIdentity(userData.memberUuid);
              FlutterUxcam.setUserProperty('email', userData.email);
              Airbridge.state.setUser(User(id: userData.memberUuid));
              Airbridge.state.updateUser(User(id: userData.memberUuid));
              yield SignUpFinishState();
            } else {
              print(
                  "LoginError : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
              loading = false;
              yield CheckState();
            }
          } else {
            print(
                "SignUpError : ${response.code}, ${response.message}, ${response.data}");
            loading = false;
            yield CheckState();
          }
        }
      }
    }

    if (event is GenderSelectEvent) {
      genderSelect = event.select;
      yield GenderSelectState(select: genderSelect);
    }
  }
}

class GenderSelectEvent extends BaseBlocEvent {
  final int select;

  GenderSelectEvent({required this.select});
}

class GenderSelectState extends BaseBlocState {
  final int select;

  GenderSelectState({required this.select});
}

class SignUpFinishState extends BaseBlocState {}

class ProfileSaveEvent extends BaseBlocEvent {
  final String? birthDate;
  final String? accessId;
  final String? email;
  final String? gender;
  final String? introText;
  final String? nickName;
  final String? phone;
  final KakaoInfo? kakaoInfo;
  final AppleInfo? appleInfo;
  final Device? device;
  final Data? image;
  final String? type;

  ProfileSaveEvent(
      {this.birthDate,
      this.accessId,
      this.email,
      this.gender,
      this.introText,
      this.nickName,
      this.phone,
      this.kakaoInfo,
      this.appleInfo,
      this.device,
      this.image,
      this.type});
}

class ProfileSaveState extends BaseBlocState {}

class GetFileEvent extends BaseBlocEvent {}

class GetFileState extends BaseBlocState {}

class ProfileInitEvent extends BaseBlocEvent {
  final bool signUp;
  final ProfileGet? profile;
  final Data? image;

  ProfileInitEvent({required this.signUp, this.profile, this.image});
}

class ProfileInitState extends BaseBlocState {}

class BaseProfileState extends BaseBlocState {}
