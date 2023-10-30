import 'dart:io';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart' as air;
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/service/image_upload_service.dart';
import 'package:baeit/data/signup/login.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/data/signup/repository/signup_repository.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/temp_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// import 'package:kakao_flutter_sdk/all.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignupBloc extends BaseBloc {
  SignupBloc(BuildContext context) : super(BaseSignupState());

  bool loading = false;

  int idx = 0;

  bool ageCheck = false;

  ageRangeText(String range) {
    switch (range) {
      case 'AgeRange.age_15_19':
        return '15~19';
      case 'AgeRange.age_20_29':
        return '20~29';
      case 'AgeRange.age_30_39':
        return '30~39';
      case 'AgeRange.age_40_49':
        return '40~49';
      case 'AgeRange.age_50_59':
        return '50~59';
      case 'AgeRange.age_60_69':
        return '60~69';
      case 'AgeRange.age_70_79':
        return '70~79';
      case 'AgeRange.age_80_89':
        return '80~89';
      case 'AgeRange.age_90':
        return '90~';
      default:
        return '90~';
    }
  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is SignupInitEvent) {
      yield SignupInitState();
    }

    if (event is SignupAuthEvent) {
      if (event.auth == 'KAKAO') {
        try {
          loading = true;
          yield LoadingState();
          var user = await UserApi.instance.me();
          Device device = Device(
              token: await messaging.getToken(),
              type: Platform.isAndroid ? 'ANDROID' : 'IOS');
          Login login = Login(
              accessId: user.id.toString(), device: device, type: 'KAKAO');
          ReturnData loginRes = await SignUpRepository.login(login);
          if (loginRes.code == -104) {
            loading = false;
            yield BanUserState(banMean: loginRes.message!);
            return;
          }

          if (loginRes.code == -100) {
            amplitudeEvent('account_create_clicks', {'login_type': 'kakao'},
                init: false);
            ReturnData imageRes = ReturnData.fromJson(jsonDecode(
                await ImageUploadService(
                        imageFile: await networkImageToFile(
                            user.kakaoAccount!.profile!.profileImageUrl))
                    .start()));

            String ageRange =
                ageRangeText(user.kakaoAccount!.ageRange.toString());

            Data image = Data.fromJson(imageRes.data);
            loading = false;
            yield SignupAuthState(
                accessId: user.id.toString(),
                email: user.kakaoAccount!.email!,
                device: device,
                kakaoInfo: KakaoInfo(
                    email: user.kakaoAccount!.email!,
                    ageRange: ageRange,
                    birthDay: user.kakaoAccount!.birthday.toString(),
                    birthYear: user.kakaoAccount!.birthyear.toString(),
                    gender: user.kakaoAccount!.gender!
                        .toString()
                        .split('.')[1]
                        .toUpperCase(),
                    nickName: user.kakaoAccount!.profile!.nickname!,
                    phoneNumber: user.kakaoAccount!.phoneNumber.toString(),
                    profileImage: user.kakaoAccount!.profile!.profileImageUrl!,
                    thumbnailImage:
                        user.kakaoAccount!.profile!.thumbnailImageUrl!),
                image: image,
                type: 'KAKAO');
          } else if (loginRes.code == 1) {
            if (production == 'prod-release' && kReleaseMode) {
              air.Airbridge.state.setUser(
                  air.User(id: UserData.fromJson(loginRes.data).memberUuid));
              air.Airbridge.state.updateUser(
                  air.User(id: UserData.fromJson(loginRes.data).memberUuid));
              air.Airbridge.event.send(air.SignInEvent(
                  option: air.EventOption(label: 'kakao'),
                  user: air.User(
                      id: UserData.fromJson(loginRes.data).memberUuid)));
              air.Airbridge.event.send(air.Event('sign_in',
                  option: air.EventOption(label: 'kakao')));
            }

            print(
                "LoginSuccess : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
            dataSaver.clear();
            sharedClear();
            await prefs!.setString('userData',
                jsonEncode(UserData.fromJson(loginRes.data).toMap()));
            dataSaver.userData = UserData.fromJson(
                jsonDecode(prefs!.getString('userData').toString()));
            await prefs!.setString('accessId', user.id.toString());
            await prefs!.setString(
                'accessToken', UserData.fromJson(loginRes.data).accessToken);
            await prefs!.setString(
                'refreshToken', UserData.fromJson(loginRes.data).refreshToken);
            if (await Permission.location.isGranted) {
              Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high)
                  .then((value) {
                CommonRepository.locationUpdate(
                    value.latitude.toString(), value.longitude.toString());
              });
            }
            yield LoginAuthState();
          } else {
            print(
                "LoginError : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
            loading = false;
            yield CheckState();
          }
        } on KakaoAuthException catch (e) {
          loading = false;
          yield ErrorState();
          debugPrint("KAKAO Auth Error : $e");
        } catch (e) {
          debugPrint("KAKAO Login Error : $e");
          loading = false;
          yield ErrorState();
          Map<String, dynamic> data = {};
          data.addAll(jsonDecode(jsonEncode(e)));
          if (data['code'] == -401) {
            final installed = await isKakaoTalkInstalled();
            installed
                ? await UserApi.instance.loginWithKakaoTalk()
                : await UserApi.instance.loginWithKakaoAccount();

            var user = await UserApi.instance.me();
            Device device = Device(
                token: await messaging.getToken(),
                type: Platform.isAndroid ? 'ANDROID' : 'IOS');
            Login login = Login(
                accessId: user.id.toString(), device: device, type: 'KAKAO');
            ReturnData loginRes = await SignUpRepository.login(login);
            if (loginRes.code == -104) {
              loading = false;
              yield BanUserState(banMean: loginRes.message!);
              return;
            }

            if (loginRes.code == -100) {
              amplitudeEvent('account_create_clicks', {'login_type': 'kakao'},
                  init: false);
              ReturnData imageRes = ReturnData.fromJson(jsonDecode(
                  await ImageUploadService(
                          imageFile: await networkImageToFile(
                              user.kakaoAccount!.profile!.profileImageUrl))
                      .start()));

              String ageRange =
                  ageRangeText(user.kakaoAccount!.ageRange.toString());

              Data image = Data.fromJson(imageRes.data);
              loading = false;
              yield SignupAuthState(
                  accessId: user.id.toString(),
                  email: user.kakaoAccount!.email!,
                  device: device,
                  kakaoInfo: KakaoInfo(
                      email: user.kakaoAccount!.email!,
                      ageRange: ageRange,
                      birthDay: user.kakaoAccount!.birthday.toString(),
                      birthYear: user.kakaoAccount!.birthyear.toString(),
                      gender: user.kakaoAccount!.gender!
                          .toString()
                          .split('.')[1]
                          .toUpperCase(),
                      nickName: user.kakaoAccount!.profile!.nickname!,
                      phoneNumber: user.kakaoAccount!.phoneNumber.toString(),
                      profileImage:
                          user.kakaoAccount!.profile!.profileImageUrl!,
                      thumbnailImage:
                          user.kakaoAccount!.profile!.thumbnailImageUrl!),
                  image: image,
                  type: 'KAKAO');
            } else if (loginRes.code == 1) {
              if (production == 'prod-release' && kReleaseMode) {
                air.Airbridge.state.setUser(
                    air.User(id: UserData.fromJson(loginRes.data).memberUuid));
                air.Airbridge.state.updateUser(
                    air.User(id: UserData.fromJson(loginRes.data).memberUuid));
                air.Airbridge.event.send(air.SignInEvent(
                    option: air.EventOption(label: 'kakao'),
                    user: air.User(
                        id: UserData.fromJson(loginRes.data).memberUuid)));
                air.Airbridge.event.send(air.Event('sign_in',
                    option: air.EventOption(label: 'kakao')));
              }

              print(
                  "LoginSuccess : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
              dataSaver.clear();
              sharedClear();
              await prefs!.setString('userData',
                  jsonEncode(UserData.fromJson(loginRes.data).toMap()));
              dataSaver.userData = UserData.fromJson(
                  jsonDecode(prefs!.getString('userData').toString()));
              await prefs!.setString('accessId', user.id.toString());
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
              yield LoginAuthState();
            } else {
              print(
                  "LoginError : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
              loading = false;
              yield CheckState();
            }
          } else {
            loading = false;
            yield CheckState();
          }
        }
      } else if (event.auth == 'APPLE') {
        try {
          final credential = await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName
              ]);

          Device device = Device(
              token: await messaging.getToken(),
              type: Platform.isAndroid ? 'ANDROID' : 'IOS');

          Map<String, dynamic> decodeToken =
              JwtDecoder.decode(credential.identityToken!);

          String? name = '${credential.familyName}${credential.givenName}';
          if (credential.familyName == null || credential.givenName == null) {
            name = null;
          }

          Login login = Login(
              accessId: decodeToken['sub'], device: device, type: 'APPLE');

          ReturnData loginRes = await SignUpRepository.login(login);
          if (loginRes.code == -104) {
            loading = false;
            yield BanUserState(banMean: loginRes.message!);
            return;
          }

          if (loginRes.code == -100) {
            amplitudeEvent('account_create_clicks', {'login_type': 'apple'},
                init: false);
            yield AgeCheckState(
                decodeToken: decodeToken, name: name ?? '', device: device);
          } else if (loginRes.code == 1) {
            loading = true;
            yield LoadingState();
            if (production == 'prod-release' && kReleaseMode) {
              air.Airbridge.state.setUser(
                  air.User(id: UserData.fromJson(loginRes.data).memberUuid));
              air.Airbridge.state.updateUser(
                  air.User(id: UserData.fromJson(loginRes.data).memberUuid));
              air.Airbridge.event.send(air.SignInEvent(
                  option: air.EventOption(label: 'apple'),
                  user: air.User(
                      id: UserData.fromJson(loginRes.data).memberUuid)));
              air.Airbridge.event.send(air.Event('sign_in',
                  option: air.EventOption(label: 'apple')));
            }

            dataSaver.clear();
            sharedClear();
            print(
                "LoginSuccess : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
            await prefs!.setString('userData',
                jsonEncode(UserData.fromJson(loginRes.data).toMap()));
            dataSaver.userData = UserData.fromJson(
                jsonDecode(prefs!.getString('userData').toString()));
            await prefs!.setString('accessId', decodeToken['sub']);
            await prefs!.setString(
                'accessToken', UserData.fromJson(loginRes.data).accessToken);
            await prefs!.setString(
                'refreshToken', UserData.fromJson(loginRes.data).refreshToken);
            if (await Permission.location.isGranted) {
              Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.medium)
                  .then((value) {
                CommonRepository.locationUpdate(
                    value.latitude.toString(), value.longitude.toString());
              });
            }

            loading = false;
            yield LoginAuthState();
          } else {
            loading = false;
            yield CheckState();
          }
        } on PlatformException catch (e) {
          loading = false;
          yield CheckState();
          print('Apple Error : ${e.code}, ${e.message}');
        }
      }
    }

    if (event is GoingSignUpEvent) {
      loading = true;
      yield LoadingState();
      SignUp signUp = SignUp(
          accessId: event.decodeToken['sub'],
          appleInfo: AppleInfo(
              nickName: event.name, email: event.decodeToken['email']),
          image: null,
          device: event.device,
          email: event.decodeToken['email'],
          nickName: event.name,
          type: 'APPLE');

      ReturnData response = await SignUpRepository.signUp(signUp);
      if (response.code == 1) {
        if (production == 'prod-release' && kReleaseMode) {
          air.Airbridge.event
              .send(air.SignUpEvent(option: air.EventOption(label: 'apple')));
          air.Airbridge.event.send(
              air.Event('sign_up', option: air.EventOption(label: 'apple')));
          await facebookAppEvents.logCompletedRegistration();
        }
        amplitudeEvent('account_create_completed', {'login_type': 'apple'},
            init: false);
        print(
            "SignUpSuccess : ${response.code}, ${response.message}, ${response.data}");
        Login login = Login(
            accessId: event.decodeToken['sub'],
            device: event.device,
            type: 'APPLE');
        ReturnData loginRes = await SignUpRepository.login(login);
        if (loginRes.code == -104) {
          loading = false;
          yield BanUserState(banMean: loginRes.message!);
          return;
        }

        if (loginRes.code == 1) {
          if (production == 'prod-release' && kReleaseMode) {
            air.Airbridge.state.setUser(
                air.User(id: UserData.fromJson(loginRes.data).memberUuid));
            air.Airbridge.state.updateUser(
                air.User(id: UserData.fromJson(loginRes.data).memberUuid));
            air.Airbridge.event.send(air.SignInEvent(
                option: air.EventOption(label: 'apple'),
                user:
                    air.User(id: UserData.fromJson(loginRes.data).memberUuid)));
            air.Airbridge.event.send(
                air.Event('sign_in', option: air.EventOption(label: 'apple')));
          }

          print(
              "LoginSuccess : ${loginRes.code}, ${loginRes.message}, ${loginRes.data}");
          await prefs!.setString(
              'userData', jsonEncode(UserData.fromJson(loginRes.data).toMap()));
          dataSaver.userData = UserData.fromJson(
              jsonDecode(prefs!.getString('userData').toString()));
          await prefs!.setString('accessId', event.decodeToken['sub']);
          await prefs!.setString(
              'accessToken', UserData.fromJson(loginRes.data).accessToken);
          await prefs!.setString(
              'refreshToken', UserData.fromJson(loginRes.data).refreshToken);
          if (await Permission.location.isGranted) {
            Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.medium)
                .then((value) {
              CommonRepository.locationUpdate(
                  value.latitude.toString(), value.longitude.toString());
            });
          }
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

class BanUserState extends BaseBlocState {
  final String banMean;

  BanUserState({required this.banMean});
}

class GoingSignUpEvent extends BaseBlocEvent {
  final dynamic decodeToken;
  final String name;
  final Device device;

  GoingSignUpEvent(
      {required this.decodeToken, required this.name, required this.device});
}

class AgeCheckState extends BaseBlocState {
  final dynamic decodeToken;
  final String name;
  final Device device;

  AgeCheckState(
      {required this.decodeToken, required this.name, required this.device});
}

class SignUpFinishState extends BaseBlocState {}

class SignupAuthEvent extends BaseBlocEvent {
  final String auth;

  SignupAuthEvent({required this.auth});
}

class SignupAuthState extends BaseBlocState {
  final String accessId;
  final String email;
  final AppleInfo? appleInfo;
  final KakaoInfo? kakaoInfo;
  final Device device;
  final Data? image;
  final String type;

  SignupAuthState(
      {required this.accessId,
      required this.email,
      this.appleInfo,
      this.kakaoInfo,
      required this.device,
      this.image,
      required this.type});
}

class LoginAuthState extends BaseBlocState {}

class SignupInitEvent extends BaseBlocEvent {}

class SignupInitState extends BaseBlocState {}

class BaseSignupState extends BaseBlocState {}
