import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/chat/chat_detail_page.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/feedback/feedback_detail_page.dart';
import 'package:baeit/ui/keyword_setting/keyword_setting_page.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/ui/my_create_class/my_create_class_page.dart';
import 'package:baeit/ui/notice/notice_detail_page.dart';
import 'package:baeit/ui/notification/notification_bloc.dart';
import 'package:baeit/ui/notification_setting/notification_setting_page.dart';
import 'package:baeit/ui/review/review_detail_page.dart';
import 'package:baeit/ui/word_cloud/word_cloud_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationPage extends BlocStatefulWidget {
  final int type;
  final int detailType;
  final MyBaeitBloc? myBaeitBloc;

  NotificationPage({this.myBaeitBloc, this.type = 0, this.detailType = 0});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return NotificationState();
  }
}

class NotificationState extends BlocState<NotificationBloc, NotificationPage> {
  ScrollController? scrollController;
  ScrollController? keywordScrollController;

  pushImage(type) {
    switch (type) {
      case 'MANAGER_NOTIFICATION':
        return AppImages.iPushAds;
      case 'FEEDBACK':
        return AppImages.iPushFeedback;
      case 'MEMBER_STOP':
        return AppImages.iPushStop;
      case 'MEMBER_STOP_RELEASE':
        return AppImages.iPushHello;
      case 'CLASS_MADE_STOP':
        return AppImages.iPushStop;
      case 'CLASS_MADE_STOP_RELEASE':
        return AppImages.iPushHello;
      case 'CLASS_REQUEST_STOP':
        return AppImages.iPushStop;
      case 'CLASS_REQUEST_STOP_RELEASE':
        return AppImages.iPushHello;
      case 'CHEERING_DONE':
        return AppImages.iPushNotice;
      case 'NOTICE':
        return AppImages.iPushNotice;
      default:
        return AppImages.iPushAds;
    }
  }

