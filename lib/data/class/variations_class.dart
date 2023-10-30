import 'package:baeit/data/common/image_value.dart';

class VariationsClass {
  final List<Area>? areas;
  final String? category;
  final String? classContentText;
  final String? classIntroText;
  final String? classUuid;
  final int? costConsultFlag;
  final int? dayConsultFlag;
  final List<String>? days;
  final List<Data>? files;
  final List<String>? keywords;
  final String? level;
  final String? costType;
  final int? maxCost;
  final int? minCost;
  final String? shareType;
  final Data? representativeFile;
  final Data? representativeOriginFile;
  final String? title;
  final String status;
  final String? tutorIntroText;
  final String type;
  final int firstFreeFlag;
  final int groupFlag;
  final int? personCount;
  final int? costOfPerson;

  VariationsClass(
      {this.areas,
      this.category,
      this.classContentText,
      this.classIntroText,
      this.classUuid,
      this.costConsultFlag,
      this.dayConsultFlag,
      this.days,
      this.files,
      this.keywords,
      this.level,
      this.costType,
      this.maxCost,
      this.minCost,
      this.shareType,
      this.representativeFile,
      this.representativeOriginFile,
      this.title,
      required this.status,
      this.tutorIntroText,
      required this.type,
      required this.firstFreeFlag,
      required this.groupFlag,
      this.personCount,
      this.costOfPerson});

  toMap() {
    Map<String, dynamic> data = {};
    if (areas != null) {
      data.addAll({
        'areas': areas!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    if (category != null) {
      data.addAll({'category': category});
    }
    if (classContentText != null) {
      data.addAll({'classContentText': classContentText});
    }
    if (classIntroText != null) {
      data.addAll({'classIntroText': classIntroText});
    }
    if (classUuid != null) {
      data.addAll({'classUuid': classUuid});
    }
    if (costConsultFlag != null) {
      data.addAll({'costConsultFlag': costConsultFlag});
    }
    if (dayConsultFlag != null) {
      data.addAll({'dayConsultFlag': dayConsultFlag});
    }
    if (days != null) {
      data.addAll({'days': days});
    }
    if (files != null) {
      data.addAll({
        'files': files!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    if (keywords != null) {
      data.addAll({
        'keywords': keywords!.map((e) {
          return {'text': e};
        }).toList()
      });
    }
    if (level != null) {
      data.addAll({'level': level});
    }
    data.addAll({'costType': costType});
    if (maxCost != null) {
      data.addAll({'maxCost': maxCost});
    }
    if (minCost != null) {
      data.addAll({'minCost': minCost});
    }
    if (shareType != null) {
      data.addAll({'shareType': shareType});
    }
    if (representativeFile != null) {
      data.addAll({'representativeFile': representativeFile!.toDecode()});
    }
    if (representativeOriginFile != null) {
      data.addAll(
          {'representativeOriginFile': representativeOriginFile!.toDecode()});
    }
    if (title != null) {
      data.addAll({'title': title});
    }
    data.addAll({'status': status});
    if (tutorIntroText != null) {
      data.addAll({'tutorIntroText': tutorIntroText});
    }
    data.addAll({'type': type});
    data.addAll({'firstFreeFlag': firstFreeFlag});
    data.addAll({'groupFlag': groupFlag});
    if (personCount != null) {
      data.addAll({'personCount': personCount});
    }
    if (costOfPerson != null) {
      data.addAll({'costOfPerson': costOfPerson});
    }
    
    return data;
  }
}

class Area {
  final String buildingName;
  final String hangCode;
  final String lati;
  final String longi;
  final String? roadAddress;
  final String zipAddress;
  final String? sidoName;
  final String? sigunguName;
  final String? eupmyeondongName;

  Area(
      {required this.buildingName,
      required this.hangCode,
      required this.lati,
      required this.longi,
      this.roadAddress,
      required this.zipAddress,
      this.sidoName,
      this.sigunguName,
      this.eupmyeondongName});

  factory Area.fromJson(data) {
    return Area(
        buildingName: data['buildingName'],
        hangCode: data['hangCode'].toString(),
        lati: data['lati'].toString(),
        longi: data['longi'].toString(),
        zipAddress: data['zipAddress'],
        roadAddress: data['roadAddress'] != null ? data['roadAddress'] : null,
        sidoName: data['sidoName'],
        sigunguName: data['sigunguName'],
        eupmyeondongName: data['eupmyeondongName']);
  }

  toDecode() {
    return {
      'buildingName': buildingName,
      'hangCode': hangCode,
      'lati': lati,
      'longi': longi,
      'roadAddress': roadAddress,
      'zipAddress': zipAddress
    };
  }
}
