import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/notice/notice.dart';
import 'package:baeit/data/notice/repository/notice_repository.dart';
import 'package:flutter/widgets.dart';

class NoticeDetailBloc extends BaseBloc {
  NoticeDetailBloc(BuildContext context) : super(BaseNoticeDetailState());

  bool loading = false;

  Notice? notice;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is NoticeDetailInitEvent) {
      loading = true;
      yield LoadingState();

      ReturnData returnData =
          await NoticeRepository.getNoticeDetail(event.noticeUuid);

      if (returnData.code == 1) {
        notice = Notice.fromJson(returnData.data);

        loading = false;
        yield NoticeDetailInitState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }
  }
}

class NoticeDetailInitEvent extends BaseBlocEvent {
  final String noticeUuid;

  NoticeDetailInitEvent({required this.noticeUuid});
}

class NoticeDetailInitState extends BaseBlocState {}

class BaseNoticeDetailState extends BaseBlocState {}
