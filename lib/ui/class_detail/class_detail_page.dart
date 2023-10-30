import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/chat/chat_detail_page.dart';
import 'package:baeit/ui/chat_help/chat_help_page.dart';
import 'package:baeit/ui/class_location/class_location_page.dart';
import 'package:baeit/ui/create_class/create_class_page.dart';
import 'package:baeit/ui/image_view/image_view_page.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/my_create_class/my_create_class_bloc.dart';
import 'package:baeit/ui/recent_or_bookmark/recent_or_bookmark_bloc.dart';
import 'package:baeit/ui/review/review_detail_page.dart';
import 'package:baeit/ui/search/search_bloc.dart';
import 'package:baeit/ui/search/search_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/kakao_link.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/opacity_container.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/stop_view.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'class_detail_bloc.dart';

class ClassDetailPage extends BlocStatefulWidget {
  final String? heroTag;
  final String classUuid;
  final NeighborHood mainNeighborHood;
  final dynamic bloc;
  final int? selectIndex;
  final ProfileGet? profileGet;
  final bool? classMadeCheck;
  final bool my;
  final bool chatDetail;
  final String inputPage;
  final Widget? keywordMoveWidget;
  final bool profileDialogCheck;

  ClassDetailPage(
      {this.heroTag,
      required this.classUuid,
      required this.mainNeighborHood,
      this.bloc,
      this.selectIndex,
      this.profileGet,
      this.classMadeCheck,
      this.my = false,
      this.chatDetail = false,
      this.inputPage = '',
      this.keywordMoveWidget,
      this.profileDialogCheck = false});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ClassDetailState();
  }
}

