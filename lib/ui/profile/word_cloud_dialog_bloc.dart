import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/data/profile/word_cloud.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:flutter/cupertino.dart';

class WordCloudDialogBloc extends BaseBloc {
  WordCloudDialogBloc(BuildContext context)
      : super(BaseWordCloudDialogState()) {
    on<WordCloudDialogInitEvent>(onWordCloudDialogInitEvent);
    on<GestureImageUpdateEvent>(onGestureImageUpdateEvent);
    on<NewDataEvent>(onNewDataEvent);
  }

  bool loading = false;
  List<WordCloud> wordClouds = [];
  int totalRow = 0;
  List<Widget> wordCloudTexts = [];
  bool gestureImageView = true;
  bool gestureUpdate = false;

  double bottomOffset = 0;
  bool scrollUnder = false;
  int nextData = 1;

  bool sendEvent = false;

  String lastCursor = '';

  onWordCloudDialogInitEvent(WordCloudDialogInitEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    ReturnData wordData = await ProfileRepository.getGoalKeyword();
    wordClouds = (wordData.data['list'] as List)
        .map((e) => WordCloud.fromJson(e))
        .toList();
    totalRow = wordData.data['totalRow'];

    for (int i = 0; i < wordClouds.length; i++) {
      wordCloudTexts.add(Padding(
        padding: EdgeInsets.only(
            left: i % 2 == 0 ? 5 : 3, right: i % 2 == 0 ? 2 : 4),
        child: customText('${wordClouds[i].text}',
            style: wordClouds[i].matchingFlag == 1
                ? TextStyle(
                    color: AppColors.primaryDark10,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T27))
                : TextStyle(
                    color: AppColors.gray500,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T21)),
            textAlign: TextAlign.start),
      ));
      if (totalRow == wordCloudTexts.length) {
        loading = false;
        emit(LoadingState());
      }
    }

    emit(WordCloudDialogInitState());
  }

  onGestureImageUpdateEvent(GestureImageUpdateEvent event, emit) {
    gestureImageView = false;
    emit(GestureImageUpdateState());
  }

  onNewDataEvent(NewDataEvent event, emit) async {
    if (wordCloudTexts.length == nextData * 60 && !scrollUnder && lastCursor != wordClouds.last.cursor) {
      scrollUnder = true;
      emit(CheckState());

      lastCursor = wordClouds.last.cursor;

      ReturnData wordData = await ProfileRepository.getGoalKeyword(
          cursor: wordClouds.last.cursor);

      if (wordData.code == 1) {
        wordClouds = [];
        wordClouds = (wordData.data['list'] as List)
            .map((e) => WordCloud.fromJson(e))
            .toList();
        totalRow = wordData.data['totalRow'];

        for (int i = 0; i < wordClouds.length; i++) {
          wordCloudTexts.add(Padding(
            padding: EdgeInsets.only(
                left: i % 2 == 0 ? 5 : 3, right: i % 2 == 0 ? 2 : 4),
            child: customText('${wordClouds[i].text}',
                style: wordClouds[i].matchingFlag == 1
                    ? TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T27))
                    : TextStyle(
                        color: AppColors.gray500,
                        fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                        fontSize: fontSizeSet(textSize: TextSize.T21)),
                textAlign: TextAlign.start),
          ));
        }

        nextData += 1;
        scrollUnder = false;
        emit(NewDataState());
      }
    }
  }
}

class NewDataEvent extends BaseBlocEvent {}

class NewDataState extends BaseBlocState {}

class GestureImageUpdateEvent extends BaseBlocEvent {}

class GestureImageUpdateState extends BaseBlocState {}

class WordCloudDialogInitEvent extends BaseBlocEvent {}

class WordCloudDialogInitState extends BaseBlocState {}

class BaseWordCloudDialogState extends BaseBlocState {}
