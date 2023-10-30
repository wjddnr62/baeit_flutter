import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/create_class/create_class_page.dart';
import 'package:baeit/ui/keyword_setting/keyword_setting_page.dart';
import 'package:baeit/ui/word_cloud/word_cloud_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WordCloudPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return WordCloudState();
  }
}

class WordCloudState extends BlocState<WordCloudBloc, WordCloudPage> {
  ScrollController? scrollController;
  ScrollController? keywordController;

  @override
  void initState() {
    super.initState();

    keywordController = ScrollController()
      ..addListener(() {
        if (keywordController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.bottomOffset = 0;
          bloc.scrollUnder = false;
        }
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < keywordController!.offset) &&
            keywordController!.offset >=
                keywordController!.position.maxScrollExtent &&
            !keywordController!.position.outOfRange) {
          bloc.scrollUnder = true;
          bloc.bottomOffset = keywordController!.offset;
        }
        if (keywordController!.position.userScrollDirection ==
                ScrollDirection.reverse ||
            keywordController!.position.userScrollDirection ==
                ScrollDirection.forward) {
          bloc.add(NewDataEvent());
        }
      });

    scrollController = ScrollController()
      ..addListener(() {
        if (bloc.scrollEnd) {
          bloc.scrollEnd = false;
          setState(() {});
        }
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < scrollController!.offset) &&
            scrollController!.offset >=
                scrollController!.position.maxScrollExtent &&
            !scrollController!.position.outOfRange) {
          bloc.scrollUnder = true;
          bloc.bottomOffset = scrollController!.offset;
          bloc.add(ScrollEndEvent());
        }
        if (scrollController!.offset <=
                scrollController!.position.minScrollExtent &&
            !scrollController!.position.outOfRange) {
          bloc.floatingAnimationEnd = true;
          bloc.add(ScrollEvent(scroll: true));
        }
        if (scrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.bottomOffset = 0;
          bloc.scrollUnder = false;
          if (!bloc.upDownCheck) {
            bloc.upDownCheck = true;
            bloc.startPixels = scrollController!.offset;
          }
          // 스크롤 다운
        } else if (scrollController!.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (bloc.upDownCheck) {
            bloc.upDownCheck = false;
            bloc.startPixels = scrollController!.offset;
          }
          // 스크롤 업
        }

        if (bloc.startPixels.toInt() - scrollController!.offset.toInt() > 30) {
          if (!bloc.scrollUp) {
            bloc.floatingAnimationEnd = false;
            bloc.add(ScrollEvent(scroll: true));
          }
        } else if (bloc.startPixels.toInt() - scrollController!.offset.toInt() <
            -30) {
          if (bloc.scrollUp) {
            bloc.floatingAnimationEnd = false;
            bloc.add(ScrollEvent(scroll: false));
          }
        }
      });
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(color: AppColors.white),
            child: SafeArea(
              child: Stack(
                children: [
                  Scaffold(
                    backgroundColor: AppColors.white,
                    appBar: baseAppBar(
                        title: '',
                        context: context,
                        onPressed: () {
                          pop(context);
                        }),
                    body: SingleChildScrollView(
                      controller: scrollController,
                      physics: bloc.tapDown
                          ? NeverScrollableScrollPhysics()
                          : ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  stops: [
                                    0.0,
                                    0.5,
                                    1.0
                                  ],
                                  colors: [
                                    AppColors.gray200.withOpacity(0),
                                    AppColors.gray200,
                                    AppColors.gray200.withOpacity(0),
                                  ]),
                            ),
                            child: Column(
                              children: [
                                spaceH(24),
                                customText('이웃들이 \'배우고 싶은 것\'에\n추가한 키워드예요!',
                                    style: TextStyle(
                                        color: AppColors.gray900,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T20)),
                                    textAlign: TextAlign.center),
                                spaceH(30),
                                RichText(
                                  text: TextSpan(children: [
                                    customTextSpan(
                                        text: '현재까지 추가된 키워드 ',
                                        style: TextStyle(
                                            color: AppColors.gray600,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14))),
                                    customTextSpan(
                                        text:
                                            '${bloc.totalRow == 0 ? 0 : bloc.totalRow}',
                                        style: TextStyle(
                                            color: AppColors.primaryDark10,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14))),
                                    customTextSpan(
                                        text: '개',
                                        style: TextStyle(
                                            color: AppColors.gray600,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14))),
                                  ]),
                                ),
                                spaceH(20),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.width - 40,
                                    constraints: BoxConstraints(
                                        maxWidth: 380, maxHeight: 380),
                                    decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                            begin: FractionalOffset.topLeft,
                                            end: FractionalOffset.bottomRight,
                                            stops: [
                                              0.0,
                                              0.99,
                                              1.0
                                            ],
                                            colors: [
                                              AppColors.black.withOpacity(0.04),
                                              AppColors.black.withOpacity(0.01),
                                              AppColors.black.withOpacity(0),
                                            ]),
                                        boxShadow: [
                                          BoxShadow(
                                              color: AppColors.black
                                                  .withOpacity(0.1),
                                              blurRadius: 24,
                                              offset: Offset(12, 12)),
                                          BoxShadow(
                                              color: AppColors.white,
                                              blurRadius: 0,
                                              spreadRadius: 0,
                                              offset: Offset(0, 0)),
                                          BoxShadow(
                                              color: AppColors.white,
                                              blurRadius: 24,
                                              offset: Offset(-12, -12)),
                                        ]),
                                    child: bloc.wordCloudTexts.length == 0
                                        ? Center(
                                            child: loadingView(bloc.loading),
                                          )
                                        : Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                child: SingleChildScrollView(
                                                  controller: keywordController,
                                                  child: Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10, bottom: 10),
                                                      child: Wrap(
                                                        runSpacing: 8,
                                                        spacing: 8,
                                                        alignment: WrapAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .center,
                                                        children:
                                                            bloc.wordCloudTexts,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              bloc.gestureImageView
                                                  ? Positioned.fill(
                                                      child: GestureDetector(
                                                      onVerticalDragUpdate:
                                                          (details) {
                                                        if (details.delta.dy <
                                                            -1) {
                                                          bloc.add(
                                                              GestureImageUpdateEvent());
                                                        }
                                                      },
                                                      onTap: () {
                                                        bloc.add(
                                                            GestureImageUpdateEvent());
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(24),
                                                          gradient: LinearGradient(
                                                              begin:
                                                                  FractionalOffset
                                                                      .topCenter,
                                                              end: FractionalOffset
                                                                  .bottomCenter,
                                                              stops: [
                                                                0.0,
                                                                0.9998,
                                                                0.9999
                                                              ],
                                                              colors: [
                                                                AppColors.white
                                                                    .withOpacity(
                                                                        0),
                                                                AppColors.white,
                                                                AppColors.black
                                                                    .withOpacity(
                                                                        0.01),
                                                              ]),
                                                        ),
                                                      ),
                                                    ))
                                                  : Container(),
                                              bloc.gestureImageView
                                                  ? Positioned(
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 12,
                                                      child: GestureDetector(
                                                        onVerticalDragUpdate:
                                                            (details) {
                                                          if (details.delta.dy <
                                                              -1) {
                                                            bloc.add(
                                                                GestureImageUpdateEvent());
                                                          }
                                                        },
                                                        onTap: () {
                                                          bloc.add(
                                                              GestureImageUpdateEvent());
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: ClipOval(
                                                                child:
                                                                    Container(
                                                                  width: 32,
                                                                  height: 32,
                                                                  color: AppColors
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.6),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              left: 0,
                                                              right: 0,
                                                              bottom: 0,
                                                              top: 0,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    Image.asset(
                                                                  AppImages
                                                                      .iDoubleArrowWDown,
                                                                  width: 16,
                                                                  height: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                  : Container(),
                                              bloc.gestureImageView
                                                  ? Positioned(
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 48,
                                                      child: customText('스크롤',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .primaryDark10,
                                                              fontWeight: weightSet(
                                                                  textWeight:
                                                                      TextWeight
                                                                          .BOLD),
                                                              fontSize: fontSizeSet(
                                                                  textSize:
                                                                      TextSize
                                                                          .T12)),
                                                          textAlign:
                                                              TextAlign.center),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                  ),
                                ),
                                spaceH(30),
                                customText(
                                    '클래스를 만들 때 같은 키워드를 입력한 이웃에게\n알림이 가요! 이 외에도 다양한 재능을 나눠보세요 :)',
                                    style: TextStyle(
                                        color: AppColors.gray600,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.REGULAR),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14)),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                          spaceH(40),
                          Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.black12,
                                      blurRadius: 16,
                                      offset: Offset(4, 4))
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.only(
                                  top: 30, bottom: 30, left: 40, right: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.iQuestionLg,
                                        width: 24,
                                        height: 24,
                                      ),
                                      spaceW(6),
                                      customText('제가 알려줘도 될까요?',
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T20)))
                                    ],
                                  ),
                                  spaceH(12),
                                  questionText('걱정마세요! 대단한 쌤의 강의도 좋지만'),
                                  questionText('옆에서 나에게 맞춰 알려줄 수 있는 쌤도'),
                                  questionText('아주 좋으니까요!'),
                                  questionText('부담없이 시작해보세요')
                                ],
                              ),
                            ),
                          ),
                          dataSaver.bannerMoveEnable ? spaceH(40) : Container(),
                          dataSaver.bannerMoveEnable
                              ? customText('배우고 싶은 클래스 알림을 받으려면,',
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)))
                              : Container(),
                          dataSaver.bannerMoveEnable ? spaceH(10) : Container(),
                          dataSaver.bannerMoveEnable
                              ? ElevatedButton(
                                  onPressed: () {
                                    amplitudeEvent('keyword_set_enter',
                                        {'inflow_page': 'word_cloud'});
                                    pushTransition(
                                        context, KeywordSettingPage());
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Opacity(
                                        opacity: 0.4,
                                        child: Image.asset(
                                          AppImages.iAlarm,
                                          width: 16,
                                          height: 16,
                                        ),
                                      ),
                                      spaceW(4),
                                      customText('키워드 알림 설정하기 >',
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12)))
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: AppColors.white,
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          side: BorderSide(
                                              width: 1,
                                              color: AppColors.gray200)),
                                      elevation: 0))
                              : Container(),
                          spaceH(100)
                        ],
                      ),
                    ),
                  ),
                  bloc.scrollEnd ? Container() : floatingActionButton(),
                ],
              ),
            ),
          );
        });
  }

  questionText(text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 32,
          child: Center(
            child: customText(text,
                style: TextStyle(
                    color: AppColors.gray600,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
                textAlign: TextAlign.center),
          ),
        ),
        heightLine(height: 1, color: AppColors.primaryLight30)
      ],
    );
  }

  floatingActionButton() {
    return Positioned(
        bottom: 12 + MediaQuery.of(context).padding.bottom,
        right: 12,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          onEnd: () {
            setState(() {
              bloc.floatingAnimationEnd = true;
            });
          },
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(!bloc.scrollUp ? 48 : 24),
          ),
          padding: EdgeInsets.zero,
          width: !bloc.scrollUp ? 48 : 160,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (!dataSaver.mainBloc!.classMadeCheck) {
                showToast(
                    context: context,
                    text: AppStrings.of(StringKey.addMaxClassToast));
              } else {
                amplitudeEvent(
                    'class_register', {'inflow_page': 'keyword_list_banner'});
                pushTransition(
                    context,
                    CreateClassPage(
                      profileGet: dataSaver.profileGet!,
                      floating: true,
                      previousPage: 'keyword_list_banner',
                    )).then((value) {
                  if (value != null) {
                    ClassDetailPage classDetailPage = ClassDetailPage(
                      classUuid: value,
                      bloc: bloc,
                      mainNeighborHood: dataSaver.neighborHood[
                          dataSaver.neighborHood.indexWhere(
                              (element) => element.representativeFlag == 1)],
                      profileGet:
                          dataSaver.nonMember ? null : dataSaver.profileGet,
                    );
                    dataSaver.keywordClassDetail = classDetailPage;
                    pushTransition(context, classDetailPage);
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
                primary: AppColors.primary,
                elevation: 0,
                padding: !bloc.scrollUp
                    ? EdgeInsets.zero
                    : EdgeInsets.only(left: 12),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(!bloc.scrollUp ? 48 : 24))),
            child: Center(
              child: !bloc.scrollUp
                  ? Image.asset(
                      AppImages.iPlusW,
                      width: 24,
                      height: 24,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.iClassFab,
                          width: 24,
                          height: 24,
                        ),
                        spaceW(10),
                        Expanded(
                          child: bloc.floatingAnimationEnd
                              ? customText(
                                  '새 클래스 만들기',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                )
                              : Container(),
                        )
                      ],
                    ),
            ),
          ),
        ));
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is WordCloudInitState) {
      Future.delayed(Duration(milliseconds: 100), () {
        bloc.gestureUpdate = true;
      });
    }

    if (state is GestureImageUpdateState) {
      if (!bloc.sendEvent) {
        bloc.sendEvent = true;
        amplitudeEvent('keyword_scroll_check', {'inflow_page': 'banner'});
      }
    }
  }

  @override
  WordCloudBloc initBloc() {
    return WordCloudBloc(context)..add(WordCloudInitEvent());
  }
}
