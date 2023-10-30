import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:flutter/cupertino.dart';

class PermissionCheckBloc extends BaseBloc {
  PermissionCheckBloc(BuildContext context) : super(BasePermissionCheckState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is PermissionCheckInitEvent) {
      yield PermissionCheckInitState();
    }
  }
}

class PermissionCheckInitEvent extends BaseBlocEvent {}

class PermissionCheckInitState extends BaseBlocState {}

class BasePermissionCheckState extends BaseBlocState {}
