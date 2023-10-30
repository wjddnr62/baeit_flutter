import 'package:baeit/data/feedback/feedback.dart';
import 'package:baeit/data/feedback/service/feedback_service.dart';
import 'package:baeit/data/feedback/service/get_feedback_detail_service.dart';
import 'package:baeit/data/feedback/service/get_feedback_service.dart';

class FeedbackRepository {
  static Future<dynamic> feedback(FeedbackSend feedbackSend) =>
      FeedbackService(feedbackSend: feedbackSend).start();

  static Future<dynamic> getFeedback({String? nextCursor, int? answerFlag}) =>
      GetFeedbackService(answerFlag: answerFlag, nextCursor: nextCursor).start();

  static Future<dynamic> getFeedbackDetail(String feedbackUuid) =>
      GetFeedbackDetailService(feedbackUuid: feedbackUuid).start();
}
