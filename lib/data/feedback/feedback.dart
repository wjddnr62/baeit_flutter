import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/common/image_value.dart';

class Feedback {
  final List<FeedbackData> feedbackData;
  final int? totalRow;

  Feedback({required this.feedbackData, required this.totalRow});

  factory Feedback.fromJson(data) {
    return Feedback(
        feedbackData: (data['list'] as List)
            .map((e) => FeedbackData.fromJson(e))
            .toList(),
        totalRow: data['totalRow']);
  }
}

class FeedbackData {
  final String feedbackUuid;
  final String type;
  final String feedbackText;
  final DateTime createDate;
  final DateTime updateDate;
  final int answerFlag;
  final DateTime? answerDate;
  final String? answerText;
  final Member member;
  final List<Data>? images;
  final List<Data>? answerImages;
  final String? cursor;

  FeedbackData(
      {required this.feedbackUuid,
      required this.type,
      required this.feedbackText,
      required this.createDate,
      required this.updateDate,
      required this.answerFlag,
      this.answerDate,
      this.answerText,
      required this.member,
      this.images,
      this.answerImages,
      this.cursor});

  factory FeedbackData.fromJson(data) {
    return FeedbackData(
        feedbackUuid: data['feedbackUuid'],
        type: data['type'],
        feedbackText: data['feedbackText'],
        createDate: DateTime.parse(data['createDate']),
        updateDate: DateTime.parse(data['updateDate']),
        answerFlag: data['answerFlag'],
        answerDate: data['answerDate'] != null
            ? DateTime.parse(data['answerDate'])
            : null,
        answerText: data['answerText'] != null ? data['answerText'] : null,
        member: Member.fromJson(data['member']),
        images: data['images'] != null
            ? (data['images'] as List).map((e) => Data.fromJson(e)).toList()
            : null,
        answerImages: data['answerImages'] != null
            ? (data['answerImages'] as List)
                .map((e) => Data.fromJson(e))
                .toList()
            : null,
        cursor: data['cursor']);
  }
}

class FeedbackSend {
  final String feedbackText;
  final String feedbackUuid;
  final List<Data>? images;
  final String type;

  FeedbackSend(
      {required this.feedbackText,
      this.feedbackUuid = '',
      this.images,
      required this.type});

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'feedbackText': feedbackText});
    if (feedbackUuid != '') {
      data.addAll({'feedbackUuid': feedbackUuid});
    }
    if (images != null) {
      data.addAll({
        'images': images!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    data.addAll({'type': type});
    return data;
  }
}
