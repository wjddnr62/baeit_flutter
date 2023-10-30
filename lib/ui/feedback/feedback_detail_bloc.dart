import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/feedback/feedback.dart';
import 'package:baeit/data/feedback/repository/feedback_repository.dart';
import 'package:flutter/widgets.dart';

class FeedbackDetailBloc extends BaseBloc {
  FeedbackDetailBloc(BuildContext context) : super(BaseFeedbackDetailState());

  bool loading = false;
  FeedbackData? feedbackData;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is FeedbackDetailInitEvent) {
      loading = true;
      yield LoadingState();

      ReturnData res =
          await FeedbackRepository.getFeedbackDetail(event.feedbackUuid);

      if (res.code == 1) {
        feedbackData = FeedbackData.fromJson(res.data);

        loading = false;
        yield FeedbackDetailInitState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }
  }
}

class BaseFeedbackDetailState extends BaseBlocState {}

class FeedbackDetailInitEvent extends BaseBlocEvent {
  final String feedbackUuid;

  FeedbackDetailInitEvent({required this.feedbackUuid});
}

class FeedbackDetailInitState extends BaseBlocState {}
