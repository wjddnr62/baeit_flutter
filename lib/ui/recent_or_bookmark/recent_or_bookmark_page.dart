import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/recent_or_bookmark/recent_or_bookmark_bloc.dart';
import 'package:baeit/utils/category.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentOrBookmarkPage extends BlocStatefulWidget {
  final String type;
  final ProfileGet profileGet;
  final int? tapSelect;

  RecentOrBookmarkPage(
      {required this.type, required this.profileGet, this.tapSelect});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return RecentOrBookmarkState();
  }
}

class RecentOrBookmarkState
    extends BlocState<RecentOrBookmarkBloc, RecentOrBookmarkPage>
    with TickerProviderStateMixin {
  ScrollController? scrollController;
  ScrollController? communityScrollController;
  final GlobalKey<AnimatedListState> listKey = GlobalKey();

  selectTap() {
    return Container(
      height: 36,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  bloc.add(RecentOrBookmarkTapChangeEvent(selectTap: 0));
                },
                child: Center(
                  child: customText(
                    AppStrings.of(StringKey.neighborhoodClass),
                    style: TextStyle(
                        color: bloc.selectTap == 0
                            ? AppColors.white
                            : AppColors.gray400,
                        fontWeight: weightSet(
                            textWeight: bloc.selectTap == 0
                                ? TextWeight.BOLD
                                : TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: bloc.selectTap == 0
                        ? AppColors.primary
                        : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6)),
                      side: bloc.selectTap == 0
                          ? BorderSide.none
                          : BorderSide(color: AppColors.gray200),
                    )),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  bloc.add(RecentOrBookmarkTapChangeEvent(selectTap: 1));
                },
                child: Center(
                  child: customText(
                    '게시글',
                    style: TextStyle(
                        color: bloc.selectTap == 1
                            ? AppColors.white
                            : AppColors.gray400,
                        fontWeight: weightSet(
                            textWeight: bloc.selectTap == 1
                                ? TextWeight.BOLD
                                : TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: bloc.selectTap == 1
                        ? AppColors.primary
                        : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6)),
                      side: bloc.selectTap == 1
                          ? BorderSide.none
                          : BorderSide(color: AppColors.gray200),
                    )),
              ),
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
                  backgroundColor: AppColors.white,
                  appBar: baseAppBar(
                      title: AppStrings.of(bloc.type == 'RECENT'
                          ? StringKey.recentText
                          : StringKey.bookmarkWrite),
                      context: context,
                      onPressed: () {
                        pop(context);
                      }),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      spaceH(10),
                      selectTap(),
                      spaceH(10),
                      Expanded(
                        child: IndexedStack(
                          index: bloc.selectTap,
                          children: [
                            Positioned.fill(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  bloc.classList == null ||
                                          bloc.classList!.classData.length == 0
                                      ? Container()
                                      : Expanded(
                                          child: Container(
                                          color: bloc.selectTap == 1
                                              ? AppColors.greenGray50
                                              : AppColors.white,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 48,
                                                padding: EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: customText(
                                                    '총 ${bloc.classList == null || bloc.classList!.classData.length == 0 ? 0 : bloc.classList!.totalRow} 건',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray500,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .MEDIUM),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T12)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: classList(),
                                              ))
                                            ],
                                          ),
                                        )),
                                  bloc.classList == null ||
                                          bloc.classList!.classData.length == 0
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              spaceH(100),
                                              Container(
                                                height: 160,
                                                child: bloc.selectTap == 0
                                                    ? Image.asset(
                                                        AppImages.imgEmptyList)
                                                    : Image.asset(AppImages
                                                        .imgEmptyRequest),
                                              ),
                                              customText(
                                                AppStrings.of(widget.type ==
                                                        'RECENT'
                                                    ? StringKey.myRecentNotYet
                                                    : StringKey
                                                        .myBookmarkNotYet),
                                                style: TextStyle(
                                                    color: AppColors.gray900,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T14)),
                                              ),
                                              spaceH(20),
                                              RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(children: [
                                                  customTextSpan(
                                                      text: AppStrings.of(bloc
                                                                  .selectTap ==
                                                              0
                                                          ? StringKey
                                                              .neighborhoodClass
                                                          : StringKey
                                                              .requestClass),
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .accentLight20,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .REGULAR),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T14))),
                                                  customTextSpan(
                                                      text: AppStrings.of(bloc
                                                                  .selectTap ==
                                                              0
                                                          ? widget.type ==
                                                                  'RECENT'
                                                              ? StringKey
                                                                  .recentThumbsUpText
                                                              : StringKey
                                                                  .bookmarkThumbsUpText
                                                          : widget.type ==
                                                                  'RECENT'
                                                              ? StringKey
                                                                  .recentRequestThumbsUpText
                                                              : StringKey
                                                                  .bookmarkRequestThumbsUpText),
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.gray400,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .REGULAR),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T14)))
                                                ]),
                                              ),
                                              spaceH(20),
                                              Container(
                                                width: 96,
                                                height: 54,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    popWithResult(
                                                        context,
                                                        bloc.selectTap == 1
                                                            ? 2
                                                            : bloc.selectTap);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      primary: AppColors.white,
                                                      elevation: 0,
                                                      padding: EdgeInsets.zero,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          side: BorderSide(
                                                              color: AppColors
                                                                  .primary))),
                                                  child: Center(
                                                    child: customText(
                                                      widget.type == 'RECENT'
                                                          ? AppStrings.of(
                                                              StringKey.goView)
                                                          : AppStrings.of(
                                                              StringKey
                                                                  .goBookmark),
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .primaryDark10,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T13)),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                            Positioned.fill(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    bloc.communityList == null ||
                                            bloc.communityList!.communityData
                                                    .length ==
                                                0
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                spaceH(100),
                                                Container(
                                                  height: 160,
                                                  child: bloc.selectTap == 0
                                                      ? Image.asset(AppImages
                                                          .imgEmptyList)
                                                      : Image.asset(AppImages
                                                          .imgEmptyRequest),
                                                ),
                                                customText(
                                                  widget.type == 'RECENT'
                                                      ? ''
                                                      : '찜한 게시글이 아직 없어요',
                                                  style: TextStyle(
                                                      color: AppColors.gray900,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T14)),
                                                ),
                                                spaceH(20),
                                                RichText(
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(children: [
                                                    customTextSpan(
                                                        text: '커뮤니티',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .accentLight20,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .REGULAR),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T14))),
                                                    customTextSpan(
                                                        text: widget.type ==
                                                                'RECENT'
                                                            ? '에서\n관심가는 게시글을 찾아보아요!'
                                                            : '에서\n좋아하는 게시글을 찜해보아요!',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .gray400,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .REGULAR),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T14)))
                                                  ]),
                                                ),
                                                spaceH(20),
                                                Container(
                                                  width: 96,
                                                  height: 54,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      popWithResult(
                                                          context,
                                                          bloc.selectTap == 1
                                                              ? 2
                                                              : bloc.selectTap);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            AppColors.white,
                                                        elevation: 0,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            side: BorderSide(
                                                                color: AppColors
                                                                    .primary))),
                                                    child: Center(
                                                      child: customText(
                                                        widget.type == 'RECENT'
                                                            ? '보러 가기'
                                                            : '찜하러 가기',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .primaryDark10,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .MEDIUM),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T13)),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    bloc.communityList == null ||
                                            bloc.communityList!.communityData
                                                    .length ==
                                                0
                                        ? Container()
                                        : Expanded(
                                            child: Container(
                                            color: bloc.selectTap == 1
                                                ? AppColors.greenGray50
                                                : AppColors.white,
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 48,
                                                  padding: EdgeInsets.only(
                                                      left: 20, right: 20),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: customText(
                                                      '총 ${bloc.communityList == null || bloc.communityList!.communityData.length == 0 ? 0 : bloc.communityList!.totalRow} 건',
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.gray500,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T12)),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 20, right: 20),
                                                  child: communityList(),
                                                ))
                                              ],
                                            ),
                                          )),
                                  ],
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is RecentOrBookmarkInitState) {
      if (widget.tapSelect != null) {
        bloc.add(RecentOrBookmarkTapChangeEvent(selectTap: widget.tapSelect!));
      }
    }

    if (state is ReloadRecentOrBookmarkState) {}
  }

  @override
  RecentOrBookmarkBloc initBloc() {
    return RecentOrBookmarkBloc(context)
      ..add(RecentOrBookmarkInitEvent(type: widget.type, animationVsync: this));
  }

  // neighborHoodClass
  classListItem(int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: AppColors.transparent,
      child: ElevatedButton(
          onPressed: () {
            ClassDetailPage classDetailPage = ClassDetailPage(
              heroTag: 'listImage$index',
              classUuid: bloc.classList!.classData[index].classUuid,
              mainNeighborHood: bloc.mainNeighborHood!,
              bloc: bloc,
              selectIndex: index,
              profileGet: widget.profileGet,
              my: true,
              inputPage: bloc.type == 'RECENT' ? 'recent' : 'bookmark',
            );
            dataSaver.keywordClassDetail = classDetailPage;
            pushTransition(context, classDetailPage).then((value) {
              if (bloc.classList!.classData[index].likeFlag == 0) {
                bloc.add(ReloadRecentOrBookmarkEvent(type: bloc.type));
              }
            });
          },
          style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: AppColors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: EdgeInsets.zero),
          child: Container(
            color: AppColors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    customText(
                        '${bloc.classList!.classData[index].content.hangNames.length > 12 ? bloc.classList!.classData[index].content.hangNames.substring(11, 12) == ',' ? bloc.classList!.classData[index].content.hangNames.substring(0, 11) + "..." : bloc.classList!.classData[index].content.hangNames.substring(0, 12) + "..." : bloc.classList!.classData[index].content.hangNames}',
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
                    bloc.classList!.classData[index].member.profile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 16,
                              height: 16,
                              child: CacheImage(
                                imageUrl: bloc.classList!.classData[index]
                                    .member.profile!,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            width: 16,
                            height: 16,
                            child: Image.asset(
                              AppImages.dfProfile,
                            ),
                          ),
                    spaceW(4),
                    customText(bloc.classList!.classData[index].member.nickName,
                        style: TextStyle(
                            color: AppColors.gray500,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T11))),
                    Expanded(child: Container()),
                    bloc.classList!.classData[index].mineFlag != 1 &&
                            bloc.type == 'BOOKMARK'
                        ? GestureDetector(
                            onTap: () async {
                              if (bloc.classList!.classData[index].likeFlag ==
                                  1) {
                                setState(() {
                                  bloc.heartAnimation[index] = true;
                                  Future.delayed(Duration(milliseconds: 100),
                                      () {
                                    setState(() {
                                      bloc.heartAnimation[index] = false;
                                    });
                                  });
                                });
                                bloc.add(BookmarkEvent(
                                    index: index, flag: 1, bookmark: false));
                              } else {
                                setState(() {
                                  bloc.heartAnimation[index] = true;
                                  Future.delayed(Duration(milliseconds: 100),
                                      () {
                                    setState(() {
                                      bloc.heartAnimation[index] = false;
                                    });
                                  });
                                });
                                bloc.add(BookmarkEvent(
                                    index: index, flag: 0, bookmark: true));
                              }
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    top: 0,
                                    left: bloc.heartAnimation[index] ? 0 : 3,
                                    right: bloc.heartAnimation[index] ? 0 : 3,
                                    bottom: 0,
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.ease,
                                    child: Image.asset(
                                      !bloc.bookmarkChecks[index]
                                          ? AppImages.iHeartCsOff
                                          : AppImages.iHeartCsOn,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 128,
                        height: 72,
                        child: CacheImage(
                          imageUrl: bloc
                              .classList!.classData[index].content.image!
                              .toView(context: context, ),
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 72,
                            decoration: BoxDecoration(
                                color: AppColors.gray200,
                                borderRadius: BorderRadius.circular(4)),
                            child: Image.asset(
                              AppImages.dfClassMain,
                              width: MediaQuery.of(context).size.width,
                              height: 72,
                            ),
                          ),
                        ),
                      ),
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
                                        text: bloc.classList!.classData[index]
                                                .content.title! +
                                            " ",
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14))),
                                    customTextSpan(
                                        text: bloc.classList!.classData[index]
                                            .content.category!.name!,
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
                                bloc.classList!.classData[index].content
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
                                                                TextWeight
                                                                    .BOLD),
                                                        fontSize: fontSizeSet(
                                                            textSize: TextSize
                                                                .T10)))),
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
                                    bloc.classList!.classData[index].content
                                                .costType ==
                                            'HOUR'
                                        ? '${numberFormatter(bloc.classList!.classData[index].content.groupFlag == 1 ? bloc.classList!.classData[index].content.costOfPerson : bloc.classList!.classData[index].content.minCost!)}원 ~'
                                        : '배움나눔',
                                    style: TextStyle(
                                        color: bloc.classList!.classData[index]
                                                    .content.costType ==
                                                'HOUR'
                                            ? AppColors.gray900
                                            : AppColors.secondaryDark30,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14)))
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
          )),
    );
  }

  classList() {
    return bloc.classList == null
        ? Container()
        : ListView.builder(
            itemCount:
                bloc.classList == null ? 0 : bloc.classList!.classData.length,
            itemBuilder: (context, idx) {
              return Column(
                children: [classListItem(idx), spaceH(20)],
              );
            },
            controller: scrollController,
            shrinkWrap: true,
          );
  }

  communityList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return communityItem(bloc.communityList!.communityData[idx]);
      },
      shrinkWrap: true,
      controller: communityScrollController,
      itemCount: bloc.communityList == null
          ? 0
          : bloc.communityList!.communityData.length,
    );
  }

  communityItem(CommunityData communityData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          pushTransition(
              context,
              CommunityDetailPage(
                communityUuid: communityData.communityUuid,
              ));
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(communityData.content.contentText!,
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
                                    width: MediaQuery.of(context).size.width,
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
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T11))),
                        customText(
                            '·${DateTime.now().difference(communityData.content.createDate).inMinutes > 14400 ? communityData.content.createDate.yearMonthDay : timeCalculationText(DateTime.now().difference(communityData.content.createDate).inMinutes)}',
                            style: TextStyle(
                                color: AppColors.gray500,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T11)))
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
                    communityData.status == 'DONE'
                        ? Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.gray200,
                              borderRadius: BorderRadius.circular(20 / 6),
                            ),
                            padding: EdgeInsets.only(left: 4, right: 4),
                            child: Center(
                              child: customText('완료',
                                  style: TextStyle(
                                      color: AppColors.gray500,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T10))),
                            ),
                          )
                        : Container(),
                    communityData.status == 'DONE' ? spaceW(6) : Container(),
                    customText(
                        communityType(
                            communityTypeIdx(communityData.content.category)),
                        style: TextStyle(
                            color: communityData.status == 'NORMAL'
                                ? AppColors.primary
                                : AppColors.gray500,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12))),
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
      ),
    );
  }

  timeCalculationText(int minutes) {
    if (minutes < 60) {
      return '$minutes분전';
    } else if (minutes < 1440) {
      return '${(minutes / 60).toStringAsFixed(0)}시간전';
    } else {
      return '${(minutes / 1440).toStringAsFixed(0)}일전';
    }
  }

  levelText(int idx) {
    switch (bloc.classList!.classData[idx].content.level) {
      case 'LOW':
        return AppStrings.of(StringKey.dontKnowAnyThing);
      case 'MIDDLE':
        return AppStrings.of(StringKey.knowTheBasics);
      case 'HIGH':
        return AppStrings.of(StringKey.knowMore);
    }
  }

  levelImage(int idx) {
    switch (bloc.classList!.classData[idx].content.level) {
      case 'LOW':
        return AppImages.iFaceSmallStep1;
      case 'MIDDLE':
        return AppImages.iFaceSmallStep2;
      case 'HIGH':
        return AppImages.iFaceSmallStep3;
    }
  }

  contentAreaText(int idx) {
    switch (idx) {
      case 0:
        return AppStrings.of(StringKey.hopefulNeighborHood);
      case 1:
        return AppStrings.of(StringKey.hopefulDay);
      case 2:
        return AppStrings.of(StringKey.hopefulCost);
      case 3:
        return AppStrings.of(StringKey.category);
    }
  }

  contentArea(int set, int idx) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          contentAreaText(set),
          style: TextStyle(
              color: AppColors.black20,
              fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
              fontSize: fontSizeSet(textSize: TextSize.T12)),
        ),
        spaceW(10),
        Flexible(
          child: customText(
            set == 0
                ? bloc.classList!.classData[idx].content.hangNames
                    .replaceAll(',', ', ')
                : set == 1
                    ? bloc.classList!.classData[idx].content.dayNames
                        .replaceAll(',', ', ')
                    : set == 2
                        ? '${numberFormatter(bloc.classList!.classData[idx].content.minCost!)}원 ~'
                        : categorySet(bloc.classList!.classData[idx].content
                            .category!.classCategoryId),
            style: TextStyle(
                color: AppColors.gray600,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T12)),
          ),
        ),
        set == 2
            ? customText(
                ' / ${AppStrings.of(StringKey.hourly)}',
                style: TextStyle(
                    color: AppColors.black20,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T10)),
              )
            : Container()
      ],
    );
  }

  requestProfile(int idx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        spaceH(12),
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: bloc.classList!.classData[idx].member.profile != null
              ? Image.network(
                  bloc.classList!.classData[idx].member.profile!,
                  width: 32,
                  height: 32,
                  errorBuilder: (context, builder, _) {
                    return Container();
                  },
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  AppImages.dfProfile,
                  width: 32,
                  height: 32,
                ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.bottomOffset = 0;
          bloc.scrollUnder = false;
        }
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
          bloc.add(GetDataEvent(key: listKey));
        }
      });

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
                communityScrollController!.position.maxScrollExtent &&
            !communityScrollController!.position.outOfRange) {
          bloc.communityScrollUnder = true;
          bloc.communityBottomOffset = communityScrollController!.offset;
        }
        if (!bloc.communityScrollUnder &&
            (bloc.communityBottomOffset == 0 ||
                bloc.communityBottomOffset <
                    communityScrollController!.offset) &&
            communityScrollController!.offset >=
                (communityScrollController!.position.maxScrollExtent * 0.7) &&
            !communityScrollController!.position.outOfRange) {
          bloc.add(GetDataEvent());
        }
      });
  }
}
