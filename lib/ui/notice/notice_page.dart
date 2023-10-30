import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/notice/notice_bloc.dart';
import 'package:baeit/ui/notice/notice_detail_page.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';

class NoticePage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return NoticeState();
  }
}

class NoticeState extends BlocState<NoticeBloc, NoticePage> {
  ScrollController? scrollController;

  noticeListItem(idx) {
    return GestureDetector(
      onTap: () {
        pushTransition(context,
            NoticeDetailPage(noticeUuid: bloc.notice!.notice[idx].noticeUuid));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: AppColors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  bloc.notice!.notice[idx].title,
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T14)),
                ),
                spaceH(4),
                customText(
                  parse(parse(bloc.notice!.notice[idx].text).body!.text)
                      .documentElement!
                      .text,
                  style: TextStyle(
                      color: AppColors.gray600,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                spaceH(4),
                customText(
                  DateTime.now()
                              .difference(bloc.notice!.notice[idx].createDate)
                              .inMinutes >
                          14400
                      ? bloc.notice!.notice[idx].createDate.yearMonthDay
                      : timeCalculationText(DateTime.now()
                          .difference(bloc.notice!.notice[idx].createDate)
                          .inMinutes),
                  style: TextStyle(
                      color: AppColors.gray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                )
              ],
            ),
          ),
          heightLine(height: 1)
        ],
      ),
    );
  }

  noticeList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return noticeListItem(idx);
      },
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount:
          bloc.notice!.notice.length == 0 ? 0 : bloc.notice!.notice.length,
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: AppColors.white,
                  appBar: baseAppBar(
                      title: AppStrings.of(StringKey.notice),
                      context: context,
                      onPressed: () {
                        pop(context);
                      }),
                  body: SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bloc.notice == null ? Container() : noticeList()
                        ],
                      ),
                    ),
                  ),
                ),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  NoticeBloc initBloc() {
    return NoticeBloc(context)..add(NoticeInitEvent());
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()
      ..addListener(() {
        if (bloc.notice != null && bloc.notice!.notice.length > 2) {
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < scrollController!.offset) &&
              scrollController!.offset >=
                  scrollController!.position.maxScrollExtent &&
              !scrollController!.position.outOfRange) {
            bloc.scrollUnder = true;
            bloc.bottomOffset = scrollController!.offset;
          }
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < scrollController!.offset) &&
              scrollController!.offset >=
                  (scrollController!.position.maxScrollExtent * 0.7) &&
              !scrollController!.position.outOfRange) {
            bloc.add(GetDataEvent());
          }

          if (scrollController!.position.userScrollDirection ==
              ScrollDirection.forward) {
            bloc.bottomOffset = 0;
            bloc.scrollUnder = false;
          }
        }
      });
  }
}
