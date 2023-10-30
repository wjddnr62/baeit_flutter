import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/repository/community_repository.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:flutter/widgets.dart';

class MyCreateCommunityBloc extends BaseBloc {
  MyCreateCommunityBloc(BuildContext context)
      : super(BaseMyCreateCommunityState()) {
    on<MyCreateCommunityInitEvent>(onMyCreateCommunityInitEvent);
    on<StatusChangeEvent>(onStatusChangeEvent);
    on<ShareEvent>(onShareEvent);
    on<ScrollEvent>(onScrollEvent);
    on<ScrollEndEvent>(onScrollEndEvent);
  }

  bool loading = false;
  CommunityList? communityList;
  int selectTab = 0;

  bool scrollUp = true;
  bool scrollEnd = false;
  bool floatingAnimationEnd = true;
  bool startScroll = false;
  bool upDownCheck = false;
  double startPixels = 0;
  double bottomOffset = 0;
  bool scrollUnder = false;
  int nextData = 1;

  onMyCreateCommunityInitEvent(MyCreateCommunityInitEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    ReturnData res = await CommunityRepository.getCommunityMine();
    communityList = null;
    communityList = CommunityList.fromJson(res.data);

    loading = false;
    emit(MyCreateCommunityInitState());
  }

  onStatusChangeEvent(StatusChangeEvent event, emit) async {
    loading = true;
    emit(LoadingState());
    if (event.idx != null) {
      selectTab = event.idx!;
    }

    if (selectTab == 0) {
      ReturnData res = await CommunityRepository.getCommunityMine();
      communityList = null;
      communityList = CommunityList.fromJson(res.data);
    } else {
      ReturnData res = await CommunityRepository.getCommunityMine(
          status: myCreateCommunityStatusIdxType(selectTab));
      communityList = null;
      communityList = CommunityList.fromJson(res.data);
    }

    loading = false;
    emit(StatusChangeState());
  }

  onShareEvent(ShareEvent event, emit) async {
    ReturnData shareRes = await CommunityRepository.getCommunityShareLink(
        communityUuid: event.communityUuid);
    emit(ShareState(shareText: shareRes.data));
  }

  onScrollEvent(ScrollEvent event, emit) {
    scrollUp = event.scroll!;
    emit(ScrollState());
  }

  onScrollEndEvent(ScrollEndEvent event, emit) {
    scrollEnd = true;
    emit(ScrollEndState());
  }

  onGetDataEvent(GetDataEvent event, emit) async {
    if (communityList!.communityData.length == nextData * 20 && !scrollUnder) {
      scrollUnder = false;
      emit(CheckState());

      ReturnData res = await CommunityRepository.getCommunityMine(
          status: myCreateCommunityStatusIdxType(selectTab),
          nextCursor: communityList!.communityData.last.cursor);

      if (res.code == 1) {
        communityList!.communityData
            .addAll(CommunityList.fromJson(res.data).communityData);

        nextData += 1;
        scrollUnder = false;
        emit(GetDataState());
      } else {
        emit(ErrorState());
      }
    }
    emit(GetDataState());
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

class ShareEvent extends BaseBlocEvent {
  final String communityUuid;

  ShareEvent({required this.communityUuid});
}

class ShareState extends BaseBlocState {
  final String shareText;

  ShareState({required this.shareText});
}

class StatusChangeEvent extends BaseBlocEvent {
  final int? idx;

  StatusChangeEvent({this.idx});
}

class StatusChangeState extends BaseBlocState {}

class MyCreateCommunityInitEvent extends BaseBlocEvent {}

class MyCreateCommunityInitState extends BaseBlocState {}

class BaseMyCreateCommunityState extends BaseBlocState {}
