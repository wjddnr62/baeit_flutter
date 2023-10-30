import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/notice/notice.dart';
import 'package:baeit/data/notice/repository/notice_repository.dart';
import 'package:flutter/widgets.dart';

class NoticeBloc extends BaseBloc {
  NoticeBloc(BuildContext context) : super(BaseNoticeState());

  bool loading = false;
  NoticeData? notice;
  double bottomOffset = 0;
  bool scrollUnder = false;
  int nextData = 1;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is NoticeInitEvent) {
      loading = true;
      yield LoadingState();

      ReturnData returnData = await NoticeRepository.getNotice();

      if (returnData.code == 1) {
        notice = NoticeData.fromJson(returnData.data);
        loading = false;
        yield NoticeInitState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is GetDataEvent) {
      if (notice!.notice.length == nextData * 20) {
        yield CheckState();

        ReturnData returnData = await NoticeRepository.getNotice(
            nextCursor: notice!.notice.last.cursor);

        if (returnData.code == 1) {
          notice!.notice.addAll(NoticeData.fromJson(returnData.data).notice);

          nextData += 1;
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

class NoticeInitEvent extends BaseBlocEvent {}

class NoticeInitState extends BaseBlocState {}

class BaseNoticeState extends BaseBlocState {}
