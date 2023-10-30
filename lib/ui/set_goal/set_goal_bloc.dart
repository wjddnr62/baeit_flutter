import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/profile/goal.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetGoalBloc extends BaseBloc {
  SetGoalBloc(BuildContext context) : super(BaseSetGoalState()) {
    on<SetGoalInitEvent>(onSetGoalInitEvent);
    on<SetActivityEvent>(onSetActivityEvent);
    on<KeywordItemAddEvent>(onKeywordItemAddEvent);
    on<KeywordItemRemoveEvent>(onKeywordItemRemoveEvent);
    on<SaveGoalEvent>(onSaveGoalEvent);
    on<SkipGoalEvent>(onSkipGoalEvent);
    on<KeywordSetEvent>(onKeywordSetEvent);
  }

  bool loading = false;

  int activityStudentIndex = 0;
  int activityTeacherIndex = 0;

  String? teacherType;
  String? studentType;

  List<String> learnKeyword = [];
  List<String> saveLearnKeyword = [];
  List<Widget> learnKeywordItems = [];

  List<String> teachingKeyword = [];
  List<String> saveTeachingKeyword = [];
  List<Widget> teachingKeywordItems = [];

  List<TextEditingController> keywordControllerMade =
  List.generate(5, (index) => TextEditingController());
  List<TextEditingController> keywordControllerRequest =
  List.generate(5, (index) => TextEditingController());

  onSetGoalInitEvent(SetGoalInitEvent event, Emitter<BaseBlocState> emit) {
    emit(SetGoalInitState());
  }

  onSetActivityEvent(SetActivityEvent event, Emitter<BaseBlocState> emit) {
    if (event.type == 'STUDENT') {
      activityStudentIndex = event.index;
      studentType = event.selectValue;
    } else if (event.type == 'TEACHER') {
      activityTeacherIndex = event.index;
      teacherType = event.selectValue;
    }
    emit(SetActivityState());
  }

  onKeywordItemAddEvent(
      KeywordItemAddEvent event, Emitter<BaseBlocState> emit) {
    if (event.type == 'STUDENT') {
      learnKeyword.add(event.keyword);
      saveLearnKeyword.add(event.keyword.split('●')[0]);
    } else if (event.type == 'TEACHER') {
      teachingKeyword.add(event.keyword);
      saveTeachingKeyword.add(event.keyword.split('●')[0]);
    }
    emit(KeywordItemAddState());
  }

  onKeywordItemRemoveEvent(
      KeywordItemRemoveEvent event, Emitter<BaseBlocState> emit) {
    if (event.type == 'STUDENT') {
      learnKeywordItems.removeAt(
          learnKeyword.indexWhere((element) => element == event.keyword));
      saveLearnKeyword.removeAt(
          learnKeyword.indexWhere((element) => element == event.keyword));
      learnKeyword.removeAt(
          learnKeyword.indexWhere((element) => element == event.keyword));
    } else if (event.type == 'TEACHER') {
      teachingKeywordItems.removeAt(
          teachingKeyword.indexWhere((element) => element == event.keyword));
      saveTeachingKeyword.removeAt(
          teachingKeyword.indexWhere((element) => element == event.keyword));
      teachingKeyword.removeAt(
          teachingKeyword.indexWhere((element) => element == event.keyword));
    }
    emit(KeywordItemRemoveState());
  }

  onSaveGoalEvent(SaveGoalEvent event, Emitter<BaseBlocState> emit) async {
    loading = true;
    emit(LoadingState());

    ReturnData returnData = await ProfileRepository.setGoal(event.goal);
    if (returnData.code == 1) {
      loading = false;
      emit(SaveGoalState());
    } else {
      loading = false;
      emit(LoadingState());
    }
  }

  onSkipGoalEvent(SkipGoalEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    ReturnData returnData = await ProfileRepository.setGoal(event.goal);
    if (returnData.code == 1) {
      loading = false;
      emit(SkipGoalState());
    } else {
      loading = false;
      emit(LoadingState());
    }
  }

  onKeywordSetEvent(KeywordSetEvent event, emit) {
    emit(KeywordSetState());
  }
}

class SkipGoalEvent extends BaseBlocEvent {
  final Goal goal;

  SkipGoalEvent({required this.goal});
}

class SkipGoalState extends BaseBlocState {}

class SaveGoalEvent extends BaseBlocEvent {
  final Goal goal;

  SaveGoalEvent({required this.goal});
}

class SaveGoalState extends BaseBlocState {}

class KeywordItemAddEvent extends BaseBlocEvent {
  final String type;
  final String keyword;

  KeywordItemAddEvent({required this.type, required this.keyword});
}

class KeywordItemAddState extends BaseBlocState {}

class KeywordItemRemoveEvent extends BaseBlocEvent {
  final String type;
  final String keyword;

  KeywordItemRemoveEvent({required this.type, required this.keyword});
}

class KeywordItemRemoveState extends BaseBlocState {}

class SetActivityEvent extends BaseBlocEvent {
  final int index;
  final String type;
  final String selectValue;

  SetActivityEvent(
      {required this.index, required this.type, required this.selectValue});
}

class KeywordSetEvent extends BaseBlocEvent {}

class KeywordSetState extends BaseBlocState {}

class SetActivityState extends BaseBlocState {}

class SetGoalInitEvent extends BaseBlocEvent {}

class SetGoalInitState extends BaseBlocState {}

class BaseSetGoalState extends BaseBlocState {}
