import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/community/comment.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/chat/chat_detail_page.dart';
import 'package:baeit/ui/community_create/community_create_page.dart';
import 'package:baeit/ui/community_detail/community_detail_bloc.dart';
import 'package:baeit/ui/community_report/community_report_page.dart';
import 'package:baeit/ui/image_view/image_view_detail_page.dart';
import 'package:baeit/ui/image_view/image_view_page.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/my_create_community/my_create_community_bloc.dart'
    as myBloc;
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/opacity_container.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/stop_view.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityDetailPage extends BlocStatefulWidget {
  final String communityUuid;
  final bool chatDetail;
  final bool profileDialogCheck;

  CommunityDetailPage(
      {required this.communityUuid,
      this.chatDetail = false,
      this.profileDialogCheck = false});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return CommunityDetailState();
  }
}

class CommunityDetailState
    extends BlocState<CommunityDetailBloc, CommunityDetailPage>
    with TickerProviderStateMixin {
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  int currentLine = 1;
  bool heartAnimation = false;
  ScrollController scrollController = ScrollController();
  double viewInsets = 0.0;

  activateCheck(String check) {
    String text = '';
    check == 'NORMAL'
        ? text = '진행중'
        : check == 'DONE'
            ? text = '완료'
            : check == 'STOP'
                ? text = '중지'
                : check == 'TEMP'
                    ? text = '임시저장'
                    : text = '';
    return OpacityTextContainer(
      text: '$text',
      color: check == 'NORMAL'
          ? AppColors.error
          : check == 'DONE'
              ? AppColors.gray600
              : check == 'STOP'
                  ? AppColors.gray600
                  : check == 'TEMP'
                      ? AppColors.secondaryDark20
                      : null,
    );
  }

  commentTextField() {
    return LayoutBuilder(
      builder: (context, size) {
        final span = TextSpan(
            text: commentController.text,
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T14)));
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: size.maxWidth - 36);

        return TextFormField(
            maxLines: null,
            maxLength: 500,
            controller: commentController,
            focusNode: commentFocus,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
            onChanged: (text) {
              currentLine = tp.computeLineMetrics().length;
              blankCheck(
                  text: text, controller: commentController, multiline: true);
              setState(() {});
            },
            decoration: InputDecoration(
                counterText: '',
                isDense: false,
                isCollapsed: false,
                contentPadding:
                    EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
                hintText: bloc.commentEdit ? '' : '댓글을 남겨보세요',
                hintStyle: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T13)),
                border: InputBorder.none));
      },
    );
  }

  keywordTag() {
    return customTextSpan(
        text: '#',
        style: TextStyle(
            color: AppColors.greenGray300,
            fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
            fontSize: fontSizeSet(textSize: TextSize.T15)));
  }

  keywordText(text) {
    return customTextSpan(
        text: text,
        style: TextStyle(
            color: AppColors.greenGray900,
            fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
            fontSize: fontSizeSet(textSize: TextSize.T15)));
  }

  contentBody() {
    List<Widget> keywordView = [];
    if (bloc.communityDetail!.content.category == 'EXCHANGE' &&
        (bloc.communityDetail!.content.teachKeywordString != null &&
            bloc.communityDetail!.content.learnKeywordString != null)) {
      for (int i = 0;
          i < bloc.communityDetail!.content.teachKeywords!.length;
          i++) {
        keywordView.add(RichText(
          text: TextSpan(
            children: [
              keywordTag(),
              keywordText(bloc.communityDetail!.content.teachKeywords![i].text)
            ],
          ),
        ));
        if (keywordView.length ==
            bloc.communityDetail!.content.teachKeywords!.length) {
          keywordView.add(Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Image.asset(
              AppImages.iSwitch,
              width: 20,
              height: 20,
            ),
          ));
          for (int j = 0;
              j < bloc.communityDetail!.content.learnKeywords!.length;
              j++) {
            keywordView.add(RichText(
              text: TextSpan(
                children: [
                  keywordTag(),
                  keywordText(
                      bloc.communityDetail!.content.learnKeywords![j].text)
                ],
              ),
            ));
          }
        }
      }
    } else if (bloc.communityDetail!.content.category == 'WITH_ME' &&
        bloc.communityDetail!.content.meetKeywordString != null) {
      for (int i = 0;
          i < bloc.communityDetail!.content.meetKeywords!.length;
          i++) {
        keywordView.add(RichText(
          text: TextSpan(
            children: [
              keywordTag(),
              keywordText(bloc.communityDetail!.content.meetKeywords![i].text)
            ],
          ),
        ));
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          spaceH(10),
          Row(
            children: [
              bloc.communityDetail!.status == 'DONE'
                  ? Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20 / 6),
                        color: AppColors.gray200,
                      ),
                      padding: EdgeInsets.only(left: 4, right: 4),
                      child: Center(
                        child: customText('완료',
                            style: TextStyle(
                                color: AppColors.gray500,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T10))),
                      ),
                    )
                  : Container(),
              bloc.communityDetail!.status == 'DONE' ? spaceW(6) : Container(),
              customText(
                  communityType(
                      communityTypeIdx(bloc.communityDetail!.content.category)),
                  style: TextStyle(
                      color: bloc.communityDetail!.status == 'DONE'
                          ? AppColors.gray500
                          : AppColors.primary,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T14)))
            ],
          ),
          keywordView.length == 0 ? Container() : spaceH(10),
          keywordView.length == 0
              ? Container()
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: keywordView,
                ),
          spaceH(10),
          SelectableLinkify(
            scrollPhysics: NeverScrollableScrollPhysics(),
            onOpen: (link) async {
              await launch(link.url).then((value) {
                systemColorSetting();
              });
            },
            text: bloc.communityDetail!.content.contentText ?? '',
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
            options: LinkifyOptions(humanize: true),
          ),
          spaceH(20),
          bloc.communityDetail!.content.images!.length == 0
              ? Container()
              : Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        pushTransition(
                            context,
                            ImageViewPage(
                                imageUrls:
                                    bloc.communityDetail!.content.images!,
                                heroTag: ''));
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              width: 96,
                              height: 54,
                              child: CacheImage(
                                imageUrl: bloc
                                    .communityDetail!.content.images![0]
                                    .toView(
                                        context: context,
                                        w: MediaQuery.of(context)
                                            .size
                                            .width
                                            .toInt()),
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          Container(
                            width: 96,
                            height: 54,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9)),
                            child: topGradient(
                                context: context,
                                height: 54,
                                upColor: AppColors.black.withOpacity(0.2),
                                downColor: AppColors.black.withOpacity(1),
                                borderRadius: BorderRadius.circular(9)),
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
                                  images: bloc.communityDetail!.content.images!,
                                  heroTag: ''));
                        },
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                                side: BorderSide(color: AppColors.primary))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.iPlusC,
                              width: 16,
                              height: 16,
                            ),
                            spaceH(4),
                            customText(
                              AppStrings.of(StringKey.viewDetail),
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T10)),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
          spaceH(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                      '${dataSaver.neighborHood[dataSaver.neighborHood.indexWhere((element) => element.representativeFlag == 1)].townName}에서 ${double.parse(bloc.communityDetail!.content.distance).toString().split('.')[0].length > 3 ? '${(double.parse(bloc.communityDetail!.content.distance) / 1000) > 20 ? '20km+' : '${(double.parse(bloc.communityDetail!.content.distance) / 1000).toStringAsFixed(1)}km'}' : '${double.parse(bloc.communityDetail!.content.distance).toString().split('.')[0].length == 3 ? (double.parse(bloc.communityDetail!.content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(bloc.communityDetail!.content.distance).toString().split('.')[0]}m'}',
                      style: TextStyle(
                          color: AppColors.primaryDark10,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T11))),
                  spaceH(4),
                  customText(
                      bloc.communityDetail!.content.areas
                          .map((e) => e.hangName)
                          .toString()
                          .substring(1)
                          .replaceRange(
                              bloc.communityDetail!.content.areas
                                      .map((e) => e.hangName)
                                      .toString()
                                      .substring(1)
                                      .length -
                                  1,
                              bloc.communityDetail!.content.areas
                                  .map((e) => e.hangName)
                                  .toString()
                                  .substring(1)
                                  .length,
                              ''),
                      style: TextStyle(
                          color: AppColors.gray500,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T11)))
                ],
              ),
              Expanded(child: Container()),
              customText(
                DateTime.now()
                            .difference(
                                bloc.communityDetail!.content.createDate)
                            .inMinutes >
                        14400
                    ? bloc.communityDetail!.content.createDate.yearMonthDay
                    : timeCalculationText(DateTime.now()
                            .difference(
                                bloc.communityDetail!.content.createDate)
                            .inMinutes) +
                        '·조회 ${bloc.communityDetail!.readCnt > 999 ? '999+' : bloc.communityDetail!.readCnt}',
                style: TextStyle(
                    color: AppColors.gray500,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T11)),
              ),
            ],
          )
        ],
      ),
    );
  }

  contentProfile() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (bloc.communityDetail!.mineFlag == 0) {
                    amplitudeEvent(
                        'community_profile_clicks', {'type': 'other'});
                  } else {
                    amplitudeEvent('community_profile_clicks', {'type': 'my'});
                  }
                  profileDialog(
                      context: context,
                      memberUuid: bloc.communityDetail!.member.memberUuid);
                },
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: bloc.communityDetail!.member.profile == null
                            ? Image.asset(
                                AppImages.dfProfile,
                                width: 24,
                                height: 24,
                              )
                            : Container(
                                width: 24,
                                height: 24,
                                child: CacheImage(
                                  imageUrl:
                                      bloc.communityDetail!.member.profile!,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              )),
                    spaceW(6),
                    customText(
                        '${bloc.communityDetail!.member.nickName.length > 8 ? bloc.communityDetail!.member.nickName.substring(0, 8) + "..." : bloc.communityDetail!.member.nickName} >',
                        style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight:
                                weightSet(textWeight: TextWeight.REGULAR),
                            fontSize: fontSizeSet(textSize: TextSize.T12)))
                  ],
                ),
              ),
              Expanded(child: Container()),
              bloc.communityDetail!.mineFlag == 1
                  ? Container()
                  : Container(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: bloc.chatBlock == 0 || bloc.chatBlock == 1
                            ? null
                            : () {
                                if (!dataSaver.nonMember) {
                                  if (bloc.communityDetail!.managerStopFlag ==
                                      1) {
                                    FocusScope.of(context).unfocus();
                                    showToast(
                                        context: context,
                                        text: '운영정지 된 게시글입니다');
                                    return;
                                  }
                                  if (widget.profileDialogCheck &&
                                      widget.chatDetail) {
                                    popWithResult(context, 'closeDialog');
                                  } else if (widget.chatDetail) {
                                    pop(context);
                                  } else if (dataSaver.chatRoom != null &&
                                      dataSaver.chatRoom!.roomData.indexWhere(
                                              (element) =>
                                                  element.communityInfo !=
                                                      null &&
                                                  element.communityInfo!
                                                          .communityUuid ==
                                                      bloc.communityDetail!
                                                          .communityUuid) !=
                                          -1) {
                                    amplitudeEvent('chat_consultation', {
                                      'type': 'community',
                                      'community_uuid':
                                          bloc.communityDetail!.communityUuid,
                                      'town_dongeupmyeon': bloc
                                          .communityDetail!.content.areas
                                          .map((e) => e.eupmyeondongName)
                                          .toList()
                                          .join(','),
                                      'town_sido': bloc
                                          .communityDetail!.content.areas
                                          .map((e) => e.sidoName)
                                          .toList()
                                          .join(','),
                                      'town_sigungu': bloc
                                          .communityDetail!.content.areas
                                          .map((e) => e.sigunguName)
                                          .toList()
                                          .join(','),
                                    });
                                    pushTransition(
                                        context,
                                        ChatDetailPage(
                                          chatRoomUuid: dataSaver
                                              .chatRoom!
                                              .roomData[dataSaver
                                                  .chatRoom!.roomData
                                                  .indexWhere((element) =>
                                                      (element.communityInfo ==
                                                              null
                                                          ? ''
                                                          : element
                                                              .communityInfo!
                                                              .communityUuid) ==
                                                      bloc.communityDetail!
                                                          .communityUuid)]
                                              .chatRoomUuid,
                                          userName: bloc
                                              .communityDetail!.member.nickName,
                                          communityCheck: true,
                                          detail: true,
                                        )).then((value) {
                                      if (value != null && value == 'BLOCK') {
                                        bloc.add(ReCheckBlockEvent());
                                      }
                                    });
                                  } else {
                                    amplitudeEvent('chat_consultation', {
                                      'type': 'community',
                                      'community_uuid':
                                          bloc.communityDetail!.communityUuid,
                                      'town_dongeupmyeon': bloc
                                          .communityDetail!.content.areas
                                          .map((e) => e.eupmyeondongName)
                                          .toList()
                                          .join(','),
                                      'town_sido': bloc
                                          .communityDetail!.content.areas
                                          .map((e) => e.sidoName)
                                          .toList()
                                          .join(','),
                                      'town_sigungu': bloc
                                          .communityDetail!.content.areas
                                          .map((e) => e.sigunguName)
                                          .toList()
                                          .join(','),
                                    });
                                    pushTransition(
                                        context,
                                        ChatDetailPage(
                                          communityDetail:
                                              bloc.communityDetail!,
                                          communityUuid: bloc.communityUuid,
                                          userName: bloc
                                              .communityDetail!.member.nickName,
                                          communityCheck: true,
                                          detail: true,
                                        )).then((value) {
                                      if (value != null && value == 'BLOCK') {
                                        bloc.add(ReCheckBlockEvent());
                                      }
                                    });
                                  }
                                } else {
                                  nonMemberDialog(
                                      context: context,
                                      title: AppStrings.of(
                                          StringKey.alertChatting),
                                      content: AppStrings.of(
                                          StringKey.alertChattingContent));
                                }
                              },
                        child: Center(
                            child: customText('1:1 채팅하기',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)))),
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.primary,
                            elevation: 0,
                            padding: EdgeInsets.only(left: 16, right: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    )
            ],
          ),
          spaceH(16)
        ],
      ),
    );
  }

  commentView() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 56,
            color: AppColors.white,
            child: Row(
              children: [
                customText(
                    '댓글 ${bloc.commentTotalRow > 999 ? '999+' : bloc.commentTotalRow}',
                    style: TextStyle(
                        color: AppColors.gray500,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
              ],
            ),
          ),
          bloc.commentTotalRow == 0
              ? Column(
                  children: [
                    spaceH(40),
                    Image.asset(
                      AppImages.imgEmptySomething,
                      width: 135,
                      height: 135,
                    ),
                    customText('댓글을 쓰고 이웃과 소통해요',
                        style: TextStyle(
                            color: AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.REGULAR),
                            fontSize: fontSizeSet(textSize: TextSize.T14))),
                    spaceH(40)
                  ],
                )
              : commentList(bloc.comment, 0)
        ],
      ),
    );
  }

  commentList(List<Comment> comments, int count) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return Padding(
          padding: EdgeInsets.only(left: (count * 42), bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (comments[idx].writeMember.status == 'STOP' ||
                          comments[idx].writeMember.status == 'WITHDRAWAL') {
                        return;
                      }
                      if (bloc.communityDetail!.mineFlag == 0) {
                        amplitudeEvent(
                            'community_profile_clicks', {'type': 'other'});
                      } else {
                        amplitudeEvent(
                            'community_profile_clicks', {'type': 'my'});
                      }
                      profileDialog(
                          context: context,
                          memberUuid: comments[idx].writeMember.memberUuid);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: comments[idx].writeMember.profile == null ||
                              comments[idx].writeMember.status == 'STOP'
                          ? Image.asset(
                              AppImages.dfProfile,
                              width: 32,
                              height: 32,
                            )
                          : Container(
                              width: 32,
                              height: 32,
                              child: CacheImage(
                                imageUrl: comments[idx].writeMember.profile!,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                placeholder: Image.asset(
                                  AppImages.dfProfile,
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ),
                    ),
                  ),
                  spaceW(10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        spaceH(2),
                        Row(
                          children: [
                            customText(
                                comments[idx].writeMember.nickName.length > 8
                                    ? comments[idx]
                                            .writeMember
                                            .nickName
                                            .substring(0, 8) +
                                        "..."
                                    : comments[idx].writeMember.nickName,
                                style: TextStyle(
                                    color: comments[idx].writeMember.status ==
                                                'STOP' ||
                                            comments[idx].writeMember.status ==
                                                'WITHDRAWAL'
                                        ? AppColors.gray400
                                        : AppColors.greenGray500,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                            spaceW(8),
                            comments[idx].status == 'DELETE' ||
                                    comments[idx].status == 'REPORT' ||
                                    comments[idx].writeMember.status ==
                                        'STOP' ||
                                    comments[idx].writeMember.status ==
                                        'WITHDRAWAL'
                                ? Container()
                                : Container(
                                    width: 1,
                                    height: 10,
                                    color: AppColors.gray300,
                                  ),
                            comments[idx].status == 'DELETE' ||
                                    comments[idx].status == 'REPORT' ||
                                    comments[idx].writeMember.status ==
                                        'STOP' ||
                                    comments[idx].writeMember.status ==
                                        'WITHDRAWAL'
                                ? Container()
                                : spaceW(8),
                            comments[idx].status == 'DELETE' ||
                                    comments[idx].status == 'REPORT' ||
                                    comments[idx].writeMember.status ==
                                        'STOP' ||
                                    comments[idx].writeMember.status ==
                                        'WITHDRAWAL'
                                ? Container()
                                : customText(
                                    '${comments[idx].eupmyeondongName}·${DateTime.now().difference(comments[idx].createDate).inMinutes > 14400 ? comments[idx].createDate.yearMonthDay : timeCalculationText(DateTime.now().difference(comments[idx].createDate).inMinutes)}',
                                    style: TextStyle(
                                        color: AppColors.gray500,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T12))),
                            Expanded(child: Container()),
                            comments[idx].status == 'DELETE' ||
                                    comments[idx].status == 'REPORT' ||
                                    comments[idx].writeMember.status ==
                                        'STOP' ||
                                    comments[idx].writeMember.status ==
                                        'WITHDRAWAL'
                                ? Container()
                                : !dataSaver.nonMember
                                    ? GestureDetector(
                                        onTap: () {
                                          if (comments[idx].mineFlag == 1) {
                                            editDialog(
                                                comments[idx].text,
                                                comments[idx]
                                                    .communityCommentUuid);
                                          } else {
                                            reportDialog(
                                                comments[idx].text,
                                                comments[idx]
                                                    .communityCommentUuid,
                                                comments[idx].reportFlag == 1
                                                    ? true
                                                    : false);
                                          }
                                        },
                                        child: Image.asset(
                                          AppImages.iMore,
                                          width: 18,
                                          height: 18,
                                        ),
                                      )
                                    : Container()
                          ],
                        ),
                        spaceH(4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  comments[idx].parentWriterMember == null
                                      ? Container()
                                      : customText(
                                          '@${comments[idx].parentWriterMember!.nickName.length > 8 ? comments[idx].parentWriterMember!.nickName.substring(0, 8) + "... " : comments[idx].parentWriterMember!.nickName} ',
                                          style: TextStyle(
                                              color: AppColors.gray400,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T14))),
                                  SelectableLinkify(
                                    scrollPhysics:
                                        NeverScrollableScrollPhysics(),
                                    onOpen: (link) async {
                                      await launch(link.url).then((value) {
                                        systemColorSetting();
                                      });
                                    },
                                    text: comments[idx].text,
                                    style: TextStyle(
                                        color: comments[idx].status == 'DELETE'
                                            ? AppColors.gray400
                                            : AppColors.gray600,
                                        letterSpacing: 0.02,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14)),
                                    textAlign: TextAlign.start,
                                    options: LinkifyOptions(humanize: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        comments[idx].editFlag == 1 &&
                                comments[idx].status != 'DELETE'
                            ? spaceH(2)
                            : Container(),
                        comments[idx].editFlag == 1 &&
                                comments[idx].status != 'DELETE'
                            ? customText('(수정됨)',
                                style: TextStyle(
                                    color: AppColors.gray400,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)),
                                textAlign: TextAlign.start)
                            : Container(),
                        comments[idx].mineFlag == 0 ? spaceH(8) : Container(),
                        comments[idx].status == 'DELETE' ||
                                comments[idx].status == 'REPORT' ||
                                comments[idx].writeMember.status == 'STOP' ||
                                comments[idx].writeMember.status == 'WITHDRAWAL'
                            ? Container()
                            : comments[idx].mineFlag == 0
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bloc.reply = true;
                                        bloc.rootCommentUuid = comments[idx]
                                                .rootCommunityCommentUuid ??
                                            comments[idx].communityCommentUuid;
                                        bloc.parentCommentUuid =
                                            comments[idx].communityCommentUuid;
                                        bloc.replyMember =
                                            comments[idx].writeMember;
                                        FocusScope.of(context)
                                            .requestFocus(commentFocus);

                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          scrollController.animateTo(
                                              scrollController.offset +
                                                  viewInsets +
                                                  50,
                                              duration:
                                                  Duration(milliseconds: 300),
                                              curve: Curves.ease);
                                        });
                                      });
                                    },
                                    child: customText('답글달기 >',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12))),
                                  )
                                : Container(),
                      ],
                    ),
                  )
                ],
              ),
              comments[idx].list.length == 0 ? Container() : spaceH(20),
              comments[idx].list.length == 0
                  ? Container()
                  : commentList(comments[idx].list, count + 1)
            ],
          ),
        );
      },
      shrinkWrap: true,
      itemCount: comments.length,
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      bloc.openMoreView = false;
                    });
                  },
                  child: Stack(
                    children: [
                      bloc.communityDetail == null
                          ? Container()
                          : Scaffold(
                              backgroundColor: AppColors.white,
                              appBar: baseAppBar(
                                  title: '',
                                  centerTitle: false,
                                  context: context,
                                  onPressed: () {
                                    pop(context);
                                  },
                                  action: bloc.communityDetail == null
                                      ? Container()
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            bloc.communityDetail!.mineFlag == 0
                                                ? Container()
                                                : activateCheck(bloc
                                                    .communityDetail!.status),
                                            bloc.communityDetail!.mineFlag == 0
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      if (!dataSaver
                                                          .nonMember) {
                                                        if (bloc.communityDetail!
                                                                .likeFlag ==
                                                            1) {
                                                          setState(() {
                                                            heartAnimation =
                                                                true;
                                                            Future.delayed(
                                                                Duration(
                                                                    milliseconds:
                                                                        100),
                                                                () {
                                                              setState(() {
                                                                heartAnimation =
                                                                    false;
                                                              });
                                                            });
                                                          });
                                                          bloc.add(
                                                              BookmarkEvent(
                                                                  flag: 1,
                                                                  bookmark:
                                                                      false));
                                                        } else {
                                                          setState(() {
                                                            heartAnimation =
                                                                true;
                                                            Future.delayed(
                                                                Duration(
                                                                    milliseconds:
                                                                        100),
                                                                () {
                                                              setState(() {
                                                                heartAnimation =
                                                                    false;
                                                              });
                                                            });
                                                          });
                                                          amplitudeEvent(
                                                              'community_bookmark_clicks',
                                                              {
                                                                'type': communityTypeCreate(
                                                                    communityTypeIdx(bloc
                                                                        .communityDetail!
                                                                        .content
                                                                        .category)),
                                                                'bookmark_count': bloc
                                                                    .communityDetail!
                                                                    .likeCnt,
                                                                'chat_count': bloc
                                                                    .communityDetail!
                                                                    .chatCnt,
                                                                'share_count': bloc
                                                                    .communityDetail!
                                                                    .shareCnt,
                                                                'view_count': bloc
                                                                    .communityDetail!
                                                                    .readCnt,
                                                                'comment_count': bloc
                                                                    .communityDetail!
                                                                    .commentCnt,
                                                                'user_id': bloc
                                                                    .communityDetail!
                                                                    .member
                                                                    .memberUuid,
                                                                'user_name': bloc
                                                                    .communityDetail!
                                                                    .member
                                                                    .nickName,
                                                                'community_id': bloc
                                                                    .communityDetail!
                                                                    .communityUuid,
                                                                'distance': bloc
                                                                    .communityDetail!
                                                                    .content
                                                                    .distance,
                                                                'town_dongeupmyeon': bloc
                                                                    .communityDetail!
                                                                    .content
                                                                    .areas
                                                                    .map((e) =>
                                                                        e.eupmyeondongName)
                                                                    .toList()
                                                                    .join(','),
                                                                'town_sido': bloc
                                                                    .communityDetail!
                                                                    .content
                                                                    .areas
                                                                    .map((e) =>
                                                                        e.sidoName)
                                                                    .toList()
                                                                    .join(','),
                                                                'town_sigungu': bloc
                                                                    .communityDetail!
                                                                    .content
                                                                    .areas
                                                                    .map((e) =>
                                                                        e.sigunguName)
                                                                    .toList()
                                                                    .join(','),
                                                                'status': bloc
                                                                    .communityDetail!
                                                                    .status
                                                              });
                                                          bloc.add(
                                                              BookmarkEvent(
                                                                  flag: 0,
                                                                  bookmark:
                                                                      true));
                                                        }
                                                      } else {
                                                        nonMemberDialog(
                                                            context: context,
                                                            title: AppStrings
                                                                .of(StringKey
                                                                    .alertBookmark),
                                                            content:
                                                                '카톡으로 로그인하고\n게시글을 찜할 수 있어요');
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      child: Stack(
                                                        children: [
                                                          AnimatedPositioned(
                                                            top: 0,
                                                            left: heartAnimation
                                                                ? 0
                                                                : 3,
                                                            right:
                                                                heartAnimation
                                                                    ? 0
                                                                    : 3,
                                                            bottom: 0,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    100),
                                                            curve: Curves.ease,
                                                            child: Image.asset(
                                                              !(bloc.communityDetail!
                                                                          .likeFlag ==
                                                                      1)
                                                                  ? AppImages
                                                                      .iHeartCsOff
                                                                  : AppImages
                                                                      .iHeartCsOn,
                                                              width: 24,
                                                              height: 24,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            bloc.communityDetail!.status ==
                                                    'TEMP'
                                                ? Container()
                                                : spaceW(16),
                                            bloc.communityDetail!.status ==
                                                    'TEMP'
                                                ? Container()
                                                : SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        bloc.add(ShareEvent());
                                                      },
                                                      icon: Image.asset(
                                                        AppImages.iShare,
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                    )),
                                            !dataSaver.nonMember
                                                ? spaceW(16)
                                                : Container(),
                                            !dataSaver.nonMember
                                                ? SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          bloc.openMoreView =
                                                              true;
                                                        });
                                                      },
                                                      icon: Image.asset(
                                                        AppImages.iMore,
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  )
                                                : Container(),
                                            spaceW(20)
                                          ],
                                        )),
                              resizeToAvoidBottomInset: true,
                              body: bloc.communityDetail == null
                                  ? Container()
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              (dataSaver.statusTop +
                                                  60 +
                                                  dataSaver.iosBottom),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              bottom: ((currentLine > 2)
                                                      ? 100
                                                      : currentLine == 2
                                                          ? 80
                                                          : 60) +
                                                  (bloc.reply ||
                                                          bloc.commentEdit
                                                      ? 50
                                                      : 0),
                                              child: RefreshIndicator(
                                                onRefresh: () async {
                                                  bloc.add(
                                                      CommunityDetailInitEvent(
                                                          communityUuid: widget
                                                              .communityUuid));
                                                },
                                                color: AppColors.primary,
                                                child: SingleChildScrollView(
                                                  controller: scrollController,
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      contentBody(),
                                                      spaceH(16),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 1,
                                                        color:
                                                            AppColors.gray100,
                                                      ),
                                                      spaceH(16),
                                                      contentProfile(),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 6,
                                                        color:
                                                            AppColors.gray100,
                                                      ),
                                                      commentView()
                                                    ],
                                                  ),
                                                ),
                                              )),
                                          Positioned(
                                              bottom: ((currentLine > 2)
                                                      ? 100
                                                      : currentLine == 2
                                                          ? 80
                                                          : 60) +
                                                  (bloc.reply ||
                                                          bloc.commentEdit
                                                      ? 50
                                                      : 0),
                                              left: 0,
                                              right: 0,
                                              child: bottomGradient(
                                                  context: context,
                                                  height: 20,
                                                  color: AppColors.white)),
                                          bloc.communityDetail!.status == 'TEMP'
                                              ? Positioned(
                                                  left: 12,
                                                  right: 12,
                                                  bottom: 12,
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 48,
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          pushTransition(
                                                              context,
                                                              CommunityCreatePage(
                                                                idx: communityTypeIdx(bloc
                                                                    .communityDetail!
                                                                    .content
                                                                    .category),
                                                                communityUuid: bloc
                                                                    .communityUuid,
                                                                edit: true,
                                                              )).then((value) {
                                                            if (value != null &&
                                                                value) {
                                                              bloc.add(CommunityDetailInitEvent(
                                                                  communityUuid:
                                                                      widget
                                                                          .communityUuid));
                                                            }
                                                          });
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
                                                                            8),
                                                                side: BorderSide(
                                                                    width: 1,
                                                                    color: AppColors
                                                                        .primary))),
                                                        child: Center(
                                                          child: customText(
                                                            '이어서 작성하기',
                                                            style: TextStyle(
                                                                fontSize: fontSizeSet(
                                                                    textSize:
                                                                        TextSize
                                                                            .T14),
                                                                color: AppColors
                                                                    .primaryDark10,
                                                                fontWeight: weightSet(
                                                                    textWeight:
                                                                        TextWeight
                                                                            .MEDIUM)),
                                                          ),
                                                        )),
                                                  ),
                                                )
                                              : Positioned(
                                                  left: 12,
                                                  right: 12,
                                                  bottom: 12,
                                                  child: Column(
                                                    children: [
                                                      bloc.reply ||
                                                              bloc.commentEdit
                                                          ? Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              decoration: BoxDecoration(
                                                                  color: bloc
                                                                          .reply
                                                                      ? AppColors
                                                                          .accentLight60
                                                                      : AppColors
                                                                          .primaryLight60,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 12,
                                                                      right: 12,
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    child: customText(
                                                                        bloc.reply
                                                                            ? '@${bloc.replyMember!.nickName.length > 10 ? bloc.replyMember!.nickName.substring(0, 10) + '...' : bloc.replyMember!.nickName}'
                                                                            : '\'${bloc.editComment.length > 10 ? bloc.editComment.substring(0, 10) + '...' : bloc.editComment}\' ',
                                                                        style:
                                                                            TextStyle(
                                                                          color: bloc.reply
                                                                              ? AppColors.accent
                                                                              : AppColors.primary,
                                                                          fontWeight:
                                                                              weightSet(textWeight: TextWeight.MEDIUM),
                                                                          fontSize:
                                                                              fontSizeSet(textSize: TextSize.T12),
                                                                        ),
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                  ),
                                                                  customText(
                                                                      bloc.reply
                                                                          ? '님에게 답글'
                                                                          : '댓글 수정',
                                                                      style: TextStyle(
                                                                          color: AppColors
                                                                              .greenGray400,
                                                                          fontWeight:
                                                                              weightSet(textWeight: TextWeight.MEDIUM),
                                                                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                                                                  Expanded(
                                                                      child:
                                                                          Container()),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (bloc
                                                                            .reply) {
                                                                          bloc.reply =
                                                                              false;
                                                                        }
                                                                        if (bloc
                                                                            .commentEdit) {
                                                                          bloc.commentEdit =
                                                                              false;
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Image
                                                                        .asset(
                                                                      AppImages
                                                                          .iInputClearTrans,
                                                                      width: 18,
                                                                      height:
                                                                          18,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : Container(),
                                                      bloc.reply ||
                                                              bloc.commentEdit
                                                          ? spaceH(10)
                                                          : Container(),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      border: Border.all(
                                                                          color: AppColors
                                                                              .gray200,
                                                                          width:
                                                                              1)),
                                                                  height: (currentLine >
                                                                          2)
                                                                      ? 88
                                                                      : currentLine ==
                                                                              2
                                                                          ? 68
                                                                          : 48,
                                                                  child:
                                                                      commentTextField())),
                                                          spaceW(10),
                                                          Container(
                                                            width: 48,
                                                            height: 48,
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                if (!dataSaver
                                                                    .nonMember) {
                                                                  if (bloc.communityDetail!
                                                                          .status ==
                                                                      'TEMP') {
                                                                    return;
                                                                  }
                                                                  if (commentController
                                                                          .text ==
                                                                      '') {
                                                                    showToast(
                                                                        context:
                                                                            context,
                                                                        text:
                                                                            '댓글을 입력해주세요',
                                                                        toastGravity:
                                                                            ToastGravity.CENTER);
                                                                  } else {
                                                                    bloc.add(
                                                                        AddCommentEvent(
                                                                      text: commentController
                                                                          .text,
                                                                    ));

                                                                    setState(
                                                                        () {
                                                                      currentLine =
                                                                          0;
                                                                      commentController
                                                                          .text = '';
                                                                    });
                                                                    FocusScope.of(
                                                                            context)
                                                                        .unfocus();
                                                                  }
                                                                } else {
                                                                  nonMemberDialog(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          '댓글달기',
                                                                      content:
                                                                          '로그인을하면 게시글에\n댓글을 달 수 있어요');
                                                                }
                                                              },
                                                              child: Center(
                                                                child:
                                                                    Image.asset(
                                                                  AppImages
                                                                      .iChatSendingW,
                                                                  width: 24,
                                                                  height: 24,
                                                                ),
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                  primary:
                                                                      AppColors
                                                                          .primary,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  elevation: 0,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8))),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                        ],
                                      ),
                                    ),
                            ),
                      bloc.communityDetail == null ||
                              bloc.communityDetail!.mineFlag == 0
                          ? Positioned(
                              top: 16,
                              right: 16,
                              child: AnimatedContainer(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            AppColors.black.withOpacity(0.16),
                                        blurRadius: 6,
                                        offset: Offset(0, 0))
                                  ],
                                  color: AppColors.white,
                                ),
                                duration: Duration(milliseconds: 200),
                                width: bloc.openMoreView ? 180 : 0,
                                padding: EdgeInsets.zero,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          if (bloc.communityDetail!
                                                  .reportFlag ==
                                              1) {
                                            showToast(
                                                context: context,
                                                text: '이미 신고한 게시글입니다');
                                          } else {
                                            setState(() {
                                              bloc.openMoreView = false;
                                            });
                                            pushTransition(
                                                context,
                                                CommunityReportPage(
                                                  type: 0,
                                                  communityUuid:
                                                      widget.communityUuid,
                                                )).then((value) {
                                              if (value != null) {
                                                bloc.communityDetail!
                                                    .reportFlag = 1;
                                              }
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            primary: AppColors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.zero),
                                        child: Row(
                                          children: [
                                            spaceW(20),
                                            Image.asset(
                                              AppImages.iWarningCe,
                                              width: 16,
                                              height: 16,
                                            ),
                                            spaceW(8),
                                            customText('신고하기',
                                                style: TextStyle(
                                                    color: AppColors.gray900,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T14)))
                                          ],
                                        )),
                                  ],
                                ),
                              ))
                          : Positioned(
                              top: 16,
                              right: 16,
                              child: AnimatedContainer(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            AppColors.black.withOpacity(0.16),
                                        blurRadius: 6,
                                        offset: Offset(0, 0))
                                  ],
                                  color: AppColors.white,
                                ),
                                duration: Duration(milliseconds: 200),
                                width: bloc.openMoreView ? 180 : 0,
                                padding: EdgeInsets.zero,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    spaceH(10),
                                    bloc.communityDetail!.status == 'TEMP'
                                        ? Container()
                                        : Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 40,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                spaceW(20),
                                                customText('진행 완료',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray900,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .MEDIUM),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T14))),
                                                Expanded(child: Container()),
                                                FlutterSwitch(
                                                  width: 46,
                                                  height: 24,
                                                  onToggle: (value) {
                                                    if (bloc.communityDetail!
                                                            .status !=
                                                        'TEMP') {
                                                      bloc.add(CommunityStatusChangeEvent(
                                                          status: bloc.communityDetail!
                                                                      .status ==
                                                                  'DONE'
                                                              ? 'NORMAL'
                                                              : 'DONE'));
                                                    }
                                                  },
                                                  padding: 2,
                                                  borderRadius: 49,
                                                  duration: Duration(
                                                      milliseconds: 100),
                                                  activeColor: AppColors.accent,
                                                  inactiveColor:
                                                      AppColors.gray100,
                                                  value: bloc.communityDetail ==
                                                          null
                                                      ? false
                                                      : bloc.communityDetail!
                                                              .status ==
                                                          'DONE',
                                                  toggleSize: 20,
                                                  inactiveIcon: ClipOval(
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.08),
                                                              blurRadius: 1,
                                                              offset:
                                                                  Offset(0, 1)),
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.15),
                                                              blurRadius: 6,
                                                              offset:
                                                                  Offset(0, 2))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  activeIcon: ClipOval(
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.08),
                                                              blurRadius: 1,
                                                              offset:
                                                                  Offset(0, 1)),
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.15),
                                                              blurRadius: 6,
                                                              offset:
                                                                  Offset(0, 2))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                spaceW(20)
                                              ],
                                            ),
                                          ),
                                    bloc.communityDetail!.status == 'TEMP'
                                        ? Container()
                                        : spaceH(10),
                                    bloc.communityDetail!.status == 'TEMP'
                                        ? Container()
                                        : Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 1,
                                            color: AppColors.gray200,
                                          ),
                                    bloc.communityDetail!.status == 'TEMP'
                                        ? Container()
                                        : spaceH(10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          bloc.communityDetail!.status == 'TEMP'
                                              ? Container()
                                              : Container(
                                                  height: 40,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        bloc.openMoreView =
                                                            false;
                                                      });
                                                      amplitudeEvent(
                                                          'community_edit', {
                                                        'type': communityTypeCreate(
                                                            communityTypeIdx(bloc
                                                                .communityDetail!
                                                                .content
                                                                .category))
                                                      });
                                                      pushTransition(
                                                          context,
                                                          CommunityCreatePage(
                                                            idx: communityTypeIdx(bloc
                                                                .communityDetail!
                                                                .content
                                                                .category),
                                                            communityUuid: bloc
                                                                .communityUuid,
                                                            edit: true,
                                                          )).then((value) {
                                                        if (value != null &&
                                                            value) {
                                                          bloc.add(CommunityDetailInitEvent(
                                                              communityUuid: widget
                                                                  .communityUuid));
                                                        }
                                                      });
                                                    },
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image.asset(
                                                          AppImages.iEditUnderG,
                                                          width: 16,
                                                          height: 16,
                                                        ),
                                                        spaceW(8),
                                                        customText('게시글 수정',
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
                                                            textAlign: TextAlign
                                                                .center)
                                                      ],
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary:
                                                                AppColors.white,
                                                            elevation: 0,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20,
                                                                    right: 20)),
                                                  ),
                                                ),
                                          Container(
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                bloc.add(
                                                    CommunityStatusChangeEvent(
                                                        status: 'DELETE'));
                                                dataSaver.learnBloc!.add(
                                                    CommunityReloadEvent());
                                                if (dataSaver
                                                        .myCreateCommunityBloc !=
                                                    null) {
                                                  dataSaver
                                                      .myCreateCommunityBloc!
                                                      .add(myBloc
                                                          .StatusChangeEvent());
                                                }
                                                popWithResult(context,
                                                    bloc.communityUuid);
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Image.asset(
                                                      AppImages.iTrashG,
                                                      width: 16,
                                                      height: 16,
                                                    ),
                                                  ),
                                                  spaceW(8),
                                                  customText('게시글 삭제',
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.gray900,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T14)),
                                                      textAlign:
                                                          TextAlign.center)
                                                ],
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  primary: AppColors.white,
                                                  elevation: 0,
                                                  padding: EdgeInsets.only(
                                                      left: 20, right: 20)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    spaceH(10)
                                  ],
                                ),
                              )),
                      bloc.communityDetail == null
                          ? Container()
                          : bloc.communityDetail!.managerStopFlag == 1 &&
                                  bloc.communityDetail!.mineFlag == 1
                              ? DetailStop(
                                  context: context,
                                  editPress: () {
                                    pushTransition(
                                        context,
                                        CommunityCreatePage(
                                          idx: communityTypeIdx(bloc
                                              .communityDetail!
                                              .content
                                              .category),
                                          communityUuid: bloc.communityUuid,
                                          edit: true,
                                          stop: true,
                                        ));
                                  },
                                  whyRemove: bloc.communityDetail!
                                          .managerStopReasonText ??
                                      '',
                                )
                              : Container(),
                      loadingView(bloc.loading)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  editDialog(String comment, String commentUuid) {
    customDialog(
        context: context,
        barrier: false,
        widget: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 60,
              child: Row(
                children: [
                  spaceW(24),
                  Expanded(
                    child: customText(comment,
                        maxLines: 1,
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)),
                        overflow: TextOverflow.ellipsis),
                  ),
                  spaceW(16),
                  GestureDetector(
                    onTap: () {
                      popDialog(context);
                    },
                    child: Image.asset(
                      AppImages.iX,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  spaceW(20)
                ],
              ),
            ),
            Container(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  popDialog(context);
                  setState(() {
                    bloc.commentEdit = true;
                    bloc.editCommentUuid = commentUuid;
                    bloc.editComment = comment;
                    commentController.text = comment;
                    FocusScope.of(context).requestFocus(commentFocus);

                    Future.delayed(Duration(milliseconds: 1200), () {
                      scrollController.animateTo(
                          scrollController.offset + viewInsets + 50,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    elevation: 0,
                    padding: EdgeInsets.only(left: 24)),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.iEditUnderG,
                      width: 16,
                      height: 16,
                    ),
                    spaceW(4),
                    customText('수정하기',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)))
                  ],
                ),
              ),
            ),
            Container(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  bloc.add(
                      RemoveCommentEvent(communityCommentUuid: commentUuid));
                  popDialog(context);
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    padding: EdgeInsets.only(left: 24)),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.iTrashG,
                      width: 16,
                      height: 16,
                    ),
                    spaceW(4),
                    customText('삭제하기',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)))
                  ],
                ),
              ),
            ),
            spaceH(20)
          ],
        ));
  }

  reportDialog(String comment, String commentUuid, bool reported) {
    customDialog(
        context: context,
        barrier: false,
        widget: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 60,
              child: Row(
                children: [
                  spaceW(24),
                  Expanded(
                    child: customText(comment,
                        maxLines: 1,
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)),
                        overflow: TextOverflow.ellipsis),
                  ),
                  spaceW(16),
                  GestureDetector(
                    onTap: () {
                      popDialog(context);
                    },
                    child: Image.asset(
                      AppImages.iX,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  spaceW(20)
                ],
              ),
            ),
            Container(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (!dataSaver.nonMember) {
                    if (reported) {
                      popDialog(context);
                    } else {
                      popDialog(context);
                      pushTransition(
                          context,
                          CommunityReportPage(
                            communityCommentUuid: commentUuid,
                            type: 1,
                          )).then((value) {
                        if (value != null && value) {
                          bloc.add(CommentInitEvent());
                        }
                      });
                    }
                  } else {
                    nonMemberDialog(
                        context: context,
                        title: '신고하기',
                        content: '로그인하면 신고하기 기능을\n사용하실 수 있어요');
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    elevation: 0,
                    padding: EdgeInsets.only(left: 24)),
                child: Row(
                  children: [
                    Image.asset(
                      reported ? AppImages.iWarningG : AppImages.iWarningCe,
                      width: 16,
                      height: 16,
                    ),
                    spaceW(4),
                    customText(reported ? '신고완료' : '신고하기',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)))
                  ],
                ),
              ),
            ),
            spaceH(20)
          ],
        ));
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is CommunityDetailInitState) {
      dataSaver.communityDetailBloc = bloc;
    }

    if (state is CommunityBlockUserState) {
      pop(context);
    }

    if (state is ShareState) {
      if (bloc.communityDetail!.status != 'TEMP') {
        if (bloc.communityDetail!.mineFlag == 0) {
          amplitudeEvent('community_share_clicks', {
            'type': communityTypeCreate(
                communityTypeIdx(bloc.communityDetail!.content.category)),
            'bookmark_count': bloc.communityDetail!.likeCnt,
            'chat_count': bloc.communityDetail!.chatCnt,
            'share_count': bloc.communityDetail!.shareCnt,
            'view_count': bloc.communityDetail!.readCnt,
            'comment_count': bloc.communityDetail!.commentCnt,
            'user_id': bloc.communityDetail!.member.memberUuid,
            'user_name': bloc.communityDetail!.member.nickName,
            'community_id': bloc.communityDetail!.communityUuid,
            'distance': bloc.communityDetail!.content.distance,
            'town_dongeupmyeon': bloc.communityDetail!.content.areas
                .map((e) => e.eupmyeondongName)
                .toList()
                .join(','),
            'town_sido': bloc.communityDetail!.content.areas
                .map((e) => e.sidoName)
                .toList()
                .join(','),
            'town_sigungu': bloc.communityDetail!.content.areas
                .map((e) => e.sigunguName)
                .toList()
                .join(','),
            'status': bloc.communityDetail!.status
          });
        } else {
          amplitudeEvent('my_community_share', {
            'type': 'community',
            'bookmark_count': bloc.communityDetail!.likeCnt,
            'chat_count': bloc.communityDetail!.chatCnt,
            'share_count': bloc.communityDetail!.shareCnt,
            'view_count': bloc.communityDetail!.readCnt,
            'comment_count': bloc.communityDetail!.commentCnt,
            'user_id': bloc.communityDetail!.member.memberUuid,
            'user_name': bloc.communityDetail!.member.nickName,
            'community_id': bloc.communityDetail!.communityUuid,
            'distance': bloc.communityDetail!.content.distance,
            'town_dongeupmyeon': bloc.communityDetail!.content.areas
                .map((e) => e.eupmyeondongName)
                .toList()
                .join(','),
            'town_sido': bloc.communityDetail!.content.areas
                .map((e) => e.sidoName)
                .toList()
                .join(','),
            'town_sigungu': bloc.communityDetail!.content.areas
                .map((e) => e.sigunguName)
                .toList()
                .join(','),
            'status': bloc.communityDetail!.status
          });
        }
        Share.share(state.shareText);
      }
    }
  }

  @override
  CommunityDetailBloc initBloc() {
    return CommunityDetailBloc(context)
      ..add(CommunityDetailInitEvent(communityUuid: widget.communityUuid));
  }
}
