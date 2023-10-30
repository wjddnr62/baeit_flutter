import 'package:baeit/data/class/class.dart';

class KeywordClass {
  final List<KeywordClassData> keywordClassData;
  final int totalRow;

  KeywordClass({required this.keywordClassData, required this.totalRow});

  factory KeywordClass.fromJson(data) {
    return KeywordClass(
        keywordClassData: data['list'].length == 0
            ? []
            : (data['list'] as List)
                .map((e) => KeywordClassData.fromJson(e))
                .toList(),
        totalRow: data['totalRow']);
  }
}

class KeywordClassData {
  final Class classData;
  final Alarm alarm;

  KeywordClassData({required this.classData, required this.alarm});

  factory KeywordClassData.fromJson(data) {
    return KeywordClassData(
        classData: Class.fromJson(data['classInfo']),
        alarm: Alarm.fromJson(data['alarm']));
  }
}

class Alarm {
  final String memberClassAlarmListUuid;
  final String keyword;
  final String eupmyeondongName;
  final DateTime createDate;
  final int readFlag;

  Alarm(
      {required this.memberClassAlarmListUuid,
      required this.keyword,
      required this.eupmyeondongName,
      required this.createDate,
      required this.readFlag});

  factory Alarm.fromJson(data) {
    return Alarm(
        memberClassAlarmListUuid: data['memberClassAlarmListUuid'],
        keyword: data['keyword'],
        eupmyeondongName: data['eupmyeondongName'],
        createDate: DateTime.parse(data['createDate']),
        readFlag: data['readFlag']);
  }
}
