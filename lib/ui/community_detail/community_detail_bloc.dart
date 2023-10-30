import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/comment.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/repository/community_repository.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/my_create_community/my_create_community_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/cupertino.dart';

class CommunityDetailBloc extends BaseBloc {
  CommunityDetailBloc(BuildContext context)
      : super(BaseCommunityDetailState()) {
    on<CommunityDetailInitEvent>(onCommunityDetailInitEvent);
    on<CommentInitEvent>(onCommentInitEvent);
    on<AddCommentEvent>(onAddCommentEvent);
    on<ShareEvent>(onShareEvent);
    on<CommunityStatusChangeEvent>(onCommunityStatusChangeEvent);
    on<BookmarkEvent>(onBookmarkEvent);
    on<RemoveCommentEvent>(onRemoveCommentEvent);
    on<ReCheckBlockEvent>(onReCheckBlockEvent);
    on<CommunityBlockUserEvent>(onCommunityBlockUserEvent);
  }

  bool loading = false;
  String communityUuid = '';
  CommunityDetail? communityDetail;
  List<Comment> comment = [];
  int commentTotalRow = 0;
  bool openMoreView = false;
  bool reply = false;
  String rootCommentUuid = '';
  String parentCommentUuid = '';
  bool commentEdit = false;
  String editCommentUuid = '';
  String editComment = '';
  CommentMember? replyMember;
  int chatBlock = 2;

  onCommunityDetailInitEvent(CommunityDetailInitEvent event, emit) async {
    communityUuid = event.communityUuid;

    loading = true;
    emit(LoadingState());

    communityDetail = null;
    comment = [];

    ReturnData communityRes = await CommunityRepository.getCommunityDetail(
        communityUuid: communityUuid,
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati
            .toString(),
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi
            .toString());

    communityDetail = CommunityDetail.fromJson(communityRes.data);

    if (!dataSaver.nonMember) {
      ReturnData blockRes = await CommunityRepository.checkCommunityChat(
          communityUuid: communityDetail!.communityUuid);
      chatBlock = blockRes.data;
    }

    add(CommentInitEvent());

    loading = false;
    emit(CommunityDetailInitState());
  }

  onCommentInitEvent(CommentInitEvent event, emit) async {
    ReturnData res = await CommunityRepository.getCommunityComment(
        communityUuid: communityUuid);

    comment = [];
    comment =
        (res.data['list'] as List).map((e) => Comment.fromJson(e)).toList();
    commentTotalRow = res.data['totalRow'];

    emit(CommentInitState());
  }

  onAddCommentEvent(AddCommentEvent event, emit) async {
    if (commentEdit) {
      await CommunityRepository.addCommunityComment(
          communityUuid: communityUuid,
          communityCommentUuid: editCommentUuid,
          text: event.text);
      commentEdit = false;
    } else if (reply) {
      amplitudeEvent('comment_completed',
          {'type': communityDetail!.content.category, 'comment_type': 'reply'});
      await CommunityRepository.addCommunityComment(
          communityUuid: communityUuid,
          rootCommentUuid: reply ? rootCommentUuid : null,
          parentCommentUuid: reply ? parentCommentUuid : null,
          text: event.text);
      reply = false;
    } else {
      amplitudeEvent('comment_completed',
          {'type': communityDetail!.content.category, 'comment_type': 'comment'});
      await CommunityRepository.addCommunityComment(
          communityUuid: communityUuid, text: event.text);
    }

    emit(AddCommentState());
    add(CommentInitEvent());
  }

  onShareEvent(ShareEvent event, emit) async {
    ReturnData shareRes = await CommunityRepository.getCommunityShareLink(
        communityUuid: communityUuid);
    emit(ShareState(shareText: shareRes.data));
  }

  onCommunityStatusChangeEvent(CommunityStatusChangeEvent event, emit) async {
    // TEMP, NORMAL, DONE, DELETE
    loading = true;
    emit(LoadingState());

    await CommunityRepository.changeCommunityStatus(
        communityUuid: communityUuid, status: event.status);
    communityDetail!.status = event.status;

    loading = false;
    emit(CommunityStatusChangeState());
    dataSaver.learnBloc!.add(CommunityReloadEvent());
    if (dataSaver.myCreateCommunityBloc != null) {
      dataSaver
          .myCreateCommunityBloc!
          .add(StatusChangeEvent());
    }
  }

  onBookmarkEvent(BookmarkEvent event, emit) async {
    if (event.bookmark) {
      communityDetail!.likeFlag = 1;
    } else {
      communityDetail!.likeFlag = 0;
    }
    await CommunityRepository.communityBookmark(communityUuid: communityUuid);
    emit(BookmarkState());
  }

  onRemoveCommentEvent(RemoveCommentEvent event, emit) async {
    await CommunityRepository.removeCommunityComment(
        communityCommentUuid: event.communityCommentUuid);
    emit(RemoveCommentState());
    add(CommentInitEvent());
  }

  onReCheckBlockEvent(ReCheckBlockEvent event, emit) async {
    ReturnData blockRes = await CommunityRepository.checkCommunityChat(
        communityUuid: communityUuid);
    chatBlock = blockRes.data;
    emit(ReCheckBlockState());
  }

  onCommunityBlockUserEvent(CommunityBlockUserEvent event, emit){
    emit(CommunityBlockUserState());
  }
}

class CommunityBlockUserEvent extends BaseBlocEvent {}

class CommunityBlockUserState extends BaseBlocState {}

class ReCheckBlockEvent extends BaseBlocEvent {}

class ReCheckBlockState extends BaseBlocState {}

class RemoveCommentEvent extends BaseBlocEvent {
  final String communityCommentUuid;

  RemoveCommentEvent({required this.communityCommentUuid});
}

class RemoveCommentState extends BaseBlocState {}

class BookmarkEvent extends BaseBlocEvent {
  final int flag;
  final bool bookmark;

  BookmarkEvent({required this.flag, required this.bookmark});
}

class BookmarkState extends BaseBlocState {}

class CommunityStatusChangeEvent extends BaseBlocEvent {
  final String status;

  CommunityStatusChangeEvent({required this.status});
}

class CommunityStatusChangeState extends BaseBlocState {}

class ShareEvent extends BaseBlocEvent {}

class ShareState extends BaseBlocState {
  final String shareText;

  ShareState({required this.shareText});
}

class AddCommentEvent extends BaseBlocEvent {
  final String? communityCommentUuid;
  final String text;

  AddCommentEvent({this.communityCommentUuid, required this.text});
}

class AddCommentState extends BaseBlocState {}

class CommentInitEvent extends BaseBlocEvent {}

class CommentInitState extends BaseBlocState {}

class CommunityDetailInitEvent extends BaseBlocEvent {
  final String communityUuid;

  CommunityDetailInitEvent({required this.communityUuid});
}

class CommunityDetailInitState extends BaseBlocState {}

class BaseCommunityDetailState extends BaseBlocState {}
