import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/repository/community_repository.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/ui/gather/gather_bloc.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';

class RecentOrBookmarkBloc extends BaseBloc {
  RecentOrBookmarkBloc(BuildContext context)
      : super(BaseRecentOrBookmarkState());

  bool loading = false;
  int selectTap = 0;

  ClassList? classList;
  CommunityList? communityList;
  String type = '';

  List<bool> bookmarkChecks = [];
  List<bool> heartAnimation = [];

  dynamic vsync;

  NeighborHood? mainNeighborHood;

  double bottomOffset = 0;
  bool scrollUnder = false;

  double communityBottomOffset = 0;
  bool communityScrollUnder = false;

  int nextData = 1;
  int communityNextData = 1;

  String communityNextCursor = '';

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is RecentOrBookmarkInitEvent) {
      loading = true;
      yield LoadingState();

      type = event.type;

      mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
          .indexWhere((element) => element.representativeFlag == 1)];
      vsync = event.animationVsync;

      if (type == 'RECENT') {
        ReturnData res = await ClassRepository.getClassViewList(
            type: selectTap == 0 ? 'MADE' : 'REQUEST');
        if (res.code == 1) {
          classList = null;
          yield CheckState();
          classList = ClassList.fromJson(res.data);

          for (int i = 0; i < classList!.classData.length; i++) {
            bookmarkChecks.add(false);
            heartAnimation.add(false);
            if (classList!.classData[i].likeFlag == 1) {
              bookmarkChecks[i] = true;
            }
          }

          loading = false;
          yield RecentOrBookmarkInitState();
        } else {
          loading = false;
          yield ErrorState();
        }
      } else {
        ReturnData res = await ClassRepository.getBookmarkClassList(
            type: selectTap == 0 ? 'MADE' : 'REQUEST');
        if (res.code == 1) {
          classList = null;
          yield CheckState();
          classList = ClassList.fromJson(res.data);

          for (int i = 0; i < classList!.classData.length; i++) {
            bookmarkChecks.add(false);
            heartAnimation.add(false);
            if (classList!.classData[i].likeFlag == 1) {
              bookmarkChecks[i] = true;
            }
          }

          loading = false;
          yield RecentOrBookmarkInitState();
        } else {
          loading = false;
          yield ErrorState();
        }
      }
    }

    if (event is RecentOrBookmarkTapChangeEvent) {
      if (selectTap != event.selectTap) {
        selectTap = event.selectTap;
        loading = true;
        yield LoadingState();

        if (type == 'RECENT') {
          if (selectTap == 0) {
            heartAnimation = [];
            bookmarkChecks = [];
            nextData = 1;
            classList = null;
            ReturnData res =
                await ClassRepository.getClassViewList(type: 'MADE');
            if (res.code == 1) {
              classList = null;
              yield CheckState();
              classList = ClassList.fromJson(res.data);

              for (int i = 0; i < classList!.classData.length; i++) {
                bookmarkChecks.add(false);
                heartAnimation.add(false);
                if (classList!.classData[i].likeFlag == 1) {
                  bookmarkChecks[i] = true;
                }
              }

              loading = false;
              yield RecentOrBookmarkTapChangeState();
            } else {
              loading = false;
              yield ErrorState();
            }
          } else {
            communityList = null;
            communityNextData = 1;
            ReturnData res = await CommunityRepository.getCommunityRecent();
            if (res.code == 1) {
              communityList = CommunityList.fromJson(res.data);

              loading = false;
              yield RecentOrBookmarkTapChangeState();
            } else {
              loading = false;
              yield ErrorState();
            }
          }
        } else {
          if (selectTap == 0) {
            heartAnimation = [];
            bookmarkChecks = [];
            classList = null;
            nextData = 1;
            ReturnData res =
                await ClassRepository.getBookmarkClassList(type: 'MADE');
            if (res.code == 1) {
              classList = null;
              yield CheckState();
              classList = ClassList.fromJson(res.data);

              for (int i = 0; i < classList!.classData.length; i++) {
                bookmarkChecks.add(false);
                heartAnimation.add(false);
                if (classList!.classData[i].likeFlag == 1) {
                  bookmarkChecks[i] = true;
                }
              }

              loading = false;
              yield RecentOrBookmarkTapChangeState();
            } else {
              loading = false;
              yield ErrorState();
            }
          } else {
            communityList = null;
            communityNextData = 1;
            ReturnData res = await CommunityRepository.getCommunityLike();
            if (res.code == 1) {
              communityList = CommunityList.fromJson(res.data);

              loading = false;
              yield RecentOrBookmarkTapChangeState();
            } else {
              loading = false;
              yield ErrorState();
            }
          }
        }
      }
    }

    if (event is BookmarkEvent) {
      if (event.flag == 0) {
        bookmarkChecks[event.index!] = true;
        classList!.classData[event.index!].likeFlag = 1;
        classList!.classData[event.index!].likeCnt =
            classList!.classData[event.index!].likeCnt + 1;
        dataSaver.gatherBloc!.add(BookmarkClassHideEvent(
            classUuid: classList!.classData[event.index!].classUuid, flag: 1));
        if (production == 'prod-release' && kReleaseMode) {
          await facebookAppEvents.logAddToCart(
              id: classList!.classData[event.index!].classUuid,
              type: classList!.classData[event.index!].content.title!,
              currency: dataSaver.abTest ?? 'KRW',
              price: 1);
        }
      } else {
        bookmarkChecks[event.index!] = false;
        classList!.classData[event.index!].likeFlag = 0;
        classList!.classData[event.index!].likeCnt =
            classList!.classData[event.index!].likeCnt - 1;
        dataSaver.gatherBloc!.add(BookmarkClassHideEvent(
            classUuid: classList!.classData[event.index!].classUuid, flag: 0));
      }

      yield CheckState();

      await ClassRepository.bookmarkClass(
          classList!.classData[event.index!].classUuid);

      dataSaver.learnBloc!.add(ReloadClassEvent());
      dataSaver.gatherBloc!.add(BookmarkReloadEvent());

      yield BookmarkState();
    }

    if (event is BookmarkAnimationCheckEvent) {
      if (event.flag == 0) {
        bookmarkChecks[event.index] = false;
        classList!.classData[event.index].likeFlag = 0;
        classList!.classData[event.index].likeCnt =
            classList!.classData[event.index].likeCnt - 1;
      } else {
        bookmarkChecks[event.index] = true;
        classList!.classData[event.index].likeFlag = 1;
        classList!.classData[event.index].likeCnt =
            classList!.classData[event.index].likeCnt + 1;
      }
      yield BookmarkAnimationCheckState();
    }

    if (event is ReloadRecentOrBookmarkEvent) {
      bookmarkChecks = [];
      heartAnimation = [];
      classList = null;
      yield CheckState();

      if (type == 'RECENT') {
        ReturnData res = await ClassRepository.getClassViewList(
            type: selectTap == 0 ? 'MADE' : 'REQUEST');
        if (res.code == 1) {
          classList = null;
          yield CheckState();
          classList = ClassList.fromJson(res.data);

          for (int i = 0; i < classList!.classData.length; i++) {
            bookmarkChecks.add(false);
            heartAnimation.add(false);
            if (classList!.classData[i].likeFlag == 1) {
              bookmarkChecks[i] = true;
            }
          }

          loading = false;
          yield ReloadRecentOrBookmarkState();
        } else {
          loading = false;
          yield ErrorState();
        }
      } else {
        ReturnData res = await ClassRepository.getBookmarkClassList(
            type: selectTap == 0 ? 'MADE' : 'REQUEST');
        if (res.code == 1) {
          classList = null;
          yield CheckState();
          classList = ClassList.fromJson(res.data);

          for (int i = 0; i < classList!.classData.length; i++) {
            bookmarkChecks.add(false);
            heartAnimation.add(false);
            if (classList!.classData[i].likeFlag == 1) {
              bookmarkChecks[i] = true;
            }
          }

          loading = false;
          yield ReloadRecentOrBookmarkState();
        } else {
          loading = false;
          yield ErrorState();
        }
      }
    }

    if (event is GetDataEvent) {
      if (selectTap == 0) {
        if (classList!.classData.length == nextData * 20 &&
            !scrollUnder &&
            dataSaver.lastNextCursor != classList!.classData.last.cursor) {
          scrollUnder = true;
          yield CheckState();

          dataSaver.lastNextCursor = classList!.classData.last.cursor!;

          if (type == 'RECENT') {
            ReturnData res = await ClassRepository.getClassViewList(
                type: selectTap == 0 ? 'MADE' : 'REQUEST',
                nextCursor: classList!.classData.last.cursor);
            if (res.code == 1) {
              classList!.classData
                  .addAll(ClassList.fromJson(res.data).classData);

              for (int i = 0;
                  i < ClassList.fromJson(res.data).classData.length;
                  i++) {
                heartAnimation.add(false);
                if (ClassList.fromJson(res.data).classData[i].likeFlag == 1) {
                  bookmarkChecks.add(true);
                } else {
                  bookmarkChecks.add(false);
                }
              }

              nextData += 1;

              scrollUnder = false;
              yield GetDataState();
            } else {
              yield ErrorState();
            }
          } else {
            ReturnData res = await ClassRepository.getBookmarkClassList(
                type: selectTap == 0 ? 'MADE' : 'REQUEST',
                nextCursor: classList!.classData.last.cursor);
            if (res.code == 1) {
              classList!.classData
                  .addAll(ClassList.fromJson(res.data).classData);

              for (int i = 0;
                  i < ClassList.fromJson(res.data).classData.length;
                  i++) {
                heartAnimation.add(false);
                if (ClassList.fromJson(res.data).classData[i].likeFlag == 1) {
                  bookmarkChecks.add(true);
                } else {
                  bookmarkChecks.add(false);
                }
              }

              nextData += 1;

              scrollUnder = false;
              yield GetDataState();
            } else {
              yield ErrorState();
            }
          }
        }
      } else {
        if (communityList!.communityData.length == communityNextData * 20 &&
            !communityScrollUnder &&
            communityNextCursor != communityList!.communityData.last.cursor) {
          communityScrollUnder = true;
          yield CheckState();

          communityNextCursor = communityList!.communityData.last.cursor;

          if (type == 'RECENT') {
            ReturnData res = await CommunityRepository.getCommunityRecent(
                nextCursor: communityList!.communityData.last.cursor);
            if (res.code == 1) {
              communityList!.communityData
                  .addAll(CommunityList.fromJson(res.data).communityData);

              communityNextData += 1;

              communityScrollUnder = false;
              yield GetDataState();
            } else {
              yield ErrorState();
            }
          } else {
            ReturnData res = await CommunityRepository.getCommunityLike(
                nextCursor: communityList!.communityData.last.cursor);
            if (res.code == 1) {
              communityList!.communityData
                  .addAll(CommunityList.fromJson(res.data).communityData);

              communityNextData += 1;

              communityScrollUnder = false;
              yield GetDataState();
            } else {
              yield ErrorState();
            }
          }
        }
      }
    }
  }
}