class ClassDetailState extends BlocState<ClassDetailBloc, ClassDetailPage>
    with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  bool lastStatus = true;
  PageController pageController = PageController(initialPage: 0);
  TabController? tabController;
  AnimationController? bookmarkController;

  scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  bool get isShrink {
    return scrollController.hasClients &&
        scrollController.offset > (430 - kToolbarHeight);
  }

  tabListener() {
    if (tabIndex == 0) {
      bloc.add(ClassIntroduceSelectEvent());
    } else {
      bloc.add(TeacherIntroduceSelectEvent());
    }
  }

  int get tabIndex {
    return tabController!.index;
  }

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    tabController = TabController(length: 3, vsync: this);
    tabController!.addListener(tabListener);
    bookmarkController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  keywordItem() {
    List<Widget> items = [];
    for (int i = 0; i < bloc.classDetail!.content.keywords!.length; i++) {
      items.add(Container(
        height: 30,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(48)),
        child: ElevatedButton(
          onPressed: () {
            dataSaver.searchText = bloc.classDetail!.content.keywords![i];
            dataSaver.keyword = true;
            pushTransition(
                context,
                SearchPage(
                  learnType: 0,
                )).then((value) {
              dataSaver.keyword = false;
            });

            // dataSaver.mainBloc!.add(MenuBarHideEvent(hide: true));
            // dataSaver.learnBloc!.add(SearchChangeEvent());
            // popUntilSearch(context, 0);
          },
          style: ElevatedButton.styleFrom(
            primary: AppColors.white.withOpacity(0.9),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(48),
                side: BorderSide(width: 1, color: AppColors.gray200)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              customText(
                '#',
                style: TextStyle(
                    color: AppColors.accentLight20,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T11)),
              ),
              customText(
                '${bloc.classDetail!.content.keywords![i]}',
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T11)),
              ),
            ],
          ),
        ),
      ));
    }
    return items;
  }

  keyword() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            AppStrings.of(StringKey.keyword),
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.BOLD),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
          ),
          spaceH(20),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: keywordItem(),
          )
        ],
      ),
    );
  }

  chatEventName() {
    if (widget.inputPage == 'main') {
      return 'chat_class_clicks';
    } else if (widget.inputPage == 'recent') {
      return 'chat_recent_class_clicks';
    } else if (widget.inputPage == 'bookmark') {
      return 'chat_bookmark_class_clicks';
    }
  }

  bool heartCheck = false;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              bloc.moreEnd = false;
              bloc.add(SelectMoreEvent(select: false));
            },
            child: Container(
              color: AppColors.white,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: AppColors.white,
                  body: Stack(
                    children: [
                      bloc.classDetail == null
                          ? Container()
                          : Positioned.fill(
                              bottom: 60,
                              child: NestedScrollView(
                                  controller: scrollController,
                                  headerSliverBuilder: (BuildContext context,
                                      bool innerBoxIsScrolled) {
                                    return <Widget>[
                                      SliverAppBar(
                                        pinned: true,
                                        snap: false,
                                        floating: false,
                                        automaticallyImplyLeading: false,
                                        titleSpacing: 0,
                                        elevation: 0,
                                        toolbarHeight: 60,
                                        title: Stack(
                                          children: [
                                            isShrink
                                                ? Container()
                                                : Positioned(
                                                    top: 0,
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    child: topGradient(
                                                        context: context,
                                                        height: 60),
                                                  ),
                                            Container(
                                              color: AppColors.white,
                                              height: 60,
                                              child: Row(
                                                children: [
                                                  spaceW(20),
                                                  SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          pop(context);
                                                        },
                                                        padding:
                                                            EdgeInsets.zero,
                                                        icon: Image.asset(
                                                          isShrink
                                                              ? AppImages
                                                                  .iChevronPrev
                                                              : AppImages
                                                                  .iChevronPrev,
                                                          width: 24,
                                                          height: 24,
                                                        )),
                                                  ),
                                                  Expanded(
                                                      child: isShrink
                                                          ? customText(
                                                              bloc.classDetail!.content
                                                                          .title ==
                                                                      null
                                                                  ? AppStrings.of(
                                                                      StringKey
                                                                          .previewTitleHint)
                                                                  : bloc
                                                                      .classDetail!
                                                                      .content
                                                                      .title!,
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .gray900,
                                                                  fontWeight: weightSet(
                                                                      textWeight:
                                                                          TextWeight
                                                                              .BOLD),
                                                                  fontSize: fontSizeSet(
                                                                      textSize:
                                                                          TextSize
                                                                              .T15)),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )
                                                          : Container()),
                                                  spaceW(20),
                                                  bloc.classDetail!.mineFlag ==
                                                              1 &&
                                                          (bloc.classDetail!
                                                                      .status ==
                                                                  'NORMAL' ||
                                                              bloc.classDetail!
                                                                      .status ==
                                                                  'STOP')
                                                      ? OpacityTextContainer(
                                                          text: bloc.classDetail!
                                                                      .status ==
                                                                  'STOP'
                                                              ? AppStrings.of(
                                                                  StringKey
                                                                      .stop)
                                                              : AppStrings.of(
                                                                  StringKey
                                                                      .inOperation),
                                                          color: bloc.classDetail!
                                                                      .status ==
                                                                  'STOP'
                                                              ? AppColors
                                                                  .gray600
                                                              : null,
                                                        )
                                                      : bloc.classDetail!
                                                                  .status ==
                                                              'TEMP'
                                                          ? OpacityTextContainer(
                                                              text: AppStrings
                                                                  .of(StringKey
                                                                      .temp),
                                                              color: AppColors
                                                                  .secondaryDark20,
                                                            )
                                                          : Container(),
                                                  spaceW(16),
                                                  bloc.classDetail != null &&
                                                          bloc.classDetail!
                                                                  .mineFlag !=
                                                              1
                                                      ? GestureDetector(
                                                          onTap: () async {
                                                            if (!dataSaver
                                                                .nonMember) {
                                                              if (!heartCheck) {
                                                                heartCheck =
                                                                    true;
                                                                if (bloc.classDetail!
                                                                        .likeFlag ==
                                                                    1) {
                                                                  setState(() {
                                                                    bloc.heartAnimation =
                                                                        true;
                                                                    Future.delayed(
                                                                        Duration(
                                                                            milliseconds:
                                                                                100),
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        bloc.heartAnimation =
                                                                            false;
                                                                      });
                                                                    });
                                                                  });
                                                                  bloc.add(
                                                                      BookmarkChangeEvent(
                                                                          flag:
                                                                              1));
                                                                  if (widget
                                                                          .bloc !=
                                                                      null) {}
                                                                } else {
                                                                  amplitudeRevenue(
                                                                      productId:
                                                                          'class_bookmark',
                                                                      price: 1);
                                                                  classEvent(
                                                                    'class_bookmark_clicks',
                                                                    bloc.classDetail!
                                                                        .classUuid,
                                                                    widget
                                                                        .mainNeighborHood
                                                                        .lati!,
                                                                    widget
                                                                        .mainNeighborHood
                                                                        .longi!,
                                                                    widget
                                                                        .mainNeighborHood
                                                                        .sidoName!,
                                                                    widget
                                                                        .mainNeighborHood
                                                                        .sigunguName!,
                                                                    widget
                                                                        .mainNeighborHood
                                                                        .eupmyeondongName!,
                                                                    firstFree: bloc.classDetail!.content.firstFreeFlag ==
                                                                            0
                                                                        ? false
                                                                        : true,
                                                                    group: bloc.classDetail!.content.groupFlag ==
                                                                            0
                                                                        ? false
                                                                        : true,
                                                                    groupCost: bloc
                                                                        .classDetail!
                                                                        .content
                                                                        .costOfPerson
                                                                        .toString(),
                                                                    reviewCount: bloc
                                                                        .classDetail!
                                                                        .reviewCnt,
                                                                  );
                                                                  setState(() {
                                                                    bloc.heartAnimation =
                                                                        true;
                                                                    Future.delayed(
                                                                        Duration(
                                                                            milliseconds:
                                                                                100),
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        bloc.heartAnimation =
                                                                            false;
                                                                      });
                                                                    });
                                                                  });
                                                                  bloc.add(
                                                                      BookmarkChangeEvent(
                                                                          flag:
                                                                              0));
                                                                  if (widget
                                                                          .bloc !=
                                                                      null) {
                                                                    if (widget
                                                                            .bloc
                                                                        is RecentOrBookmarkBloc) {
                                                                      widget
                                                                          .bloc
                                                                          .add(
                                                                              BookmarkAnimationCheckEvent(
                                                                        index: widget
                                                                            .selectIndex!,
                                                                        flag: 1,
                                                                      ));
                                                                    }
                                                                  }
                                                                }
                                                                Future.delayed(
                                                                    Duration(
                                                                        milliseconds:
                                                                            1000),
                                                                    () {
                                                                  heartCheck =
                                                                      false;
                                                                });
                                                              }
                                                            } else {
                                                              nonMemberDialog(
                                                                  context:
                                                                      context,
                                                                  title: AppStrings
                                                                      .of(StringKey
                                                                          .alertBookmark),
                                                                  content: AppStrings
                                                                      .of(StringKey
                                                                          .alertBookmarkContent));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 28,
                                                            height: 28,
                                                            child: Stack(
                                                              children: [
                                                                AnimatedPositioned(
                                                                  top: 0,
                                                                  left:
                                                                      bloc.heartAnimation
                                                                          ? 0
                                                                          : 3,
                                                                  right:
                                                                      bloc.heartAnimation
                                                                          ? 0
                                                                          : 3,
                                                                  bottom: 0,
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          100),
                                                                  curve: Curves
                                                                      .ease,
                                                                  child: Image
                                                                      .asset(
                                                                    bloc.classDetail!.likeFlag ==
                                                                            0
                                                                        ? AppImages
                                                                            .iHeartCoff
                                                                        : AppImages
                                                                            .iHeartCOn,
                                                                    width: 24,
                                                                    height: 24,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  bloc.classDetail != null &&
                                                          bloc.classDetail!
                                                                  .mineFlag !=
                                                              1
                                                      ? spaceW(12)
                                                      : Container(),
                                                  SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        onPressed: () async {
                                                          if (bloc.classDetail!
                                                                  .mineFlag ==
                                                              1) {
                                                            bloc.moreEnd =
                                                                false;
                                                            bloc.add(SelectMoreEvent(
                                                                select: !bloc
                                                                    .selectMore));
                                                          } else {
                                                            amplitudeRevenue(
                                                                productId:
                                                                    'class_share',
                                                                price: 2);
                                                            classEvent(
                                                                'class_share_clicks',
                                                                bloc.classDetail!
                                                                    .classUuid,
                                                                widget
                                                                    .mainNeighborHood
                                                                    .lati!,
                                                                widget
                                                                    .mainNeighborHood
                                                                    .longi!,
                                                                widget
                                                                    .mainNeighborHood
                                                                    .sidoName!,
                                                                widget
                                                                    .mainNeighborHood
                                                                    .sigunguName!,
                                                                widget
                                                                    .mainNeighborHood
                                                                    .eupmyeondongName!,
                                                                firstFree:
                                                                    bloc.classDetail!.content.firstFreeFlag == 0
                                                                        ? false
                                                                        : true,
                                                                group: bloc
                                                                            .classDetail!
                                                                            .content
                                                                            .groupFlag ==
                                                                        0
                                                                    ? false
                                                                    : true,
                                                                groupCost: bloc
                                                                    .classDetail!
                                                                    .content
                                                                    .costOfPerson
                                                                    .toString());

                                                            if (!dataSaver
                                                                .share) {
                                                              dataSaver.share =
                                                                  true;
                                                              await ClassRepository
                                                                      .getShareLink(bloc
                                                                          .classDetail!
                                                                          .classUuid)
                                                                  .then(
                                                                      (value) async {
                                                                await Share
                                                                    .share(value
                                                                        .data);
                                                                dataSaver
                                                                        .share =
                                                                    false;
                                                              });
                                                            }
                                                          }
                                                        },
                                                        icon: Image.asset(
                                                          isShrink
                                                              ? bloc.classDetail!
                                                                          .mineFlag ==
                                                                      1
                                                                  ? AppImages
                                                                      .iMore
                                                                  : AppImages
                                                                      .iShare
                                                              : bloc.classDetail!
                                                                          .mineFlag ==
                                                                      1
                                                                  ? AppImages
                                                                      .iMore
                                                                  : AppImages
                                                                      .iShare,
                                                          width: 24,
                                                          height: 24,
                                                        )),
                                                  ),
                                                  spaceW(20),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.white,
                                        expandedHeight: bloc.classDetail!
                                                    .content.groupFlag ==
                                                0
                                            ? 580
                                            : 600,
                                        flexibleSpace: FlexibleSpaceBar(
                                          background: Container(
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 60,
                                                  left: 0,
                                                  right: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 191,
                                                        child: bloc
                                                                    .classDetail!
                                                                    .content
                                                                    .images!
                                                                    .length ==
                                                                0
                                                            ? Center(
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  height: 191,
                                                                  color: AppColors
                                                                      .gray200,
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned(
                                                                          left:
                                                                              0,
                                                                          right:
                                                                              0,
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              0,
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                AppColors.white.withOpacity(0),
                                                                            child:
                                                                                Image.asset(
                                                                              AppImages.dfClassMain,
                                                                              width: 160,
                                                                              height: 142,
                                                                            ),
                                                                          )),
                                                                      Container(
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        height:
                                                                            180,
                                                                        decoration: BoxDecoration(
                                                                            color: AppColors
                                                                                .gray200,
                                                                            gradient:
                                                                                LinearGradient(begin: FractionalOffset.bottomCenter, end: FractionalOffset.topCenter, stops: [
                                                                              0.0,
                                                                              1.0
                                                                            ], colors: [
                                                                              AppColors.black.withOpacity(0),
                                                                              AppColors.black.withOpacity(0.2)
                                                                            ])),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : Stack(
                                                                children: [
                                                                  PageView
                                                                      .builder(
                                                                    physics: bloc.classDetail!.content.images!.length ==
                                                                            1
                                                                        ? NeverScrollableScrollPhysics()
                                                                        : null,
                                                                    onPageChanged:
                                                                        (int
                                                                            idx) {
                                                                      bloc.add(TopImageChangeEvent(
                                                                          idx: idx %
                                                                              bloc.classDetail!.content.images!.length));
                                                                    },
                                                                    itemBuilder:
                                                                        (context,
                                                                            idx) {
                                                                      return GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          pushTransition(
                                                                              context,
                                                                              ImageViewPage(
                                                                                imageUrls: bloc.classDetail!.content.images!,
                                                                                heroTag: widget.heroTag ?? '',
                                                                                originImage: bloc.classDetail!.content.representativeOriginFile,
                                                                              ));
                                                                        },
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: 191,
                                                                              padding: EdgeInsets.only(left: 10, right: 10),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                child: CacheImage(
                                                                                  imageUrl: '${bloc.classDetail!.content.images![idx % bloc.classDetail!.content.images!.length].toView(
                                                                                    context: context,
                                                                                  )}',
                                                                                  heightSet: false,
                                                                                  width: MediaQuery.of(context).size.width * 2,
                                                                                  fit: (idx % bloc.classDetail!.content.images!.length) == 0
                                                                                      ? BoxFit.cover
                                                                                      : idx == 0
                                                                                          ? BoxFit.cover
                                                                                          : BoxFit.cover,
                                                                                  placeholder: Container(
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(4)),
                                                                                    child: Image.asset(
                                                                                      AppImages.dfClassMain,
                                                                                      width: MediaQuery.of(context).size.width,
                                                                                      height: 191,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  bloc.classDetail!.content
                                                                              .firstFreeFlag ==
                                                                          1
                                                                      ? Positioned(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              20,
                                                                          child: Container(
                                                                              height: 24,
                                                                              padding: EdgeInsets.only(left: 8, right: 8),
                                                                              decoration: BoxDecoration(color: AppColors.black.withOpacity(0.24), borderRadius: BorderRadius.circular(4)),
                                                                              child: Center(child: customText('첫회무료', style: TextStyle(fontSize: fontSizeSet(textSize: TextSize.T12), color: AppColors.white, fontWeight: weightSet(textWeight: TextWeight.BOLD))))),
                                                                        )
                                                                      : Container(),
                                                                  bloc.classDetail!.content.images!
                                                                              .length ==
                                                                          1
                                                                      ? Container()
                                                                      : Positioned
                                                                          .fill(
                                                                          top:
                                                                              176,
                                                                          bottom:
                                                                              6,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Center(
                                                                              child: Container(
                                                                                height: 8,
                                                                                child: Center(
                                                                                  child: ListView.builder(
                                                                                    shrinkWrap: true,
                                                                                    physics: NeverScrollableScrollPhysics(),
                                                                                    itemBuilder: (context, index) {
                                                                                      return Center(
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.only(right: bloc.classDetail!.content.images!.length - 1 == index ? 0 : 8),
                                                                                          child: Stack(
                                                                                            children: [
                                                                                              ClipOval(
                                                                                                  child: Container(
                                                                                                width: 8,
                                                                                                height: 8,
                                                                                                decoration: BoxDecoration(
                                                                                                  boxShadow: [
                                                                                                    BoxShadow(color: AppColors.black.withOpacity(0.2), blurRadius: 16, offset: Offset(0, 0))
                                                                                                  ],
                                                                                                  color: AppColors.white.withOpacity(0.5),
                                                                                                ),
                                                                                              )),
                                                                                              ClipOval(
                                                                                                  child: Container(
                                                                                                width: 8,
                                                                                                height: 8,
                                                                                                color: bloc.topImageIdx % bloc.classDetail!.content.images!.length == index ? AppColors.gray600.withOpacity(0.7) : AppColors.gray600.withOpacity(0.16),
                                                                                              )),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                    itemCount: bloc.classDetail!.content.images != null ? bloc.classDetail!.content.images!.length : 0,
                                                                                    scrollDirection: Axis.horizontal,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                ],
                                                              ),
                                                      ),
                                                      spaceH(24),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20,
                                                                right: 20),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            customText(
                                                              bloc.classDetail!.content
                                                                          .title ==
                                                                      null
                                                                  ? AppStrings.of(
                                                                      StringKey
                                                                          .previewTitleHint)
                                                                  : bloc
                                                                      .classDetail!
                                                                      .content
                                                                      .title!,
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .gray900,
                                                                  fontWeight: weightSet(
                                                                      textWeight:
                                                                          TextWeight
                                                                              .BOLD),
                                                                  fontSize: fontSizeSet(
                                                                      textSize:
                                                                          TextSize
                                                                              .T16)),
                                                            ),
                                                            spaceH(6),
                                                            Row(
                                                              children: [
                                                                customText(
                                                                  DateTime.now()
                                                                              .difference(bloc
                                                                                  .classDetail!.content.createDate)
                                                                              .inMinutes >
                                                                          14400
                                                                      ? bloc
                                                                          .classDetail!
                                                                          .content
                                                                          .createDate
                                                                          .yearMonthDay
                                                                      : timeCalculationText(DateTime
                                                                              .now()
                                                                          .difference(bloc
                                                                              .classDetail!
                                                                              .content
                                                                              .createDate)
                                                                          .inMinutes),
                                                                  style: TextStyle(
                                                                      color: AppColors
                                                                          .gray600,
                                                                      fontWeight: weightSet(
                                                                          textWeight: TextWeight
                                                                              .MEDIUM),
                                                                      fontSize: fontSizeSet(
                                                                          textSize:
                                                                              TextSize.T12)),
                                                                ),
                                                                spaceW(10),
                                                                bloc.classDetail!
                                                                            .status ==
                                                                        'TEMP'
                                                                    ? Container()
                                                                    : Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            AppImages.iViewCountG,
                                                                            width:
                                                                                12,
                                                                            height:
                                                                                12,
                                                                          ),
                                                                          spaceW(
                                                                              4),
                                                                          customText(
                                                                            bloc.classDetail!.readCnt.toString(),
                                                                            style: TextStyle(
                                                                                color: AppColors.gray400,
                                                                                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                                                                                fontSize: fontSizeSet(textSize: TextSize.T11)),
                                                                          ),
                                                                          spaceW(
                                                                              10),
                                                                          Row(
                                                                            children: [
                                                                              Image.asset(
                                                                                AppImages.iHeartGOff,
                                                                                width: 12,
                                                                                height: 12,
                                                                              ),
                                                                              spaceW(4),
                                                                              customText(
                                                                                bloc.classDetail!.likeCnt.toString(),
                                                                                style: TextStyle(color: AppColors.gray400, fontWeight: weightSet(textWeight: TextWeight.MEDIUM), fontSize: fontSizeSet(textSize: TextSize.T11)),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          spaceW(
                                                                              10),
                                                                          Container(
                                                                            decoration: BoxDecoration(
                                                                                color: AppColors.white,
                                                                                borderRadius: BorderRadius.circular(4),
                                                                                border: Border.all(color: AppColors.gray200)),
                                                                            padding: EdgeInsets.only(
                                                                                left: 8,
                                                                                right: 8,
                                                                                top: 6,
                                                                                bottom: 6),
                                                                            child: bloc.classDetail!.chatCnt == 0
                                                                                ? customText(
                                                                                    AppStrings.of(StringKey.chatWait),
                                                                                    style: TextStyle(color: AppColors.gray600, fontWeight: weightSet(textWeight: TextWeight.REGULAR), fontSize: fontSizeSet(textSize: TextSize.T11)),
                                                                                  )
                                                                                : RichText(
                                                                                    textAlign: TextAlign.center,
                                                                                    text: TextSpan(children: [
                                                                                      customTextSpan(text: bloc.classDetail!.chatCnt.toString(), style: TextStyle(color: AppColors.primaryDark10, fontWeight: weightSet(textWeight: TextWeight.BOLD), fontSize: fontSizeSet(textSize: TextSize.T11))),
                                                                                      customTextSpan(text: '명이 채팅을 보냈어요', style: TextStyle(color: AppColors.gray600, fontWeight: weightSet(textWeight: TextWeight.MEDIUM), fontSize: fontSizeSet(textSize: TextSize.T11))),
                                                                                    ]),
                                                                                  ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                              ],
                                                            ),
                                                            spaceH(16),
                                                            GestureDetector(
                                                              onTap: () {
                                                                amplitudeEvent(
                                                                    'profile_click',
                                                                    {
                                                                      'class_uuid': bloc
                                                                          .classDetail!
                                                                          .classUuid,
                                                                      'type':
                                                                          'class'
                                                                    });
                                                                profileDialog(
                                                                    context:
                                                                        context,
                                                                    memberUuid: bloc
                                                                        .classDetail!
                                                                        .member
                                                                        .memberUuid);
                                                              },
                                                              child: Container(
                                                                color: AppColors
                                                                    .white,
                                                                child: Center(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30),
                                                                        child: bloc.classDetail!.member.profile !=
                                                                                null
                                                                            ? Container(
                                                                                width: 24,
                                                                                height: 24,
                                                                                child: CacheImage(
                                                                                  imageUrl: bloc.classDetail!.member.profile!,
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              )
                                                                            : Image.asset(
                                                                                AppImages.dfProfile,
                                                                                width: 24,
                                                                                height: 24,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                      ),
                                                                      spaceW(6),
                                                                      customText(
                                                                        '${bloc.classDetail!.member.nickName} >',
                                                                        style: TextStyle(
                                                                            color:
                                                                                AppColors.gray600,
                                                                            fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                                                                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            spaceH(20),
                                                            Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              decoration: BoxDecoration(
                                                                  color: AppColors
                                                                      .primaryLight60,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 16,
                                                                      right: 16,
                                                                      top: 12,
                                                                      bottom:
                                                                          12),
                                                              child: Row(
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            AppImages.iLocation,
                                                                            width:
                                                                                12,
                                                                            height:
                                                                                12,
                                                                          ),
                                                                          spaceW(
                                                                              2),
                                                                          customText(
                                                                            '${widget.mainNeighborHood.townName}에서 ${double.parse(bloc.classDetail!.content.distance).toString().split('.')[0].length > 3 ? '${(double.parse(bloc.classDetail!.content.distance) / 1000) > 20 ? '20km+' : '${(double.parse(bloc.classDetail!.content.distance) / 1000).toStringAsFixed(1)}km'}' : '${double.parse(bloc.classDetail!.content.distance).toString().split('.')[0].length == 3 ? (double.parse(bloc.classDetail!.content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(bloc.classDetail!.content.distance).toString().split('.')[0]}m'}',
                                                                            style: TextStyle(
                                                                                color: AppColors.primaryDark10,
                                                                                fontWeight: weightSet(textWeight: TextWeight.BOLD),
                                                                                fontSize: fontSizeSet(textSize: TextSize.T12)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      spaceH(4),
                                                                      customText(
                                                                          '${bloc.classDetail!.content.areas!.map((e) => e.eupmyeondongName).toString().replaceAll('(', '').replaceAll(')', '')}',
                                                                          style: TextStyle(
                                                                              color: AppColors.gray500,
                                                                              fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                                                                              fontSize: fontSizeSet(textSize: TextSize.T12)))
                                                                    ],
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(),
                                                                  ),
                                                                  Container(
                                                                    height: 24,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        amplitudeEvent(
                                                                            'check_location_clicks',
                                                                            {
                                                                              'class_uuid': bloc.classDetail!.classUuid,
                                                                              'class_title': bloc.classDetail!.content.title,
                                                                              'costType': bloc.classDetail!.content.costType == 'HOUR' ? 0 : 1,
                                                                              'costSharing': bloc.classDetail!.content.shareType ?? '',
                                                                              'cost_min': bloc.classDetail!.content.minCost,
                                                                              'themeType': dataSaver.themeType,
                                                                              'town_dongeupmyeon': bloc.classDetail!.content.areas == null ? '' : bloc.classDetail!.content.areas!.map((e) => e.eupmyeondongName).toList().join(','),
                                                                              'town_sido': bloc.classDetail!.content.areas == null ? '' : bloc.classDetail!.content.areas!.map((e) => e.sidoName).toList().join(','),
                                                                              'town_sigungu': bloc.classDetail!.content.areas == null ? '' : bloc.classDetail!.content.areas!.map((e) => e.sigunguName).toList().join(','),
                                                                              'first_free': bloc.classDetail!.content.firstFreeFlag == 0 ? false : true,
                                                                              'group': bloc.classDetail!.content.groupFlag == 0 ? false : true,
                                                                              'group_cost': bloc.classDetail!.content.costOfPerson
                                                                            });
                                                                        pushTransition(
                                                                            context,
                                                                            ClassLocationPage(
                                                                              title: bloc.classDetail!.content.title!,
                                                                              classUuid: bloc.classDetail!.classUuid,
                                                                              lati: bloc.classDetail!.content.areas![0].lati,
                                                                              longi: bloc.classDetail!.content.areas![0].longi,
                                                                            ));
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                          primary: AppColors
                                                                              .primary,
                                                                          elevation:
                                                                              0,
                                                                          padding: EdgeInsets.only(
                                                                              left:
                                                                                  10,
                                                                              right:
                                                                                  10),
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                                                                      child:
                                                                          Center(
                                                                        child: customText(
                                                                            '위치보기',
                                                                            style: TextStyle(
                                                                                color: AppColors.white,
                                                                                fontWeight: weightSet(textWeight: TextWeight.BOLD),
                                                                                fontSize: fontSizeSet(textSize: TextSize.T10))),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            spaceH(20),
                                                            Row(
                                                              children: [
                                                                customText(
                                                                    '시간당 비용',
                                                                    style: TextStyle(
                                                                        color: AppColors
                                                                            .greenGray300,
                                                                        fontWeight: weightSet(
                                                                            textWeight: TextWeight
                                                                                .MEDIUM),
                                                                        fontSize:
                                                                            fontSizeSet(textSize: TextSize.T12))),
                                                                Expanded(
                                                                  child:
                                                                      Container(),
                                                                ),
                                                                bloc.classDetail!.content
                                                                            .costType ==
                                                                        'HOUR'
                                                                    ? Row(
                                                                        children: [
                                                                          bloc.classDetail!.content.firstFreeFlag == 1
                                                                              ? customText('첫회무료', style: TextStyle(color: AppColors.gray900, fontWeight: weightSet(textWeight: TextWeight.MEDIUM), fontSize: fontSizeSet(textSize: TextSize.T12)))
                                                                              : Container(),
                                                                          bloc.classDetail!.content.firstFreeFlag == 1
                                                                              ? spaceW(8)
                                                                              : Container(),
                                                                          customText(
                                                                              bloc.classDetail!.content.minCost == null ? AppStrings.of(StringKey.previewCostHint) : '${numberFormat.format(bloc.classDetail!.content.minCost ?? 0)}원 ~',
                                                                              style: TextStyle(color: AppColors.gray900, fontWeight: weightSet(textWeight: TextWeight.BOLD), fontSize: fontSizeSet(textSize: TextSize.T16)))
                                                                        ],
                                                                      )
                                                                    : Row(
                                                                        children: [
                                                                          customText(
                                                                              shareSelectText(shareTypeIdx(bloc.classDetail!.content.shareType)),
                                                                              style: TextStyle(color: AppColors.gray900, fontWeight: weightSet(textWeight: TextWeight.MEDIUM), fontSize: fontSizeSet(textSize: TextSize.T12))),
                                                                          spaceW(
                                                                              8),
                                                                          customText(
                                                                              '배움나눔',
                                                                              style: TextStyle(color: AppColors.secondaryDark30, fontWeight: weightSet(textWeight: TextWeight.BOLD), fontSize: fontSizeSet(textSize: TextSize.T16)))
                                                                        ],
                                                                      )
                                                              ],
                                                            ),
                                                            spaceH(10),
                                                            bloc.classDetail!.content
                                                                        .groupFlag ==
                                                                    0
                                                                ? Container()
                                                                : Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Container(),
                                                                      ),
                                                                      Image
                                                                          .asset(
                                                                        AppImages
                                                                            .iTipExclamationU,
                                                                        width:
                                                                            12,
                                                                        height:
                                                                            12,
                                                                      ),
                                                                      spaceW(4),
                                                                      customText(
                                                                          '여럿이 모이면 ${numberFormat.format(bloc.classDetail!.content.costOfPerson)}원 ~',
                                                                          style: TextStyle(
                                                                              color: AppColors.accentDark10,
                                                                              fontWeight: weightSet(textWeight: TextWeight.BOLD),
                                                                              fontSize: fontSizeSet(textSize: TextSize.T12))),
                                                                      spaceW(8),
                                                                      Container(
                                                                        height:
                                                                            24,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            await ClassRepository.getShareLink(bloc.classDetail!.classUuid).then((value) {
                                                                              amplitudeEvent('suggest_friends_clicks', {
                                                                                'class_uuid': bloc.classDetail!.classUuid,
                                                                                'class_title': bloc.classDetail!.content.title,
                                                                                'costType': bloc.classDetail!.content.costType == 'HOUR' ? 0 : 1,
                                                                                'costSharing': bloc.classDetail!.content.shareType ?? '',
                                                                                'themeType': dataSaver.themeType,
                                                                                'town_dongeupmyeon': bloc.classDetail!.content.areas == null ? '' : bloc.classDetail!.content.areas!.map((e) => e.eupmyeondongName).toList().join(','),
                                                                                'town_sido': bloc.classDetail!.content.areas == null ? '' : bloc.classDetail!.content.areas!.map((e) => e.sidoName).toList().join(','),
                                                                                'town_sigungu': bloc.classDetail!.content.areas == null ? '' : bloc.classDetail!.content.areas!.map((e) => e.sigunguName).toList().join(','),
                                                                                'first_free': bloc.classDetail!.content.firstFreeFlag == 0 ? false : true,
                                                                                'group': bloc.classDetail!.content.groupFlag == 0 ? false : true,
                                                                                'group_cost': bloc.classDetail!.content.costOfPerson
                                                                              });
                                                                              kakaoLinkShare(
                                                                                  classUuid: bloc.classDetail!.classUuid,
                                                                                  title: bloc.classDetail!.content.title!,
                                                                                  content: '친구가 공유한 클래스 동네에서 함께 배워보세요!',
                                                                                  image: bloc.classDetail!.content.images![0].toView(
                                                                                    context: context,
                                                                                  ),
                                                                                  link: 'https://' + value.data.toString().split('https://')[1]);
                                                                            });
                                                                          },
                                                                          style: ElevatedButton.styleFrom(
                                                                              primary: AppColors.accent,
                                                                              padding: EdgeInsets.only(left: 10, right: 10),
                                                                              elevation: 0,
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                customText('친구에게 물어보기 >', style: TextStyle(color: AppColors.white, fontWeight: weightSet(textWeight: TextWeight.BOLD), fontSize: fontSizeSet(textSize: TextSize.T10))),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      spaceH(24),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 6,
                                                        color:
                                                            AppColors.gray100,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        bottom: PreferredSize(
                                          preferredSize: Size.fromHeight(60),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: AppColors.white,
                                            child: TabBar(
                                              indicatorPadding: EdgeInsets.zero,
                                              labelPadding: EdgeInsets.zero,
                                              indicatorSize:
                                                  TabBarIndicatorSize.label,
                                              indicatorColor:
                                                  AppColors.primaryDark10,
                                              labelColor:
                                                  AppColors.primaryDark10,
                                              unselectedLabelColor:
                                                  AppColors.gray400,
                                              onTap: (int) {
                                                if (int == 2) {
                                                  if (bloc.classDetail!
                                                          .status ==
                                                      'TEMP') {
                                                    return;
                                                  }
                                                  if (bloc.classDetail!
                                                          .mineFlag !=
                                                      1)
                                                    amplitudeEvent(
                                                        'review_tabclick', {
                                                      'review_count': bloc
                                                          .classDetail!
                                                          .reviewCnt,
                                                      'user_name': dataSaver
                                                          .profileGet!.nickName,
                                                      'class_name': bloc
                                                          .classDetail!
                                                          .content
                                                          .title,
                                                      'cost_min': bloc
                                                          .classDetail!
                                                          .content
                                                          .minCost,
                                                      'town_sido': bloc
                                                          .classDetail!
                                                          .content
                                                          .areas!
                                                          .map(
                                                              (e) => e.sidoName)
                                                          .toList()
                                                          .join(','),
                                                      'town_sigungu': bloc
                                                          .classDetail!
                                                          .content
                                                          .areas!
                                                          .map((e) =>
                                                              e.sigunguName)
                                                          .toList()
                                                          .join(','),
                                                      'town_dongeupmyeon': bloc
                                                          .classDetail!
                                                          .content
                                                          .areas!
                                                          .map((e) => e
                                                              .eupmyeondongName)
                                                          .toList()
                                                          .join(','),
                                                      'costType': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .costType ==
                                                              'HOUR'
                                                          ? 0
                                                          : 1,
                                                      'costSharing': bloc
                                                              .classDetail!
                                                              .content
                                                              .shareType ??
                                                          '',
                                                      'type': 'class',
                                                      'first_free': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .firstFreeFlag ==
                                                              0
                                                          ? false
                                                          : true,
                                                      'group': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .groupFlag ==
                                                              0
                                                          ? false
                                                          : true,
                                                      'group_cost': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .groupFlag ==
                                                              0
                                                          ? ''
                                                          : bloc
                                                              .classDetail!
                                                              .content
                                                              .costOfPerson
                                                    });
                                                  pushTransition(
                                                      context,
                                                      ReviewDetailPage(
                                                        classUuid:
                                                            widget.classUuid,
                                                        chatBlock:
                                                            bloc.chatBlock,
                                                        moveChat: () =>
                                                            moveChat(context),
                                                        nickName: bloc
                                                            .classDetail!
                                                            .member
                                                            .nickName,
                                                        myClass: bloc
                                                                    .classDetail!
                                                                    .mineFlag ==
                                                                0
                                                            ? false
                                                            : true,
                                                        classDetail:
                                                            bloc.classDetail,
                                                      )).then((value) {
                                                    bloc.add(ClassDetailInitEvent(
                                                        mainNeighborHood: widget
                                                            .mainNeighborHood,
                                                        classUuid:
                                                            widget.classUuid));
                                                  });
                                                  return;
                                                }
                                              },
                                              labelStyle: TextStyle(
                                                  color:
                                                      AppColors.primaryDark10,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.BOLD),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T13)),
                                              indicatorWeight: 2,
                                              controller: tabController,
                                              tabs: [
                                                Container(
                                                  width: 80,
                                                  height: 46,
                                                  child: Center(
                                                    child: customText(
                                                        AppStrings.of(StringKey
                                                            .classIntroduce),
                                                        style: TextStyle(
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .BOLD),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T13))),
                                                  ),
                                                ),
                                                Container(
                                                  width: 67,
                                                  height: 48,
                                                  child: Center(
                                                    child: customText(
                                                        AppStrings.of(StringKey
                                                            .teacherIntroduce),
                                                        style: TextStyle(
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .BOLD),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T13))),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (bloc.classDetail!
                                                            .status ==
                                                        'TEMP') {
                                                      return;
                                                    }
                                                    if (bloc.classDetail!
                                                            .mineFlag !=
                                                        1)
                                                      amplitudeEvent(
                                                          'review_tabclick', {
                                                        'review_count': bloc
                                                            .classDetail!
                                                            .reviewCnt,
                                                        'user_name': dataSaver
                                                            .profileGet!
                                                            .nickName,
                                                        'class_name': bloc
                                                            .classDetail!
                                                            .content
                                                            .title,
                                                        'cost_min': bloc
                                                            .classDetail!
                                                            .content
                                                            .minCost,
                                                        'town_sido': bloc
                                                            .classDetail!
                                                            .content
                                                            .areas!
                                                            .map((e) =>
                                                                e.sidoName)
                                                            .toList()
                                                            .join(','),
                                                        'town_sigungu': bloc
                                                            .classDetail!
                                                            .content
                                                            .areas!
                                                            .map((e) =>
                                                                e.sigunguName)
                                                            .toList()
                                                            .join(','),
                                                        'town_dongeupmyeon': bloc
                                                            .classDetail!
                                                            .content
                                                            .areas!
                                                            .map((e) => e
                                                                .eupmyeondongName)
                                                            .toList()
                                                            .join(','),
                                                        'costType': bloc
                                                                    .classDetail!
                                                                    .content
                                                                    .costType ==
                                                                'HOUR'
                                                            ? 0
                                                            : 1,
                                                        'costSharing': bloc
                                                                .classDetail!
                                                                .content
                                                                .shareType ??
                                                            '',
                                                        'type': 'class',
                                                        'first_free': bloc
                                                                    .classDetail!
                                                                    .content
                                                                    .firstFreeFlag ==
                                                                0
                                                            ? false
                                                            : true,
                                                        'group': bloc
                                                                    .classDetail!
                                                                    .content
                                                                    .groupFlag ==
                                                                0
                                                            ? false
                                                            : true,
                                                        'group_cost': bloc
                                                                    .classDetail!
                                                                    .content
                                                                    .groupFlag ==
                                                                0
                                                            ? ''
                                                            : bloc
                                                                .classDetail!
                                                                .content
                                                                .costOfPerson
                                                      });
                                                    pushTransition(
                                                        context,
                                                        ReviewDetailPage(
                                                          classUuid:
                                                              widget.classUuid,
                                                          chatBlock:
                                                              bloc.chatBlock,
                                                          moveChat: () =>
                                                              moveChat(context),
                                                          nickName: bloc
                                                              .classDetail!
                                                              .member
                                                              .nickName,
                                                          myClass: bloc
                                                                      .classDetail!
                                                                      .mineFlag ==
                                                                  0
                                                              ? false
                                                              : true,
                                                          classDetail:
                                                              bloc.classDetail,
                                                        )).then((value) {
                                                      bloc.add(ClassDetailInitEvent(
                                                          mainNeighborHood: widget
                                                              .mainNeighborHood,
                                                          classUuid: widget
                                                              .classUuid));
                                                    });
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 48,
                                                    color: AppColors.white,
                                                    child: Center(
                                                        child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        customText(
                                                            '후기 ${bloc.classDetail!.reviewCnt}',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .gray900,
                                                                fontWeight: weightSet(
                                                                    textWeight:
                                                                        TextWeight
                                                                            .BOLD),
                                                                fontSize: fontSizeSet(
                                                                    textSize:
                                                                        TextSize
                                                                            .T13))),
                                                        spaceW(4),
                                                        Image.asset(
                                                          AppImages.iPopup,
                                                          width: 16,
                                                          height: 16,
                                                        )
                                                      ],
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ];
                                  },
                                  body: TabBarView(
                                    controller: tabController,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      ListView(
                                        physics: NeverScrollableScrollPhysics(),
                                        key: PageStorageKey('classText'),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 30,
                                                bottom: 30),
                                            child: SelectableLinkify(
                                              scrollPhysics:
                                                  NeverScrollableScrollPhysics(),
                                              onOpen: (link) async {
                                                await launch(link.url)
                                                    .then((value) {
                                                  systemColorSetting();
                                                });
                                              },
                                              text: bloc.classDetail!.content
                                                      .classIntroText ??
                                                  '',
                                              style: TextStyle(
                                                  color: AppColors.gray600,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.REGULAR),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T13)),
                                              options: LinkifyOptions(
                                                  humanize: true),
                                            ),
                                          ),
                                          heightLine(
                                              color: AppColors.gray100,
                                              height: 6),
                                          keyword()
                                        ],
                                      ),
                                      ListView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          key: PageStorageKey('teacherText'),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  top: 30,
                                                  bottom: 30),
                                              child: SelectableLinkify(
                                                scrollPhysics:
                                                    NeverScrollableScrollPhysics(),
                                                onOpen: (link) async {
                                                  await launch(link.url)
                                                      .then((value) {
                                                    systemColorSetting();
                                                  });
                                                },
                                                text: bloc.classDetail!.content
                                                        .tutorIntroText ??
                                                    '',
                                                style: TextStyle(
                                                    color: AppColors.gray600,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.REGULAR),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T13)),
                                                options: LinkifyOptions(
                                                    humanize: true),
                                              ),
                                            ),
                                            heightLine(
                                                color: AppColors.gray100,
                                                height: 6),
                                            keyword()
                                          ]),
                                      ListView()
                                    ],
                                  )),
                            ),
                      bloc.classDetail == null
                          ? Container()
                          : Positioned(
                              bottom: 60,
                              child: bottomGradient(
                                  context: context,
                                  height: 20,
                                  color: AppColors.white)),
                      bloc.chatBlock != 2 && bloc.chatBlock != null
                          ? Positioned(
                              left: 0,
                              right: 0,
                              bottom: 60,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 36,
                                color: AppColors.white,
                                child: Center(
                                  child: customText(
                                    bloc.chatBlock == 1
                                        ? '차단한 클래스에는 상담을 요청할 수 없습니다'
                                        : '차단당한 클래스에는 상담을 요청할 수 없습니다',
                                    style: TextStyle(
                                        color: AppColors.gray600,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T12)),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      bloc.classDetail == null
                          ? Container()
                          : bloc.classDetail!.mineFlag != 1
                              ? Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              amplitudeEvent(
                                                  'chat_consultation', {
                                                'type': 'class',
                                                'subType': 'suggest',
                                                'continue': true,
                                                'class_uuid':
                                                    bloc.classDetail!.classUuid,
                                                'class_title': bloc
                                                    .classDetail!.content.title,
                                                'costType': bloc.classDetail!
                                                            .content.costType ==
                                                        'HOUR'
                                                    ? 0
                                                    : 1,
                                                'costSharing': bloc.classDetail!
                                                        .content.shareType ??
                                                    '',
                                                'inflow_page': widget.inputPage,
                                                'themeType':
                                                    dataSaver.themeType,
                                                'town_dongeupmyeon': bloc
                                                            .classDetail!
                                                            .content
                                                            .areas ==
                                                        null
                                                    ? ''
                                                    : bloc.classDetail!.content
                                                        .areas!
                                                        .map((e) =>
                                                            e.eupmyeondongName)
                                                        .toList()
                                                        .join(','),
                                                'town_sido': bloc.classDetail!
                                                            .content.areas ==
                                                        null
                                                    ? ''
                                                    : bloc.classDetail!.content
                                                        .areas!
                                                        .map((e) => e.sidoName)
                                                        .toList()
                                                        .join(','),
                                                'town_sigungu': bloc
                                                            .classDetail!
                                                            .content
                                                            .areas ==
                                                        null
                                                    ? ''
                                                    : bloc.classDetail!.content
                                                        .areas!
                                                        .map((e) =>
                                                            e.sigunguName)
                                                        .toList()
                                                        .join(','),
                                                'first_free': bloc
                                                            .classDetail!
                                                            .content
                                                            .firstFreeFlag ==
                                                        0
                                                    ? false
                                                    : true,
                                                'group': bloc
                                                            .classDetail!
                                                            .content
                                                            .groupFlag ==
                                                        0
                                                    ? false
                                                    : true,
                                                'group_cost': bloc.classDetail!
                                                    .content.costOfPerson,
                                                'review_count':
                                                    bloc.classDetail!.reviewCnt,
                                              });

                                              if (dataSaver.chatRoom != null &&
                                                  dataSaver.chatRoom!.roomData
                                                          .indexWhere((element) =>
                                                              element.classInfo !=
                                                                  null &&
                                                              element.classInfo!
                                                                      .classUuid ==
                                                                  bloc.classDetail!
                                                                      .classUuid) !=
                                                      -1) {
                                                dataSaver.themeType = null;
                                                pushTransition(
                                                    context,
                                                    ChatDetailPage(
                                                      chatRoomUuid: dataSaver
                                                                  .chatRoom!
                                                                  .roomData
                                                                  .indexWhere((element) =>
                                                                      (element.classInfo == null ? '' : element.classInfo!.classUuid) ==
                                                                      bloc.classDetail!
                                                                          .classUuid) ==
                                                              -1
                                                          ? null
                                                          : dataSaver
                                                              .chatRoom!
                                                              .roomData[dataSaver
                                                                  .chatRoom!
                                                                  .roomData
                                                                  .indexWhere((element) =>
                                                                      (element.classInfo == null
                                                                          ? ''
                                                                          : element.classInfo!.classUuid) ==
                                                                      bloc.classDetail!.classUuid)]
                                                              .chatRoomUuid,
                                                      classCheck: true,
                                                      detail: true,
                                                    )).then((value) {
                                                  if (value != null &&
                                                      value == 'BLOCK') {
                                                    bloc.add(
                                                        ClassBlockReCheckEvent());
                                                  }
                                                });
                                              } else {
                                                pushTransition(
                                                        context, ChatHelpPage())
                                                    .then((value) {
                                                  if (value != null) {
                                                    dataSaver.themeType = null;
                                                    pushTransition(
                                                        context,
                                                        ChatDetailPage(
                                                          classUuid: bloc
                                                              .classDetail!
                                                              .classUuid,
                                                          userName: bloc
                                                              .classDetail!
                                                              .member
                                                              .nickName,
                                                          content: bloc
                                                              .classDetail!
                                                              .content,
                                                          classCheck: true,
                                                          detail: true,
                                                          chatHelp: value,
                                                        )).then((value) {
                                                      if (value != null &&
                                                          value == 'BLOCK') {
                                                        bloc.add(
                                                            ClassBlockReCheckEvent());
                                                      }
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                            child: Center(
                                              child: customText('도와드릴까요?',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryDark10,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T15))),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                primary: AppColors.white,
                                                side: BorderSide(
                                                    width: 1,
                                                    color: AppColors.primary),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                          ),
                                        ),
                                      ),
                                      spaceW(12),
                                      Expanded(
                                        child: bottomButton(
                                            context: context,
                                            elevation: 0,
                                            onPress: bloc.chatBlock == 0 ||
                                                    bloc.chatBlock == 1
                                                ? null
                                                : () => moveChat(context),
                                            text: AppStrings.of(
                                                StringKey.chatConsultation)),
                                      )
                                    ],
                                  ))
                              : Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Row(
                                    children: [
                                      bloc.classDetail!.status == 'NORMAL' ||
                                              bloc.classDetail!.status ==
                                                  'TEMP' ||
                                              bloc.classDetail!.status == 'STOP'
                                          ? Expanded(
                                              child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                  color: AppColors.white),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (bloc.classDetail!
                                                          .status ==
                                                      'TEMP') {
                                                    if (!widget
                                                        .classMadeCheck!) {
                                                      showToast(
                                                          context: context,
                                                          text: AppStrings.of(
                                                              StringKey
                                                                  .addMaxClassToast));
                                                      return;
                                                    }
                                                    amplitudeEvent(
                                                        'class_register', {
                                                      'inflow_page':
                                                          'connected_in_register'
                                                    });
                                                  }
                                                  classEvent(
                                                      'class_edit',
                                                      bloc.classDetail!
                                                          .classUuid,
                                                      widget.mainNeighborHood
                                                          .lati!,
                                                      widget.mainNeighborHood
                                                          .longi!,
                                                      widget.mainNeighborHood
                                                          .sidoName!,
                                                      widget.mainNeighborHood
                                                          .sigunguName!,
                                                      widget.mainNeighborHood
                                                          .eupmyeondongName!);
                                                  pushTransition(
                                                      context,
                                                      CreateClassPage(
                                                        profileGet:
                                                            widget.profileGet!,
                                                        edit: true,
                                                        temp: bloc.classDetail!
                                                                    .status ==
                                                                'TEMP'
                                                            ? true
                                                            : false,
                                                        classUuid: bloc
                                                            .classDetail!
                                                            .classUuid,
                                                        ing: bloc.classDetail!
                                                                    .status ==
                                                                'NORMAL'
                                                            ? true
                                                            : false,
                                                        previousPage:
                                                            'connected_in_register',
                                                      )).then((value) {
                                                    if (value != null) {
                                                      if (widget.bloc
                                                          is LearnBloc) {
                                                        widget.bloc.add(
                                                            ReloadClassEvent());
                                                      } else if (widget.bloc
                                                          is MyCreateClassBloc) {
                                                        widget.bloc.add(
                                                            MyCreateReloadEvent());
                                                      }
                                                      bloc.add(ClassDetailInitEvent(
                                                          mainNeighborHood: widget
                                                              .mainNeighborHood,
                                                          classUuid: widget
                                                              .classUuid));
                                                    }
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    primary: AppColors.white,
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            side: BorderSide(
                                                                color: AppColors
                                                                    .primary))),
                                                child: Center(
                                                  child: customText(
                                                    bloc.classDetail!.status !=
                                                            'TEMP'
                                                        ? AppStrings.of(
                                                            StringKey.edit)
                                                        : AppStrings.of(
                                                            StringKey.toCreate),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryDark10,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .MEDIUM),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T14)),
                                                  ),
                                                ),
                                              ),
                                            ))
                                          : Container(),
                                      bloc.classDetail!.status != 'TEMP'
                                          ? spaceW(12)
                                          : Container(),
                                      bloc.classDetail!.status != 'TEMP'
                                          ? Expanded(
                                              child: bottomButton(
                                              context: context,
                                              elevation: 0,
                                              onPress: () async {
                                                if (bloc.classDetail!.status ==
                                                    'NORMAL') {
                                                  amplitudeRevenue(
                                                      productId:
                                                          'my_class_share',
                                                      price: 2);
                                                  if (!dataSaver.share) {
                                                    dataSaver.share = true;
                                                    amplitudeEvent(
                                                        'my_class_share', {
                                                      'user_name': dataSaver
                                                          .profileGet!.nickName,
                                                      'class_name': bloc
                                                          .classDetail!
                                                          .content
                                                          .title,
                                                      'cost_min': bloc
                                                          .classDetail!
                                                          .content
                                                          .minCost,
                                                      'town_sido': bloc
                                                          .classDetail!
                                                          .content
                                                          .areas!
                                                          .map(
                                                              (e) => e.sidoName)
                                                          .toList()
                                                          .join(','),
                                                      'town_sigungu': bloc
                                                          .classDetail!
                                                          .content
                                                          .areas!
                                                          .map((e) =>
                                                              e.sigunguName)
                                                          .toList()
                                                          .join(','),
                                                      'town_dongeupmyeon': bloc
                                                          .classDetail!
                                                          .content
                                                          .areas!
                                                          .map((e) => e
                                                              .eupmyeondongName)
                                                          .toList()
                                                          .join(','),
                                                      'costType': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .costType ==
                                                              'HOUR'
                                                          ? 0
                                                          : 1,
                                                      'costSharing': bloc
                                                              .classDetail!
                                                              .content
                                                              .shareType ??
                                                          '',
                                                      'type': 'class',
                                                      'first_free': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .firstFreeFlag ==
                                                              0
                                                          ? false
                                                          : true,
                                                      'group': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .groupFlag ==
                                                              0
                                                          ? false
                                                          : true,
                                                      'group_cost': bloc
                                                                  .classDetail!
                                                                  .content
                                                                  .groupFlag ==
                                                              0
                                                          ? ''
                                                          : bloc
                                                              .classDetail!
                                                              .content
                                                              .costOfPerson
                                                    });
                                                    await ClassRepository
                                                            .getShareLink(bloc
                                                                .classDetail!
                                                                .classUuid)
                                                        .then((value) async {
                                                      await Share.share(
                                                              value.data)
                                                          .then((value) {
                                                        dataSaver.share = false;
                                                      });
                                                    });
                                                  }
                                                } else {
                                                  if (!dataSaver.mainBloc!
                                                      .classMadeCheck) {
                                                    showToast(
                                                        context: context,
                                                        text: AppStrings.of(
                                                            StringKey
                                                                .addMaxClassToast));
                                                  } else {
                                                    bloc.add(
                                                        RequestChangeEvent());
                                                  }
                                                }
                                              },
                                              text: bloc.classDetail!.status ==
                                                      'NORMAL'
                                                  ? AppStrings.of(StringKey
                                                      .spreadRumorMyClass)
                                                  : AppStrings.of(StringKey
                                                      .operationChange),
                                            ))
                                          : Container()
                                    ],
                                  )),
                      bloc.classDetail != null
                          ? Positioned(
                              top: 12,
                              right: 20,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: 180,
                                onEnd: () {
                                  bloc.moreEnd = true;
                                  setState(() {});
                                },
                                height: bloc.selectMore
                                    ? bloc.classDetail!.status == 'NORMAL'
                                        ? 100
                                        : 60
                                    : 0,
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.16),
                                        blurRadius: 6,
                                        offset: Offset(0, 0))
                                  ],
                                ),
                                child: bloc.selectMore && bloc.moreEnd
                                    ? Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              bloc.moreEnd = false;
                                              bloc.add(SelectMoreEvent(
                                                  select: false));
                                              decisionDialog(
                                                  context: context,
                                                  barrier: false,
                                                  text: AppStrings.of(
                                                      StringKey.deleteClass),
                                                  allowText: AppStrings.of(
                                                      StringKey.remove),
                                                  disallowText: AppStrings.of(
                                                      StringKey.cancel),
                                                  allowCallback: () {
                                                    popDialog(context);
                                                    bloc.add(
                                                        RemoveRequestEvent());
                                                  },
                                                  disallowCallback: () {
                                                    popDialog(context);
                                                  });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 40,
                                              color: AppColors.white,
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    AppImages.iTrashG,
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  spaceW(8),
                                                  customText(
                                                    AppStrings.of(
                                                        StringKey.classRemove),
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray900,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .MEDIUM),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T14)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          bloc.classDetail!.status == "NORMAL"
                                              ? GestureDetector(
                                                  onTap: () {
                                                    bloc.moreEnd = false;
                                                    bloc.add(SelectMoreEvent(
                                                        select: false));
                                                    decisionDialog(
                                                        context: context,
                                                        barrier: false,
                                                        text: AppStrings.of(
                                                            StringKey
                                                                .stopClass),
                                                        allowText: '중지',
                                                        disallowText:
                                                            AppStrings.of(
                                                                StringKey
                                                                    .cancel),
                                                        allowCallback: () {
                                                          bloc.add(
                                                              DeadLineChangeEvent());
                                                          popDialog(context);
                                                        },
                                                        disallowCallback: () {
                                                          popDialog(context);
                                                        });
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 40,
                                                    color: AppColors.white,
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          AppImages.iWarningCe,
                                                          width: 16,
                                                          height: 16,
                                                        ),
                                                        spaceW(8),
                                                        customText(
                                                          AppStrings.of(
                                                              StringKey
                                                                  .classStop),
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .gray900,
                                                              fontWeight: weightSet(
                                                                  textWeight:
                                                                      TextWeight
                                                                          .MEDIUM),
                                                              fontSize: fontSizeSet(
                                                                  textSize:
                                                                      TextSize
                                                                          .T14)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : Container(),
                              ),
                            )
                          : Container(),
                      bloc.classDetail == null
                          ? Container()
                          : bloc.classDetail!.managerStopFlag == 1 &&
                                  bloc.classDetail!.mineFlag == 1
                              ? DetailStop(
                                  context: context,
                                  editPress: () {
                                    pushTransition(
                                        context,
                                        CreateClassPage(
                                          profileGet: widget.profileGet!,
                                          edit: true,
                                          temp: false,
                                          classUuid:
                                              bloc.classDetail!.classUuid,
                                          ing: bloc.classDetail!.status ==
                                                  'NORMAL'
                                              ? true
                                              : false,
                                          stop: true,
                                          previousPage: 'connected_in_register',
                                        ));
                                  },
                                  whyRemove:
                                      bloc.classDetail!.managerStopReasonText ??
                                          '',
                                )
                              : Container(),
                      loadingView(bloc.isLoading)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  moveChat(BuildContext context) {
    if (!dataSaver.nonMember) {
      if (bloc.classDetail!.managerStopFlag == 1) {
        showToast(context: context, text: '운영정지 된 클래스입니다');
        return;
      }
      if (widget.profileDialogCheck && widget.chatDetail) {
        popWithResult(context, 'closeDialog');
      } else if (widget.chatDetail) {
        pop(context);
      } else if (dataSaver.chatRoom != null &&
          dataSaver.chatRoom!.roomData.indexWhere((element) =>
                  element.classInfo != null &&
                  element.classInfo!.classUuid ==
                      bloc.classDetail!.classUuid) !=
              -1) {
        amplitudeEvent('chat_consultation', {
          'type': 'class',
          'continue': true,
          'class_uuid': bloc.classDetail!.classUuid,
          'class_title': bloc.classDetail!.content.title,
          'costType': bloc.classDetail!.content.costType == 'HOUR' ? 0 : 1,
          'costSharing': bloc.classDetail!.content.shareType ?? '',
          'inflow_page': widget.inputPage,
          'themeType': dataSaver.themeType,
          'town_dongeupmyeon': bloc.classDetail!.content.areas == null
              ? ''
              : bloc.classDetail!.content.areas!
                  .map((e) => e.eupmyeondongName)
                  .toList()
                  .join(','),
          'town_sido': bloc.classDetail!.content.areas == null
              ? ''
              : bloc.classDetail!.content.areas!
                  .map((e) => e.sidoName)
                  .toList()
                  .join(','),
          'town_sigungu': bloc.classDetail!.content.areas == null
              ? ''
              : bloc.classDetail!.content.areas!
                  .map((e) => e.sigunguName)
                  .toList()
                  .join(','),
          'first_free':
              bloc.classDetail!.content.firstFreeFlag == 0 ? false : true,
          'group': bloc.classDetail!.content.groupFlag == 0 ? false : true,
          'group_cost': bloc.classDetail!.content.costOfPerson,
          'review_count': bloc.classDetail!.reviewCnt,
        });
        dataSaver.themeType = null;
        pushTransition(
            context,
            ChatDetailPage(
              chatRoomUuid: dataSaver.chatRoom!.roomData.indexWhere((element) =>
                          (element.classInfo == null
                              ? ''
                              : element.classInfo!.classUuid) ==
                          bloc.classDetail!.classUuid) ==
                      -1
                  ? null
                  : dataSaver
                      .chatRoom!
                      .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                          (element) =>
                              (element.classInfo == null
                                  ? ''
                                  : element.classInfo!.classUuid) ==
                              bloc.classDetail!.classUuid)]
                      .chatRoomUuid,
              classCheck: true,
              detail: true,
            )).then((value) {
          if (value != null && value == 'BLOCK') {
            bloc.add(ClassBlockReCheckEvent());
          }
        });
      } else {
        amplitudeEvent('chat_consultation', {
          'type': 'class',
          'continue': false,
          'class_uuid': bloc.classDetail!.classUuid,
          'class_title': bloc.classDetail!.content.title,
          'costType': bloc.classDetail!.content.costType == 'HOUR' ? 0 : 1,
          'costSharing': bloc.classDetail!.content.shareType ?? '',
          'inflow_page': widget.inputPage,
          'themeType': dataSaver.themeType,
          'town_dongeupmyeon': bloc.classDetail!.content.areas == null
              ? ''
              : bloc.classDetail!.content.areas!
                  .map((e) => e.eupmyeondongName)
                  .toList()
                  .join(','),
          'town_sido': bloc.classDetail!.content.areas == null
              ? ''
              : bloc.classDetail!.content.areas!
                  .map((e) => e.sidoName)
                  .toList()
                  .join(','),
          'town_sigungu': bloc.classDetail!.content.areas == null
              ? ''
              : bloc.classDetail!.content.areas!
                  .map((e) => e.sigunguName)
                  .toList()
                  .join(','),
          'first_free':
              bloc.classDetail!.content.firstFreeFlag == 0 ? false : true,
          'group': bloc.classDetail!.content.groupFlag == 0 ? false : true,
          'group_cost': bloc.classDetail!.content.costOfPerson,
          'review_count': bloc.classDetail!.reviewCnt,
        });
        dataSaver.themeType = null;
        pushTransition(
            context,
            ChatDetailPage(
              classUuid: bloc.classDetail!.classUuid,
              userName: bloc.classDetail!.member.nickName,
              content: bloc.classDetail!.content,
              classCheck: true,
              detail: true,
            )).then((value) {
          if (value != null && value == 'BLOCK') {
            bloc.add(ClassBlockReCheckEvent());
          }
        });
      }
    } else {
      nonMemberDialog(
          context: context,
          title: AppStrings.of(StringKey.alertChatting),
          content: AppStrings.of(StringKey.alertChattingContent));
    }
  }

  @override
  blocListener(BuildContext context, state) async {
    if (state is DeadLineChangeState) {
      if (widget.bloc is LearnBloc) {
        widget.bloc.add(ReloadClassEvent());
      }

      if (widget.bloc is SearchBloc) {
        widget.bloc.add(SearchReloadClassEvent());
      }

      if (widget.bloc is MyCreateClassBloc) {
        widget.bloc.add(MyCreateReloadEvent());
      }

      dataSaver.mainBloc!.add(UiUpdateEvent());
    }

    if (state is RemoveRequestState) {
      if (widget.bloc is LearnBloc) {
        widget.bloc.add(ReloadClassEvent());
      }

      if (widget.bloc is SearchBloc) {
        widget.bloc.add(SearchReloadClassEvent());
      }

      if (widget.bloc is MyCreateClassBloc) {
        widget.bloc.add(MyCreateReloadEvent());
      }

      dataSaver.mainBloc!.add(UiUpdateEvent());
      pop(context);
    }

    if (state is RequestChangeState) {
      dataSaver.mainBloc!.add(UiUpdateEvent());
    }

    if (state is BookmarkChangeState) {
      if (widget.bloc is RecentOrBookmarkBloc) {
        widget.bloc.add(ReloadRecentOrBookmarkEvent(type: 'BOOKMARK'));
      }
    }

    if (state is ClassDetailInitState) {
      if (!widget.my) {
        if (production == 'prod-release' && kReleaseMode) {
          await facebookAppEvents.logViewContent(
              id: bloc.classDetail!.classUuid,
              type: bloc.classDetail!.content.title!,
              currency: dataSaver.abTest ?? 'KRW',
              price: 1);
        }
      }
    }
  }

  @override
  ClassDetailBloc initBloc() {
    return ClassDetailBloc(context)
      ..add(ClassDetailInitEvent(
          classUuid: widget.classUuid,
          mainNeighborHood: widget.mainNeighborHood));
  }
}
