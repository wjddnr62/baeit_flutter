import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/review/repository/review_repository.dart';
import 'package:baeit/data/review/review.dart';
import 'package:flutter/widgets.dart';

class ReviewDetailBloc extends BaseBloc {
  ReviewDetailBloc(BuildContext context) : super(BaseReviewDetailState()) {
    on<ReviewDetailInitEvent>(onReviewDetailInitEvent);
    on<RemoveReviewEvent>(onRemoveReviewEvent);
    on<NewDataEvent>(onNewDataEvent);
    on<AddCommentEvent>(onAddCommentEvent);
  }

  late String classUuid;
  late ReviewCount? reviewCount;

  double bottomOffset = 0;
  bool scrollUnder = false;
  int nextData = 1;

  String lastCursor = '';

  bool loading = false;
  ReviewList? reviewList;
  List<ReviewGrade> reviewGrade = [];
  List<String> reviewType = ['TYPE_0', 'TYPE_1', 'TYPE_2', 'TYPE_3', 'TYPE_4'];

  setReviewGrade(ReviewCount reviewCount) {
    List<int> count = [
      reviewCount.typeZeroSumCnt,
      reviewCount.typeFirstSumCnt,
      reviewCount.typeSecondSumCnt,
      reviewCount.typeThirdSumCnt,
      reviewCount.typeFourthSumCnt
    ];

    List<int> resetCount = [
      reviewCount.typeZeroSumCnt,
      reviewCount.typeFirstSumCnt,
      reviewCount.typeSecondSumCnt,
      reviewCount.typeThirdSumCnt,
      reviewCount.typeFourthSumCnt
    ];

    count.sort((a, b) => b.compareTo(a));
    List<int> setCount = [];
    setCount = count.toSet().toList();
    for (int i = 0; i < setCount.length; i++) {
      for (int j = 0; j < resetCount.length; j++) {
        if (setCount[i] == resetCount[j]) {
          reviewGrade.add(ReviewGrade(num: i, type: reviewType[j]));
        }
      }
    }
  }

  onReviewDetailInitEvent(ReviewDetailInitEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    classUuid = event.classUuid;
    reviewCount = null;
    reviewCount = ReviewCount.fromJson(
        (await ReviewRepository.reviewCnt(event.classUuid)).data);

    reviewGrade = [];
    setReviewGrade(reviewCount!);
    emit(LoadingState());

    ReturnData returnData =
        await ReviewRepository.getReviewService(classUuid: event.classUuid);

    if (returnData.code == 1) {
      reviewList = null;
      reviewList = ReviewList.fromJson(returnData.data);

      loading = false;
      emit(ReviewDetailInitState());
    } else {
      loading = false;
      emit(ErrorState());
    }
  }

  onRemoveReviewEvent(RemoveReviewEvent event, emit) async {
    await ReviewRepository.removeReview(event.classReviewUuid);
    emit(RemoveReviewState());
    add(ReviewDetailInitEvent(classUuid: classUuid, reviewCount: reviewCount));
  }

  onNewDataEvent(NewDataEvent event, emit) async {
    if (reviewList!.reviewData.length == nextData * 20 &&
        !scrollUnder &&
        lastCursor != reviewList!.reviewData.last.cursor) {
      scrollUnder = true;

      lastCursor = reviewList!.reviewData.last.cursor!;

      reviewCount = null;
      reviewCount = ReviewCount.fromJson(
          (await ReviewRepository.reviewCnt(classUuid)).data);

      reviewGrade = [];
      setReviewGrade(reviewCount!);

      ReturnData returnData = await ReviewRepository.getReviewService(
          classUuid: classUuid, nextCursor: lastCursor);

      reviewList!.reviewData
          .addAll(ReviewList.fromJson(returnData.data).reviewData);
      nextData += 1;
      scrollUnder = false;
      emit(NewDataState());
    }
  }

  onAddCommentEvent(AddCommentEvent event, emit) async {
    await ReviewRepository.saveReviewComment(SaveReviewComment(
        answerText: event.text, classReviewUuid: event.classReviewUuid));
    emit(AddCommentState());
    add(ReviewDetailInitEvent(classUuid: classUuid, reviewCount: reviewCount));
  }
}

class AddCommentEvent extends BaseBlocEvent {
  final String text;
  final String classReviewUuid;

  AddCommentEvent({required this.text, required this.classReviewUuid});
}

class AddCommentState extends BaseBlocState {}

class NewDataEvent extends BaseBlocEvent {}

class NewDataState extends BaseBlocState {}

class RemoveReviewEvent extends BaseBlocEvent {
  final String classReviewUuid;

  RemoveReviewEvent({required this.classReviewUuid});
}

class RemoveReviewState extends BaseBlocState {}

class ReviewDetailInitEvent extends BaseBlocEvent {
  final String classUuid;
  final ReviewCount? reviewCount;

  ReviewDetailInitEvent({required this.classUuid, this.reviewCount});
}

class ReviewDetailInitState extends BaseBlocState {}

class BaseReviewDetailState extends BaseBlocState {}
