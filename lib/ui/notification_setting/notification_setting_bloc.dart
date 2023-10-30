import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/notification/repository/notification_repository.dart';
import 'package:baeit/data/notification/setting.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/widgets.dart';
import 'package:notification_permissions/notification_permissions.dart';

class NotificationSettingBloc extends BaseBloc {
  NotificationSettingBloc(BuildContext context)
      : super(BaseNotificationSettingState());

  bool loading = false;
  Setting? setting;
  bool marketing = false;
  bool chatting = false;
  bool prohibit = false;
  bool keywordClass = false;
  bool keywordRequest = false;
  bool communityComment = false;
  Future<PermissionStatus> permission =
      NotificationPermissions.getNotificationPermissionStatus();
  String permissionStatus = '';

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is NotificationSettingInitEvent) {
      loading = true;
      yield LoadingState();
      await permission.then((value) {
        permissionStatus = value.toString();
        if (permissionStatus != 'PermissionStatus.granted') {
          identifyAdd('push_ios_allowed', false);
        } else {
          identifyAdd('push_ios_allowed', true);
        }
      });

      ReturnData returnData = await NotificationRepository.getSetting();
      if (returnData.code == 1) {
        setting = Setting.fromJson(returnData.data);

        marketing = setting!.marketingReceptionFlag == 1 ? true : false;
        chatting = setting!.chattingFlag == 1 ? true : false;
        prohibit = setting!.prohibitFlag == 1 ? true : false;
        keywordClass = setting!.classMadeKeywordAlarmFlag == 1 ? true : false;
        keywordRequest =
            setting!.classRequestKeywordAlarmFlag == 1 ? true : false;
        communityComment =
            setting!.communityCommentAlarmFlag == 1 ? true : false;

        loading = false;
        yield NotificationSettingInitState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is ChangeSettingEvent) {
      loading = true;
      yield LoadingState();

      ReturnData updateSetting = await NotificationRepository.updateSetting(
          chattingFlag: chatting ? 1 : 0,
          marketingReceptionFlag: marketing ? 1 : 0,
          prohibitFlag: prohibit ? 1 : 0,
          classMadeKeywordAlarmFlag: keywordClass ? 1 : 0,
          classRequestKeywordAlarmFlag: keywordRequest ? 1 : 0,
          communityCommentAlarmFlag: communityComment ? 1 : 0);

      if (updateSetting.code == 1) {
        ReturnData returnData = await NotificationRepository.getSetting();
        if (returnData.code == 1) {
          setting = null;
          setting = Setting.fromJson(returnData.data);

          marketing = setting!.marketingReceptionFlag == 1 ? true : false;
          chatting = setting!.chattingFlag == 1 ? true : false;
          prohibit = setting!.prohibitFlag == 1 ? true : false;
          keywordClass = setting!.classMadeKeywordAlarmFlag == 1 ? true : false;
          keywordRequest =
              setting!.classRequestKeywordAlarmFlag == 1 ? true : false;
          communityComment =
              setting!.communityCommentAlarmFlag == 1 ? true : false;

          loading = false;
          yield ChangeSettingState();
        } else {
          loading = false;
          yield ErrorState();
        }
      } else {
        loading = false;
        yield ErrorState();
      }
    }
  }
}

class ChangeSettingEvent extends BaseBlocEvent {}

class ChangeSettingState extends BaseBlocState {}

class NotificationSettingInitEvent extends BaseBlocEvent {}

class NotificationSettingInitState extends BaseBlocState {}

class BaseNotificationSettingState extends BaseBlocState {}
