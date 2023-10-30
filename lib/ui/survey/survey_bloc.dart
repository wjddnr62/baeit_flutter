import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/survey/repository/survey_repository.dart';
import 'package:flutter/widgets.dart';

class SurveyBloc extends BaseBloc {
  SurveyBloc(BuildContext context) : super(BaseSurveyState()) {
    on<SurveyInitEvent>(onSurveyInitEvent);
    on<SurveyFinishEvent>(onSurveyFinishEvent);
  }

  bool loading = false;
  bool surveyFinish = false;

  onSurveyInitEvent(SurveyInitEvent event, emit) {
    emit(SurveyInitState());
  }

  onSurveyFinishEvent(SurveyFinishEvent event, emit) async {
    surveyFinish = true;
    await SurveyRepository.registrationSurvey(event.surveyUuid);
    emit(SurveyFinishState());
  }
}

class SurveyFinishEvent extends BaseBlocEvent {
  final String surveyUuid;

  SurveyFinishEvent({required this.surveyUuid});
}

class SurveyFinishState extends BaseBlocState {}

class SurveyInitEvent extends BaseBlocEvent {}

class SurveyInitState extends BaseBlocState {}

class BaseSurveyState extends BaseBlocState {}
