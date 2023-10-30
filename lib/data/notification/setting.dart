class Setting {
  final String memberUuid;
  final int marketingReceptionFlag;
  final DateTime marketingReceptionDate;
  final int chattingFlag;
  final DateTime chattingUpdateDate;
  final int prohibitFlag;
  final DateTime prohibitUpdateDate;
  final int classMadeKeywordAlarmFlag;
  final DateTime? classMadeKeywordAlarmDate;
  final int classRequestKeywordAlarmFlag;
  final DateTime? classRequestKeywordAlarmDate;
  final int communityCommentAlarmFlag;
  final DateTime? communityCommentAlarmDate;

  Setting(
      {required this.memberUuid,
      required this.marketingReceptionFlag,
      required this.marketingReceptionDate,
      required this.chattingFlag,
      required this.chattingUpdateDate,
      required this.prohibitFlag,
      required this.prohibitUpdateDate,
      required this.classMadeKeywordAlarmFlag,
      this.classMadeKeywordAlarmDate,
      required this.classRequestKeywordAlarmFlag,
      this.classRequestKeywordAlarmDate,
      required this.communityCommentAlarmFlag,
      this.communityCommentAlarmDate});

  factory Setting.fromJson(data) {
    return Setting(
        memberUuid: data['memberUuid'],
        marketingReceptionFlag: data['marketingReceptionFlag'],
        marketingReceptionDate: DateTime.parse(data['marketingReceptionDate']),
        chattingFlag: data['chattingFlag'],
        chattingUpdateDate: DateTime.parse(data['chattingUpdateDate']),
        prohibitFlag: data['prohibitFlag'],
        prohibitUpdateDate: DateTime.parse(data['prohibitUpdateDate']),
        classMadeKeywordAlarmFlag: data['classMadeKeywordAlarmFlag'],
        classMadeKeywordAlarmDate: data['classMadeKeywordAlarmDate'] != null
            ? DateTime.parse(data['classMadeKeywordAlarmDate'])
            : null,
        classRequestKeywordAlarmFlag: data['classRequestKeywordAlarmFlag'],
        classRequestKeywordAlarmDate:
            data['classRequestKeywordAlarmDate'] != null
                ? DateTime.parse(data['classRequestKeywordAlarmDate'])
                : null,
        communityCommentAlarmFlag: data['communityCommentAlarmFlag'],
        communityCommentAlarmDate: data['communityCommentAlarmDate'] != null
            ? DateTime.parse(data['communityCommentAlarmDate'])
            : null);
  }
}
