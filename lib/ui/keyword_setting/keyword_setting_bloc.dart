import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/keyword/keyword.dart';
import 'package:baeit/data/keyword/repository/keyword_repository.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/widgets.dart';
import 'package:notification_permissions/notification_permissions.dart';

class KeywordSettingBloc extends BaseBloc {
  KeywordSettingBloc(BuildContext context) : super(BaseKeywordSettingState()) {
    on<KeywordSettingInitEvent>(onKeywordSettingInitEvent);
    on<KeywordAddEvent>(onKeywordAddEvent);
    on<KeywordRemoveEvent>(onKeywordRemoveEvent);
    on<KeywordNotificationChangeEvent>(onKeywordNotificationChangeEvent);
    on<KeywordLoadEvent>(onKeywordLoadEvent);
    on<KeywordSetEvent>(onKeywordSetEvent);
  }

  List<TextEditingController> keywordControllerMade =
      List.generate(10, (index) => TextEditingController());
  bool loading = false;

  List<String> uuidMade = List.generate(10, (index) => '');

  Future<PermissionStatus> permission =
      NotificationPermissions.getNotificationPermissionStatus();
  String permissionStatus = '';

  onKeywordNotificationChangeEvent(KeywordNotificationChangeEvent event, emit) {
    KeywordRepository.keywordAlarmNotiChange(
        alarmFlag: event.alarmFlag,
        memberAreaUuid: event.memberAreaUuid,
        type: event.type);
    if (event.type == 'MADE') {
      dataSaver.classKeywordNotification!.areas[event.index].alarmFlag =
          event.alarmFlag;
    } else {}
    emit(KeywordNotificationChangeState());
  }

  onKeywordRemoveEvent(KeywordRemoveEvent event, emit) async {
    await KeywordRepository.removeKeywordAlarm(
        memberClassKeywordUuid: event.memberClassKeywordUuid);
    String keywordText = '';
    String areas = '';
    if (event.type == 'MADE') {
      if (dataSaver.classKeywordNotification!.keywords.indexWhere((element) =>
              element.memberClassKeywordUuid == event.memberClassKeywordUuid) !=
          -1) {
        dataSaver.classKeywordNotification!.keywords.removeAt(
            dataSaver.classKeywordNotification!.keywords.indexWhere((element) =>
                element.memberClassKeywordUuid ==
                event.memberClassKeywordUuid));
      }
      for (int i = 0;
          i < dataSaver.classKeywordNotification!.keywords.length;
          i++) {
        keywordText +=
            dataSaver.classKeywordNotification!.keywords[i].keywordText + ",";
      }
      for (int i = 0;
          i < dataSaver.classKeywordNotification!.areas.length;
          i++) {
        areas +=
            dataSaver.classKeywordNotification!.areas[i].eupmyeondongName + ",";
      }
      amplitudeEvent('keyword_set_completed', {
        'type': 'class',
        'keyword': keywordText,
        'action': 'delete',
        'class_town': areas
      });
    } else {}
    emit(KeywordRemoveState());
  }

  onKeywordAddEvent(KeywordAddEvent event, emit) async {
    await KeywordRepository.addKeywordAlarm(
        keywordText: event.keyword, type: event.type);
    var res = await KeywordRepository.getKeywordAlarm(type: event.type);
    String keywordText = '';
    String areas = '';
    if (event.type == 'MADE') {
      dataSaver.classKeywordNotification = Keyword.fromJson(res.data);
      uuidMade[event.idx] = dataSaver
          .classKeywordNotification!.keywords.last.memberClassKeywordUuid;

      for (int i = 0;
          i < dataSaver.classKeywordNotification!.keywords.length;
          i++) {
        keywordText +=
            dataSaver.classKeywordNotification!.keywords[i].keywordText + ",";
      }
      for (int i = 0;
          i < dataSaver.classKeywordNotification!.areas.length;
          i++) {
        areas +=
            dataSaver.classKeywordNotification!.areas[i].eupmyeondongName + ",";
      }
      amplitudeEvent('keyword_set_completed', {
        'type': 'class',
        'keyword': keywordText,
        'action': 'add',
        'class_town': areas
      });
    } else {}

    emit(KeywordAddState());
  }

  onKeywordSettingInitEvent(KeywordSettingInitEvent event, emit) async {
    loading = true;
    emit(LoadingState());
    await permission.then((value) {
      permissionStatus = value.toString();
    });

    await KeywordRepository.getKeywordAlarm(type: 'MADE').then((value) {
      dataSaver.classKeywordNotification = null;
      dataSaver.classKeywordNotification = Keyword.fromJson(value.data);
      for (int i = 0;
          i < dataSaver.classKeywordNotification!.keywords.length;
          i++) {
        uuidMade[i] = dataSaver
            .classKeywordNotification!.keywords[i].memberClassKeywordUuid;
        keywordControllerMade[i].text =
            dataSaver.classKeywordNotification!.keywords[i].keywordText;
      }
      add(KeywordLoadEvent(type: 'MADE'));
    });

    loading = false;
    emit(KeywordSettingInitState());
  }

  onKeywordLoadEvent(KeywordLoadEvent event, emit) {
    emit(KeywordLoadState(type: event.type));
  }

  onKeywordSetEvent(KeywordSetEvent event, emit) {
    emit(KeywordSetState());
  }
}

class KeywordSetEvent extends BaseBlocEvent {}

class KeywordSetState extends BaseBlocState {}

class KeywordLoadEvent extends BaseBlocEvent {
  final String type;

  KeywordLoadEvent({required this.type});
}

class KeywordLoadState extends BaseBlocState {
  final String type;

  KeywordLoadState({required this.type});
}

class KeywordNotificationChangeEvent extends BaseBlocEvent {
  final int index;
  final String memberAreaUuid;
  final String type;
  final int alarmFlag;

  KeywordNotificationChangeEvent(
      {required this.index,
      required this.memberAreaUuid,
      required this.type,
      required this.alarmFlag});
}

class KeywordNotificationChangeState extends BaseBlocState {}

class KeywordRemoveEvent extends BaseBlocEvent {
  final String memberClassKeywordUuid;
  final int index;
  final String type;

  KeywordRemoveEvent(
      {required this.memberClassKeywordUuid,
      required this.index,
      required this.type});
}

class KeywordRemoveState extends BaseBlocState {}

class KeywordAddEvent extends BaseBlocEvent {
  final String type;
  final String keyword;
  final int idx;

  KeywordAddEvent(
      {required this.type, required this.keyword, required this.idx});
}

class KeywordAddState extends BaseBlocState {}

class KeywordSettingInitEvent extends BaseBlocEvent {
  final bool first;

  KeywordSettingInitEvent({this.first = true});
}

class KeywordSettingInitState extends BaseBlocState {}

class BaseKeywordSettingState extends BaseBlocState {}