class GetDataEvent extends BaseBlocEvent {
  final GlobalKey<AnimatedListState>? key;

  GetDataEvent({this.key});
}

class GetDataState extends BaseBlocState {}

class ReloadRecentOrBookmarkEvent extends BaseBlocEvent {
  final String type;

  ReloadRecentOrBookmarkEvent({required this.type});
}

class ReloadRecentOrBookmarkState extends BaseBlocState {}

class BookmarkAnimationCheckEvent extends BaseBlocEvent {
  final int index;
  final int flag;

  BookmarkAnimationCheckEvent({required this.index, required this.flag});
}

class BookmarkAnimationCheckState extends BaseBlocState {}

class BookmarkEvent extends BaseBlocEvent {
  final int? index;
  final int flag;
  final bool? bookmark;

  BookmarkEvent({this.index, required this.flag, this.bookmark});
}

class BookmarkState extends BaseBlocState {}

class RecentOrBookmarkTapChangeEvent extends BaseBlocEvent {
  final int selectTap;

  RecentOrBookmarkTapChangeEvent({required this.selectTap});
}

class RecentOrBookmarkTapChangeState extends BaseBlocState {}

class RecentOrBookmarkInitEvent extends BaseBlocEvent {
  final String type;
  final dynamic animationVsync;

  RecentOrBookmarkInitEvent({required this.type, required this.animationVsync});
}

class RecentOrBookmarkInitState extends BaseBlocState {}

class BaseRecentOrBookmarkState extends BaseBlocState {}
