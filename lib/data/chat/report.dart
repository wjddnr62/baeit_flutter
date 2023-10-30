import 'package:baeit/data/common/image_value.dart';

class Report {
  final String chatRoomUuid;
  final String defendantUuid;
  final List<Data>? images;
  final String? reportText;

  Report(
      {required this.chatRoomUuid,
      required this.defendantUuid,
      this.images,
      this.reportText});

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'chatRoomUuid': chatRoomUuid});
    data.addAll({'defendantUuid': defendantUuid});
    if (images != null) {
      data.addAll({'images': images!.map((e) => e.toDecode()).toList()});
    }
    if (reportText != null) {
      data.addAll({'reportText': reportText});
    }
    return data;
  }
}
