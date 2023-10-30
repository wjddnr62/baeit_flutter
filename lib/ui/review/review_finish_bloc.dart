import 'package:baeit/config/base_bloc.dart';
import 'package:flutter/widgets.dart';

class ReviewFinishBloc extends BaseBloc {
  ReviewFinishBloc(BuildContext context) : super(BaseReviewFinishState()) {
    on<ReviewFinishInitEvent>(onReviewFinishInitEvent);
  }

  onReviewFinishInitEvent(ReviewFinishInitEvent event, emit) async {
    emit(ReviewFinishInitState());
  }
}

class ReviewFinishInitEvent extends BaseBlocEvent {
  final String classUuid;

  ReviewFinishInitEvent({required this.classUuid});
}

class ReviewFinishInitState extends BaseBlocState {}

class BaseReviewFinishState extends BaseBlocState {}
