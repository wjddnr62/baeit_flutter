import 'package:baeit/data/common/image_value.dart';

class Profile {
  final String? birthDate;
  final String? email;
  final String? gender;
  final Data? image;
  final String? introText;
  final String? nickName;
  final String? phone;
  final String type;
  final int updateImageFlag;

  Profile(
      {this.birthDate,
      this.email,
      this.gender,
      this.image,
      this.introText,
      this.nickName,
      this.phone,
      required this.type,
      this.updateImageFlag = 1});

  factory Profile.fromJson(data) {
    return Profile(
        birthDate: data['birthDate'] != null ? data['birthDate'] : null,
        email: data['email'] != null ? data['email'] : null,
        gender: data['gender'] != null ? data['gender'] : null,
        image: data['image'] != null ? data['image'] : null,
        introText: data['introText'] != null ? data['introText'] : null,
        nickName: data['nickName'] != null ? data['nickName'] : null,
        phone: data['phone'] != null ? data['phone'] : null,
        type: data['type']);
  }

  toMap() {
    Map<String, Object> data = {};
    if (birthDate != null) {
      data.addAll({'birthDate': birthDate!});
    }
    if (email != null) {
      data.addAll({'email': email!});
    }
    if (gender != null) {
      data.addAll({'gender': gender!});
    }
    if (image != null) {
      data.addAll({'image': image!.toMap()});
    }
    if (introText != null) {
      data.addAll({'introText': introText!});
    }
    if (nickName != null) {
      data.addAll({'nickName': nickName!});
    }
    if (phone != null) {
      data.addAll({'phone': phone!});
    }
    data.addAll({'type': type});
    data.addAll({'updateImageFlag': updateImageFlag});
    return data;
  }
}

class ProfileGet {
  final String memberUuid;
  final String type;
  final String nickName;
  final String phone;
  final String status;
  final String email;
  final String gender;
  final String birthDate;
  final String? introText;
  final String? profile;
  final DateTime? createDate;
  final int goalFlag;

  ProfileGet(
      {required this.memberUuid,
      required this.type,
      required this.nickName,
      required this.phone,
      required this.status,
      required this.email,
      required this.gender,
      required this.birthDate,
      this.introText,
      this.profile,
      this.createDate,
      required this.goalFlag});

  factory ProfileGet.fromJson(data) {
    return ProfileGet(
        memberUuid: data['memberUuid'],
        type: data['type'],
        nickName: data['nickName'],
        phone: data['phone'],
        status: data['status'],
        email: data['email'],
        gender: data['gender'],
        birthDate: data['birthDate'],
        introText: data['introText'] != null ? data['introText'] : null,
        profile: data['profile'] != null ? data['profile'] : null,
        createDate: DateTime.parse(data['createDate']),
        goalFlag: data['goalFlag']);
  }
}
