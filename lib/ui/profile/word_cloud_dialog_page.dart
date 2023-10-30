import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/create_class/create_class_page.dart';
import 'package:baeit/ui/learn/learn_bloc.dart' as learn;
import 'package:baeit/ui/profile/word_cloud_dialog_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WordCloudDialogPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return WordCloudDialogState();
  }
}

class WordCloudDialogState
    extends BlocState<WordCloudDialogBloc, WordCloudDialogPage> {
  final globalKey = GlobalKey();
  ScrollController? keywordController;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                spaceH(30),
                customText('이웃들이 배우고 싶어해요!',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T17))),
                spaceH(10),
                RichText(
                  text: TextSpan(children: [
                    customTextSpan(
                        text: '현재까지 추가된 키워드 ',
                        style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12))),
                    customTextSpan(
                        text: '${bloc.totalRow == 0 ? 0 : bloc.totalRow}',
                        style: TextStyle(
                            color: AppColors.primaryDark10,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T12))),
                    customTextSpan(
                        text: '개',
                        style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12))),
                  ]),
                ),
                spaceH(20),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 36, right: 36),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      // height: MediaQuery.of(context).size.width -
                      //     72 -
                      //     ((MediaQuery.of(context).size.width * 0.15) * 2),
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
                                color: AppColors.black.withOpacity(0.1),
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
                                  borderRadius: BorderRadius.circular(24),
                                  child: SingleChildScrollView(
                                    controller: keywordController,
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Wrap(
                                          runSpacing: 4,
                                          spacing: 8,
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: bloc.wordCloudTexts,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                bloc.gestureImageView
                                    ? Positioned.fill(
                                        child: GestureDetector(
                                        onVerticalDragUpdate: (details) {
                                          if (details.delta.dy < -1) {
                                            bloc.add(GestureImageUpdateEvent());
                                          }
                                        },
                                        onTap: () {
                                          bloc.add(GestureImageUpdateEvent());
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            gradient: LinearGradient(
                                                begin:
                                                    FractionalOffset.topCenter,
                                                end: FractionalOffset
                                                    .bottomCenter,
                                                stops: [
                                                  0.0,
                                                  0.9998,
                                                  0.9999
                                                ],
                                                colors: [
                                                  AppColors.white
                                                      .withOpacity(0),
                                                  AppColors.white,
                                                  AppColors.black
                                                      .withOpacity(0.01),
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
                                          onVerticalDragUpdate: (details) {
                                            if (details.delta.dy < -1) {
                                              bloc.add(
                                                  GestureImageUpdateEvent());
                                            }
                                          },
                                          onTap: () {
                                            bloc.add(GestureImageUpdateEvent());
                                          },
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: ClipOval(
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    color: AppColors.primary
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                bottom: 0,
                                                top: 0,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Image.asset(
                                                    AppImages.iDoubleArrowWDown,
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
                                                color: AppColors.primaryDark10,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.BOLD),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T12)),
                                            textAlign: TextAlign.center),
                                      )
                                    : Container()
                              ],
                            ),
                    ),
                  ),
                ),
                spaceH(24),
                customText('내가 알려줄만한 내용이 있나요?\n바로 이웃들이 기다리던 분이네요 :)',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12)),
                    textAlign: TextAlign.center),
                spaceH(20),
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: bottomButton(
                      context: context,
                      onPress: () {
                        if (!dataSaver.mainBloc!.classMadeCheck) {
                          showToast(
                              context: context,
                              text: AppStrings.of(StringKey.addMaxClassToast));
                        } else {
                          amplitudeRevenue(productId: 'class_register', price: 3);
                          amplitudeEvent('class_register',
                              {'inflow_page': 'keyword_list_main'});
                          pushTransition(
                              context,
                              CreateClassPage(
                                profileGet: dataSaver.profileGet!,
                                floating: true,
                                previousPage: 'keyword_list_main',
                              )).then((value) {
                            if (value != null) {
                              popDialog(context);
                              ClassDetailPage classDetailPage = ClassDetailPage(
                                classUuid: value,
                                bloc: bloc,
                                mainNeighborHood: dataSaver.neighborHood[
                                    dataSaver.neighborHood.indexWhere(
                                        (element) =>
                                            element.representativeFlag == 1)],
                                profileGet: dataSaver.nonMember
                                    ? null
                                    : dataSaver.profileGet,
                              );
                              dataSaver.keywordClassDetail = classDetailPage;
                              pushTransition(context, classDetailPage)
                                  .then((value) {
                                dataSaver.learnBloc!
                                    .add(learn.NotificationAnimationEvent());
                              });
                            }
                          });
                        }
                      },
                      text: '클래스 만들어보기'),
                ),
                GestureDetector(
                  onTap: () {
                    amplitudeEvent('keyword_list_main_close', {});
                    popDialog(context);
                    dataSaver.learnBloc!
                        .add(learn.NotificationAnimationEvent());
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.gray50,
                    ),
                    child: Center(
                      child: customText('닫기',
                          style: TextStyle(
                              color: AppColors.gray600,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T12),
                              decoration: TextDecoration.underline)),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is WordCloudDialogInitState) {
      Future.delayed(Duration(milliseconds: 100), () {
        bloc.gestureUpdate = true;
      });
    }

    if (state is GestureImageUpdateState) {
      if (!bloc.sendEvent) {
        bloc.sendEvent = true;
        amplitudeEvent('keyword_scroll_check', {'inflow_page': 'main'});
      }
    }
  }

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
  }

  @override
  WordCloudDialogBloc initBloc() {
    return WordCloudDialogBloc(context)..add(WordCloudDialogInitEvent());
  }
}
