import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/widgets.dart';

class MainNavigationBloc extends BaseBloc {
  MainNavigationBloc(BuildContext context) : super(BaseMainNavigationState());

  int viewIndex = 0;
  bool bottomView = true;

  int sliderSelectValue = 0;

  bool setView = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    yield CheckState();
    if (event is MainNavigationInitEvent) {
      if (event.viewIndex != null) {
        viewIndex = event.viewIndex!;
      }
      yield MainNavigationInitState();
    }

    if (event is ChangeViewEvent) {
      viewIndex = event.viewIndex!;
      if (viewIndex != 2) {
        dataSaver.chatBloc = null;
      }
      yield ChangeViewState();
    }

    if (event is BottomEvent) {
      bottomView = event.view!;
      yield BottomState();
    }

    if (event is SaveAppBarDataEvent) {
      sliderSelectValue = event.sliderSelectValue;
    }

    if (event is NeighborHoodSaveEvent) {
      dataSaver.neighborHood = event.neighborHood;
      await identifyInit();
    }

    if (event is ChatCountReloadEvent) {
      yield ChatCountReloadState();
    }

    if (event is StopEvent) {
      yield StopState(stopText: event.stopText);
    }
  }
}

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

class NeighborHoodSaveEvent extends BaseBlocEvent {
  final List<NeighborHood> neighborHood;

  NeighborHoodSaveEvent({required this.neighborHood});
}

class SaveAppBarDataEvent extends BaseBlocEvent {
  final int sliderSelectValue;

  SaveAppBarDataEvent({required this.sliderSelectValue});
}

class SaveAppBarDataState extends BaseBlocState {}

class BottomEvent extends BaseBlocEvent {
  final bool? view;

  BottomEvent({this.view});
}

class BottomState extends BaseBlocState {}

class ChangeViewEvent extends BaseBlocEvent {
  final int? viewIndex;

  ChangeViewEvent({this.viewIndex});
}

class ChangeViewState extends BaseBlocState {}

class MainNavigationInitEvent extends BaseBlocEvent {
  final List<NeighborHood>? neighborHood;
  final int? viewIndex;

  MainNavigationInitEvent({this.neighborHood, this.viewIndex});
}

class MainNavigationInitState extends BaseBlocState {}

class BaseMainNavigationState extends BaseBlocState {}
