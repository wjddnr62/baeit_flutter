import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/chat/chat_bloc.dart';
import 'package:baeit/ui/chat/chat_detail_page.dart';
import 'package:baeit/ui/chat/chat_page.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/create_class/create_class_page.dart';
import 'package:baeit/ui/feedback/feedback_detail_page.dart';
import 'package:baeit/ui/feedback/feedback_page.dart';
import 'package:baeit/ui/keyword_setting/keyword_setting_page.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/learn/learn_page.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_page.dart';
import 'package:baeit/ui/my_create_class/my_create_class_page.dart';
import 'package:baeit/ui/my_create_community/my_create_community_page.dart';
import 'package:baeit/ui/notice/notice_detail_page.dart';
import 'package:baeit/ui/notification/notification_page.dart';
import 'package:baeit/ui/profile/profile_page.dart';
import 'package:baeit/ui/recent_or_bookmark/recent_or_bookmark_page.dart';
import 'package:baeit/ui/review/review_detail_page.dart';
import 'package:baeit/ui/splash/splash_page.dart';
import 'package:baeit/ui/word_cloud/word_cloud_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_links/uni_links.dart';

class MainPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return MainState();
  }
}

class MainState extends BlocState<MainBloc, MainPage>
    with TickerProviderStateMixin {
  Animation? animation;
  AnimationController? balloonAnimation;

  selectPage(int index) {
    return IndexedStack(
      index: index == 0 || index == 1 || index == 2 ? 0 : index - 2,
      children: [LearnPage(), ChatPage(), MyBaeitPage(mainBloc: bloc)],
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    dataSaver.mainBloc = bloc;
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: GestureDetector(
              onTap: () {
                if (bloc.plus) {
                  bloc.add(PlusMenuChangeEvent());
                }
              },
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                        bottom: bloc.menuBarHide ? 0 : 60,
                        left: 0,
                        right: 0,
                        top: 0,
                        child: selectPage(bloc.selectMenu)),
                    createMenu(),
                    bloc.balloonShow
                        ? Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 60,
                            child: Lottie.asset(
                                AppImages.communityFirstPopupBalloon,
                                controller: balloonAnimation,
                                onLoaded: (composition) {
                              setState(() {
                                balloonAnimation!
                                  ..duration = composition.duration;
                                balloonAnimation!.repeat();
                              });
                            }))
                        : Container(),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: bloc.menuBarHide ? 0 : 60,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          boxShadow: bloc.shadowAndPlusTapView
                              ? [
                                  BoxShadow(
                                    color: AppColors.black.withOpacity(0.03),
                                    blurRadius: 12,
                                    offset: Offset(0, -8),
                                  )
                                ]
                              : null,
                        ),
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: menuBar(),
                      ),
                    ),
                    (bloc.selectMenu == 0 || bloc.selectMenu == 2) &&
                            bloc.shadowAndPlusTapView
                        ? Positioned(
                            bottom: 72,
                            right: 12,
                            child: plusTap(),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          );
        });
  }

  createMenu() {
    return Positioned(
      bottom: 130,
      right: 12,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.ease,
        width: 200,
        height: bloc.plus ? 100 : 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bloc.selectMenu != 0
                ? Container()
                : Flexible(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.accent,
                          image: DecorationImage(
                              image: AssetImage(AppImages.imgClassMake))),
                      child: ElevatedButton(
                        onPressed: () {
                          if (!bloc.classMadeCheck) {
                            showToast(
                                context: context,
                                text:
                                    AppStrings.of(StringKey.addMaxClassToast));
                          } else {
                            bloc.add(PlusMenuChangeEvent());
                            if (!dataSaver.nonMember) {
                              amplitudeRevenue(
                                  productId: 'class_register', price: 3);
                              amplitudeEvent('class_register',
                                  {'inflow_page': 'main_register'});
                              if (production == 'prod-release' &&
                                  kReleaseMode) {
                                Airbridge.event.send(ViewHomeEvent(
                                    option: EventOption(label: 'home_screen')));
                                Airbridge.event
                                    .send(Event('class_register_start'));
                              }
                              pushTransition(
                                  context,
                                  CreateClassPage(
                                    profileGet: dataSaver.profileGet!,
                                    floating: true,
                                    previousPage: 'main_register',
                                  )).then((value) {
                                if (value != null) {
                                  ClassDetailPage classDetailPage =
                                      ClassDetailPage(
                                    classUuid: value,
                                    bloc: bloc,
                                    mainNeighborHood: dataSaver.neighborHood[
                                        dataSaver.neighborHood.indexWhere(
                                            (element) =>
                                                element.representativeFlag ==
                                                1)],
                                    profileGet: dataSaver.nonMember
                                        ? null
                                        : dataSaver.profileGet,
                                  );
                                  dataSaver.keywordClassDetail =
                                      classDetailPage;
                                  pushTransition(context, classDetailPage);
                                }
                              });
                            } else {
                              nonMemberDialog(
                                  context: context,
                                  title: AppStrings.of(StringKey.alertClassAdd),
                                  content: AppStrings.of(
                                      StringKey.alertClassAddContent));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8))),
                            padding: EdgeInsets.all(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: customText('알려줄래요',
                                    style: TextStyle(
                                        color: AppColors.accentLight40,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T15)),
                                    textAlign: TextAlign.start),
                              ),
                            ),
                            spaceH(24),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  customText('클래스 만들기',
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.BOLD),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T15))),
                                  spaceW(8),
                                  Image.asset(
                                    AppImages.iGotoTrans2,
                                    width: 20,
                                    height: 20,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  menuBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        menuBarTap(0),
        Expanded(child: Container()),
        menuBarTap(1),
        Expanded(child: Container()),
        menuBarTap(2),
        Expanded(child: Container()),
        menuBarTap(3),
        Expanded(child: Container()),
        menuBarTap(4)
      ],
    );
  }

  plusTap() {
    return Container(
      width: 48,
      height: 48,
      child: ElevatedButton(
          onPressed: () {
            bloc.closePlusMenu = false;
            bloc.add(PlusMenuChangeEvent());
            // Future.delayed(Duration(milliseconds: 2500), () {
            //   bloc.closePlusMenu = true;
            //   dataSaver.mainBloc!.closePlusMenu = true;
            // });
          },
          style: ElevatedButton.styleFrom(
              primary: bloc.plus ? AppColors.greenGray400 : AppColors.primary,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48))),
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.125)
                .animate(bloc.plusAnimationController!),
            child: Image.asset(
              AppImages.iPlusW,
              width: 28,
              height: 28,
              color: AppColors.white,
            ),
          )),
    );
  }

  menuBarTap(int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            if (index != bloc.selectMenu) {
              if (bloc.plus) {
                bloc.add(PlusMenuChangeEvent());
              }

              bloc.animationControllers[index].forward(from: 0.0);
              bloc.add(MenuChangeEvent(select: index));
              if (index == 0) {
                if (dataSaver.learnBloc!.snapIndex == 0) {
                  if (bloc.shadowAndPlusTapView) {
                    bloc.add(ShadowAndPlusTapChangeEvent());
                  }
                } else if (dataSaver.learnBloc!.snapIndex == 1) {
                  if (!bloc.shadowAndPlusTapView) {
                    bloc.add(ShadowAndPlusTapChangeEvent());
                  }
                }
              }
              if (index == 2) {
                if (prefs!.getBool('communityFirstIn') ?? true) {
                  bloc.balloonShow = true;
                  await prefs!.setBool('communityFirstIn', false);
                  setState(() {});
                  dataSaver.learnBloc!.add(CommunityFirstInEvent());
                }
                if (!bloc.shadowAndPlusTapView) {
                  bloc.add(ShadowAndPlusTapChangeEvent());
                }
              }
              if (index == 3) {
                dataSaver.chatBloc!.add(AnimationStartEvent());
              }
            }
          },
          child: Container(
            width: 55,
            color: AppColors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Transform.scale(
                        scale: bloc.animations[index].value,
                        child: Image.asset(
                          bloc.selectMenu == index
                              ? bloc.menuActiveIcon[index]
                              : bloc.menuDeActiveIcon[index],
                          width: 24,
                          height: 24,
                        )),
                    dataSaver.chatRoom == null || index != 3
                        ? Positioned(top: 0, right: 0, child: Container())
                        : dataSaver.chatRoom!.totalUnreadCnt == 0
                            ? Positioned(top: 0, right: 0, child: Container())
                            : Positioned(
                                top: 0,
                                right: 0,
                                child: Align(
                                  widthFactor: 0,
                                  heightFactor: 0.5,
                                  child: Container(
                                    height: 16,
                                    constraints: BoxConstraints(minWidth: 16),
                                    padding: EdgeInsets.only(left: 4, right: 4),
                                    decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: Center(
                                      child: customText(
                                        dataSaver.chatRoom!.totalUnreadCnt > 99
                                            ? '99+'
                                            : dataSaver.chatRoom!.totalUnreadCnt
                                                .toString(),
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T10)),
                                      ),
                                    ),
                                  ),
                                )),
                    dataSaver.forceUpdate && index == 4
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: Align(
                                widthFactor: 0.2,
                                heightFactor: 0.5,
                                child: Image.asset(
                                  AppImages.iUpdateCheck,
                                  width: 22,
                                  height: 16,
                                )))
                        : Positioned(top: 0, right: 0, child: Container())
                  ],
                ),
                index == 2 && (prefs!.getBool('communityFirstIn') ?? true)
                    ? spaceH(4)
                    : spaceH(6),
                index == 2 && (prefs!.getBool('communityFirstIn') ?? true)
                    ? Image.asset(
                        AppImages.iNew,
                        height: 16,
                      )
                    : customText(bloc.menuName[index],
                        style: TextStyle(
                            color: bloc.selectMenu == index
                                ? AppColors.primary
                                : AppColors.greenGray200,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T10))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is MainInitState) {
      dataSaver.iosBottom = MediaQuery.of(context).padding.bottom;
      dataSaver.statusTop = MediaQuery.of(context).padding.top;
    }

    if (state is MenuChangeState) {
      late String view;
      if (bloc.selectMenu == 0) {
        view = 'class';
      } else if (bloc.selectMenu == 1) {
        view = 'gather';
      } else if (bloc.selectMenu == 2) {
        view = 'community';
      } else if (bloc.selectMenu == 3) {
        view = 'chat';
      } else if (bloc.selectMenu == 4) {
        view = 'my_baeit';
      }
      amplitudeEvent('change_view', {'view': view});
      if (dataSaver.myBaeitBloc != null)
        dataSaver.myBaeitBloc!.add(UpdateDataEvent());
      setState(() {});
    }

    if (state is PlusMenuChangeState) {
      if (bloc.plus) {
        bloc.plusAnimationController!.forward(from: 0.0);
      } else {
        bloc.plusAnimationController!.reverse();
      }
    }

    if (state is StopState) {
      pushAndRemoveUntil(
          context,
          SplashPage(
            stopText: state.stopText,
          ));
    }

    if (state is ChatCountReloadState) {
      setState(() {});
      if (dataSaver.chatRoom!.totalUnreadCnt == 0) {
        flutterLocalNotificationsPlugin?.cancel(0);
      }
    }
  }

  @override
  MainBloc initBloc() {
    return MainBloc(context)..add(MainInitEvent(animationVsync: this));
  }

  managerNotificationMove(String type) {
    switch (type) {
      case 'MENU_CLASS':
        return bloc.add(MenuChangeEvent(select: 0));
      case 'MENU_THEME':
        return bloc.add(MenuChangeEvent(select: 1));
      case 'MENU_COMMUNITY':
        return bloc.add(MenuChangeEvent(select: 2));
      case 'MENU_CHAT':
        return bloc.add(MenuChangeEvent(select: 3));
      case 'MENU_MY_BAEIT':
        return bloc.add(MenuChangeEvent(select: 4));
      case 'KEYWORDS_BANNER':
        return pushTransition(context, WordCloudPage());
      case 'KEYWORDS_SETTING':
        return pushTransition(context, KeywordSettingPage());
      case 'MY_CLASS_LIST':
        return pushTransition(
            context, MyCreateClassPage(profile: dataSaver.profileGet));
      case 'MY_COMMUNITY_LIST':
        return pushTransition(context, MyCreateCommunityPage());
      case 'LIKE_CLASS_LIST':
        return pushTransition(
            context,
            RecentOrBookmarkPage(
              type: 'BOOKMARK',
              profileGet: dataSaver.profileGet!,
              tapSelect: 0,
            ));
      case 'LIKE_COMMUNITY_LIST':
        return pushTransition(
            context,
            RecentOrBookmarkPage(
              type: 'BOOKMARK',
              profileGet: dataSaver.profileGet!,
              tapSelect: 1,
            ));
      case 'FEEDBACK':
        return pushTransition(context, FeedbackPage());
      case 'PROFILE_EDIT':
        return pushTransition(
            context,
            ProfilePage(
              profile: dataSaver.profileGet,
              type: dataSaver.profileGet!.type,
            ));
    }
  }

  typeMovePage(type, data) {
    if (type != null) {
      amplitudeEvent('touch_push', {
        'type': type == 'CLASS_MADE_KEYWORD_ALARM'
            ? 'class_keyword'
            : type == 'CLASS_REQUEST_KEYWORD_ALARM'
                ? 'request_keyword'
                : type,
        'content': data
      });
    }

    switch (type) {
      case 'MANAGER_NOTIFICATION':
        CommonRepository.pushClick(data['pushUuid']);
        return managerNotificationMove(data['targetPage']);
      case 'FEEDBACK':
        return pushTransition(
            context, FeedbackDetailPage(feedbackUuid: data['feedbackUuid']));
      case 'MEMBER_STOP':
        return;
      case 'MEMBER_STOP_RELEASE':
        return;
      case 'CLASS_MADE_STOP':
        return pushTransition(
            context,
            ClassDetailPage(
                profileGet: dataSaver.profileGet,
                classUuid: data['classUuid'],
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: true));
      case 'CLASS_MADE_STOP_RELEASE':
        return pushTransition(
            context,
            ClassDetailPage(
                profileGet: dataSaver.profileGet,
                classUuid: data['classUuid'],
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: true));
      case 'CHEERING_DONE':
        return;
      case 'NOTICE':
        return pushTransition(
            context, NoticeDetailPage(noticeUuid: data['noticeUuid']));
      case 'CHATTING':
        if (data['chatRoomUuid'] != dataSaver.chatRoomUuid) {
          bloc.add(MenuChangeEvent(select: 3));
          return pushTransition(
              context, ChatDetailPage(chatRoomUuid: data['chatRoomUuid']));
        }
        return;
      case 'CLASS_MADE_KEYWORD_ALARM':
        return pushTransition(
            context,
            NotificationPage(
              type: 1,
              detailType: 1,
            ));
      case 'CLASS_REQUEST_KEYWORD_ALARM':
        return pushTransition(
            context,
            NotificationPage(
              type: 1,
              detailType: 2,
            ));
      case 'CRM_SSAM_MOTIVATION':
        return pushTransition(
            context, MyCreateClassPage(profile: dataSaver.profileGet));
      case 'ADD_CLASS_MADE_LIKE':
        return pushTransition(
            context,
            ClassDetailPage(
                profileGet: dataSaver.profileGet,
                classUuid: data['classUuid'],
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: true));
      case 'ADD_COMMUNITY_LIKE':
        return pushTransition(
            context, CommunityDetailPage(communityUuid: data['communityUuid']));
      case 'ADD_COMMUNITY_COMMENT':
        return pushTransition(
            context, CommunityDetailPage(communityUuid: data['communityUuid']));
      case 'ADD_COMMUNITY_REPLY_COMMENT':
        return pushTransition(
            context, CommunityDetailPage(communityUuid: data['communityUuid']));
      case 'CLASS_REVIEW_SAVE_ALARM':
        if (data['chatRoomUuid'] != dataSaver.chatRoomUuid) {
          bloc.add(MenuChangeEvent(select: 3));
          return pushTransition(
              context, ChatDetailPage(chatRoomUuid: data['chatRoomUuid']));
        }
        return;
      case 'CLASS_REVIEW_SAVE':
        return pushTransition(
            context,
            ReviewDetailPage(
              classUuid: data['classUuid'],
              myClass: true,
            ));
      case 'CLASS_REVIEW_ANSWER_SAVE':
        return pushTransition(
            context,
            ReviewDetailPage(
              classUuid: data['classUuid'],
            ));
      case 'COMMUNIYT_KEYWORD_ALARM':
        return pushTransition(
            context, CommunityDetailPage(communityUuid: data['communityUuid']));
    }
  }

  pushInteractive(payload) {
    Map<String, dynamic> data = {};
    if (payload != null && payload != '') {
      data = jsonDecode(payload);
    }

    typeMovePage(data['messageType'], data);
  }

  void _configureSelectNotificationSubject(String payload) {
    pushInteractive(payload);
  }

  initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      print(
          "Dynamic Link : ${dynamicLink?.link.queryParameters}, ${dynamicLink?.link}");
      Map<String, String>? data = dynamicLink?.link.queryParameters;
      String? type = data!['type'];
      String? classUuid = data['classUuid'];
      String? memberUuid = data['memberUuid'];
      String? communityUuid = data['communityUuid'];
      if (!dataSaver.nonMember) {
        if (type == 'MADE_CLASS_DETAILS') {
          pushTransition(
              context,
              ClassDetailPage(
                profileGet: dataSaver.profileGet,
                classUuid: classUuid!,
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: dataSaver.userData!.memberUuid == memberUuid!
                    ? true
                    : false,
              ));
        } else if (type == 'ALIM_TALK_CHATTING') {
        } else if (type == 'COMMUNITY_DETAILS') {
          pushTransition(
              context, CommunityDetailPage(communityUuid: communityUuid!));
        }
      } else {
        if (type == 'MADE_CLASS_DETAILS') {
          pushTransition(
              context,
              ClassDetailPage(
                classUuid: classUuid!,
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: false,
              ));
        } else if (type == 'ALIM_TALK_CHATTING') {
        } else if (type == 'COMMUNITY_DETAILS') {
          pushTransition(
              context, CommunityDetailPage(communityUuid: communityUuid!));
        }
      }
    }, onError: (OnLinkErrorException e) async {
      debugPrint('Dynamic Link Error : ${e.message}');
    });

    final PendingDynamicLinkData? deeplinkData =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = deeplinkData?.link;
    if (deepLink != null) {
      Map<String, String>? data = deepLink.queryParameters;

      String? type = data['type'] ?? '';
      String? classUuid = data['classUuid'] ?? '';
      String? memberUuid = data['memberUuid'] ?? '';
      String? communityUuid = data['communityUuid'] ?? '';
      if (!dataSaver.nonMember) {
        if (type == 'MADE_CLASS_DETAILS') {
          pushTransition(
              context,
              ClassDetailPage(
                profileGet: dataSaver.profileGet,
                classUuid: classUuid,
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: dataSaver.userData!.memberUuid == memberUuid ? true : false,
              ));
        } else if (type == 'ALIM_TALK_CHATTING') {
        } else if (type == 'COMMUNITY_DETAILS') {
          pushTransition(
              context, CommunityDetailPage(communityUuid: communityUuid));
        }
      } else {
        if (dataSaver.neighborHood.length == 0) {
          ReturnData returnData =
              await NeighborHoodSelectRepository.nonMemberArea();
          dataSaver.neighborHood.add(NeighborHood.fromJson(returnData.data));

          List<String> data = [];

          for (int i = 0; i < dataSaver.neighborHood.length; i++) {
            data.add(jsonEncode(dataSaver.neighborHood[i].toMapAll()));
          }
          await prefs!.setString('guestNeighborHood', jsonEncode(data));
        }

        if (type == 'MADE_CLASS_DETAILS') {
          pushTransition(
              context,
              ClassDetailPage(
                classUuid: classUuid,
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: false,
              ));
        } else if (type == 'ALIM_TALK_CHATTING') {
        } else if (type == 'COMMUNITY_DETAILS') {
          pushTransition(
              context, CommunityDetailPage(communityUuid: communityUuid));
        }
      }
    }
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  StreamSubscription? sub;

  void _handleIncomingLinks() {
    // foreground, background
    sub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      Map<String, String>? data = uri?.queryParameters;
      String? type = data!['type'];
      String? classUuid = data['classUuid'];
      String? memberUuid = data['memberUuid'];

      if (!dataSaver.nonMember) {
        if (type == 'MADE_CLASS_DETAILS') {
          pushTransition(
              context,
              ClassDetailPage(
                profileGet: dataSaver.profileGet,
                classUuid: classUuid!,
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: dataSaver.userData!.memberUuid == memberUuid!
                    ? true
                    : false,
              ));
        } else if (type == 'feedback') {
          pushTransition(context, FeedbackPage());
        } else if (type == 'gather_view') {
          bloc.add(MenuChangeEvent(select: 1));
        } else if (type == 'community') {
          bloc.add(MenuChangeEvent(select: 2));
        }
      } else {
        if (type == 'MADE_CLASS_DETAILS') {
          pushTransition(
              context,
              ClassDetailPage(
                classUuid: classUuid!,
                mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)],
                my: false,
              ));
        }
      }

      if (data
          .toString()
          .split('&')[data
              .toString()
              .split('&')
              .indexWhere((element) => element.contains('channel'))]
          .replaceAll('channel=', '')
          .contains('crm')) {
        amplitudeEvent('crm_push', {
          'type': data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
        });
      }

      if (data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
              .contains('google') &&
          !data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
              .contains('web')) {
        amplitudeEvent('google_ads', {
          'type': data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
        });
      }

      if (data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '') ==
          'kakao') {
        amplitudeEvent('kakao_ads', {
          'type': data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
        });
      }

      if (data
          .toString()
          .split('&')[data
              .toString()
              .split('&')
              .indexWhere((element) => element.contains('channel'))]
          .replaceAll('channel=', '')
          .contains('homepage')) {
        amplitudeEvent('homepage_download', {
          'type': data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
        });
      }
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
    });
  }

  Future<void> _handleInitialUri() async {
    // terminated
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;

      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          Map<String, String>? data = uri.queryParameters;

          String? type = data['type'];
          String? classUuid = data['classUuid'];
          String? memberUuid = data['memberUuid'];
          if (!dataSaver.nonMember) {
            if (type == 'MADE_CLASS_DETAILS') {
              pushTransition(
                  context,
                  ClassDetailPage(
                    profileGet: dataSaver.profileGet,
                    classUuid: classUuid!,
                    mainNeighborHood: dataSaver.neighborHood[
                        dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)],
                    my: dataSaver.userData!.memberUuid == memberUuid!
                        ? true
                        : false,
                  ));
            } else if (type == 'feedback') {
              pushTransition(context, FeedbackPage());
            } else if (type == 'gather_view') {
              bloc.add(MenuChangeEvent(select: 1));
            } else if (type == 'community') {
              bloc.add(MenuChangeEvent(select: 2));
            }
          } else {
            if (type == 'MADE_CLASS_DETAILS') {
              pushTransition(
                  context,
                  ClassDetailPage(
                    classUuid: classUuid!,
                    mainNeighborHood: dataSaver.neighborHood[
                        dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)],
                    my: false,
                  ));
            }
          }

          if (data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
              .contains('crm')) {
            amplitudeEvent('crm_push', {
              'type': data
                  .toString()
                  .split('&')[data
                      .toString()
                      .split('&')
                      .indexWhere((element) => element.contains('channel'))]
                  .replaceAll('channel=', '')
            });
          }

          if (data
              .toString()
              .split('&')[data
                  .toString()
                  .split('&')
                  .indexWhere((element) => element.contains('channel'))]
              .replaceAll('channel=', '')
              .contains('google')) {
            amplitudeEvent('google_ads', {
              'type': data
                  .toString()
                  .split('&')[data
                      .toString()
                      .split('&')
                      .indexWhere((element) => element.contains('channel'))]
                  .replaceAll('channel=', '')
            });
          }

          if (data
                  .toString()
                  .split('&')[data
                      .toString()
                      .split('&')
                      .indexWhere((element) => element.contains('channel'))]
                  .replaceAll('channel=', '') ==
              'kakao') {
            amplitudeEvent('kakao_ads', {
              'type': data
                  .toString()
                  .split('&')[data
                      .toString()
                      .split('&')
                      .indexWhere((element) => element.contains('channel'))]
                  .replaceAll('channel=', '')
            });
          }

          if (data
                  .toString()
                  .split('&')[data
                      .toString()
                      .split('&')
                      .indexWhere((element) => element.contains('channel'))]
                  .replaceAll('channel=', '') ==
              'homepage') {
            amplitudeEvent('homepage_download', {
              'type': data
                  .toString()
                  .split('&')[data
                      .toString()
                      .split('&')
                      .indexWhere((element) => element.contains('channel'))]
                  .replaceAll('channel=', '')
            });
          }
        }
      } on PlatformException {
        print('failed to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri : $err');
      }
    }
  }

  checkNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin!
            .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.payload;
      if (notificationAppLaunchDetails.payload != null) {
        selectedNotificationPayload = notificationAppLaunchDetails.payload;
        selectNotificationSubject.add(notificationAppLaunchDetails.payload);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    balloonAnimation = AnimationController(vsync: this);

    FlutterDownloader.registerCallback(downloadCallback);

    selectNotificationSubject = PublishSubject<String?>();

    selectNotificationSubject.listen((String? payload) async {
      messaging.getInitialMessage();
      if (!dataSaver.logout) {
        _configureSelectNotificationSubject(payload!);
      }
      selectedNotificationPayload = null;
    });

    checkNotification();

    if (Platform.isIOS) {
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          selectedNotificationPayload = jsonEncode(message.data);
          selectNotificationSubject.add(jsonEncode(message.data));
        }
      });
    }

    initDynamicLinks();
    _handleIncomingLinks();
    _handleInitialUri();

    for (int i = 0; i < bloc.menuActiveIcon.length; i++) {
      bloc.animationControllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 400))
        ..addListener(() {
          setState(() {});
        }));
      bloc.animations.add(Tween(begin: 1.25, end: 1.0).animate(CurvedAnimation(
          parent: bloc.animationControllers[i], curve: Curves.elasticOut)));
      bloc.animationControllers[i].value = 1;
    }

    bloc.plusAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150))
          ..addListener(() {
            setState(() {});
          });
    bloc.plusAnimationController!.value = 0;
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    balloonAnimation!.dispose();
    super.dispose();
  }
}

bool _initialUriIsHandled = false;
