import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';

class MyCreateClassBloc extends BaseBloc {
  MyCreateClassBloc(BuildContext context) : super(BaseMyCreateClassState());

  bool loading = false;
  int selectTap = 0;
  ClassList? classList;
  late NeighborHood mainNeighborHood;
  bool classMadeCheck = true;
  bool scrollUp = true;
  bool scrollEnd = false;
  bool floatingAnimationEnd = true;
  bool startScroll = false;
  bool upDownCheck = false;
  double startPixels = 0;
  double bottomOffset = 0;
  bool scrollUnder = false;
  int nextData = 1;

  statusSet(int select) {
    switch (select) {
      case 0:
        return null;
      case 1:
        return 'NORMAL';
      case 2:
        return 'TEMP';
      case 3:
        return 'STOP';
    }
  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is MyCreateClassInitEvent) {
      loading = true;
      yield LoadingState();

      if (event.selectTap != null) {
        selectTap = event.selectTap!;
      }

      mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
          .indexWhere((element) => element.representativeFlag == 1)];

      ReturnData returnData = await ClassRepository.getMineClassList(
          type: 'MADE', status: statusSet(selectTap));

      if (returnData.code == 1) {
        classList = ClassList.fromJson(returnData.data);

        ReturnData mineClassRes = await ClassRepository.madeClassCheck();

        classMadeCheck = mineClassRes.data;

        loading = false;
        yield MyCreateClassInitState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is MyCreateTapChangeEvent) {
      selectTap = event.tap;
      loading = true;
      yield LoadingState();
      nextData = 1;

      ReturnData returnData = await ClassRepository.getMineClassList(
          type: 'MADE', status: statusSet(selectTap));

      if (returnData.code == 1) {
        classList = null;
        classList = ClassList.fromJson(returnData.data);
        loading = false;
        yield MyCreateTapChangeState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is MyCreateReloadEvent) {
      loading = true;
      yield LoadingState();
      nextData = 1;

      ReturnData returnData = await ClassRepository.getMineClassList(
          type: 'MADE', status: statusSet(selectTap));

      if (returnData.code == 1) {
        classList = null;

        classList = ClassList.fromJson(returnData.data);
        ReturnData mineClassRes = await ClassRepository.madeClassCheck();

        classMadeCheck = mineClassRes.data;

        loading = false;
        yield MyCreateReloadState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is ScrollEvent) {
      scrollUp = event.scroll!;
      yield ScrollState();
    }

    if (event is ScrollEndEvent) {
      scrollEnd = true;
      yield ScrollEndState();
    }

    if (event is GetDataEvent) {
      if (classList!.classData.length == nextData * 20 && !scrollUnder) {
        scrollUnder = true;
        yield CheckState();

        ReturnData returnData = await ClassRepository.getMineClassList(
            type: 'MADE',
            status: statusSet(selectTap),
            nextCursor: classList!.classData.last.cursor);

        if (returnData.code == 1) {
          classList!.classData
              .addAll(ClassList.fromJson(returnData.data).classData);

          nextData += 1;
          scrollUnder = false;
          yield GetDataState();
        } else {
          yield ErrorState();
        }
      }
    }
  }
}

class GetDataEvent extends BaseBlocEvent {}

class GetDataState extends BaseBlocState {}

class ScrollEndEvent extends BaseBlocEvent {}

class ScrollEndState extends BaseBlocState {}

class ScrollEvent extends BaseBlocEvent {
  final bool? scroll;

  ScrollEvent({this.scroll});
}

class ScrollState extends BaseBlocState {}

class MyCreateReloadEvent extends BaseBlocEvent {}

class MyCreateReloadState extends BaseBlocState {}

class MyCreateTapChangeEvent extends BaseBlocEvent {
  final int tap;

  MyCreateTapChangeEvent({required this.tap});
}

class MyCreateTapChangeState extends BaseBlocState {}

class MyCreateClassInitEvent extends BaseBlocEvent {
  final int? selectTap;

  MyCreateClassInitEvent({this.selectTap});
}

class MyCreateClassInitState extends BaseBlocState {}

class BaseMyCreateClassState extends BaseBlocState {}
