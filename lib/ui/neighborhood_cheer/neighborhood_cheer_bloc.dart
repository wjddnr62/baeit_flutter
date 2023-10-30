import 'dart:async';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/cheer/repository/cheer_repository.dart';
import 'package:flutter/widgets.dart';

class NeighborHoodCheerBloc extends BaseBloc {
  NeighborHoodCheerBloc(BuildContext context)
      : super(BaseNeighborHoodCheerState());

  bool loading = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is NeighborHoodInitEvent) {
      yield NeighborHoodInitState();
    }

    if (event is SaveCheerContentEvent) {
      if (event.text!.length == 0) {
        yield SaveCheerContentState();
      } else {
        loading = true;
        yield LoadingState();

        await CheerRepository.cheeringMsg(event.uuid, event.text!);

        loading = false;
        yield SaveCheerContentState();
      }
    }
  }
}

class SaveCheerContentEvent extends BaseBlocEvent {
  final String uuid;
  final String? text;

  SaveCheerContentEvent({required this.uuid, this.text});
}

class SaveCheerContentState extends BaseBlocState {}

class NeighborHoodInitEvent extends BaseBlocEvent {}

class NeighborHoodInitState extends BaseBlocState {}

class BaseNeighborHoodCheerState extends BaseBlocState {}
