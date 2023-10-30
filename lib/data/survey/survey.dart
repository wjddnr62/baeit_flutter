class Survey {
  final String surveyUuid;
  final String title;
  final String contentText;
  final String url;
  final int viewFlag;

  Survey(
      {required this.surveyUuid,
      required this.title,
      required this.contentText,
      required this.url,
      required this.viewFlag});

  factory Survey.fromJson(json) {
    return Survey(
        surveyUuid: json['surveyUuid'],
        title: json['title'],
        contentText: json['contentText'],
        url: json['url'],
        viewFlag: json['viewFlag']);
  }
}
