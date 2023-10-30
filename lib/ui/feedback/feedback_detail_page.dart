import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/feedback/feedback_detail_bloc.dart';
import 'package:baeit/ui/image_view/image_view_detail_page.dart';
import 'package:baeit/ui/image_view/image_view_page.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedbackDetailPage extends BlocStatefulWidget {
  final String feedbackUuid;

  FeedbackDetailPage({required this.feedbackUuid});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return FeedbackDetailState();
  }
}

class FeedbackDetailState
    extends BlocState<FeedbackDetailBloc, FeedbackDetailPage> {
  typeText(text) {
    switch (text) {
      case 'NOT_WORK':
        return '작동하지 않아요';
      case 'UPGRADE':
        return '이렇게 바꿔주세요';
      case 'LIKE':
        return '이런 점 좋아요';
      case 'REQUEST':
        return '할 말 있어요';
    }
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
                bloc.feedbackData == null
                    ? Container()
                    : Scaffold(
                        backgroundColor: AppColors.white,
                        appBar: baseAppBar(
                            title: typeText(bloc.feedbackData!.type),
                            context: context,
                            onPressed: () {
                              pop(context);
                            }),
                        body: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(20),
                                color: AppColors.primaryLight60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        customText(
                                          bloc.feedbackData!.answerFlag == 0
                                              ? '답변대기'
                                              : '답변완료',
                                          style: TextStyle(
                                              color: AppColors.gray600,
                                              fontWeight: weightSet(
                                                  textWeight: TextWeight.BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12)),
                                        ),
                                        Expanded(child: Container()),
                                        customText(
                                          DateTime.now()
                                                      .difference(bloc
                                                          .feedbackData!
                                                          .createDate)
                                                      .inMinutes >
                                                  14400
                                              ? bloc.feedbackData!.createDate
                                                  .yearMonthDay
                                              : timeCalculationText(
                                                  DateTime.now()
                                                      .difference(bloc
                                                          .feedbackData!
                                                          .createDate)
                                                      .inMinutes),
                                          style: TextStyle(
                                              color: AppColors.greenGray200,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12)),
                                        )
                                      ],
                                    ),
                                    spaceH(20),
                                    customText(
                                      bloc.feedbackData!.feedbackText,
                                      style: TextStyle(
                                          color: AppColors.gray600,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.REGULAR),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T13)),
                                    ),
                                    bloc.feedbackData!.images!.length == 0
                                        ? Container()
                                        : spaceH(20),
                                    bloc.feedbackData!.images!.length == 0
                                        ? Container()
                                        : Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  pushTransition(
                                                      context,
                                                      ImageViewPage(
                                                          imageUrls: bloc
                                                              .feedbackData!
                                                              .images!,
                                                          heroTag: ''));
                                                },
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              9),
                                                      child: CacheImage(
                                                        imageUrl:
                                                            '${bloc.feedbackData!.images![0].toView(context: context, w: MediaQuery.of(context).size.width ~/ 2)}',
                                                        fit: BoxFit.cover,
                                                        width: 96,
                                                        height: 54,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 96,
                                                      height: 54,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9)),
                                                      child: topGradient(
                                                          context: context,
                                                          height: 54,
                                                          upColor: AppColors
                                                              .black
                                                              .withOpacity(0.2),
                                                          downColor: AppColors
                                                              .black
                                                              .withOpacity(1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              spaceW(10),
                                              Container(
                                                width: 54,
                                                height: 54,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    pushTransition(
                                                        context,
                                                        ImageViewDetailPage(
                                                            idx: 0,
                                                            images: bloc
                                                                .feedbackData!
                                                                .images!,
                                                            heroTag: ''));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      primary: AppColors.white,
                                                      padding: EdgeInsets.zero,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9),
                                                          side: BorderSide(
                                                              color: AppColors
                                                                  .primary))),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        AppImages.iPlusC,
                                                        width: 16,
                                                        height: 16,
                                                      ),
                                                      spaceH(4),
                                                      customText(
                                                        AppStrings.of(StringKey
                                                            .viewDetail),
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .primary,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .BOLD),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T10)),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                  ],
                                ),
                              ),
                              bloc.feedbackData!.answerText != null
                                  ? spaceH(30)
                                  : spaceH(46),
                              bloc.feedbackData!.answerText != null
                                  ? Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(
                                          left: 20, right: 20, bottom: 20),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              customText(
                                                '안녕하세요 배잇입니다 :)',
                                                style: TextStyle(
                                                    color: AppColors.gray900,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.BOLD),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T15)),
                                              ),
                                              Expanded(child: Container()),
                                              customText(
                                                DateTime.now()
                                                            .difference(bloc
                                                                .feedbackData!
                                                                .answerDate!)
                                                            .inMinutes >
                                                        14400
                                                    ? bloc
                                                        .feedbackData!
                                                        .answerDate!
                                                        .yearMonthDay
                                                    : timeCalculationText(
                                                        DateTime.now()
                                                            .difference(bloc
                                                                .feedbackData!
                                                                .answerDate!)
                                                            .inMinutes),
                                                style: TextStyle(
                                                    color:
                                                        AppColors.greenGray200,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T12)),
                                              )
                                            ],
                                          ),
                                          spaceH(20),
                                          customText(
                                            bloc.feedbackData!.answerText!,
                                            style: TextStyle(
                                                color: AppColors.gray600,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.REGULAR),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T13)),
                                          ),
                                          bloc.feedbackData!.answerImages!
                                                      .length ==
                                                  0
                                              ? Container()
                                              : spaceH(20),
                                          bloc.feedbackData!.answerImages!
                                                      .length ==
                                                  0
                                              ? Container()
                                              : Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        pushTransition(
                                                            context,
                                                            ImageViewPage(
                                                                imageUrls: bloc
                                                                    .feedbackData!
                                                                    .answerImages!,
                                                                heroTag: ''));
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        9),
                                                            child:
                                                                CacheImage(
                                                              imageUrl:
                                                                  '${bloc.feedbackData!.answerImages![0].toView(context: context, w: MediaQuery.of(context).size.width ~/ 2)}',
                                                              fit: BoxFit.cover,
                                                              width: 96,
                                                              height: 54,
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 96,
                                                            height: 54,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            9)),
                                                            child: topGradient(
                                                                context:
                                                                    context,
                                                                height: 54,
                                                                upColor: AppColors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.2),
                                                                downColor: AppColors
                                                                    .black
                                                                    .withOpacity(
                                                                        1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            9)),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    spaceW(10),
                                                    Container(
                                                      width: 54,
                                                      height: 54,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          pushTransition(
                                                              context,
                                                              ImageViewDetailPage(
                                                                  idx: 0,
                                                                  images: bloc
                                                                      .feedbackData!
                                                                      .answerImages!,
                                                                  heroTag: ''));
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            primary:
                                                                AppColors.white,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            elevation: 0,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            9),
                                                                side: BorderSide(
                                                                    color: AppColors
                                                                        .primary))),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              AppImages.iPlusC,
                                                              width: 16,
                                                              height: 16,
                                                            ),
                                                            spaceH(4),
                                                            customText(
                                                              AppStrings.of(
                                                                  StringKey
                                                                      .viewDetail),
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .primary,
                                                                  fontWeight: weightSet(
                                                                      textWeight:
                                                                          TextWeight
                                                                              .BOLD),
                                                                  fontSize: fontSizeSet(
                                                                      textSize:
                                                                          TextSize
                                                                              .T10)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          customText(
                                            '시간을 내어주셔서 감사합니다\n최대한 빨리 확인하고 답변드릴게요\n💚💛',
                                            style: TextStyle(
                                                color: AppColors.gray400,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.REGULAR),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T13)),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    )
                            ],
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
  FeedbackDetailBloc initBloc() {
    return FeedbackDetailBloc(context)
      ..add(FeedbackDetailInitEvent(feedbackUuid: widget.feedbackUuid));
  }
}
