import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notice_detail_bloc.dart';

class NoticeDetailPage extends BlocStatefulWidget {
  final String noticeUuid;

  NoticeDetailPage({required this.noticeUuid});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return NoticeDetailState();
  }
}

class NoticeDetailState extends BlocState<NoticeDetailBloc, NoticeDetailPage> {
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
                  body: bloc.notice == null
                      ? Container()
                      : SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customText(
                                  bloc.notice!.title,
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                                spaceH(4),
                                customText(
                                  DateTime.now()
                                              .difference(
                                                  bloc.notice!.createDate)
                                              .inMinutes >
                                          14400
                                      ? bloc.notice!.createDate.yearMonthDay
                                      : timeCalculationText(DateTime.now()
                                          .difference(bloc.notice!.createDate)
                                          .inMinutes),
                                  style: TextStyle(
                                      color: AppColors.greenGray200,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)),
                                ),
                                spaceH(20),
                                heightLine(height: 1),
                                spaceH(20),
                                HtmlWidget(
                                  bloc.notice!.text,
                                  onTapUrl: (url) async {
                                    return await launch(url, enableJavaScript: true, );
                                  },
                                ),
                                spaceH(20),
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
  initBloc() {
    return NoticeDetailBloc(context)
      ..add(NoticeDetailInitEvent(noticeUuid: widget.noticeUuid));
  }
}
