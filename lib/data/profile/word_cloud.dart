class WordCloud {
  final String type;
  final String text;
  final int matchingFlag;
  final int count;
  final String cursor;

  WordCloud(
      {required this.type,
      required this.text,
      required this.matchingFlag,
      required this.count,
      required this.cursor});

  factory WordCloud.fromJson(data) {
    return WordCloud(
        type: data['type'],
        text: data['text'],
        matchingFlag: data['matchingFlag'],
        count: data['count'],
        cursor: data['cursor']);
  }
}
