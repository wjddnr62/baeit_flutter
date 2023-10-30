import 'dart:ui';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/feedback/feedback_page.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/my_create_class/my_create_class_page.dart';
import 'package:baeit/ui/my_create_community/my_create_community_page.dart';
import 'package:baeit/ui/notice/notice_page.dart';
import 'package:baeit/ui/notification/notification_page.dart';
import 'package:baeit/ui/notification_setting/notification_setting_page.dart';
import 'package:baeit/ui/recent_or_bookmark/recent_or_bookmark_page.dart';
import 'package:baeit/ui/signup/signup_page.dart';
import 'package:baeit/ui/support_fund/support_fund_page.dart';
import 'package:baeit/ui/survey/survey_page.dart';
import 'package:baeit/ui/view_more/view_more_page.dart';
import 'package:baeit/ui/word_cloud/word_cloud_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'my_baeit_bloc.dart';

class MyBaeitPage extends BlocStatefulWidget {
  final MainBloc mainBloc;

  MyBaeitPage({required this.mainBloc});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return MyBaeitState();
  }
}

class MyBaeitState extends BlocState<MyBaeitBloc, MyBaeitPage> {
  PageController bannerController = PageController(initialPage: 1000);
  int selectIndex = 0;

  appBar() {
    return baseAppBar(
        title: AppStrings.of(StringKey.myBaeitKr),
        context: context,
        onPressed: () {},
        close: true,
        action: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8, top: 6),
              child: IconButton(
                  onPressed: () {
                    if (dataSaver.nonMember) {
                      nonMemberDialog(
                          context: context,
                          title: '잠시만요',
                          content: AppStrings.of(StringKey.kakaoEasyLogin));
                      return;
                    }
                    amplitudeEvent('notification_enter', {'type': 'my_home'});
                    pushTransition(context, NotificationPage(myBaeitBloc: bloc))
                        .then((value) {
                      bloc.add(UpdateDataEvent());
                    });
                  },
                  icon: Image.asset(
                    AppImages.iAlarm,
                    width: 24,
                    height: 24,
                  )),
            ),
            dataSaver.alarmCount == 0
                ? Container()
                : Positioned(
                    right: 20,
                    top: 13,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(18)),
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Center(
                        child: customText(
                          dataSaver.alarmCount > 99
                              ? '99+'
                              : dataSaver.alarmCount.toString(),
                          style: TextStyle(
                              letterSpacing: 0,
                              color: AppColors.white,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T10)),
                        ),
                      ),
                    ),
                  )
          ],
        ));
  }

  profileView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          spaceH(30),
          ClipRRect(
            borderRadius: BorderRadius.circular(54),
            child: dataSaver.profileGet == null ||
                    dataSaver.profileGet!.profile == null
                ? Image.asset(AppImages.dfProfile, width: 54, height: 54)
                : Container(
                    width: 54,
                    height: 54,
                    child: CacheImage(
                      imageUrl: dataSaver.profileGet!.profile!,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                    ),
                  ),
          ),
          spaceH(10),
          dataSaver.profileGet == null
              ? customText(
                  '배잇이웃',
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T16)),
                )
              : GestureDetector(
                  onTap: () {
                    amplitudeEvent('profile_click', {'type': 'my_home'});
                    profileDialog(
                        context: context,
                        memberUuid: dataSaver.profileGet!.memberUuid);
                  },
                  child: customText(
                    '${dataSaver.profileGet!.nickName} >',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T16)),
                  ),
                )
        ],
      ),
    );
  }

  menuBarTitle(idx) {
    switch (idx) {
      case 0:
        return AppStrings.of(StringKey.recentBons);
      case 1:
        return AppStrings.of(StringKey.bookmarkWrite);
      case 2:
        return AppStrings.of(StringKey.myMadeClass);
      case 3:
        return '만든 게시글';
    }
  }

  menuBarImage(idx) {
    switch (idx) {
      case 0:
        return AppImages.iMyPageQuickRecent;
      case 1:
        return AppImages.iMyPageQuickLike;
      case 2:
        return AppImages.iMyPageQuickClass;
      case 3:
        return AppImages.iMyPageQuickRequest;
    }
  }

  menuBarCount(idx) {
    switch (idx) {
      case 0:
        return bloc.classCnt!.viewCnt > 99 ? '99+' : bloc.classCnt!.viewCnt;
      case 1:
        return bloc.classCnt!.likeCnt > 99 ? '99+' : bloc.classCnt!.likeCnt;
      case 2:
        return bloc.classCnt!.madeCnt > 99 ? '99+' : bloc.classCnt!.madeCnt;
      case 3:
        return bloc.classCnt!.communityCnt > 99
            ? '99+'
            : bloc.classCnt!.communityCnt;
    }
  }

  menuBarItem(idx) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: ElevatedButton(
                  onPressed: () {
                    if (dataSaver.nonMember) {
                      nonMemberDialog(
                          context: context,
                          title: '잠시만요',
                          content: AppStrings.of(StringKey.kakaoEasyLogin));
                      return;
                    }

                    if (idx == 0) {
                      amplitudeEvent('mybaeit_item_clicks', {'type': 'recent'});
                      pushTransition(
                              context,
                              RecentOrBookmarkPage(
                                  type: 'RECENT',
                                  profileGet: dataSaver.profileGet!))
                          .then((value) {
                        bloc.add(UpdateDataEvent());
                        if (value != null && value == 0) {
                          widget.mainBloc.add(MenuChangeEvent(select: value));
                        } else if (value == 2) {
                          widget.mainBloc.add(MenuChangeEvent(select: value));
                        }
                      });
                    } else if (idx == 1) {
                      amplitudeEvent(
                          'mybaeit_item_clicks', {'type': 'bookmark'});
                      pushTransition(
                              context,
                              RecentOrBookmarkPage(
                                  type: 'BOOKMARK',
                                  profileGet: dataSaver.profileGet!))
                          .then((value) {
                        bloc.add(UpdateDataEvent());
                        if (value != null && value == 0) {
                          widget.mainBloc.add(MenuChangeEvent(select: value));
                        } else if (value == 2) {
                          widget.mainBloc.add(MenuChangeEvent(select: value));
                        }
                      });
                    } else if (idx == 2) {
                      amplitudeEvent('mybaeit_item_clicks', {'type': 'made'});
                      pushTransition(context,
                              MyCreateClassPage(profile: dataSaver.profileGet))
                          .then((value) {
                        bloc.add(UpdateDataEvent());
                      });
                    } else if (idx == 3) {
                      amplitudeEvent(
                          'mybaeit_item_clicks', {'type': 'community'});
                      pushTransition(context, MyCreateCommunityPage());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: AppColors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Image.asset(
                    menuBarImage(idx),
                    width: 54,
                    height: 54,
                  )),
            ),
            dataSaver.profileGet == null
                ? Container()
                : Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 16,
                      padding: EdgeInsets.only(left: 16 / 3, right: 16 / 3),
                      decoration: BoxDecoration(
                          color: AppColors.accentLight50,
                          borderRadius: BorderRadius.circular(16 / 6)),
                      child: Center(
                        child: customText(
                          bloc.classCnt == null ? '0' : '${menuBarCount(idx)}',
                          style: TextStyle(
                              color: AppColors.accentLight10,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T10)),
                        ),
                      ),
                    ))
          ],
        ),
        spaceH(10),
        customText(
          menuBarTitle(idx),
          style: TextStyle(
              color: AppColors.gray600,
              fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
              fontSize: fontSizeSet(textSize: TextSize.T12)),
        )
      ],
    );
  }

  menuBar() {
    return Padding(
      padding: EdgeInsets.only(left: 36, right: 36),
      child: Row(
        children: [
          menuBarItem(0),
          Expanded(child: Container()),
          menuBarItem(1),
          Expanded(child: Container()),
          menuBarItem(2),
          Expanded(child: Container()),
          menuBarItem(3)
        ],
      ),
    );
  }

  listBarItem(idx, widget) {
    return GestureDetector(
      onTap: () async {
        if (idx == 1) {
          return;
          try {
            await ChannelTalk.setDebugMode(flag: false);
            await ChannelTalk.boot(
                pluginKey: '641678df-f344-4037-b309-44b3bb05bc59',
                memberHash: '.',
                memberId: dataSaver.userData!.memberUuid,
                language: 'korean');
          } on PlatformException catch (error) {
            debugPrint('channel talk error : $error');
          } catch (err) {}
          await ChannelTalk.showMessenger();
          return;
        } else if (idx == 3) {
          return;
        } else {
          if (dataSaver.nonMember) {
            nonMemberDialog(
                context: context,
                title: '잠시만요',
                content: AppStrings.of(StringKey.kakaoEasyLogin));
            return;
          }

          if (idx == 0) {
            pushTransition(context, FeedbackPage());
          } else if (idx == 1) {
          } else if (idx == 2) {
            pushTransition(context, NotificationSettingPage());
          } else if (idx == 4) {
            pushTransition(context, NoticePage());
          } else if (idx == 5) {
            pushTransition(context, ViewMorePage());
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 54,
        color: AppColors.white,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 54,
              decoration: BoxDecoration(
                  color: idx == 5
                      ? dataSaver.forceUpdate
                          ? AppColors.accentLight60
                          : AppColors.white
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spaceW(10),
                  Expanded(
                    child: widget,
                    flex: 2,
                  ),
                  Expanded(child: Container()),
                  idx == 1
                      ? Container(
                          width: 44,
                          height: 24,
                          child: Image.asset(AppImages.iChatConsult),
                        )
                      : Container(),
                  idx == 1 ? spaceW(10) : Container(),
                  idx == 5 && dataSaver.forceUpdate
                      ? Row(
                          children: [
                            Image.asset(
                              AppImages.iTipExclamationU,
                              width: 12,
                              height: 12,
                            ),
                            spaceW(4),
                            customText('업데이트가 있습니다',
                                style: TextStyle(
                                    color: AppColors.accentDark10,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                            spaceW(10)
                          ],
                        )
                      : Container(),
                  Transform.rotate(
                    angle: 180 * math.pi / 180,
                    child: Image.asset(
                      AppImages.iChevronPrev,
                      width: 16,
                      height: 16,
                      color: AppColors.gray400,
                    ),
                  ),
                  spaceW(10)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  listBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          spaceH(20),
          listBarItem(
              0,
              customText(
                AppStrings.of(StringKey.baeitExperience),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              )),
          // listBarItem(
          //     1,
          //     customText(AppStrings.of(StringKey.kakaoCounseling),
          //         style: TextStyle(
          //             color: AppColors.gray900,
          //             fontWeight: weightSet(textWeight: TextWeight.BOLD),
          //             fontSize: fontSizeSet(textSize: TextSize.T14)))),
          listBarItem(
              2,
              customText(
                AppStrings.of(StringKey.notificationSetting),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              )),
          listBarItem(
              4,
              customText(
                AppStrings.of(StringKey.notice),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              )),
          listBarItem(
              5,
              customText(
                AppStrings.of(StringKey.plusMore),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              )),
        ],
      ),
    );
  }

  topLogin() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 20),
      color: AppColors.white.withOpacity(0.6),
      child: Stack(
        children: [
          Column(
            children: [profileView(), spaceH(40), menuBar()],
          ),
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Container(
              color: AppColors.black.withOpacity(0),
            ),
          )),
          Positioned(
            top: 20,
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 54,
                padding: EdgeInsets.only(left: 48, right: 48),
                child: ElevatedButton(
                  onPressed: () {
                    pushTransition(context, SignupPage());
                  },
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppColors.gray300))),
                  child: Row(
                    children: [
                      customText(
                        AppStrings.of(StringKey.kakao5secondLogin),
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T13)),
                      ),
                      Expanded(child: Container()),
                      Image.asset(
                        AppImages.iKakaoCircle,
                        width: 28,
                        height: 28,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  keywordBanner() {
    return Container(
            width: MediaQuery.of(context).size.width,
            height: 116,
            child: Stack(
              children: [
                Positioned.fill(
                  left: 0,
                  right: 0,
                  child: PageView.builder(
                    itemBuilder: (context, idx) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: GestureDetector(
                            onTap: () {
                              if ((idx % 2) == 0) {
                                dataSaver.bannerMoveEnable = true;
                                amplitudeEvent('keyword_list_banner_open', {});
                                pushTransition(context, WordCloudPage());
                              } else {
                                pushTransition(
                                    context,
                                    SurveyPage(
                                      url: bloc.survey!.url,
                                      surveyUuid: bloc.survey!.surveyUuid,
                                    ));
                              }
                            },
                            child: Image.asset(
                              bloc.banners[idx % 2],
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            )),
                      );
                    },
                    controller: bannerController,
                    physics: bloc.survey == null
                        ? NeverScrollableScrollPhysics()
                        : AlwaysScrollableScrollPhysics(),
                    onPageChanged: (idx) {
                      setState(() {
                        selectIndex = idx % 2;
                      });
                    },
                  ),
                ),
                bloc.survey == null
                    ? Container()
                    : Positioned(
                        left: 35,
                        bottom: 16,
                        child: Row(
                          children: [
                            ClipOval(
                                child: Container(
                              width: 6,
                              height: 6,
                              color: selectIndex == 0
                                  ? AppColors.black.withOpacity(0.54)
                                  : AppColors.black.withOpacity(0.16),
                            )),
                            spaceW(6),
                            ClipOval(
                                child: Container(
                              width: 6,
                              height: 6,
                              color: selectIndex == 1
                                  ? AppColors.black.withOpacity(0.54)
                                  : AppColors.black.withOpacity(0.16),
                            ))
                          ],
                        ),
                      )
              ],
            ),
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
                  resizeToAvoidBottomInset: true,
                  backgroundColor: AppColors.white,
                  appBar: appBar(),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        dataSaver.profileGet == null
                            ? Container()
                            : profileView(),
                        dataSaver.nonMember ? topLogin() : Container(),
                        dataSaver.nonMember ? Container() : spaceH(40),
                        dataSaver.nonMember ? Container() : menuBar(),
                        dataSaver.nonMember ? Container() : spaceH(20),
                        // dataSaver.nonMember ? Container() : applicantBanner(),
                        dataSaver.nonMember ? Container() : keywordBanner(),
                        listBar(),
                        spaceH(20),
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

  applicantBanner() {
    return dataSaver.reward != null && dataSaver.reward!.viewFlag == 1
        ? Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: GestureDetector(
              onTap: () {
                amplitudeEvent('reward_click', {});
                pushTransition(
                    context, SupportFundPage(reward: dataSaver.reward!));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CacheImage(
                  imageUrl: dataSaver.reward!.bannerImages[0]
                      .toView(context: context),
                  width: MediaQuery.of(context).size.width * 3,
                  heightSet: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : Container();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is MyBaeitInitState) {
      dataSaver.myBaeitBloc = bloc;
    }

    if (state is MyBaeitReloadState) {
      setState(() {});
    }
  }

  @override
  MyBaeitBloc initBloc() {
    return MyBaeitBloc(context)..add(MyBaeitInitEvent());
  }
}
