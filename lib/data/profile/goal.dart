class Goal {
  final List<String>? ssamKeywords;
  final String ssamType;
  final List<String>? studentKeywords;
  final String studentType;

  Goal(
      {this.ssamKeywords,
      required this.ssamType,
      this.studentKeywords,
      required this.studentType});

  toMap() {
    Map<String, dynamic> data = {};
    if (ssamKeywords != null) {
      data.addAll({
        'ssamKeywords': ssamKeywords!.map((e) {
          return {'text': e};
        }).toList()
      });
    }
    data.addAll({'ssamType': ssamType});
    if (studentKeywords != null) {
      data.addAll({
        'studentKeywords': studentKeywords!.map((e) {
          return {'text': e};
        }).toList()
      });
    }
    data.addAll({'studentType': studentType});
    return data;
  }
}
