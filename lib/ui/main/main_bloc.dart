import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/ui/gather/gather_bloc.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';

class MainBloc extends BaseBloc {
  MainBloc(BuildContext context) : super(BaseMainState()) {
    on<MainInitEvent>(onMainInitEvent);
    on<MenuChangeEvent>(onMenuChangeEvent);
    on<PlusMenuChangeEvent>(onPlusMenuChangeEvent);
    on<MenuBarHideEvent>(onMenuBarHideEvent);
    on<StopEvent>(onStopEvent);
    on<ChatCountReloadEvent>(onChatCountReloadEvent);
    on<UiUpdateEvent>(onUiUpdateEvent);
    on<ShadowAndPlusTapChangeEvent>(onShadowAndPlusTapChangeEvent);
  }

  int selectMenu = 0;

  List<String> menuDeActiveIcon = [
    AppImages.iNavFindOff,
    AppImages.iNavAroundOff,
    AppImages.iNavCommunityOff,
    AppImages.iNavChatOff,
    AppImages.iNavMyOff
  ];

  List<String> menuActiveIcon = [
    AppImages.iNavFindOn,
    AppImages.iNavAroundOn,
    AppImages.iNavCommunityOn,
    AppImages.iNavChatOn,
    AppImages.iNavMyOn
  ];

  List<String> menuName = ['클래스', '모아보기', '커뮤니티', '채팅', '나의배잇'];

  List<AnimationController> animationControllers = [];
  List<Animation> animations = [];

  bool plus = false;

  bool menuBarHide = false;
  bool classMadeCheck = true;

  bool closePlusMenu = true;

  bool shadowAndPlusTapView = true;

  AnimationController? plusAnimationController;

  bool balloonShow = false;

  onPlusMenuChangeEvent(PlusMenuChangeEvent event, emit) {
    plus = !plus;
    if (plus && dataSaver.learnBloc!.learnType == 1) {
      dataSaver.learnBloc!.communityPanelController.open();
    } else  if (dataSaver.learnBloc!.learnType == 1) {
      closePlusMenu = !closePlusMenu;
      dataSaver.learnBloc!.communityPanelController.close();
    }
    emit(PlusMenuChangeState());
  }

  onMenuChangeEvent(MenuChangeEvent event, emit) {
    selectMenu = event.select;
    if (selectMenu == 0) {
      dataSaver.learnBloc!.add(LearnTypeChangeEvent(type: 0));
    } else if (selectMenu == 1) {
      dataSaver.learnBloc!.add(LearnTypeChangeEvent(type: 2));
      if (dataSaver.gatherBloc != null)
        dataSaver.gatherBloc!.add(BookmarkReloadEvent());
    } else if (selectMenu == 2) {
      dataSaver.learnBloc!.add(LearnTypeChangeEvent(type: 1));
    }
    dataSaver.learnBloc!.add(ChangeViewEvent());
    emit(MenuChangeState());
  }

  onMainInitEvent(MainInitEvent event, emit) {
    if (!dataSaver.nonMember) {
      ClassRepository.madeClassCheck().then((value) {
        classMadeCheck = value.data;
      });
    }

    emit(MainInitState());
  }

  onMenuBarHideEvent(MenuBarHideEvent event, emit) {
    menuBarHide = event.hide;
    emit(MenuBarHideState());
  }

  onStopEvent(StopEvent event, emit) {
    emit(StopState(stopText: event.stopText));
  }

  onChatCountReloadEvent(ChatCountReloadEvent event, emit) {
    emit(ChatCountReloadState());
  }

  onUiUpdateEvent(UiUpdateEvent event, emit) {
    if (!dataSaver.nonMember) {
      ClassRepository.madeClassCheck().then((value) {
        classMadeCheck = value.data;
      });
    }
    emit(UiUpdateState());
  }

  onShadowAndPlusTapChangeEvent(ShadowAndPlusTapChangeEvent event, emit) {
    shadowAndPlusTapView = !shadowAndPlusTapView;
    emit(ShadowAndPlusTapChangeState());
  }
}

class ShadowAndPlusTapChangeEvent extends BaseBlocEvent {}

class ShadowAndPlusTapChangeState extends BaseBlocState {}

class UiUpdateEvent extends BaseBlocEvent {}

class UiUpdateState extends BaseBlocState {}

class StopEvent extends BaseBlocEvent {
  final String? stopText;

  StopEvent({this.stopText});
}

class StopState extends BaseBlocState {
  final String? stopText;

  StopState({this.stopText});
}

class ChatCountReloadEvent extends BaseBlocEvent {}

class ChatCountReloadState extends BaseBlocState {}

class MenuBarHideEvent extends BaseBlocEvent {
  final bool hide;

  MenuBarHideEvent({required this.hide});
}

class MenuBarHideState extends BaseBlocState {}

class PlusMenuChangeEvent extends BaseBlocEvent {}

class PlusMenuChangeState extends BaseBlocState {}

class MenuChangeEvent extends BaseBlocEvent {
  final int select;

  MenuChangeEvent({required this.select});
}

class MenuChangeState extends BaseBlocState {}

class MainInitEvent extends BaseBlocEvent {
  final dynamic animationVsync;

  MainInitEvent({required this.animationVsync});
}

class MainInitState extends BaseBlocState {}

class BaseMainState extends BaseBlocState {}
