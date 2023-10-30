import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/review/review.dart';
import 'package:baeit/data/review/service/get_review_cnt_service.dart';
import 'package:baeit/data/review/service/get_review_details_service.dart';
import 'package:baeit/data/review/service/get_review_service.dart';
import 'package:baeit/data/review/service/remove_review_service.dart';
import 'package:baeit/data/review/service/review_report_service.dart';
import 'package:baeit/data/review/service/save_comment_review_service.dart';
import 'package:baeit/data/review/service/save_review_service.dart';
import 'package:baeit/data/review/service/send_review_alarm_service.dart';

class ReviewRepository {
  static Future<dynamic> sendReviewAlarm(String chatRoomUuid) =>
      SendReviewAlarmService(chatRoomUuid: chatRoomUuid).start();

  static Future<dynamic> saveReview(ReviewSaveForm reviewSaveForm) =>
      SaveReviewService(reviewSaveForm: reviewSaveForm).start();

  static Future<dynamic> reviewCnt(String classUuid) =>
      GetReviewCntService(classUuid: classUuid).start();

  static Future<dynamic> getReviewService(
          {required String classUuid,
          String? nextCursor,
          int? orderType = 2}) =>
      GetReviewService(
              classUuid: classUuid,
              nextCursor: nextCursor,
              orderType: orderType)
          .start();

  static Future<dynamic> reviewReport(
          {required String classReviewUuid,
          List<Data>? images,
          required String reportText}) =>
      ReviewReportService(
              classReviewUuid: classReviewUuid,
              reportText: reportText,
              images: images)
          .start();

  static Future<dynamic> getReviewDetails(String classReviewUuid) =>
      GetReviewDetailsService(classReviewUuid: classReviewUuid).start();

  static Future<dynamic> removeReview(String classReviewUuid) =>
      RemoveReviewService(classReviewUuid: classReviewUuid).start();

  static Future<dynamic> saveReviewComment(
          SaveReviewComment saveReviewComment) =>
      SaveCommentReviewService(saveReviewComment: saveReviewComment).start();
}
