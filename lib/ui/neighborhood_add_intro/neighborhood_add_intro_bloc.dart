import 'package:baeit/config/base_bloc.dart';
import 'package:flutter/widgets.dart';

class NeighborHoodAddIntroBloc extends BaseBloc {
  NeighborHoodAddIntroBloc(BuildContext context)
      : super(BaseNeighborHoodAddIntroState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is NeighborHoodAddIntroInitEvent) {
      yield NeighborHoodAddIntroInitState();
    }
  }
}

class NeighborHoodAddIntroInitEvent extends BaseBlocEvent {}

class NeighborHoodAddIntroInitState extends BaseBlocState {}

class BaseNeighborHoodAddIntroState extends BaseBlocState {}
