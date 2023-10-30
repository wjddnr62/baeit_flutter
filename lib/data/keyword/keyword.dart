class Keyword {
  List<KeywordData> keywords;
  List<KeywordArea> areas;

  Keyword({required this.keywords, required this.areas});

  factory Keyword.fromJson(data) {
    return Keyword(
        keywords: data['keywords'].length == 0
            ? []
            : (data['keywords'] as List)
                .map((e) => KeywordData.fromJson(e))
                .toList(),
        areas: (data['areas'] as List)
            .map((e) => KeywordArea.fromJson(e))
            .toList());
  }
}

class KeywordData {
  final String memberClassKeywordUuid;
  final String type;
  final String keywordText;

  KeywordData(
      {required this.memberClassKeywordUuid,
      required this.type,
      required this.keywordText});

  factory KeywordData.fromJson(data) {
    return KeywordData(
        memberClassKeywordUuid: data['memberClassKeywordUuid'],
        type: data['type'],
        keywordText: data['keywordText']);
  }
}

class KeywordArea {
  final String memberAreaUuid;
  final String type;
  final String townName;
  final String sidoName;
  final String sigunguName;
  final String eupmyeondongName;
  int alarmFlag;

  KeywordArea(
      {required this.memberAreaUuid,
      required this.type,
      required this.townName,
      required this.sidoName,
      required this.sigunguName,
      required this.eupmyeondongName,
      required this.alarmFlag});

  factory KeywordArea.fromJson(data) {
    return KeywordArea(
        memberAreaUuid: data['memberAreaUuid'],
        type: data['type'],
        townName: data['townName'],
        sidoName: data['sidoName'],
        sigunguName: data['sigunguName'],
        eupmyeondongName: data['eupmyeondongName'],
        alarmFlag: data['alarmFlag']);
  }
}