  typeMovePage(type, idx) {
    switch (type) {
      case 'FEEDBACK':
        return pushTransition(
            context,
            FeedbackDetailPage(
                feedbackUuid: bloc.notification[idx].data['feedbackUuid']));
      case 'MEMBER_STOP':
        return;
      case 'MEMBER_STOP_RELEASE':
        return;
      case 'CLASS_MADE_STOP':
        ClassDetailPage classDetailPage = ClassDetailPage(
            profileGet: dataSaver.profileGet,
            classUuid: bloc.notification[idx].data['classUuid'],
            mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)],
            my: true);
        dataSaver.keywordClassDetail = classDetailPage;
        return pushTransition(context, classDetailPage);
      case 'CLASS_MADE_STOP_RELEASE':
        ClassDetailPage classDetailPage = ClassDetailPage(
            profileGet: dataSaver.profileGet,
            classUuid: bloc.notification[idx].data['classUuid'],
            mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)],
            my: true);
        dataSaver.keywordClassDetail = classDetailPage;
        return pushTransition(context, classDetailPage);
      case 'CHEERING_DONE':
        return;
      case 'NOTICE':
        return pushTransition(
            context,
            NoticeDetailPage(
                noticeUuid: bloc.notification[idx].data['noticeUuid']));
      case 'CRM_SSAM_MOTIVATION':
        return pushTransition(
            context, MyCreateClassPage(profile: dataSaver.profileGet));
      case 'ADD_CLASS_MADE_LIKE':
        amplitudeEvent(
            'social_history_click', {'classType': 'made', 'type': 'bookmark'});
        return pushTransition(
            context,
            ClassDetailPage(
              classUuid: bloc.notification[idx].data['classUuid'],
              mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)],
              profileGet: dataSaver.profileGet,
            ));
      case 'ADD_COMMUNITY_LIKE':
        amplitudeEvent('social_history_click',
            {'classType': 'community', 'type': 'bookmark'});
        return pushTransition(
            context,
            CommunityDetailPage(
                communityUuid: bloc.notification[idx].data['communityUuid']));
      case 'ADD_COMMUNITY_COMMENT':
        amplitudeEvent('social_history_click',
            {'classType': 'community', 'type': 'comment'});
        return pushTransition(
            context,
            CommunityDetailPage(
                communityUuid: bloc.notification[idx].data['communityUuid']));
      case 'ADD_COMMUNITY_REPLY_COMMENT':
        amplitudeEvent('social_history_click',
            {'classType': 'community', 'type': 'reply'});
        return pushTransition(
            context,
            CommunityDetailPage(
                communityUuid: bloc.notification[idx].data['communityUuid']));
      case 'CLASS_REVIEW_SAVE_ALARM':
        if (bloc.notification[idx].data['chatRoomUuid'] !=
            dataSaver.chatRoomUuid) {
          dataSaver.mainBloc!.add(MenuChangeEvent(select: 3));
          return pushTransition(
              context,
              ChatDetailPage(
                  chatRoomUuid: bloc.notification[idx].data['chatRoomUuid']));
        }
        return;
      case 'CLASS_REVIEW_SAVE':
        return pushTransition(
            context,
            ReviewDetailPage(
              classUuid: bloc.notification[idx].data['classUuid'],
              myClass: true,
            ));
      case 'CLASS_REVIEW_ANSWER_SAVE':
        return pushTransition(
            context,
            ReviewDetailPage(
              classUuid: bloc.notification[idx].data['classUuid'],
            ));
    }
  }

  notificationListItem(idx) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (bloc.type == 0) typeMovePage(bloc.notification[idx].type, idx);
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: bloc.notification[idx].readFlag == 0
                ? AppColors.primaryLight60
                : AppColors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bloc.notification[idx].largeIcon == null ||
                            bloc.notification[idx].largeIcon == ''
                        ? ClipOval(
                            child: Image.asset(
                              pushImage(bloc.notification[idx].type),
                              width: 40,
                              height: 40,
                            ),
                          )
                        : bloc.notification[idx].type.contains('ADD_CLASS')
                            ? Stack(
                                children: [
                                  bloc.notification[idx].type
                                          .contains('ADD_CLASS')
                                      ? ClipOval(
                                          child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  border: Border.all(
                                                      color:
                                                          AppColors.gray100))),
                                        )
                                      : Container(),
                                  Positioned(
                                    left: 4,
                                    right: 4,
                                    top: 4,
                                    bottom: 4,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(32),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        child: CacheImage(
                                          imageUrl:
                                              bloc.notification[idx].largeIcon,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          placeholder: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: AppColors.gray200,
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Image.asset(
                                              AppImages.dfClassMain,
                                              width: 32,
                                              height: 32,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ClipOval(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: CacheImage(
                                      imageUrl:
                                          bloc.notification[idx].largeIcon,
                                      width: MediaQuery.of(context).size.width,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                    spaceW(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customText(
                            bloc.notification[idx].title,
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T14)),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          bloc.notification[idx].body == ''
                              ? Container()
                              : spaceH(4),
                          bloc.notification[idx].body == ''
                              ? Container()
                              : customText(
                                  bloc.notification[idx].body,
                                  style: TextStyle(
                                      color: AppColors.gray600,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          spaceH(4),
                          customText(
                            DateTime.now()
                                        .difference(
                                            bloc.notification[idx].createDate)
                                        .inMinutes >
                                    14400
                                ? bloc.notification[idx].createDate.yearMonthDay
                                : timeCalculationText(DateTime.now()
                                    .difference(
                                        bloc.notification[idx].createDate)
                                    .inMinutes),
                            style: TextStyle(
                                color: AppColors.gray400,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12)),
                          ),
                          bloc.notification[idx].image == ''
                              ? Container()
                              : spaceH(8),
                          bloc.notification[idx].image == ''
                              ? Container()
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 180,
                                    child: CacheImage(
                                      imageUrl: bloc.notification[idx].image,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                    ),
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
        heightLine(height: 1)
      ],
    );
  }

  notificationList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return notificationListItem(idx);
      },
      shrinkWrap: true,
      itemCount: bloc.notification.length,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  notificationSelecter() {
    return Row(
      children: [
        spaceW(20),
        Expanded(
          child: Container(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                if (bloc.type != 0) {
                  bloc.add(NotificationTypeChangeEvent(type: 0));
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: bloc.type == 0 ? AppColors.primary : AppColors.white,
                  elevation: 0,
                  side: bloc.type == 1
                      ? BorderSide(color: AppColors.gray200)
                      : BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)))),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customText('배잇 알림',
                        style: TextStyle(
                            color: bloc.type == 0
                                ? AppColors.white
                                : AppColors.gray400,
                            fontWeight: weightSet(
                                textWeight: bloc.type == 0
                                    ? TextWeight.BOLD
                                    : TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T13))),
                    bloc.notificationUnReadCount == 0 ? Container() : spaceW(4),
                    bloc.notificationUnReadCount == 0
                        ? Container()
                        : Container(
                            height: 16,
                            padding:
                                EdgeInsets.only(left: 16 / 3, right: 16 / 3),
                            decoration: BoxDecoration(
                                color: bloc.type == 0
                                    ? AppColors.secondaryLight10
                                    : AppColors.primaryLight20,
                                borderRadius: BorderRadius.circular(16 / 6)),
                            child: Center(
                              child: customText(
                                  bloc.notificationUnReadCount.toString(),
                                  style: TextStyle(
                                      color: bloc.type == 1
                                          ? AppColors.white
                                          : AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T10))),
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                if (bloc.type != 1) {
                  bloc.add(NotificationTypeChangeEvent(type: 1));
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: bloc.type == 1 ? AppColors.primary : AppColors.white,
                  elevation: 0,
                  side: bloc.type == 0
                      ? BorderSide(color: AppColors.gray200)
                      : BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)))),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customText('키워드 알림',
                        style: TextStyle(
                            color: bloc.type == 1
                                ? AppColors.white
                                : AppColors.gray400,
                            fontWeight: weightSet(
                                textWeight: bloc.type == 1
                                    ? TextWeight.BOLD
                                    : TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T13))),
                    bloc.keywordUnReadCount == 0 ? Container() : spaceW(4),
                    bloc.keywordUnReadCount == 0
                        ? Container()
                        : Container(
                            height: 16,
                            padding:
                                EdgeInsets.only(left: 16 / 3, right: 16 / 3),
                            decoration: BoxDecoration(
                                color: bloc.type == 1
                                    ? AppColors.secondaryLight10
                                    : AppColors.primaryLight20,
                                borderRadius: BorderRadius.circular(16 / 6)),
                            child: Center(
                              child: customText(
                                  bloc.keywordUnReadCount.toString(),
                                  style: TextStyle(
                                      color: bloc.type == 0
                                          ? AppColors.white
                                          : AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T10))),
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
        spaceW(20)
      ],
    );
  }

  keywordView() {
    return Column(
      children: [
        keywordTop(),
        spaceH(10),
        bloc.selectKeywordType == 0
            ? bloc.keywordLearn != null &&
                    bloc.keywordLearn!.keyword.length != 0
                ? keywordContent()
                : keywordAlarmNone()
            : bloc.keywordTeach != null &&
                    bloc.keywordTeach!.keyword.length != 0
                ? keywordContent()
                : keywordAlarmNone()
      ],
    );
  }

  keywordAlarmNone() {
    return Column(
      children: [
        spaceH(50),
        Image.asset(
          AppImages.imgEmptyKeywords,
          height: 160,
        ),
        customText(
            bloc.selectKeywordType == 0
                ? '알림 받은 배우고 싶은 것이 아직 없어요'
                : '받은 알림이 아직 없어요',
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T15))),
        bloc.selectKeywordType == 0 ? spaceH(20) : Container(),
        bloc.selectKeywordType == 0
            ? Container(
                height: 48,
                child: IntrinsicWidth(
                  child: ElevatedButton(
                    onPressed: () {
                      amplitudeEvent(
                          'keyword_set_enter', {'inflow_page': 'notification'});
                      pushTransition(context, KeywordSettingPage());
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        side: BorderSide(width: 1, color: AppColors.primary)),
                    child: Center(
                      child: customText('다른 키워드 설정하기',
                          style: TextStyle(
                              color: AppColors.primaryDark10,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T15))),
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  keywordTop() {
    return Column(
      children: [
        Container(
          height: 48,
          child: Row(
            children: [
              spaceW(20),
              GestureDetector(
                onTap: () {
                  if (bloc.selectKeywordType != 0)
                    bloc.add(SelectKeywordTypeEvent(selectKeywordType: 0));
                },
                child: Container(
                  height: 36,
                  color: AppColors.white,
                  child: Center(
                    child: customText('배우고 싶은 것',
                        style: TextStyle(
                            color: bloc.selectKeywordType == 0
                                ? AppColors.gray900
                                : AppColors.gray500,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12))),
                  ),
                ),
              ),
              spaceW(8),
              Container(
                width: 1,
                height: 10,
                color: AppColors.gray300,
              ),
              spaceW(8),
              GestureDetector(
                onTap: () {
                  if (bloc.selectKeywordType != 1)
                    bloc.add(SelectKeywordTypeEvent(selectKeywordType: 1));
                },
                child: Container(
                  height: 36,
                  color: AppColors.white,
                  child: Center(
                    child: customText('알려주고 싶은 것',
                        style: TextStyle(
                            color: bloc.selectKeywordType == 1
                                ? AppColors.gray900
                                : AppColors.gray500,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12))),
                  ),
                ),
              ),
              Expanded(child: Container()),
              Container(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    amplitudeEvent(
                        'keyword_set_enter', {'inflow_page': 'notification'});
                    pushTransition(context, KeywordSettingPage());
                  },
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side:
                              BorderSide(color: AppColors.primary, width: 1))),
                  child: Center(
                    child: customText('키워드 설정',
                        style: TextStyle(
                            color: AppColors.primaryDark10,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T13))),
                  ),
                ),
              ),
              spaceW(20)
            ],
          ),
        ),
        spaceH(10),
        GestureDetector(
            onTap: () {
              dataSaver.bannerMoveEnable = false;
              amplitudeEvent('keyword_list_banner_open', {});
              pushTransition(context, WordCloudPage());
            },
            child: Stack(
              children: [
                Positioned.fill(
                    left: 0,
                    right: MediaQuery.of(context).size.width / 2,
                    child: Container(
                      color: AppColors.accentLight50,
                    )),
                Positioned.fill(
                    left: MediaQuery.of(context).size.width / 2,
                    right: 0,
                    child: Container(
                      color: AppColors.accentLight50,
                    )),
                Image.asset(
                  AppImages.bnrWordCloud,
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                ),
              ],
            )),
      ],
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

  keywordContent() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, idx) {
          List<Widget> keywordView = [];
          if ((bloc.selectKeywordType == 0
                      ? bloc.keywordLearn!
                      : bloc.keywordTeach!)
                  .keyword[idx]
                  .communityInfo !=
              null) {
            if ((bloc.selectKeywordType == 0
                        ? bloc.keywordLearn!
                        : bloc.keywordTeach!)
                    .keyword[idx]
                    .communityInfo!
                    .category ==
                'WITH_ME') {
              keywordView.add(RichText(
                text: TextSpan(
                  children: [
                    keywordTag(),
                    keywordText((bloc.selectKeywordType == 0
                            ? bloc.keywordLearn!
                            : bloc.keywordTeach!)
                        .keyword[idx]
                        .communityInfo!
                        .meetKeywordString)
                  ],
                ),
              ));
            } else {
              keywordView.add(RichText(
                text: TextSpan(
                  children: [
                    keywordTag(),
                    keywordText((bloc.selectKeywordType == 0
                            ? bloc.keywordLearn!
                            : bloc.keywordTeach!)
                        .keyword[idx]
                        .communityInfo!
                        .teachKeywordString)
                  ],
                ),
              ));
              keywordView.add(Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Image.asset(
                  AppImages.iSwitch,
                  width: 20,
                  height: 20,
                ),
              ));

              keywordView.add(RichText(
                text: TextSpan(
                  children: [
                    keywordTag(),
                    keywordText((bloc.selectKeywordType == 0
                            ? bloc.keywordLearn!
                            : bloc.keywordTeach!)
                        .keyword[idx]
                        .communityInfo!
                        .learnKeywordString)
                  ],
                ),
              ));
            }
          }

          return GestureDetector(
            onTap: () {
              if (bloc.selectKeywordType == 0) {
                if (bloc.keywordLearn!.keyword[idx].classInfo != null) {
                  ClassDetailPage classDetailPage = ClassDetailPage(
                    heroTag: 'listImage$idx',
                    classUuid:
                        bloc.keywordLearn!.keyword[idx].classInfo!.classUuid,
                    mainNeighborHood: dataSaver.neighborHood[
                        dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)],
                    bloc: bloc,
                    selectIndex: idx,
                    profileGet:
                        dataSaver.nonMember ? null : dataSaver.profileGet,
                    inputPage: 'main',
                  );
                  dataSaver.keywordClassDetail = classDetailPage;
                  pushTransition(context, classDetailPage);
                } else {
                  pushTransition(
                      context,
                      CommunityDetailPage(
                          communityUuid: bloc.keywordLearn!.keyword[idx]
                              .communityInfo!.communityUuid));
                }
              } else {
                if (bloc.keywordTeach!.keyword[idx].classInfo != null) {
                  ClassDetailPage classDetailPage = ClassDetailPage(
                    heroTag: 'listImage$idx',
                    classUuid:
                        bloc.keywordTeach!.keyword[idx].classInfo!.classUuid,
                    mainNeighborHood: dataSaver.neighborHood[
                        dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)],
                    bloc: bloc,
                    selectIndex: idx,
                    profileGet:
                        dataSaver.nonMember ? null : dataSaver.profileGet,
                    inputPage: 'main',
                  );
                  dataSaver.keywordClassDetail = classDetailPage;
                  pushTransition(context, classDetailPage);
                } else {
                  pushTransition(
                      context,
                      CommunityDetailPage(
                          communityUuid: bloc.keywordTeach!.keyword[idx]
                              .communityInfo!.communityUuid));
                }
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightLine(
                    height: 1,
                    color: (bloc.selectKeywordType == 0
                                    ? bloc.keywordLearn!
                                    : bloc.keywordTeach!)
                                .keyword[idx]
                                .classInfo !=
                            null
                        ? AppColors.accentLight40
                        : AppColors.primaryLight40),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 36,
                  color: (bloc.selectKeywordType == 0
                                  ? bloc.keywordLearn!
                                  : bloc.keywordTeach!)
                              .keyword[idx]
                              .classInfo !=
                          null
                      ? AppColors.accentLight60
                      : AppColors.primaryLight60,
                  child: Row(
                    children: [
                      spaceW(20),
                      Image.asset(
                        AppImages.iAlarmFull,
                        width: 14,
                        height: 14,
                        color: (bloc.selectKeywordType == 0
                                        ? bloc.keywordLearn!
                                        : bloc.keywordTeach!)
                                    .keyword[idx]
                                    .classInfo !=
                                null
                            ? AppColors.accent
                            : AppColors.primary,
                      ),
                      spaceW(4),
                      customText(
                          '${(bloc.selectKeywordType == 0 ? bloc.keywordLearn! : bloc.keywordTeach!).keyword[idx].keyword} - ${(bloc.selectKeywordType == 0 ? bloc.keywordLearn! : bloc.keywordTeach!).keyword[idx].eupmyeondongName} ${(bloc.selectKeywordType == 0 ? bloc.keywordLearn! : bloc.keywordTeach!).keyword[idx].classInfo != null ? '클래스' : (bloc.selectKeywordType == 0 ? bloc.keywordLearn! : bloc.keywordTeach!).keyword[idx].communityInfo?.category == 'EXCHANGE' ? '배움교환' : '배움모임'}',
                          style: TextStyle(
                              color: (bloc.selectKeywordType == 0
                                              ? bloc.keywordLearn!
                                              : bloc.keywordTeach!)
                                          .keyword[idx]
                                          .classInfo !=
                                      null
                                  ? AppColors.accent
                                  : AppColors.primary,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T12))),
                      Expanded(child: Container()),
                      customText(
                        DateTime.now()
                                    .difference((bloc.selectKeywordType == 0
                                            ? bloc.keywordLearn!
                                            : bloc.keywordTeach!)
                                        .keyword[idx]
                                        .createDate)
                                    .inMinutes >
                                14400
                            ? (bloc.selectKeywordType == 0
                                    ? bloc.keywordLearn!
                                    : bloc.keywordTeach!)
                                .keyword[idx]
                                .createDate
                                .yearMonthDay
                            : timeCalculationText(DateTime.now()
                                .difference((bloc.selectKeywordType == 0
                                        ? bloc.keywordLearn!
                                        : bloc.keywordTeach!)
                                    .keyword[idx]
                                    .createDate)
                                .inMinutes),
                        style: TextStyle(
                            color: (bloc.selectKeywordType == 0
                                            ? bloc.keywordLearn!
                                            : bloc.keywordTeach!)
                                        .keyword[idx]
                                        .classInfo !=
                                    null
                                ? AppColors.accent
                                : AppColors.primary,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                      ),
                      spaceW(20)
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  color: (bloc.selectKeywordType == 0
                                  ? bloc.keywordLearn!
                                  : bloc.keywordTeach!)
                              .keyword[idx]
                              .classInfo !=
                          null
                      ? (bloc.selectKeywordType == 0
                                      ? bloc.keywordLearn!
                                      : bloc.keywordTeach!)
                                  .keyword[idx]
                                  .readFlag ==
                              0
                          ? AppColors.accentLight60
                          : AppColors.white
                      : (bloc.selectKeywordType == 0
                                      ? bloc.keywordLearn!
                                      : bloc.keywordTeach!)
                                  .keyword[idx]
                                  .readFlag ==
                              0
                          ? AppColors.primaryLight60
                          : AppColors.white,
                  child: (bloc.selectKeywordType == 0
                                  ? bloc.keywordLearn!
                                  : bloc.keywordTeach!)
                              .keyword[idx]
                              .classInfo !=
                          null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 128,
                                height: 72,
                                child: CacheImage(
                                  imageUrl: (bloc.selectKeywordType == 0
                                          ? bloc.keywordLearn!
                                          : bloc.keywordTeach!)
                                      .keyword[idx]
                                      .classInfo!
                                      .image
                                      .toView(
                                          context: context,
                                          w: MediaQuery.of(context)
                                              .size
                                              .width
                                              .toInt()),
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            spaceW(16),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(children: [
                                      customTextSpan(
                                          text: (bloc.selectKeywordType == 0
                                                      ? bloc.keywordLearn!
                                                      : bloc.keywordTeach!)
                                                  .keyword[idx]
                                                  .classInfo!
                                                  .title +
                                              " ",
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T14))),
                                      customTextSpan(
                                          text: (bloc.selectKeywordType == 0
                                                  ? bloc.keywordLearn!
                                                  : bloc.keywordTeach!)
                                              .keyword[idx]
                                              .classInfo!
                                              .category!
                                              .name!,
                                          style: TextStyle(
                                              color: AppColors.gray500,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T11))),
                                    ]),
                                  ),
                                  spaceH(6),
                                  Row(
                                    children: [
                                      customText('시간당',
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12))),
                                      spaceW(2),
                                      customText(
                                          '${numberFormatter((bloc.selectKeywordType == 0 ? bloc.keywordLearn! : bloc.keywordTeach!).keyword[idx].classInfo!.minCost)}원 ~',
                                          style: TextStyle(
                                              color: AppColors.gray500,
                                              fontWeight: weightSet(
                                                  textWeight: TextWeight.BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T14)))
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: keywordView,
                              ),
                              spaceH(10),
                              customText(
                                  '${(bloc.selectKeywordType == 0 ? bloc.keywordLearn! : bloc.keywordTeach!).keyword[idx].communityInfo?.contentText}',
                                  style: TextStyle(
                                      color: AppColors.gray500,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12))),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
        shrinkWrap: true,
        itemCount: bloc.selectKeywordType == 0
            ? bloc.keywordLearn == null
                ? 0
                : bloc.keywordLearn!.keyword.length
            : bloc.keywordTeach == null
                ? 0
                : bloc.keywordTeach!.keyword.length);
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
                      title: '알림',
                      context: context,
                      onPressed: () {
                        pop(context);
                      },
                      action: IconButton(
                          onPressed: () {
                            amplitudeEvent('notification_set_enter',
                                {'inflow_page': 'notice_history'});
                            pushTransition(context, NotificationSettingPage());
                          },
                          icon: Image.asset(
                            AppImages.iSetting,
                            width: 24,
                            height: 24,
                          ))),
                  body: Column(
                    children: [
                      spaceH(10),
                      notificationSelecter(),
                      spaceH(10),
                      Expanded(
                        child: IndexedStack(
                          index: bloc.type,
                          children: [
                            bloc.notification.length == 0
                                ? Container()
                                : SingleChildScrollView(
                                    controller: scrollController,
                                    child: Column(
                                      children: [notificationList()],
                                    ),
                                  ),
                            SingleChildScrollView(
                              controller: keywordScrollController,
                              child: keywordView(),
                            )
                          ],
                        ),
                      ),
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
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        if (bloc.notification.length > 2) {
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
            bloc.add(GetDataEvent());
          }

          if (scrollController!.position.userScrollDirection ==
              ScrollDirection.forward) {
            bloc.bottomOffset = 0;
            bloc.scrollUnder = false;
          }
        }

        if (!bloc.keywordScrollUnder &&
            (bloc.keywordBottomOffset == 0 ||
                bloc.keywordBottomOffset < keywordScrollController!.offset) &&
            keywordScrollController!.offset >=
                keywordScrollController!.position.maxScrollExtent &&
            !keywordScrollController!.position.outOfRange) {
          bloc.keywordScrollUnder = true;
          bloc.keywordBottomOffset = keywordScrollController!.offset;
        }
        if (!bloc.keywordScrollUnder &&
            (bloc.keywordBottomOffset == 0 ||
                bloc.keywordBottomOffset < keywordScrollController!.offset) &&
            keywordScrollController!.offset >=
                (keywordScrollController!.position.maxScrollExtent * 0.7) &&
            !keywordScrollController!.position.outOfRange) {
          bloc.add(GetKeywordDataEvent());
        }

        if (keywordScrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.keywordBottomOffset = 0;
          bloc.keywordScrollUnder = false;
        }
      });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is NotificationInitState) {
      if (widget.myBaeitBloc != null)
        widget.myBaeitBloc!.add(UpdateDataEvent());
    }
  }

  @override
  NotificationBloc initBloc() {
    return NotificationBloc(context)
      ..add(NotificationInitEvent(
          type: widget.type, detailType: widget.detailType));
  }
}
