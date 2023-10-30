import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/community_made.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_create/community_create_page.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/gather/gather_bloc.dart';
import 'package:baeit/ui/gather/gather_page.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/neighborhood_select/neighborhood_select_page.dart';
import 'package:baeit/ui/notification/notification_page.dart';
import 'package:baeit/ui/profile/word_cloud_dialog_page.dart';
import 'package:baeit/ui/search/search_bloc.dart' as searchBloc;
import 'package:baeit/ui/search/search_page.dart';
import 'package:baeit/ui/support_fund/support_fund_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/double_back_press.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class LearnPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return LearnState();
  }
}

class LearnState extends BlocState<LearnBloc, LearnPage>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> listKey = GlobalKey();

  PanelController panelController = PanelController();
  PanelController filterController = PanelController();

  ScrollController? scrollController;
  ScrollController? communityScrollController;
  ScrollController? selectScrollController;
  LocationTrackingMode trackingMode = LocationTrackingMode.None;

  AnimationController? notificationAnimation;
  AnimationController? loadingController;

  List<CommunityMade> communityMade = [
    // CommunityMade(
    //     icon: AppImages.iCategoryCQuestion,
    //     type: '알려주세요',
    //     description: '원하는 클래스 요청하기'),
    CommunityMade(
        icon: AppImages.iCategoryCChange,
        type: '배움교환',
        description: '재능 주고받을 이웃찾기'),
    CommunityMade(
        icon: AppImages.iCategoryCTogether,
        type: '배움모임',
        description: '같이 배울 이웃 모으기'),
    // CommunityMade(
    //     icon: AppImages.iCategoryCStory,
    //     type: '얘기해요',
    //     description: '배움과 관련된 모든 이야기'),
  ];

  bool learnLoadingPass = false;

  @override
  Widget blocBuilder(BuildContext context, state) {
    dataSaver.learnBloc = bloc;
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          if (bloc.closeNeighborhoodSelecter) {
            if (bloc.neighborhoodSelecterView) {
              bloc.neighborhoodSelecterAnimationEnd = false;
              bloc.neighborhoodSelecterView = false;
              bloc.add(ChangeViewEvent());
            }
          }
          if (dataSaver.mainBloc != null &&
              dataSaver.mainBloc!.plus &&
              dataSaver.mainBloc!.closePlusMenu) {
            dataSaver.mainBloc!.add(PlusMenuChangeEvent());
          }
          if (bloc.notificationAnimation && bloc.notificationAnimationClose) {
            bloc.notificationAnimation = false;
            bloc.add(ChangeViewEvent());
          }
          return WillPopScope(
            onWillPop: () async {
              if (bloc.neighborhoodSelecterView) {
                setState(() {
                  bloc.neighborhoodSelecterAnimationEnd = false;
                  bloc.neighborhoodSelecterView = false;
                });
              } else if (filterController.isPanelOpen) {
                filterController.close();
              } else if (bloc.communityPanelController.isPanelOpen) {
                dataSaver.mainBloc!.add(PlusMenuChangeEvent());
              } else if (bloc.search) {
                dataSaver.searchBloc!.searchController.text = '';
                dataSaver.searchBloc!.classList = null;
                FocusScope.of(context).unfocus();
                dataSaver.mainBloc!.add(MenuBarHideEvent(hide: false));
                bloc.add(SearchChangeEvent());
              } else {
                return await appExitBackPress(context);
              }

              return Future.value(false);
            },
            child: Container(
              color: AppColors.white,
              child: SafeArea(
                  child: GestureDetector(
                onTap: () {
                  if (dataSaver.mainBloc!.plus) {
                    dataSaver.mainBloc!.add(PlusMenuChangeEvent());
                  }
                  setState(() {
                    if (bloc.neighborhoodSelecterView) {
                      bloc.neighborhoodSelecterAnimationEnd = false;
                    }
                    bloc.neighborhoodSelecterView = false;
                    FocusScope.of(context).unfocus();
                  });
                },
                child: Stack(
                  children: [
                    IndexedStack(
                      index: bloc.search ? 1 : 0,
                      children: [
                        Scaffold(
                          resizeToAvoidBottomInset: true,
                          backgroundColor: AppColors.white,
                          appBar: AppBar(
                            toolbarHeight: 60,
                            backgroundColor: AppColors.white,
                            elevation: bloc.snapIndex == 2
                                ? 0
                                : bloc.learnType == 0
                                    ? 10
                                    : 0,
                            shadowColor: AppColors.black12,
                            leadingWidth: 0,
                            leading: Container(),
                            titleSpacing: 0,
                            title: appBarContent(),
                          ),
                          body: Container(
                            height: MediaQuery.of(context).size.height -
                                (60 +
                                    dataSaver.statusTop +
                                    dataSaver.iosBottom),
                            child: Stack(
                              children: [
                                IndexedStack(
                                  index: bloc.learnType,
                                  children: [
                                    Stack(
                                      children: [
                                        Stack(
                                          children: [
                                            mapView(),
                                            loadingView(bloc.loading)
                                          ],
                                        ),
                                        myNeighborHoodMove(),
                                        mapSlidingUpPanel()
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                            color: AppColors.greenGray50,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          child: communityTab(),
                                        ),
                                        Positioned.fill(
                                            top: 48,
                                            child: RefreshIndicator(
                                              onRefresh: () async {
                                                bloc.add(
                                                    CommunityReloadEvent());
                                              },
                                              color: AppColors.primary,
                                              child: SingleChildScrollView(
                                                controller:
                                                    communityScrollController,
                                                child: Container(
                                                  child: bloc.communityList ==
                                                              null ||
                                                          bloc
                                                                  .communityList!
                                                                  .communityData
                                                                  .length ==
                                                              0
                                                      ? Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height -
                                                              (158 +
                                                                  dataSaver
                                                                      .statusTop +
                                                                  dataSaver
                                                                      .iosBottom),
                                                          child: Center(
                                                            child: customText(
                                                                '작성된 커뮤니티가 아직 없어요',
                                                                style: TextStyle(
                                                                    color: AppColors
                                                                        .gray400,
                                                                    fontWeight: weightSet(
                                                                        textWeight:
                                                                            TextWeight
                                                                                .REGULAR),
                                                                    fontSize: fontSizeSet(
                                                                        textSize:
                                                                            TextSize.T14))),
                                                          ),
                                                        )
                                                      : Container(
                                                          child:
                                                              communityView(),
                                                        ),
                                                  color: AppColors.greenGray50,
                                                ),
                                              ),
                                            )),
                                        communityMadeSlidingPanel(),
                                        loadingView(bloc.communityLoading)
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        learnLoadingPass
                                            ? GatherPage()
                                            : Container()
                                      ],
                                    )
                                  ],
                                ),
                                // settingBar(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    bloc.notificationAnimation
                        ? Positioned(
                            top: 54,
                            right: 12,
                            child: Image.asset(
                              AppImages.imgTooltipNew,
                              width: 150,
                              height: 47,
                            ))
                        : Container(),
                    neighborHoodSelecter(),
                    filterSlidingUpPanel(),
                    ((prefs!.getBool('memberLoad') == null ||
                                !prefs!.getBool('memberLoad')!) &&
                            dataSaver.nonMember)
                        ? nonMemberLoad()
                        : Container()
                  ],
                ),
              )),
            ),
          );
        });
  }

  communityTab() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 54,
      color: AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          spaceW(20),
          Container(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                bloc.add(CommunityTabChangeEvent(selectTab: 0));
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  primary: bloc.communityTabIndex == 0
                      ? AppColors.primary
                      : AppColors.gray200,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: Center(
                  child: customText(
                '배움교환',
                style: TextStyle(
                    color: bloc.communityTabIndex == 0
                        ? AppColors.white
                        : AppColors.gray500,
                    fontWeight: weightSet(
                        textWeight: bloc.communityTabIndex == 0
                            ? TextWeight.BOLD
                            : TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T15)),
              )),
            ),
          ),
          spaceW(8),
          Container(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                bloc.add(CommunityTabChangeEvent(selectTab: 1));
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  primary: bloc.communityTabIndex == 1
                      ? AppColors.primary
                      : AppColors.gray200,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: Center(
                  child: customText(
                '배움모임',
                style: TextStyle(
                    color: bloc.communityTabIndex == 1
                        ? AppColors.white
                        : AppColors.gray500,
                    fontWeight: weightSet(
                        textWeight: bloc.communityTabIndex == 1
                            ? TextWeight.BOLD
                            : TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T15)),
              )),
            ),
          ),
        ],
      ),
    );
  }

  communityTop() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          GestureDetector(
            onTap: () {
              if (bloc.communityOrderType != 0) {
                bloc.communityOrderType = 0;
                amplitudeEvent('community_order', {
                  'type': 'recent',
                  'view': communityChangeType(bloc.communityTabIndex)
                });
                bloc.add(CommunityReloadEvent());
              }
            },
            child: Container(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: customText(
                  '최신 순 ${bloc.communityOrderType == 0 ? '↓' : ''}',
                  style: TextStyle(
                      color: bloc.communityOrderType == 0
                          ? AppColors.gray900
                          : AppColors.gray500,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12))),
            ),
          ),
          Container(
            width: 1,
            height: 10,
            color: AppColors.gray300,
          ),
          GestureDetector(
            onTap: () {
              if (bloc.communityOrderType != 1) {
                bloc.communityOrderType = 1;
                amplitudeEvent('community_order', {
                  'type': 'near',
                  'view': communityChangeType(bloc.communityTabIndex)
                });
                bloc.add(CommunityReloadEvent());
              }
            },
            child: Container(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: customText(
                  '가까운 순 ${bloc.communityOrderType == 1 ? '↓' : ''}',
                  style: TextStyle(
                      color: bloc.communityOrderType == 1
                          ? AppColors.gray900
                          : AppColors.gray500,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12))),
            ),
          ),
          spaceW(20)
        ],
      ),
    );
  }

  communityList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return communityItem(bloc.communityList!.communityData[idx]);
      },
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: bloc.communityList == null
          ? 0
          : bloc.communityList!.communityData.length,
    );
  }

  communityItem(CommunityData communityData) {
    final span = TextSpan(
        text: communityData.content.contentText!,
        style: TextStyle(
            color: AppColors.greenGray500,
            fontWeight: weightSet(textWeight: TextWeight.BOLD),
            fontSize: fontSizeSet(textSize: TextSize.T12)));
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: MediaQuery.of(context).size.width - 32);

    List<Widget> teachView = [];
    List<Widget> learnView = [];
    List<Widget> meetView = [];

    if (communityData.content.category == 'EXCHANGE' &&
        (communityData.content.teachKeywordString != null &&
            communityData.content.learnKeywordString != null)) {
      List<String> teachTexts =
          communityData.content.teachKeywordString!.split(',');
      List<String> learnTexts =
          communityData.content.learnKeywordString!.split(',');
      for (int i = 0; i < teachTexts.length; i++) {
        teachView.add(RichText(
          text: TextSpan(
            children: [
              customTextSpan(
                  text: '#',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray100
                          : AppColors.primaryLight30,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              customTextSpan(
                  text: '${teachTexts[i]}',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray400
                          : AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15)))
            ],
          ),
        ));
      }
      for (int i = 0; i < learnTexts.length; i++) {
        learnView.add(RichText(
          text: TextSpan(
            children: [
              customTextSpan(
                  text: '#',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray100
                          : AppColors.accentLight30,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              customTextSpan(
                  text: '${learnTexts[i]}',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray400
                          : AppColors.accentDark10,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15)))
            ],
          ),
        ));
      }
    } else if (communityData.content.category == 'WITH_ME' &&
        communityData.content.meetKeywordString != null) {
      List<String> meetTexts =
          communityData.content.meetKeywordString!.split(',');
      for (int i = 0; i < meetTexts.length; i++) {
        meetView.add(RichText(
          text: TextSpan(
            children: [
              customTextSpan(
                  text: '#',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray100
                          : AppColors.primaryLight30,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              customTextSpan(
                  text: '${meetTexts[i]}',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray400
                          : AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15)))
            ],
          ),
        ));
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: GestureDetector(
        onTap: () {
          if (communityData.mineFlag == 0) {
            amplitudeEvent('community_clicks', {
              'type': communityTypeCreate(
                  communityTypeIdx(communityData.content.category)),
              'bookmark_count': communityData.likeCnt,
              'chat_count': communityData.chatCnt,
              'share_count': communityData.shareCnt,
              'view_count': communityData.readCnt,
              'comment_count': communityData.commentCnt,
              'user_id': communityData.member.memberUuid,
              'user_name': communityData.member.nickName,
              'community_id': communityData.communityUuid,
              'distance': communityData.content.distance,
              'status': communityData.status,
              'hang_name': communityData.content.hangNames
            });
          }
          pushTransition(
              context,
              CommunityDetailPage(
                communityUuid: communityData.communityUuid,
              )).then((value) {
            if (value != null && value) {
              bloc.add(CommunityReloadEvent());
            }
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            communityData.content.category == 'EXCHANGE' &&
                    (communityData.content.teachKeywordString != null &&
                        communityData.content.learnKeywordString != null)
                ? IntrinsicHeight(
                    child: Container(
                        decoration: BoxDecoration(
                          color: communityData.status == 'DONE'
                              ? AppColors.white.withOpacity(0.6)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 12, left: 12, right: 12, bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  customText('알려 드려요',
                                      style: TextStyle(
                                          color: AppColors.greenGray400,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12))),
                                  spaceH(6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          runSpacing: 4,
                                          spacing: 4,
                                          alignment: WrapAlignment.start,
                                          children: teachView,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                              spaceW(12),
                              Image.asset(
                                AppImages.iSwitch,
                                width: 20,
                                height: 20,
                              ),
                              spaceW(12),
                              Expanded(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  customText('배우고 싶어요',
                                      style: TextStyle(
                                          color: AppColors.greenGray400,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12))),
                                  spaceH(6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          runSpacing: 4,
                                          spacing: 4,
                                          alignment: WrapAlignment.end,
                                          children: learnView,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )),
                            ],
                          ),
                        )),
                  )
                : (communityData.content.category == 'WITH_ME' &&
                        communityData.content.meetKeywordString != null)
                    ? Container(
                        decoration: BoxDecoration(
                          color: communityData.status == 'DONE'
                              ? AppColors.white.withOpacity(0.6)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 12, left: 12, right: 12, bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Wrap(
                                  runSpacing: 4,
                                  spacing: 4,
                                  children: meetView,
                                ),
                              ),
                            ],
                          ),
                        ))
                    : Container(),
            spaceH(1),
            Container(
              decoration: BoxDecoration(
                color: communityData.status == 'DONE'
                    ? AppColors.white.withOpacity(0.6)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                            (communityData.content.contentText!
                                        .split('\n')
                                        .length >
                                    2)
                                ? '${communityData.content.contentText!.split('\n')[0].toString() + '\n' + communityData.content.contentText!.split('\n')[1] + '\n' + communityData.content.contentText!.split('\n')[2]}' +
                                    '${tp.computeLineMetrics().length > 2 ? '⋯' : ''}'
                                : communityData.content.contentText!,
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.REGULAR),
                                fontSize: fontSizeSet(textSize: TextSize.T14)),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                        spaceH(20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            customText(
                                '${double.parse(communityData.content.distance).toString().split('.')[0].length > 3 ? '${(double.parse(communityData.content.distance) / 1000) > 20 ? '20km+' : '${(double.parse(communityData.content.distance) / 1000).toStringAsFixed(1)}km'}' : '${double.parse(communityData.content.distance).toString().split('.')[0].length == 3 ? (double.parse(communityData.content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(communityData.content.distance).toString().split('.')[0]}m'} ${communityData.content.hangNames.split(',')[0]}',
                                style: TextStyle(
                                    color: AppColors.greenGray500,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                            spaceW(8),
                            Container(
                              width: 1,
                              height: 8,
                              color: AppColors.gray300,
                            ),
                            spaceW(8),
                            communityData.member.profile == null
                                ? Image.asset(
                                    AppImages.dfProfile,
                                    width: 16,
                                    height: 16,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      child: CacheImage(
                                        imageUrl: communityData.member.profile!,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                            spaceW(4),
                            customText(
                                communityData.member.nickName.length > 8
                                    ? communityData.member.nickName
                                            .substring(0, 8) +
                                        "..."
                                    : communityData.member.nickName,
                                style: TextStyle(
                                    color: AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T11))),
                            customText(
                                '·${DateTime.now().difference(communityData.content.createDate).inMinutes > 14400 ? communityData.content.createDate.yearMonthDay : timeCalculationText(DateTime.now().difference(communityData.content.createDate).inMinutes)}',
                                style: TextStyle(
                                    color: AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T11)))
                          ],
                        ),
                        spaceH(12),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: AppColors.gray200,
                  ),
                  spaceH(12),
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        customText('조회 ${communityData.readCnt}',
                            style: TextStyle(
                                color: AppColors.gray600,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                        spaceW(10),
                        Image.asset(
                          AppImages.iChatG,
                          width: 16,
                          height: 16,
                        ),
                        spaceW(4),
                        customText(
                            '${communityData.commentCnt == 0 ? '댓글달기' : communityData.commentCnt} >',
                            style: TextStyle(
                                color: AppColors.gray600,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12)))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  communityView() {
    return Column(
      children: [communityTop(), communityList()],
    );
  }

  communityMadeSlidingPanel() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: SlidingUpPanel(
        color: AppColors.white,
        controller: bloc.communityPanelController,
        panel: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: ListView.builder(
              itemBuilder: (context, idx) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!dataSaver.nonMember) {
                          dataSaver.mainBloc!.add(PlusMenuChangeEvent());
                          amplitudeRevenue(
                              productId: 'community_register', price: 3);
                          amplitudeEvent('community_register',
                              {'type': communityTypeCreate(idx)});
                          if (production == 'prod-release' && kReleaseMode) {
                            Airbridge.event.send(ViewSearchResultEvent());
                          }
                          pushTransition(
                              context, CommunityCreatePage(idx: idx));
                        } else {
                          nonMemberDialog(
                              context: context,
                              title: '게시글 쓰기',
                              content: '로그인을하면 게시글을\n쓰기가 가능해요');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.white,
                        padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(width: 1, color: AppColors.gray200),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            communityMade[idx].icon,
                            width: 42,
                            height: 42,
                          ),
                          spaceW(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(communityMade[idx].description,
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14))),
                              spaceH(4),
                              customText(
                                communityMade[idx].type,
                                style: TextStyle(
                                    color: AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              shrinkWrap: true,
              itemCount: communityMade.length),
        ),
        onPanelClosed: () {
          if (dataSaver.mainBloc!.plus) {
            setState(() {
              dataSaver.mainBloc!.plusAnimationController!.reverse();
              dataSaver.mainBloc!.plus = !dataSaver.mainBloc!.plus;
            });
          }
        },
        backdropTapClosesPanel: true,
        backdropEnabled: true,
        isDraggable: false,
        backdropColor: AppColors.black,
        backdropOpacity: 0,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        minHeight: 0,
        maxHeight: 264,
      ),
    );
  }

  neighborHoodSelecter() {
    return Positioned(
      top: bloc.search ? 114 : 12,
      left: 20,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
        opacity: bloc.neighborhoodSelecterView ? 1.0 : 0.0,
        onEnd: () {
          setState(() {
            bloc.neighborhoodSelecterAnimationEnd = true;
          });
        },
        child: Container(
          width: bloc.neighborhoodSelecterView
              ? 180
              : bloc.neighborhoodSelecterAnimationEnd
                  ? 0
                  : 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                  color: AppColors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 0))
            ],
          ),
          child: Column(
            children: [
              spaceH(10),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, idx) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (dataSaver.neighborHood[idx].representativeFlag !=
                            1) {
                          if (bloc.neighborhoodSelecterView) {
                            bloc.neighborhoodSelecterAnimationEnd = false;
                          }
                          bloc.neighborhoodSelecterView = false;
                          bloc.add(NeighborHoodChangeEvent(index: idx));
                          if (dataSaver.searchBloc != null) {
                            dataSaver.searchBloc!
                                .add(searchBloc.SearchReloadClassEvent());
                          }
                          dataSaver.gatherBloc!.add(GatherInitEvent());
                          amplitudeEvent('town_change', {
                            'town_sido': dataSaver
                                .neighborHood[dataSaver.neighborHood.indexWhere(
                                    (element) =>
                                        element.representativeFlag == 1)]
                                .sidoName,
                            'town_sigungu': dataSaver
                                .neighborHood[dataSaver.neighborHood.indexWhere(
                                    (element) =>
                                        element.representativeFlag == 1)]
                                .sigunguName,
                            'town_dongeupmyeon': dataSaver
                                .neighborHood[dataSaver.neighborHood.indexWhere(
                                    (element) =>
                                        element.representativeFlag == 1)]
                                .eupmyeondongName,
                            'inflow_page': 'main'
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.white, elevation: 0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customText(dataSaver.neighborHood[idx].townName!,
                                style: TextStyle(
                                    color: dataSaver.neighborHood[idx]
                                                .representativeFlag ==
                                            1
                                        ? AppColors.gray900
                                        : AppColors.gray400,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T14))),
                            dataSaver.neighborHood[idx].representativeFlag == 1
                                ? spaceW(4)
                                : Container(),
                            dataSaver.neighborHood[idx].representativeFlag == 1
                                ? Image.asset(
                                    AppImages.iCheckC,
                                    width: 14,
                                    height: 14,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: dataSaver.neighborHood.length,
              ),
              spaceH(10),
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      amplitudeEvent('town_set_enter', {
                        'type': bloc.learnType == 0 ? 'class' : 'community'
                      });
                      pushTransition(context, NeighborHoodSelectPage())
                          .then((value) {
                        if (value != null && value) {
                          bloc.add(ReloadClassEvent());
                          dataSaver.gatherBloc!.add(GatherInitEvent());

                          if (bloc.neighborhoodSelecterView) {
                            bloc.neighborhoodSelecterAnimationEnd = false;
                          }
                          bloc.neighborhoodSelecterView = false;
                          bloc.add(NeighborHoodChangeEvent(
                              index: dataSaver.neighborHood.indexWhere(
                                  (element) =>
                                      element.representativeFlag == 1)));
                          bloc.add(CommunityReloadEvent());
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryLight40,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.iSetting,
                            width: 16,
                            height: 16,
                            color: AppColors.primary,
                          ),
                          spaceW(4),
                          customText('동네설정',
                              style: TextStyle(
                                  color: AppColors.primaryDark10,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T13)))
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  appBarContent() {
    return Row(
      children: [
        spaceW(20),
        GestureDetector(
          onTap: () {
            bloc.closeNeighborhoodSelecter = false;
            Future.delayed(Duration(milliseconds: 1500), () {
              bloc.closeNeighborhoodSelecter = true;
            });
            setState(() {
              bloc.neighborhoodSelecterView = true;
              bloc.neighborhoodSelecterAnimationEnd = false;
            });
            amplitudeEvent('town_select',
                {'type': bloc.learnType == 0 ? 'class' : 'community'});
          },
          child: Row(
            children: [
              customText(
                  bloc.mainNeighborHood == null
                      ? ''
                      : bloc.mainNeighborHood!.townName!,
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T18))),
              spaceW(4),
              Image.asset(
                AppImages.iSelectACDown,
                width: 16,
                height: 16,
                color: AppColors.gray400,
              )
            ],
          ),
        ),
        bloc.learnType == 2 ? Container() : Expanded(child: Container()),
        bloc.learnType == 2
            ? Container()
            : Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12, top: 0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (dataSaver.nonMember) {
                              nonMemberDialog(
                                  context: context,
                                  title: '잠시만요',
                                  content:
                                      AppStrings.of(StringKey.kakaoEasyLogin));
                              return;
                            }
                            amplitudeEvent('notification_enter', {
                              'type':
                                  bloc.learnType == 0 ? 'class' : 'community'
                            });
                            pushTransition(
                                context,
                                NotificationPage(
                                  type: 0,
                                  detailType: bloc.learnType == 0 ? 1 : 2,
                                ));
                          },
                          icon: Lottie.asset(AppImages.notificationAnimation,
                              controller: notificationAnimation,
                              width: 24,
                              height: 24,
                              repeat: true, onLoaded: (composition) {
                            setState(() {
                              notificationAnimation!.reset();
                              notificationAnimation!
                                ..duration = composition.duration * 0.8;
                              notificationAnimation!.forward(from: 1.0);
                            });
                          })),
                    ),
                  ),
                  dataSaver.alarmCount == 0
                      ? Container()
                      : Positioned(
                          right: 12,
                          top: 0,
                          child: Align(
                            heightFactor: 0.4,
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
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T10)),
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
        bloc.learnType == 2
            ? Container()
            : SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // dataSaver.keyword = false;
                      // bloc.search = false;
                      setState(() {
                        if (bloc.neighborhoodSelecterView) {
                          bloc.neighborhoodSelecterAnimationEnd = false;
                        }
                        bloc.neighborhoodSelecterView = false;
                        if (dataSaver.mainBloc != null &&
                            dataSaver.mainBloc!.plus) {
                          dataSaver.mainBloc!.add(PlusMenuChangeEvent());
                        }
                      });
                      // dataSaver.mainBloc!.add(MenuBarHideEvent(hide: true));
                      // dataSaver.searchBloc!.reloadView();
                      // dataSaver.searchBloc!.add(
                      //     searchBloc.SearchInitEvent(learnType: bloc.learnType));
                      // bloc.add(SearchChangeEvent());
                      dataSaver.searchText = '';
                      dataSaver.keyword = true;
                      amplitudeEvent('search_start', {
                        'inflow_page': bloc.learnType == 0
                            ? 'class'
                            : bloc.learnType == 1
                                ? '${bloc.communityTabIndex == 0 ? 'exchange' : 'gather'}'
                                : ''
                      });
                      pushTransition(
                          context,
                          SearchPage(
                            learnType: bloc.learnType,
                            keywordDetailType: bloc.learnType == 0
                                ? 0
                                : bloc.communityTabIndex == 0
                                    ? 1
                                    : 2,
                          )).then((value) {
                        dataSaver.keyword = false;
                      });
                    },
                    icon: Image.asset(
                      AppImages.iSearchVisual,
                      width: 24,
                      height: 24,
                    )),
              ),
        spaceW(20)
      ],
    );
  }

  bool mapCreate = false;

  mapView() {
    return Positioned.fill(
      top: 0,
      bottom: 74 +
          (dataSaver.mainBloc == null
              ? 0
              : dataSaver.mainBloc!.menuBarHide
                  ? 60
                  : 0),
      child: Opacity(
        opacity: bloc.learnType == 0 ? 1.0 : 0.0,
        child: bloc.mainNeighborHood == null
            ? Container()
            : NaverMap(
                contentPadding: EdgeInsets.only(
                    bottom: bloc.snapIndex == 1
                        ? MediaQuery.of(context).size.height * 0.5 - 40
                        : 0),
                onMapTap: (_) {
                  if (dataSaver.mainBloc!.plus) {
                    dataSaver.mainBloc!.add(PlusMenuChangeEvent());
                  }
                  setState(() {
                    if (bloc.neighborhoodSelecterView) {
                      bloc.neighborhoodSelecterAnimationEnd = false;
                    }
                    bloc.neighborhoodSelecterView = false;
                    if (bloc.selectMarker) {
                      bloc.selectedMarkerTap(bloc.selectMarkerData, null);
                      bloc.selectMarker = false;
                      bloc.selectLocation = '전국';
                      bloc.selectMarkerData = null;
                      scrollController!.jumpTo(0);
                    }
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      double.parse(dataSaver
                          .neighborHood[dataSaver.neighborHood.indexWhere(
                              (element) => element.representativeFlag == 1)]
                          .lati!),
                      double.parse(dataSaver
                          .neighborHood[dataSaver.neighborHood.indexWhere(
                              (element) => element.representativeFlag == 1)]
                          .longi!)),
                  zoom: bloc.mapLevel.toDouble(),
                ),
                polygons: bloc.selectMarker ? bloc.polygonOverlay : [],
                onMapCreated: (NaverMapController controller) async {
                  bloc.naverMapController = controller;
                  if (!mapCreate) bloc.add(GetMarkerDataEvent());
                  mapCreate = true;
                },
                maxZoom: 18,
                minZoom: 6,
                mapType: MapType.Basic,
                initLocationTrackingMode: trackingMode,
                indoorEnable: true,
                liteModeEnable: false,
                markers: bloc.markerLoad ? [] : bloc.markers,
                onCameraChange: (LatLng? latLng, CameraChangeReason reason,
                    bool? isAnimated) {
                  bloc.naverMapController!.getCameraPosition().then((value) {
                    if (bloc.mapLevel !=
                        double.parse(value.zoom.toStringAsFixed(1))) {
                      bloc.mapLevel =
                          double.parse(value.zoom.toStringAsFixed(1));
                      bloc.add(GetMarkerDataEvent());
                    }
                  });
                },
                onCameraIdle: () {
                  // STOP CAMERA
                },
              ),
      ),
    );
  }

  filterOpen() async {
    if (filterController.isPanelClosed && !bloc.loading) {
      setState(() {
        if (bloc.learnType == 0) {
          bloc.categoryFilter = true;
          bloc.openFilterValues = bloc.filterValues.toList();
          bloc.openFilterData = bloc.filterData.toList();
        } else {}
        dataSaver.mainBloc!.add(MenuBarHideEvent(hide: true));
      });
      amplitudeEvent(
          'category', {'type': bloc.learnType == 0 ? 'class' : 'request'});
      await filterController.open();
    }
  }

  filterSlidingUpPanel() {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: SlidingUpPanel(
          color: AppColors.white,
          controller: filterController,
          panel: panelView(),
          boxShadow: null,
          backdropTapClosesPanel: true,
          backdropEnabled: true,
          isDraggable: false,
          onPanelClosed: () {
            setState(() {
              bloc.categoryFilter = false;
              if (!bloc.search)
                dataSaver.mainBloc!.add(MenuBarHideEvent(hide: false));
              if (bloc.scrollUnder) {
                scrollController!.animateTo(bloc.bottomOffset,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
                bloc.bottomOffset = 0;
                bloc.scrollUnder = false;
              }
              if (!bloc.saveIng) {
                if (bloc.openFilterValues.length != 0) {
                  bloc.filterValues = [];
                  bloc.filterValues = bloc.openFilterValues;
                  bloc.filterData = [];
                  bloc.filterData = bloc.openFilterData;
                }
              }
            });
          },
          backdropColor: AppColors.black,
          backdropOpacity: 0.6,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          minHeight: filterController.isAttached
              ? filterController.isPanelClosed
                  ? 0
                  : bloc.categoryFilter
                      ? 534
                      : 542
              : 0,
          maxHeight: bloc.categoryFilter ? 534 : 542,
        ));
  }

  panelView() {
    return Stack(
      children: [
        panelViewTitle('카테고리'),
        panelFilter(),
        Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: bottomButton(
                context: context,
                text: AppStrings.of(StringKey.save),
                onPress: () async {
                  bloc.saveIng = true;
                  if (filterController.isPanelOpen) {
                    amplitudeEvent('category_set_completed', {
                      'type': bloc.learnType == 0 ? 'class' : 'request',
                      'category': bloc.filterData.join(',')
                    });
                    await filterController.close();
                  }
                  bloc.add(SaveFilterEvent());
                }))
      ],
    );
  }

  panelFilter() {
    return Stack(
      children: [
        bloc.filterValues.length == 0
            ? Container()
            : Positioned(
                top: 60,
                left: 20,
                right: 20,
                bottom: 60,
                child: Column(
                  children: [
                    spaceH(10),
                    GestureDetector(
                      onTap: () {
                        if (!bloc.filterValues.contains(false)) {
                          bloc.add(FilterSetAllEvent(check: false));
                        } else {
                          bloc.add(FilterSetAllEvent(check: true));
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: bloc.filterValues.contains(false)
                                ? AppColors.white
                                : AppColors.primary.withOpacity(0.14)),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                bloc.filterValues.contains(false)
                                    ? AppImages.iCategoryLAll
                                    : AppImages.iCategoryCAll,
                                width: 42,
                                height: 42,
                              ),
                              spaceH(4),
                              customText('모든 카테고리',
                                  style: TextStyle(
                                      color: AppColors.black.withOpacity(0.4),
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)))
                            ],
                          ),
                        ),
                      ),
                    ),
                    spaceH(18),
                    Flexible(
                      child: Container(
                          height: 296,
                          child: GridView.count(
                            physics: ClampingScrollPhysics(),
                            crossAxisCount: 3,
                            childAspectRatio:
                                (((MediaQuery.of(context).size.width - 72) /
                                        3) /
                                    80),
                            padding: EdgeInsets.only(bottom: 18),
                            shrinkWrap: true,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 16,
                            children: List.generate(bloc.filterItemName.length,
                                (index) {
                              return GestureDetector(
                                onTap: () {
                                  if (!bloc.filterValues.contains(false)) {
                                    if (bloc.learnType == 0) {
                                      bloc.filterData = [];
                                      bloc.filterValues =
                                          List.generate(9, (index) => false);
                                    } else {}
                                  }

                                  if (bloc.filterValues.indexWhere(
                                              (element) => element == true) !=
                                          bloc.filterValues.lastIndexWhere(
                                              (element) => element == true) ||
                                      !bloc.filterValues[index]) {
                                    setState(() {
                                      if (!bloc.filterValues[index]) {
                                        bloc.filterData.add(dataSaver
                                            .category[index].classCategoryId!);
                                      } else {
                                        bloc.filterData.remove(dataSaver
                                            .category[index].classCategoryId);
                                      }
                                      bloc.filterValues[index] =
                                          !bloc.filterValues[index];
                                    });
                                  } else {
                                    showToast(
                                        context: context,
                                        text: AppStrings.of(
                                            StringKey.filterToast));
                                  }
                                },
                                child: Container(
                                  width: 96,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: bloc.filterValues.contains(false)
                                          ? bloc.filterValues[index]
                                              ? AppColors.primary
                                                  .withOpacity(0.14)
                                              : AppColors.white
                                          : AppColors.white),
                                  child: Column(
                                    children: [
                                      spaceH(8.5),
                                      Image.asset(
                                        bloc.filterValues.contains(false)
                                            ? bloc.filterValues[index]
                                                ? bloc
                                                    .filterItemCheckImage[index]
                                                : bloc.filterItemUnCheckImage[
                                                    index]
                                            : bloc
                                                .filterItemUnCheckImage[index],
                                        width: 42,
                                        height: 42,
                                      ),
                                      spaceH(4),
                                      customText(
                                        bloc.filterItemName[index],
                                        style: TextStyle(
                                            color: AppColors.black
                                                .withOpacity(0.4),
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12)),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          )),
                    ),
                    bloc.categoryFilter
                        ? Container()
                        : Container(
                            height: 48,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                customText(
                                  AppStrings.of(StringKey.sort),
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                                Expanded(child: Container()),
                                GestureDetector(
                                  onTap: () {},
                                  child: customText(
                                    AppStrings.of(StringKey.distanceOrder),
                                    style: TextStyle(
                                        color: AppColors.primaryDark10,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T12)),
                                  ),
                                )
                              ],
                            ),
                          ),
                  ],
                ),
              ),
      ],
    );
  }

  panelViewTitle(text) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: customText(
                    text,
                    style: TextStyle(
                        fontSize: fontSizeSet(textSize: TextSize.T15),
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        color: AppColors.gray900),
                  ),
                ),
                Positioned(
                  right: 20,
                  child: GestureDetector(
                      onTap: () async {
                        await filterController.close();
                      },
                      child: Image.asset(
                        AppImages.iX,
                        width: 24,
                        height: 24,
                      )),
                ),
              ],
            ),
          ),
          heightLine(color: AppColors.gray100, height: 1),
        ],
      ),
    );
  }

  mapSlidingUpPanel() {
    return Positioned.fill(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Opacity(
        opacity: bloc.learnType == 0 ? 1.0 : 0.0,
        child: SlidingUpPanel(
          boxShadow: bloc.categoryFilter
              ? null
              : [
                  BoxShadow(
                      color: AppColors.black08,
                      blurRadius: 16,
                      offset: Offset(0, 0))
                ],
          header: GestureDetector(
            onTapDown: (_) {
              setState(() {
                bloc.gesture = true;
              });
            },
            onTapCancel: () {
              setState(() {
                bloc.gesture = false;
              });
            },
            onTapUp: (_) {
              setState(() {
                bloc.gesture = false;
              });
            },
            onVerticalDragStart: (_) {
              setState(() {
                bloc.gesture = true;
              });
            },
            onVerticalDragUpdate: (details) async {
              if (bloc.gesture) {
                if (details.delta.dy > 2) {
                  // Down Swipe
                  if (bloc.snapIndex == 2) {
                    setState(() {
                      bloc.snapIndex = 1;
                      bloc.gesture = false;
                      if (scrollController!.hasClients &&
                          dataSaver.neighborHoodClass != null &&
                          dataSaver.neighborHoodClass!.classData.length > 2) {
                        if (scrollController!.position.maxScrollExtent ==
                            scrollController!.offset) {
                          Future.delayed(Duration(milliseconds: 200), () {
                            scrollController!.animateTo(
                                scrollController!.position.maxScrollExtent,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.ease);
                          });
                        }
                      }

                      panelController.animatePanelToSnapPoint(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                      if (scrollController!.position.maxScrollExtent ==
                          scrollController!.offset) {
                        Future.delayed(Duration(milliseconds: 200), () {
                          scrollController!.animateTo(
                              scrollController!.position.maxScrollExtent,
                              duration: Duration(milliseconds: 100),
                              curve: Curves.ease);
                        });
                      }
                    });
                  } else if (bloc.snapIndex == 1) {
                    setState(() {
                      dataSaver.mainBloc!.add(ShadowAndPlusTapChangeEvent());
                      bloc.snapIndex = 0;
                      bloc.gesture = false;
                      panelController.animatePanelToPosition(0.0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    });
                  }
                } else if (details.delta.dy < -2) {
                  // Up Swipe
                  if (bloc.snapIndex == 1) {
                    setState(() {
                      bloc.snapIndex = 2;
                      bloc.gesture = false;
                      panelController.animatePanelToPosition(1.0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    });
                  } else if (bloc.snapIndex == 0) {
                    setState(() {
                      dataSaver.mainBloc!.add(ShadowAndPlusTapChangeEvent());
                      bloc.snapIndex = 1;
                      bloc.gesture = false;
                      panelController
                          .animatePanelToSnapPoint(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease)
                          .then((value) {
                        setState(() {
                          if (scrollController!.hasClients &&
                              dataSaver.neighborHoodClass!.classData.length >
                                  2) {
                            if (scrollController!.position.maxScrollExtent ==
                                scrollController!.offset) {
                              Future.delayed(Duration(milliseconds: 200), () {
                                scrollController!.animateTo(
                                    scrollController!.position.maxScrollExtent,
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.ease);
                              });
                            }
                          }
                        });
                      });
                    });
                  }
                }
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(bloc.snapIndex == 2 ? 0 : 16),
                    topRight: Radius.circular(bloc.snapIndex == 2 ? 0 : 16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  bloc.snapIndex == 2
                      ? heightLine(height: 1, color: AppColors.gray100)
                      : Container(
                          height: 1,
                        ),
                  spaceH(14),
                  Container(
                    height: 5,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      width: bloc.gesture ? 46 : 42,
                      height: bloc.gesture ? 5 : 4,
                      decoration: BoxDecoration(
                          color: bloc.gesture
                              ? AppColors.greenGray500
                              : AppColors.greenGray300,
                          borderRadius:
                              BorderRadius.circular(bloc.gesture ? 4 : 2)),
                    ),
                  ),
                  spaceH(14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      spaceW(20),
                      Container(
                        height: 20,
                        child: customText(bloc.selectLocation,
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T14))),
                      ),
                      spaceW(10),
                      Container(
                        height: 20,
                        child: Center(
                          child: customText(
                              bloc.selectMarker
                                  ? '${bloc.selectClass == null ? 0 : bloc.selectClass!.totalRow}건'
                                  : '${dataSaver.neighborHoodClass == null ? 0 : dataSaver.neighborHoodClass!.totalRow}건',
                              style: TextStyle(
                                  color: AppColors.gray500,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.MEDIUM),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T12)),
                              textAlign: TextAlign.center),
                        ),
                      ),
                      Expanded(child: Container()),
                      GestureDetector(
                        onTap: () {
                          if (bloc.orderType != 2) {
                            bloc.orderType = 2;
                            amplitudeEvent('class_order',
                                {'page': 'main', 'type': 'cost'});
                            bloc.add(ReloadClassEvent());
                          }
                        },
                        child: Container(
                          height: 36,
                          padding: EdgeInsets.only(left: 8, right: 8),
                          color: AppColors.white,
                          child: Center(
                            child: customText(
                                '가격 순${bloc.orderType == 2 ? ' ↓' : ''}',
                                style: TextStyle(
                                    color: bloc.orderType == 2
                                        ? AppColors.gray900
                                        : AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: bloc.orderType == 2
                                            ? TextWeight.BOLD
                                            : TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 10,
                        color: AppColors.gray300,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (bloc.orderType != 0) {
                            bloc.orderType = 0;
                            amplitudeEvent('class_order',
                                {'page': 'main', 'type': 'recent'});
                            bloc.add(ReloadClassEvent());
                          }
                        },
                        child: Container(
                          height: 36,
                          padding: EdgeInsets.only(left: 8, right: 8),
                          color: AppColors.white,
                          child: Center(
                            child: customText(
                                '최신 순${bloc.orderType == 0 ? ' ↓' : ''}',
                                style: TextStyle(
                                    color: bloc.orderType == 0
                                        ? AppColors.gray900
                                        : AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: bloc.orderType == 0
                                            ? TextWeight.BOLD
                                            : TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 10,
                        color: AppColors.gray300,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (bloc.orderType != 1) {
                            amplitudeEvent('class_order',
                                {'page': 'main', 'type': 'near'});
                            bloc.orderType = 1;
                            bloc.add(ReloadClassEvent());
                          }
                        },
                        child: Container(
                          height: 36,
                          padding: EdgeInsets.only(left: 8, right: 0),
                          color: AppColors.white,
                          child: Center(
                            child: customText(
                                '가까운 순${bloc.orderType == 1 ? ' ↓' : ''}',
                                style: TextStyle(
                                    color: bloc.orderType == 1
                                        ? AppColors.gray900
                                        : AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: bloc.orderType == 1
                                            ? TextWeight.BOLD
                                            : TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                          ),
                        ),
                      ),
                      spaceW(20)
                    ],
                  ),
                  spaceH(10)
                ],
              ),
            ),
          ),
          panelBuilder: (sc) {
            sc = ScrollController()
              ..addListener(() {
                if (bloc.selectMarker) {
                  if (sc.position.userScrollDirection ==
                      ScrollDirection.forward) {
                    bloc.selectBottomOffset = 0;
                    bloc.selectScrollUnder = false;
                  }
                  if (!bloc.selectScrollUnder &&
                      (bloc.selectBottomOffset == 0 ||
                          bloc.selectBottomOffset < sc.offset) &&
                      sc.offset >= sc.position.maxScrollExtent &&
                      !sc.position.outOfRange) {
                    bloc.selectScrollUnder = true;
                    bloc.selectBottomOffset = sc.offset;
                  }
                  if (!bloc.selectScrollUnder &&
                      (bloc.selectBottomOffset == 0 ||
                          bloc.selectBottomOffset < sc.offset) &&
                      sc.offset >= (sc.position.maxScrollExtent * 0.7) &&
                      !sc.position.outOfRange) {
                    bloc.add(NewDataEvent());
                  }
                } else {
                  if (sc.position.userScrollDirection ==
                      ScrollDirection.forward) {
                    bloc.bottomOffset = 0;
                    bloc.scrollUnder = false;
                  }
                  if (sc.position.userScrollDirection ==
                      ScrollDirection.reverse) {
                    bloc.add(NewDataEvent());
                  }
                  if (!bloc.scrollUnder &&
                      (bloc.bottomOffset == 0 ||
                          bloc.bottomOffset < sc.offset) &&
                      sc.offset >= sc.position.maxScrollExtent &&
                      !sc.position.outOfRange) {
                    bloc.scrollUnder = true;
                    bloc.bottomOffset = sc.offset;
                  }
                }
              });
            scrollController = sc;
            selectScrollController = sc;
            return Stack(
              children: [
                Positioned.fill(
                  top: 80,
                  bottom: bloc.snapIndex == 1
                      ? MediaQuery.of(context).size.height * 0.5 - 40
                      : 120 + dataSaver.statusTop + dataSaver.iosBottom,
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.white,
                          onRefresh: () async {
                            bloc.add(ReloadClassEvent());
                          },
                          child: classList(sc),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  top: 80,
                  bottom: bloc.snapIndex == 1
                      ? MediaQuery.of(context).size.height * 0.5 - 40
                      : 120 + dataSaver.statusTop + dataSaver.iosBottom,
                  child: Center(
                    child: loadingView(bloc.listLoading),
                  ),
                )
              ],
            );
          },
          isDraggable: false,
          controller: panelController,
          snapPoint: 0.5,
          minHeight: 76,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(bloc.snapIndex == 2 ? 0 : 16),
              topRight: Radius.circular(bloc.snapIndex == 2 ? 0 : 16)),
          color: AppColors.white,
          maxHeight: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  classList(ScrollController sc) {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return Column(
          children: [
            idx == 0 &&
                    dataSaver.reward != null &&
                    dataSaver.reward!.viewFlag == 1
                ? Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        amplitudeEvent('reward_click', {});
                        pushTransition(context,
                            SupportFundPage(reward: dataSaver.reward!));
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
                : Container(),
            classListItem(idx),
            spaceH(20)
          ],
        );
      },
      controller: sc,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: bloc.selectMarker
          ? (bloc.selectClass == null ? 0 : bloc.selectClass!.classData.length)
          : (dataSaver.neighborHoodClass == null
              ? 0
              : dataSaver.neighborHoodClass!.classData.length),
    );
  }

  classListItem(index) {
    return GestureDetector(
      onTap: () {
        if (bloc.selectMarker
            ? bloc.selectClass!.classData[index].mineFlag != 1
            : dataSaver.neighborHoodClass!.classData[index].mineFlag != 1) {
          airbridgeEvent('class_view');
          classEvent(
              'totals_class_clicks',
              bloc.selectMarker
                  ? bloc.selectClass!.classData[index].classUuid
                  : dataSaver.neighborHoodClass!.classData[index].classUuid,
              bloc.mainNeighborHood!.lati!,
              bloc.mainNeighborHood!.longi!,
              bloc.mainNeighborHood!.sidoName!,
              bloc.mainNeighborHood!.sigunguName!,
              bloc.mainNeighborHood!.eupmyeondongName!,
              firstFree: bloc.selectMarker
                  ? bloc.selectClass!.classData[index].content.firstFreeFlag ==
                          0
                      ? false
                      : true
                  : dataSaver.neighborHoodClass!.classData[index].content
                              .firstFreeFlag ==
                          0
                      ? false
                      : true,
              group: bloc.selectMarker
                  ? bloc.selectClass!.classData[index].content.groupFlag == 0
                      ? false
                      : true
                  : dataSaver.neighborHoodClass!.classData[index].content.groupFlag ==
                          0
                      ? false
                      : true,
              groupCost: bloc.selectMarker
                  ? bloc.selectClass!.classData[index].content.costOfPerson
                      .toString()
                  : dataSaver
                      .neighborHoodClass!.classData[index].content.costOfPerson
                      .toString());
          classEvent(
              'class_clicks',
              bloc.selectMarker
                  ? bloc.selectClass!.classData[index].classUuid
                  : dataSaver.neighborHoodClass!.classData[index].classUuid,
              bloc.mainNeighborHood!.lati!,
              bloc.mainNeighborHood!.longi!,
              bloc.mainNeighborHood!.sidoName!,
              bloc.mainNeighborHood!.sigunguName!,
              bloc.mainNeighborHood!.eupmyeondongName!,
              firstFree: bloc.selectMarker
                  ? bloc.selectClass!.classData[index].content.firstFreeFlag ==
                          0
                      ? false
                      : true
                  : dataSaver.neighborHoodClass!.classData[index].content
                              .firstFreeFlag ==
                          0
                      ? false
                      : true,
              group: bloc.selectMarker
                  ? bloc.selectClass!.classData[index].content.groupFlag == 0
                      ? false
                      : true
                  : dataSaver.neighborHoodClass!.classData[index].content.groupFlag ==
                          0
                      ? false
                      : true,
              groupCost: bloc.selectMarker
                  ? bloc.selectClass!.classData[index].content.costOfPerson
                      .toString()
                  : dataSaver
                      .neighborHoodClass!.classData[index].content.costOfPerson
                      .toString());
        }
        ClassDetailPage classDetailPage = ClassDetailPage(
          heroTag: 'listImage$index',
          classUuid: bloc.selectMarker
              ? bloc.selectClass!.classData[index].classUuid
              : dataSaver.neighborHoodClass!.classData[index].classUuid,
          mainNeighborHood: bloc.mainNeighborHood!,
          bloc: bloc,
          selectIndex: index,
          profileGet: dataSaver.nonMember ? null : dataSaver.profileGet,
          inputPage: 'main',
        );
        dataSaver.keywordClassDetail = classDetailPage;
        pushTransition(context, classDetailPage).then((value) {
          if (value != null) {
            bloc.add(ReloadClassEvent());
          }
        });
      },
      child: Container(
        color: AppColors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Row(
                children: [
                  customText(
                      '${double.parse((bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.distance).toString().split('.')[0].length > 3 ? '${(double.parse((bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.distance) / 1000) > 20 ? '20km+' : '${(double.parse((bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.distance) / 1000).toStringAsFixed(1)}km'} ${(bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.hangNames.split(',')[0]}' : '${double.parse((bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.distance).toString().split('.')[0].length == 3 ? (double.parse((bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse((bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.distance).toString().split('.')[0]}m ${(bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.hangNames.split(',')[0]}'}',
                      style: TextStyle(
                          color: AppColors.greenGray500,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                  spaceW(8),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.gray300,
                  ),
                  spaceW(8),
                  (bloc.selectMarker
                                  ? bloc.selectClass
                                  : dataSaver.neighborHoodClass)!
                              .classData[index]
                              .member
                              .profile !=
                          null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 16,
                            height: 16,
                            child: CacheImage(
                              imageUrl: (bloc.selectMarker
                                      ? bloc.selectClass
                                      : dataSaver.neighborHoodClass)!
                                  .classData[index]
                                  .member
                                  .profile!,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            AppImages.dfProfile,
                            width: 16,
                            height: 16,
                          ),
                        ),
                  spaceW(4),
                  customText(
                      (bloc.selectMarker
                                      ? bloc.selectClass
                                      : dataSaver.neighborHoodClass)!
                                  .classData[index]
                                  .member
                                  .nickName
                                  .length >
                              8
                          ? (bloc.selectMarker
                                      ? bloc.selectClass
                                      : dataSaver.neighborHoodClass)!
                                  .classData[index]
                                  .member
                                  .nickName
                                  .substring(0, 8) +
                              "...·"
                          : (bloc.selectMarker
                                      ? bloc.selectClass
                                      : dataSaver.neighborHoodClass)!
                                  .classData[index]
                                  .member
                                  .nickName +
                              "·",
                      style: TextStyle(
                          color: AppColors.gray500,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T11))),
                  customText(
                    DateTime.now()
                                .difference((bloc.selectMarker
                                        ? bloc.selectClass
                                        : dataSaver.neighborHoodClass)!
                                    .classData[index]
                                    .content
                                    .createDate)
                                .inMinutes >
                            14400
                        ? (bloc.selectMarker
                                ? bloc.selectClass
                                : dataSaver.neighborHoodClass)!
                            .classData[index]
                            .content
                            .createDate
                            .yearMonthDay
                        : timeCalculationText(DateTime.now()
                            .difference((bloc.selectMarker
                                    ? bloc.selectClass
                                    : dataSaver.neighborHoodClass)!
                                .classData[index]
                                .content
                                .createDate)
                            .inMinutes),
                    style: TextStyle(
                        color: AppColors.gray500,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T11)),
                  ),
                  Expanded(child: Container()),
                  Container(
                    width: 30,
                    height: 30,
                  )
                ],
              ),
              spaceH(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 128,
                        height: 72,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CacheImage(
                            imageUrl: (bloc.selectMarker
                                    ? bloc.selectClass
                                    : dataSaver.neighborHoodClass)!
                                .classData[index]
                                .content
                                .image!
                                .toView(
                                  context: context,
                                ),
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            placeholder: Container(
                              width: 128,
                              height: 72,
                              decoration: BoxDecoration(
                                  color: AppColors.gray200,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Image.asset(
                                AppImages.dfClassMain,
                                width: 128,
                                height: 72,
                              ),
                            ),
                          ),
                        ),
                      ),
                      (bloc.selectMarker
                                      ? bloc.selectClass
                                      : dataSaver.neighborHoodClass)!
                                  .classData[index]
                                  .content
                                  .firstFreeFlag ==
                              1
                          ? Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                  height: 20,
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  decoration: BoxDecoration(
                                      color: AppColors.black.withOpacity(0.24),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Center(
                                    child: customText('첫회무료',
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T10))),
                                  )),
                            )
                          : Container()
                    ],
                  ),
                  spaceW(16),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(children: [
                                  customTextSpan(
                                      text: (bloc.selectMarker
                                                  ? bloc.selectClass
                                                  : dataSaver
                                                      .neighborHoodClass)!
                                              .classData[index]
                                              .content
                                              .title! +
                                          " ",
                                      style: TextStyle(
                                          color: AppColors.gray900,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T14))),
                                  customTextSpan(
                                      text: (bloc.selectMarker
                                              ? bloc.selectClass
                                              : dataSaver.neighborHoodClass)!
                                          .classData[index]
                                          .content
                                          .category!
                                          .name!,
                                      style: TextStyle(
                                          color: AppColors.gray500,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T11))),
                                ]),
                              ),
                            )
                          ],
                        ),
                        spaceH(6),
                        Container(
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              (bloc.selectMarker
                                              ? bloc.selectClass
                                              : dataSaver.neighborHoodClass)!
                                          .classData[index]
                                          .content
                                          .groupFlag ==
                                      1
                                  ? Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          padding: EdgeInsets.only(
                                              left: 6, right: 6),
                                          child: Center(
                                              child: customText('그룹할인',
                                                  style: TextStyle(
                                                      color: AppColors.white,
                                                      fontWeight: weightSet(
                                                          textWeight:
                                                              TextWeight.BOLD),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T10)))),
                                          decoration: BoxDecoration(
                                              color: AppColors.accent,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                        ),
                                        spaceW(6)
                                      ],
                                    )
                                  : Container(),
                              customText(
                                  (bloc.selectMarker
                                                  ? bloc.selectClass
                                                  : dataSaver
                                                      .neighborHoodClass)!
                                              .classData[index]
                                              .content
                                              .costType ==
                                          'HOUR'
                                      ? '${numberFormatter((bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.groupFlag == 1 ? (bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.costOfPerson : (bloc.selectMarker ? bloc.selectClass : dataSaver.neighborHoodClass)!.classData[index].content.minCost!)}원 ~'
                                      : '배움나눔',
                                  style: TextStyle(
                                      color: (bloc.selectMarker
                                                      ? bloc.selectClass
                                                      : dataSaver
                                                          .neighborHoodClass)!
                                                  .classData[index]
                                                  .content
                                                  .costType ==
                                              'HOUR'
                                          ? AppColors.gray900
                                          : AppColors.secondaryDark30,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  myNeighborHoodMove() {
    return Positioned(
        top: 12,
        right: 12,
        child: Opacity(
          opacity: bloc.learnType == 0 ? 1.0 : 0.0,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: AppColors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: Offset(0, 0))
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                amplitudeEvent('current_location_button', {});
                trackingChange();
                // 현재 선택한 동네 위치로 이동
                // bloc.naverMapController!.moveCamera(
                //     CameraUpdate.toCameraPosition(
                //         CameraPosition(
                //             target: LatLng(
                //                 double.parse(bloc.mainNeighborHood!.lati!),
                //                 double.parse(bloc.mainNeighborHood!.longi!)))));
              },
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  primary: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
              child: Center(
                child: Image.asset(
                  AppImages.crosshairSimple,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ));
  }

  trackingChange() async {
    if (trackingMode == LocationTrackingMode.Follow) {
      trackingMode = LocationTrackingMode.None;
      bloc.naverMapController!.setLocationTrackingMode(trackingMode);
    } else {
      trackingMode = LocationTrackingMode.Follow;
      await bloc.naverMapController!.setLocationTrackingMode(trackingMode);
      Future.delayed(Duration(milliseconds: 2000), () {
        trackingChange();
      });
    }
  }

  settingBar() {
    int filterTrue = 0;
    for (int i = 0; i < bloc.openFilterValues.length; i++) {
      if (bloc.openFilterValues[i]) {
        filterTrue += 1;
      }
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 54,
        decoration: BoxDecoration(
          boxShadow: bloc.learnType == 0 && bloc.snapIndex != 2
              ? [
                  BoxShadow(
                      color: AppColors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: Offset(0, 4))
                ]
              : [],
          color: AppColors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spaceW(20),
            Container(
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  if (dataSaver.mainBloc!.plus) {
                    dataSaver.mainBloc!.add(PlusMenuChangeEvent());
                  }
                  filterOpen();
                },
                style: ElevatedButton.styleFrom(
                    primary: bloc.learnType == 0
                        ? AppColors.accentLight50
                        : AppColors.primaryLight50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.only(left: 12, right: 8),
                    elevation: 0),
                child: Center(
                  child: Row(
                    children: [
                      filterTrue > 8
                          ? customText('모든 카테고리',
                              style: TextStyle(
                                  color: bloc.learnType == 0
                                      ? AppColors.accent
                                      : AppColors.primary,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T12)))
                          : customText(
                              filterController.isAttached
                                  ? filterController.isPanelOpen
                                      ? bloc.filterItemName[
                                          bloc.openFilterValues.indexOf(true)]
                                      : bloc.filterValues.indexOf(true) != -1
                                          ? bloc.filterItemName[
                                              bloc.filterValues.indexOf(true)]
                                          : ''
                                  : bloc.filterValues.indexOf(true) != -1
                                      ? bloc.filterItemName[
                                          bloc.filterValues.indexOf(true)]
                                      : '',
                              style: TextStyle(
                                  color: bloc.learnType == 0
                                      ? AppColors.accentDark10
                                      : AppColors.primaryDark10,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T12))),
                      spaceW(4),
                      filterTrue > 8
                          ? Container()
                          : filterTrue > 1
                              ? Container(
                                  height: 16,
                                  padding:
                                      EdgeInsets.only(left: 4.67, right: 4.67),
                                  decoration: BoxDecoration(
                                      color: bloc.learnType == 0
                                          ? AppColors.accent
                                          : AppColors.primary,
                                      borderRadius:
                                          BorderRadius.circular(2.33)),
                                  child: Center(
                                    child: customText(
                                        '+${(filterTrue - 1).toString()}',
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T10))),
                                  ),
                                )
                              : Container(),
                      filterTrue > 8
                          ? Container()
                          : filterTrue > 1
                              ? spaceW(2)
                              : Container(),
                      Image.asset(
                        bloc.learnType == 0
                            ? AppImages.iSelectBCDown
                            : AppImages.iSelectBCaDown,
                        width: 12,
                        height: 12,
                        color: bloc.learnType == 0
                            ? AppColors.accentDark10
                            : AppColors.primaryDark10,
                      )
                    ],
                  ),
                ),
              ),
            ),
            bloc.learnType == 0 ? Expanded(child: Container()) : Container(),
            bloc.learnType == 0 && bloc.snapIndex == 2
                ? Container(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          bloc.snapIndex = 1;
                          bloc.gesture = false;
                          if ((bloc.selectMarker
                                      ? selectScrollController
                                      : scrollController)!
                                  .hasClients &&
                              (bloc.selectMarker
                                          ? bloc.selectClass
                                          : dataSaver.neighborHoodClass)!
                                      .classData
                                      .length >
                                  2) {
                            if ((bloc.selectMarker
                                        ? selectScrollController
                                        : scrollController)!
                                    .position
                                    .maxScrollExtent ==
                                (bloc.selectMarker
                                        ? selectScrollController
                                        : scrollController)!
                                    .offset) {
                              Future.delayed(Duration(milliseconds: 200), () {
                                (bloc.selectMarker
                                        ? selectScrollController
                                        : scrollController)!
                                    .animateTo(
                                        (bloc.selectMarker
                                                ? selectScrollController
                                                : scrollController)!
                                            .position
                                            .maxScrollExtent,
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.ease);
                              });
                            }
                          }
                          panelController.animatePanelToSnapPoint(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.ease);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryLight50,
                          elevation: 0,
                          padding: EdgeInsets.only(left: 12, right: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      child: Center(
                        child: customText('지도보기',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  )
                : Container(),
            spaceW(20)
          ],
        ),
      ),
    );
  }

  nonMemberLoad() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: AppColors.black.withOpacity(0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 144,
                // height: 196,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Lottie.asset(
                      AppImages.nonMemberLoad,
                      width: 104,
                      height: 104,
                      controller: loadingController,
                      onLoaded: (composition) {
                        setState(() {
                          loadingController!..duration = composition.duration;
                          loadingController!.forward().then((value) async {
                            await prefs!.setBool('memberLoad', true);
                            dataSaver.mainBloc!
                                .add(MenuBarHideEvent(hide: false));
                            setState(() {});
                          });
                        });
                      },
                    ),
                    spaceH(18),
                    customText(
                      '다른 동네로\n구경가는 중이에요',
                      style: TextStyle(
                          color: AppColors.gray600,
                          fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                          fontSize: fontSizeSet(textSize: TextSize.T13)),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool openWord = false;

  @override
  blocListener(BuildContext context, state) async {
    setState(() {});
    if (state is GetKeywordCountState) {
      setState(() {});
    }

    if (state is LearnInitState) {
      dataSaver.learnBloc = bloc;
      dataSaver.filterOpen = filterOpen;
      panelController.animatePanelToSnapPoint(
          duration: Duration(milliseconds: 300));
      if (!openWord) {
        openWord = true;
        if (!(prefs!.getBool('keyword') ?? false) && !dataSaver.nonMember) {
          await prefs!.setBool('keyword', true);
          amplitudeEvent('keyword_list_main_open', {});
          customDialog(
              context: context,
              barrier: true,
              widget: WordCloudDialogPage(),
              update: true);
        }
      }
      await Future.delayed(Duration(milliseconds: 2000));
      setState(() {
        learnLoadingPass = true;
      });
    }

    if (state is NotificationAnimationState) {
      setState(() {
        notificationAnimation!.reset();
        notificationAnimation!.forward();
      });
    }

    if (state is SaveFilterState) {
      if (bloc.learnType == 0) {
        bloc.setPublicClassData();
        bloc.mapDatas = [];
        bloc.markers = [];
        if (bloc.selectMarker) {
          bloc.selectMarker = false;
          bloc.selectLocation = '전국';
          bloc.selectMarkerData = null;
          scrollController!.jumpTo(0);
        }
        bloc.sidoMarkerAdd = false;
        bloc.sigunguMarkerAdd = false;
        bloc.eupmyeondongMarkerAdd = false;
        if (bloc.mapLevel >= 6 && bloc.mapLevel < 11.6) {
          bloc.getMarker(2);
        } else if (bloc.mapLevel >= 11.6 && bloc.mapLevel < 18) {
          bloc.getMarker(3);
        }
        bloc.add(ReloadClassEvent());
        if (bloc.search) {
          dataSaver.searchBloc!.add(searchBloc.SearchReloadClassEvent());
        }
      }
    }

    if (state is NeighborHoodChangeState) {
      if (bloc.selectMarker) {
        bloc.selectedMarkerTap(bloc.selectMarkerData, null);
        bloc.selectMarker = false;
        bloc.selectLocation = '전국';
        bloc.selectMarkerData = null;
        scrollController!.jumpTo(0);
      }

      bloc.naverMapController!.moveCamera(CameraUpdate.scrollWithOptions(
          LatLng(double.parse(bloc.mainNeighborHood!.lati!),
              double.parse(bloc.mainNeighborHood!.longi!)),
          duration: 1,
          zoom: bloc.mapLevel.toDouble()));
      bloc.add(ReloadClassEvent());
      bloc.add(CommunityReloadEvent());
    }

    if (state is ReloadLearnState) {
      scrollController!.jumpTo(0);
    }

    if (state is ChangeViewState) {
      setState(() {
        if (bloc.closeNeighborhoodSelecter) {
          if (bloc.neighborhoodSelecterView) {
            bloc.neighborhoodSelecterAnimationEnd = false;
          }
          bloc.neighborhoodSelecterView = false;
        }
      });
    }

    if (state is CommunityFirstInState) {
      firstCommunityDialog();
    }
  }

  firstCommunityDialog() {
    return customDialog(
        context: context,
        barrier: true,
        elevation: 1,
        update: true,
        barrierColor: AppColors.transparent,
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Image.asset(
                    AppImages.bnrNewCommunity,
                    width: MediaQuery.of(context).size.width -
                        (MediaQuery.of(context).size.width * 0.3),
                    fit: BoxFit.contain,
                  )),
            ),
            spaceH(12),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Container(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    dataSaver.mainBloc!.balloonShow = false;
                    dataSaver.mainBloc!.add(UiUpdateEvent());
                    popDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.secondaryLight20,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Center(
                    child: customText('좋아요!',
                        style: TextStyle(
                            color: AppColors.secondaryDark30,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T14))),
                  ),
                ),
              ),
            ),
            spaceH(12)
          ],
        ));
  }

  @override
  initBloc() {
    return LearnBloc(context)..add(LearnInitEvent(vsync: this));
  }

  @override
  void dispose() {
    notificationAnimation!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    communityScrollController = ScrollController()
      ..addListener(() {
        if (communityScrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.communityBottomOffset = 0;
          bloc.communityScrollUnder = false;
        }
        if (!bloc.communityScrollUnder &&
            (bloc.communityBottomOffset == 0 ||
                bloc.communityBottomOffset <
                    communityScrollController!.offset) &&
            communityScrollController!.offset >=
                (communityScrollController!.position.maxScrollExtent * 0.7) &&
            !communityScrollController!.position.outOfRange) {
          bloc.add(CommunityNewDataEvent());
        }
        if (!bloc.communityScrollUnder &&
            (bloc.communityBottomOffset == 0 ||
                bloc.communityBottomOffset <
                    communityScrollController!.offset) &&
            communityScrollController!.offset >=
                communityScrollController!.position.maxScrollExtent &&
            !communityScrollController!.position.outOfRange) {
          bloc.communityScrollUnder = true;
          bloc.communityBottomOffset = communityScrollController!.offset;
        }
      });

    notificationAnimation = AnimationController(vsync: this);
    loadingController = AnimationController(vsync: this);

    if ((prefs!.getBool('memberLoad') == null ||
            !prefs!.getBool('memberLoad')!) &&
        dataSaver.nonMember) {
      dataSaver.mainBloc!.add(MenuBarHideEvent(hide: true));
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      panelController.animatePanelToSnapPoint(
          duration: Duration(milliseconds: 200), curve: Curves.ease);
    });
  }
}
