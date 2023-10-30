import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/keyword/keyword.dart';
import 'package:baeit/data/keyword/keyword_v2.dart';
import 'package:baeit/data/keyword/repository/keyword_repository.dart';
import 'package:baeit/data/notification/notification.dart';
import 'package:baeit/data/notification/repository/notification_repository.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/widgets.dart';

class NotificationBloc extends BaseBloc {
  NotificationBloc(BuildContext context) : super(BaseNotificationState());

  bool loading = false;
  int type = 0;

  List<NotificationData> notification = [];

  double bottomOffset = 0;
  bool scrollUnder = false;
  int nextData = 1;

  double keywordBottomOffset = 0;
  bool keywordScrollUnder = false;

  int keywordSelectTap = 0;

  int notificationUnReadCount = 0;
  int keywordUnReadCount = 0;

  int keywordLearnNextData = 1;
  int keywordTeachNextData = 1;
  KeywordList? keywordTeach;
  KeywordList? keywordLearn;

  int selectKeywordType = 0;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is NotificationInitEvent) {
      type = event.type;
      if (type == 1) {
        keywordSelectTap = event.detailType;
      }
      loading = true;
      yield LoadingState();

      keywordTeach = KeywordList.fromJson(
          (await KeywordRepository.getKeywordAlarmList(type: 'TEACH')).data);
      keywordLearn = KeywordList.fromJson(
          (await KeywordRepository.getKeywordAlarmList(type: 'LEARN')).data);

      for (int i = 0; i < keywordTeach!.keyword.length; i++) {
        if (keywordTeach!.keyword[i].readFlag == 0) {
          keywordUnReadCount += 1;
        }
      }

      for (int i = 0; i < keywordLearn!.keyword.length; i++) {
        if (keywordLearn!.keyword[i].readFlag == 0) {
          keywordUnReadCount += 1;
        }
      }

      if (type == 1) {
        await KeywordRepository.putKeywordAlarmRead('LEARN');
      }

      KeywordRepository.getKeywordAlarm(type: 'MADE').then((value) {
        dataSaver.classKeywordNotification = Keyword.fromJson(value.data);
      });

      ReturnData returnData = await NotificationRepository.getNotification();

      if (returnData.code == 1) {
        notification = (returnData.data['list'] as List)
            .map((e) => NotificationData.fromJson(e))
            .toList();

        for (int i = 0; i < notification.length; i++) {
          if (notification[i].readFlag == 0) {
            notificationUnReadCount += 1;
          }
        }

        if (type == 0) {
          NotificationRepository.readNotification().then((value) {
            flutterLocalNotificationsPlugin!.cancel(0);
          });
        }

        loading = false;
        yield NotificationInitState();
      } else {
        yield ErrorState();
      }
    }

    if (event is GetDataEvent) {
      if (notification.length == nextData * 20) {
        yield CheckState();

        ReturnData returnData = await NotificationRepository.getNotification(
            nextCursor: notification.last.cursor);

        if (returnData.code == 1) {
          notification.addAll((returnData.data['list'] as List)
              .map((e) => NotificationData.fromJson(e))
              .toList());

          nextData += 1;
          yield GetDataState();
        } else {
          yield ErrorState();
        }
      }
    }

    if (event is GetKeywordDataEvent) {
      if (selectKeywordType == 0) {
        if (keywordLearn!.keyword.length == keywordLearnNextData * 20) {
          yield CheckState();

          keywordLearn!.keyword.addAll(KeywordList.fromJson(
                  (await KeywordRepository.getKeywordAlarmList(
                          type: 'LEARN',
                          cursor: keywordLearn!.keyword.last.cursor))
                      .data)
              .keyword);

          keywordLearnNextData += 1;
          yield GetKeywordDataState();
        }
      } else {
        if (keywordTeach!.keyword.length == keywordTeachNextData * 20) {
          yield CheckState();

          keywordTeach!.keyword.addAll(KeywordList.fromJson(
                  (await KeywordRepository.getKeywordAlarmList(
                          type: 'TEACH',
                          cursor: keywordTeach!.keyword.last.cursor))
                      .data)
              .keyword);

          keywordTeachNextData += 1;
          yield GetKeywordDataState();
        }
      }
    }

    if (event is NotificationTypeChangeEvent) {
      type = event.type;
      if (type == 0) {
        NotificationRepository.readNotification().then((value) {
          flutterLocalNotificationsPlugin?.cancel(0);
          if (!dataSaver.nonMember) {
            dataSaver.myBaeitBloc!.add(UpdateDataEvent());
          }
        });
      } else if (type == 1) {
        KeywordRepository.keywordAlarmCountRead().then((value) {
          dataSaver.learnBloc!.add(GetKeywordCountEvent());
          if (!dataSaver.nonMember) {
            dataSaver.myBaeitBloc!.add(UpdateDataEvent());
          }
        });
      }
      yield NotificationTypeChangeState();
    }

    if (event is KeywordChangeTapEvent) {
      keywordSelectTap = event.index;
      yield KeywordChangeTapState();
    }

    if (event is DataLoadEvent) {
      yield DataLoadState();
    }

    if (event is SelectKeywordTypeEvent) {
      loading = true;
      yield (LoadingState());
      selectKeywordType = event.selectKeywordType;

      if (selectKeywordType == 0) {
        await KeywordRepository.putKeywordAlarmRead('LEARN')
            .then((value) async {
          keywordLearn = null;
          keywordLearn = KeywordList.fromJson(
              (await KeywordRepository.getKeywordAlarmList(type: 'LEARN'))
                  .data);
          keywordUnReadCount = 0;
          for (int i = 0; i < keywordLearn!.keyword.length; i++) {
            if (keywordLearn!.keyword[i].readFlag == 0) {
              keywordUnReadCount += 1;
            }
          }
          for (int i = 0; i < keywordTeach!.keyword.length; i++) {
            if (keywordTeach!.keyword[i].readFlag == 0) {
              keywordUnReadCount += 1;
            }
          }
          add(DataLoadEvent());
        });
      } else {
        await KeywordRepository.putKeywordAlarmRead('TEACH')
            .then((value) async {
          keywordTeach = KeywordList.fromJson(
              (await KeywordRepository.getKeywordAlarmList(type: 'TEACH'))
                  .data);
          keywordUnReadCount = 0;
          for (int i = 0; i < keywordLearn!.keyword.length; i++) {
            if (keywordLearn!.keyword[i].readFlag == 0) {
              keywordUnReadCount += 1;
            }
          }
          for (int i = 0; i < keywordTeach!.keyword.length; i++) {
            if (keywordTeach!.keyword[i].readFlag == 0) {
              keywordUnReadCount += 1;
            }
          }
          add(DataLoadEvent());
        });
      }

      loading = false;
      yield SelectKeywordTypeState();
    }
  }
}

class SelectKeywordTypeEvent extends BaseBlocEvent {
  final int selectKeywordType;

  SelectKeywordTypeEvent({required this.selectKeywordType});
}

class SelectKeywordTypeState extends BaseBlocState {}

class DataLoadEvent extends BaseBlocEvent {}

class DataLoadState extends BaseBlocState {}

class KeywordChangeTapEvent extends BaseBlocEvent {
  final int index;

  KeywordChangeTapEvent({required this.index});
}

class KeywordChangeTapState extends BaseBlocState {}

class NotificationTypeChangeEvent extends BaseBlocEvent {
  final int type;

  NotificationTypeChangeEvent({required this.type});
}

class NotificationTypeChangeState extends BaseBlocState {}

class GetDataEvent extends BaseBlocEvent {}

class GetDataState extends BaseBlocState {}

class GetKeywordDataEvent extends BaseBlocEvent {}

class GetKeywordDataState extends BaseBlocState {}

class NotificationInitEvent extends BaseBlocEvent {
  final int type;
  final int detailType;

  NotificationInitEvent({required this.type, required this.detailType});
}

class NotificationInitState extends BaseBlocState {}

class BaseNotificationState extends BaseBlocState {}
