import 'dart:async';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/chat/repository/chat_repository.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/review/repository/review_repository.dart';
import 'package:baeit/data/review/review.dart';
import 'package:baeit/ui/gather/gather_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';

class ClassDetailBloc extends BaseBloc {
  ClassDetailBloc(BuildContext context) : super(BaseClassDetailState());

  bool isLoading = false;

  Class? classDetail;

  bool selectClass = true;
  bool selectTeacher = false;

  int topImageIdx = 0;

  bool selectMore = false;
  int chatBlock = 2;

  bool moreEnd = false;

  bool heartAnimation = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is ClassDetailInitEvent) {
      isLoading = true;
      yield LoadingState();

      if (!dataSaver.nonMember) {
        ReturnData chatBlockData =
            await ChatRepository.classBlockCheck(event.classUuid);

        if (chatBlockData != null) {
          if (chatBlockData.code == 1) {
            chatBlock = chatBlockData.data;
          }
        }
      }

      ReturnData returnData = await ClassRepository.getClassDetail(
          event.classUuid,
          event.mainNeighborHood.lati!,
          event.mainNeighborHood.longi!);

      if (returnData.code == 1) {
        classDetail = null;
        classDetail = Class.fromJson(returnData.data);
        isLoading = false;
        yield ClassDetailInitState();
      } else {
        isLoading = false;
        yield ErrorState();
      }
    }

    if (event is ClassIntroduceSelectEvent) {
      selectClass = true;
      selectTeacher = false;
      yield ClassIntroduceSelectState();
    }

    if (event is TeacherIntroduceSelectEvent) {
      selectClass = false;
      selectTeacher = true;
      yield TeacherIntroduceSelectState();
    }

    if (event is TopImageChangeEvent) {
      topImageIdx = event.idx;
      yield TopImageChangeState();
    }

    if (event is BookmarkChangeEvent) {
      if (event.flag == 0) {
        classDetail!.likeFlag = 1;
        classDetail!.likeCnt = classDetail!.likeCnt + 1;
        dataSaver.gatherBloc!.add(
            BookmarkClassHideEvent(classUuid: classDetail!.classUuid, flag: 1));
        if (production == 'prod-release' && kReleaseMode) {
          await facebookAppEvents.logAddToCart(
              id: classDetail!.classUuid,
              type: classDetail!.content.title!,
              currency: dataSaver.abTest ?? 'KRW',
              price: 1);
        }
      } else {
        classDetail!.likeFlag = 0;
        classDetail!.likeCnt = classDetail!.likeCnt - 1;
        dataSaver.gatherBloc!.add(
            BookmarkClassHideEvent(classUuid: classDetail!.classUuid, flag: 0));
      }
      await ClassRepository.bookmarkClass(classDetail!.classUuid);
      dataSaver.gatherBloc!.add(BookmarkReloadEvent());
      yield BookmarkChangeState();
    }

    if (event is SelectMoreEvent) {
      selectMore = event.select;
      yield SelectMoreState();
    }

    if (event is DeadLineChangeEvent) {
      isLoading = true;
      yield LoadingState();

      ReturnData deadLineRes = await ClassRepository.updateClassStatus(
          classDetail!.classUuid, event.status);

      if (deadLineRes.code == 1) {
        classDetail!.status = event.status;

        isLoading = false;
        yield DeadLineChangeState();
      } else {
        isLoading = false;
        yield ErrorState();
      }
    }

    if (event is RequestChangeEvent) {
      isLoading = true;
      yield LoadingState();

      ReturnData requestRes = await ClassRepository.updateClassStatus(
          classDetail!.classUuid, event.status);

      if (requestRes.code == 1) {
        classDetail!.status = event.status;

        isLoading = false;
        yield DeadLineChangeState();
      } else {
        isLoading = false;
        yield ErrorState();
      }
    }

    if (event is RemoveRequestEvent) {
      isLoading = true;
      yield LoadingState();

      ReturnData requestRes = await ClassRepository.updateClassStatus(
          classDetail!.classUuid, event.status);

      if (requestRes.code == 1) {
        classDetail!.status = event.status;

        isLoading = false;
        yield RemoveRequestState();
      } else {
        isLoading = false;
        yield ErrorState();
      }
    }

    if (event is ClassBlockReCheckEvent) {
      isLoading = true;
      yield LoadingState();

      if (!dataSaver.nonMember) {
        ReturnData chatBlockData =
            await ChatRepository.classBlockCheck(classDetail!.classUuid);
        if (chatBlockData.code == 1) {
          if (chatBlockData.data != null) {
            chatBlock = chatBlockData.data;
          }
        }
      }

      isLoading = false;
      yield ClassBlockReCheckState();
    }
  }
}

class ClassBlockReCheckEvent extends BaseBlocEvent {}

class ClassBlockReCheckState extends BaseBlocState {}

class RemoveRequestEvent extends BaseBlocEvent {
  final String status;

  RemoveRequestEvent({this.status = 'DELETE'});
}

class RemoveRequestState extends BaseBlocState {}

class DeadLineChangeEvent extends BaseBlocEvent {
  final String status;

  DeadLineChangeEvent({this.status = 'STOP'});
}

class DeadLineChangeState extends BaseBlocState {}

class RequestChangeEvent extends BaseBlocEvent {
  final String status;

  RequestChangeEvent({this.status = 'NORMAL'});
}

class RequestChangeState extends BaseBlocState {}

class SelectMoreEvent extends BaseBlocEvent {
  final bool select;

  SelectMoreEvent({required this.select});
}

class SelectMoreState extends BaseBlocState {}

class BookmarkChangeEvent extends BaseBlocEvent {
  final int flag;

  BookmarkChangeEvent({required this.flag});
}

class BookmarkChangeState extends BaseBlocState {}

class TopImageChangeEvent extends BaseBlocEvent {
  final int idx;

  TopImageChangeEvent({required this.idx});
}

class TopImageChangeState extends BaseBlocState {}

class ClassIntroduceSelectEvent extends BaseBlocEvent {}

class ClassIntroduceSelectState extends BaseBlocState {}

class TeacherIntroduceSelectEvent extends BaseBlocEvent {}

class TeacherIntroduceSelectState extends BaseBlocState {}

class ClassDetailInitEvent extends BaseBlocEvent {
  final NeighborHood mainNeighborHood;
  final String classUuid;

  ClassDetailInitEvent(
      {required this.mainNeighborHood, required this.classUuid});
}

class ClassDetailInitState extends BaseBlocState {}

class BaseClassDetailState extends BaseBlocState {}
