import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/repository/community_repository.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';

class ProfileDialogBloc extends BaseBloc {
  ProfileDialogBloc(BuildContext context) : super(BaseProfileDialogState()) {
    on<ProfileDialogInitEvent>(onProfileDialogInitEvent);
    on<NewMemberClassDataEvent>(onNewMemberClassDataEvent);
    on<ViewTapChangeEvent>(onViewTapChangeEvent);
    on<UserBlockEvent>(onUserBlockEvent);
  }

  bool loading = false;
  String? memberUuid;

  int viewTap = 0;

  ClassList? classList;
  CommunityList? communityList;

  ProfileGet? profileGet;

  bool moreView = false;

  // Class
  double bottomOffset = 0;
  bool scrollUnder = false;

  bool scrollUp = true;
  bool scrollEnd = false;

  bool startScroll = false;
  bool upDownCheck = false;
  double startPixels = 0;

  int nextData = 1;

  //

  // Community
  int communityOrderType = 0;

  double communityBottomOffset = 0;
  bool communityScrollUnder = false;

  bool communityScrollUp = true;
  bool communityScrollEnd = false;

  bool communityStartScroll = false;
  bool communityUpDownCheck = false;
  double communityStartPixels = 0;

  int communityNextData = 1;

  //

  onViewTapChangeEvent(ViewTapChangeEvent event, emit) async {
    viewTap = event.index;
    emit(ViewTapChangeState());
  }

  onNewMemberClassDataEvent(NewMemberClassDataEvent event, emit) async {
    if (viewTap == 0) {
      if (classList!.classData.length == nextData * 20 &&
          !scrollUnder &&
          dataSaver.lastNextCursor != classList!.classData.last.cursor) {
        scrollUnder = true;
        emit(CheckState());

        dataSaver.lastNextCursor = classList!.classData.last.cursor!;

        ReturnData returnData = await ClassRepository.getMemberClass(
            memberUuid: memberUuid!,
            type: 'MADE',
            nextCursor: classList!.classData.last.cursor);

        if (returnData.code == 1) {
          classList!.classData
              .addAll(ClassList.fromJson(returnData.data).classData);

          nextData += 1;
          scrollUnder = false;
          emit(NewMemberClassDataState());
        }
      }
    } else {
      if (communityList!.communityData.length == communityNextData * 20 &&
          !communityScrollUnder &&
          dataSaver.lastNextCursor !=
              communityList!.communityData.last.cursor) {
        communityScrollUnder = true;
        emit(CheckState());

        dataSaver.lastNextCursor = communityList!.communityData.last.cursor;

        ReturnData returnData = await CommunityRepository.getCommunityMember(
            memberUuid: memberUuid!,
            nextCursor: communityList!.communityData.last.cursor);

        if (returnData.code == 1) {
          communityList!.communityData
              .addAll(CommunityList.fromJson(returnData.data).communityData);

          communityNextData += 1;
          communityScrollUnder = false;
          emit(NewMemberClassDataState());
        }
      }
    }
  }

  onProfileDialogInitEvent(ProfileDialogInitEvent event, emit) async {
    memberUuid = event.memberUuid;
    loading = true;
    emit(LoadingState());

    ReturnData value =
        await ProfileRepository.getProfileOther(memberUuid: event.memberUuid);
    profileGet = ProfileGet.fromJson(value.data);

    ReturnData classData = await ClassRepository.getMemberClass(
        memberUuid: memberUuid!, type: 'MADE');
    classList = ClassList.fromJson(classData.data);

    ReturnData communityData =
        await CommunityRepository.getCommunityMember(memberUuid: memberUuid!);
    communityList = CommunityList.fromJson(communityData.data);

    loading = false;
    emit(ProfileDialogInitState());
  }

  onUserBlockEvent(UserBlockEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    await CommonRepository.memberBlock(memberUuid: event.memberUuid);

    loading = false;
    moreView = false;
    emit(UserBlockState());
  }
}

class UserBlockEvent extends BaseBlocEvent {
  final String memberUuid;

  UserBlockEvent({required this.memberUuid});
}

class UserBlockState extends BaseBlocState {}

class ViewTapChangeEvent extends BaseBlocEvent {
  final int index;

  ViewTapChangeEvent({required this.index});
}

class ViewTapChangeState extends BaseBlocState {}

class NewMemberClassDataEvent extends BaseBlocEvent {}

class NewMemberClassDataState extends BaseBlocState {}

class ProfileDialogInitEvent extends BaseBlocEvent {
  final String memberUuid;

  ProfileDialogInitEvent({required this.memberUuid});
}

class ProfileDialogInitState extends BaseBlocState {}

class BaseProfileDialogState extends BaseBlocState {}
