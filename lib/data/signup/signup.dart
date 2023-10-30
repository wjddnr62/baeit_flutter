import 'package:baeit/data/common/image_value.dart';

class SignUp {
  final String accessId;
  final KakaoInfo? kakaoInfo;
  final AppleInfo? appleInfo;
  final Device device;
  final Data? image;
  final String email;
  final String? birthDate;
  final String? gender;
  final String? nickName;
  final String? phone;
  final String type;

  SignUp(
      {required this.accessId,
      this.kakaoInfo,
      this.appleInfo,
      required this.device,
      this.image,
      required this.email,
      this.birthDate,
      this.gender,
      this.nickName,
      this.phone,
      required this.type});
}

class KakaoInfo {
  String ageRange;
  String birthDay;
  String birthYear;
  final String email;
  final String gender;
  final String nickName;
  final String phoneNumber;
  final String profileImage;
  final String thumbnailImage;

  KakaoInfo(
      {required this.ageRange,
      required this.birthDay,
      required this.birthYear,
      required this.email,
      required this.gender,
      required this.nickName,
      required this.phoneNumber,
      required this.profileImage,
      required this.thumbnailImage});

  toMap() {
    Map<String, Object> data = {};
    data.addAll({'ageRange': ageRange});
    data.addAll({'birthDay': birthDay});
    data.addAll({'birthYear': birthYear});
    data.addAll({'email': email});
    data.addAll({'gender': gender});
    data.addAll({'nickName': nickName});
    data.addAll({'phoneNumber': phoneNumber});
    data.addAll({'profileImage': profileImage});
    data.addAll({'thumbnailImage': thumbnailImage});
    return data;
  }
}

class AppleInfo {
  final String email;
  final String? nickName;

  AppleInfo({required this.email, this.nickName});

  toMap() {
    Map<String, Object> data = {};
    data.addAll({'email': email});
    if (nickName != null) {
      data.addAll({'nickName': nickName!});
    }
    return data;
  }
}

class Device {
  final String? token;
  final String? type;

  Device({required this.token, required this.type});

  toMap() {
    Map<String, Object> data = {};
    data.addAll({'token': token!});
    data.addAll({'type': type!});
    return data;
  }
}

class UserData {
  final String memberUuid;
  final String refreshToken;
  final String accessToken;
  final String type;
  final String status;
  final String gender;
  final String email;

  UserData(
      {required this.memberUuid,
      required this.refreshToken,
      required this.accessToken,
      required this.type,
      required this.status,
      required this.gender,
      required this.email});

  factory UserData.fromJson(data) {
    return UserData(
        memberUuid: data['memberUuid'].toString(),
        refreshToken: data['refreshToken'],
        accessToken: data['accessToken'],
        type: data['type'],
        status: data['status'],
        gender: data['gender'],
        email: data['email']);
  }

  toMap() {
    Map<String, Object> data = {};
    data.addAll({'memberUuid': memberUuid});
    data.addAll({'refreshToken': refreshToken});
    data.addAll({'accessToken': accessToken});
    data.addAll({'type': type});
    data.addAll({'status': status});
    data.addAll({'gender': gender});
    data.addAll({'email': email});
    return data;
  }
}
