import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/community_create/community_create_page.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/my_create_community/my_create_community_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/stop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class MyCreateCommunityPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return MyCreateCommunityState();
  }
}

class MyCreateCommunityState
    extends BlocState<MyCreateCommunityBloc, MyCreateCommunityPage> {
  ScrollController? communityScrollController;

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
                  backgroundColor: AppColors.greenGray50,
                  appBar: baseAppBar(
                      title: '만든 게시글',
                      context: context,
                      onPressed: () {
                        pop(context);
                      }),
                  body: bloc.communityList == null
                      ? Container()
                      : Column(
                          children: [
                            myCreateCommunityTop(),
                            bloc.communityList!.communityData.length == 0 ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                spaceH(100),
                                Container(
                                  height: 160,
                                  child:
                                  Image.asset(AppImages.imgEmptyList),
                                ),
                                customText('게시글이 아직 없어요',
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize: fontSizeSet(
                                          textSize: TextSize.T14)),
                                ),
                                spaceH(20),
                                customText('커뮤니티에서 게시글을 작성하고\n이웃들과 배움을 나눠보세요!', style: TextStyle(color: AppColors.gray400, fontWeight: weightSet(textWeight: TextWeight.MEDIUM), fontSize: fontSizeSet(textSize: TextSize.T14),), textAlign: TextAlign.center)
                              ],
                            ) : Expanded(child: communityList())
                          ],
                        ),
                ),
                bloc.scrollEnd ? Container() : floatingActionButton(),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
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
              amplitudeRevenue(productId: 'community_register', price: 3);
              amplitudeEvent('community_register',
                  {'type': communityTypeCreate(0), 'page': 'my'});
              pushTransition(
                  context,
                  CommunityCreatePage(
                    idx: 0,
                    myCreate: true,
                  ));
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
                                  '새 게시글 만들기',
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

  myCreateCommunityTop() {
    List<Widget> tabs = [];
    for (int i = 0; i < 4; i++) {
      tabs.add(Padding(
        padding: EdgeInsets.only(right: i == 3 ? 0 : 17),
        child: GestureDetector(
          onTap: () {
            bloc.add(StatusChangeEvent(idx: i));
          },
          child: Container(
            height: 48,
            color: AppColors.greenGray50,
            child: Center(
              child: customText(myCreateCommunityStatus(i),
                  style: TextStyle(
                      color: bloc.selectTab == i
                          ? AppColors.gray900
                          : AppColors.gray500,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12))),
            ),
          ),
        ),
      ));
    }
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          customText(
              '총 ${bloc.communityList == null ? 0 : bloc.communityList!.totalRow} 건',
              style: TextStyle(
                  color: AppColors.gray500,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T12))),
          Expanded(child: Container()),
          Row(
            children: tabs,
          )
        ],
      ),
    );
  }

  communityList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        if (bloc.selectTab == 0) {
          return communityItem(bloc.communityList!.communityData[idx]);
        } else if (bloc.selectTab == 1 &&
            bloc.communityList!.communityData[idx].status == 'NORMAL') {
          return communityItem(bloc.communityList!.communityData[idx]);
        } else if (bloc.selectTab == 2 &&
            bloc.communityList!.communityData[idx].status == 'TEMP') {
          return communityItem(bloc.communityList!.communityData[idx]);
        } else if (bloc.selectTab == 3 &&
            bloc.communityList!.communityData[idx].status == 'DONE') {
          return communityItem(bloc.communityList!.communityData[idx]);
        } else {
          return Container();
        }
      },
      shrinkWrap: true,
      controller: communityScrollController,
      itemCount: bloc.communityList == null
          ? 0
          : bloc.communityList!.communityData.length,
    );
  }

  statusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return AppColors.error;
      case 'TEMP':
        return AppColors.secondaryDark20;
      case 'DONE':
        return AppColors.gray600;
    }
  }

  communityItem(CommunityData communityData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  pushTransition(
                      context,
                      CommunityDetailPage(
                        communityUuid: communityData.communityUuid,
                      )).then((value) {
                        if (value != null && value) {
                          bloc.add(StatusChangeEvent(idx: bloc.selectTab));
                        }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customText(
                                communityData.status == 'TEMP' &&
                                        communityData.content.contentText == ''
                                    ? '게시글 내용을 적어주세요'
                                    : communityData.content.contentText!,
                                style: TextStyle(
                                    color: communityData.status == 'TEMP' &&
                                            communityData.content.contentText ==
                                                ''
                                        ? AppColors.gray500
                                        : AppColors.gray900,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.REGULAR),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T14)),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                            spaceH(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: statusColor(communityData.status),
                                      borderRadius:
                                          BorderRadius.circular(3.33)),
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Center(
                                    child: customText(
                                        myCreateCommunityStatusText(
                                            communityData.status),
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T10)),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                                spaceW(10),
                                customText(
                                    '${DateTime.now().difference(communityData.content.createDate).inMinutes > 14400 ? communityData.content.createDate.yearMonthDay : timeCalculationText(DateTime.now().difference(communityData.content.createDate).inMinutes)}',
                                    style: TextStyle(
                                        color: AppColors.gray500,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T11)))
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
                        padding:
                            EdgeInsets.only(left: 12, right: 12, bottom: 12),
                        child: Row(
                          children: [
                            communityData.status == 'DONE'
                                ? Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.gray200,
                                      borderRadius:
                                          BorderRadius.circular(20 / 6),
                                    ),
                                    padding: EdgeInsets.only(left: 4, right: 4),
                                    child: Center(
                                      child: customText('완료',
                                          style: TextStyle(
                                              color: AppColors.gray500,
                                              fontWeight: weightSet(
                                                  textWeight: TextWeight.BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T10))),
                                    ),
                                  )
                                : Container(),
                            communityData.status == 'DONE'
                                ? spaceW(6)
                                : Container(),
                            customText(
                                communityType(communityTypeIdx(
                                    communityData.content.category)),
                                style: TextStyle(
                                    color: communityData.status == 'NORMAL'
                                        ? AppColors.primary
                                        : AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                            Expanded(child: Container()),
                            customText('조회 ${communityData.readCnt}',
                                style: TextStyle(
                                    color: AppColors.gray600,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
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
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              communityData.managerStopFlag == 1
                  ? Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          pushTransition(
                              context,
                              CommunityDetailPage(
                                  communityUuid: communityData.communityUuid));
                        },
                        child: ListStop(
                          editPress: () {
                            pushTransition(
                                context,
                                CommunityCreatePage(
                                  idx: communityTypeIdx(
                                      communityData.content.category),
                                  edit: true,
                                  communityUuid: communityData.communityUuid,
                                  stop: true,
                                ));
                          },
                          whyRemove: communityData.managerStopReasonText ?? '',
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          communityData.status == 'NORMAL'
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      amplitudeEvent('my_community_share', {
                        'type': 'made_community',
                        'bookmark_count': communityData.likeCnt,
                        'chat_count': communityData.chatCnt,
                        'share_count': communityData.shareCnt,
                        'view_count': communityData.readCnt,
                        'comment_count': communityData.commentCnt,
                        'user_id': communityData.member.memberUuid,
                        'user_name': communityData.member.nickName,
                        'community_id': communityData.communityUuid,
                        'distance': communityData.content.distance,
                        'hangNames': communityData.content.hangNames,
                        'status': communityData.status
                      });
                      bloc.add(ShareEvent(
                          communityUuid: communityData.communityUuid));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.errorLight30,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Center(
                      child: customText('내 게시글 공유하기',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T13))),
                    ),
                  ),
                )
              : Container(),
          communityData.status == 'TEMP'
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      amplitudeEvent('community_edit', {
                        'type': communityTypeCreate(
                            communityTypeIdx(communityData.content.category)),
                        'page': 'my'
                      });
                      pushTransition(
                          context,
                          CommunityCreatePage(
                            idx: communityTypeIdx(
                                communityData.content.category),
                            communityUuid: communityData.communityUuid,
                            edit: true,
                            myCreate: true,
                          )).then((value) {
                        if (value != null && value) {
                          pushTransition(
                              context,
                              CommunityDetailPage(
                                  communityUuid: communityData.communityUuid));
                          bloc.add(StatusChangeEvent(idx: bloc.selectTab));
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.secondaryLight30,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Center(
                      child: customText('이어서 작성하기',
                          style: TextStyle(
                              color: AppColors.secondaryDark30,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T13))),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is MyCreateCommunityInitState) {
      dataSaver.myCreateCommunityBloc = bloc;
    }

    if (state is ShareState) {
      Share.share(state.shareText);
    }
  }

  @override
  void dispose() {
    dataSaver.myCreateCommunityBloc = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    communityScrollController = ScrollController()
      ..addListener(() {
        if (bloc.communityList != null &&
            bloc.communityList!.communityData.length > 2) {
          if (bloc.scrollEnd) {
            bloc.scrollEnd = false;
            setState(() {});
          }
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < communityScrollController!.offset) &&
              communityScrollController!.offset >=
                  communityScrollController!.position.maxScrollExtent &&
              !communityScrollController!.position.outOfRange) {
            bloc.scrollUnder = true;
            bloc.bottomOffset = communityScrollController!.offset;
            bloc.add(ScrollEndEvent());
          }
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < communityScrollController!.offset) &&
              communityScrollController!.offset >=
                  (communityScrollController!.position.maxScrollExtent * 0.7) &&
              !communityScrollController!.position.outOfRange) {
            bloc.add(GetDataEvent());
          }
          if (communityScrollController!.offset <=
                  communityScrollController!.position.minScrollExtent &&
              !communityScrollController!.position.outOfRange) {
            bloc.floatingAnimationEnd = true;
            bloc.add(ScrollEvent(scroll: true));
          }
          if (communityScrollController!.position.userScrollDirection ==
              ScrollDirection.forward) {
            bloc.bottomOffset = 0;
            bloc.scrollUnder = false;
            if (!bloc.upDownCheck) {
              bloc.upDownCheck = true;
              bloc.startPixels = communityScrollController!.offset;
            }
            // 스크롤 다운
          } else if (communityScrollController!.position.userScrollDirection ==
              ScrollDirection.reverse) {
            if (bloc.upDownCheck) {
              bloc.upDownCheck = false;
              bloc.startPixels = communityScrollController!.offset;
            }
            // 스크롤 업
          }

          if (bloc.startPixels.toInt() -
                  communityScrollController!.offset.toInt() >
              30) {
            if (!bloc.scrollUp) {
              bloc.floatingAnimationEnd = false;
              bloc.add(ScrollEvent(scroll: true));
            }
          } else if (bloc.startPixels.toInt() -
                  communityScrollController!.offset.toInt() <
              -30) {
            if (bloc.scrollUp) {
              bloc.floatingAnimationEnd = false;
              bloc.add(ScrollEvent(scroll: false));
            }
          }
        }
      });
  }

  @override
  MyCreateCommunityBloc initBloc() {
    return MyCreateCommunityBloc(context)..add(MyCreateCommunityInitEvent());
  }
}
