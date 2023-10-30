import 'package:baeit/config/base_bloc.dart';
import 'package:flutter/widgets.dart';

class ImageViewBloc extends BaseBloc {
  ImageViewBloc(BuildContext context) : super(BaseImageViewState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is ImageViewInitEvent) {
      yield ImageViewInitState();
    }
  }
}

class ImageViewInitEvent extends BaseBlocEvent {}

class ImageViewInitState extends BaseBlocState {}

class BaseImageViewState extends BaseBlocState {}
