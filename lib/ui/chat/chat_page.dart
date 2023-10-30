import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/chat/chat_bloc.dart';
import 'package:baeit/ui/chat/chat_detail_page.dart';
import 'package:baeit/ui/signup/signup_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ChatState();
  }
}

class ChatState extends BlocState<ChatBloc, ChatPage> {
  chatList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return dataSaver.chatRoom!.roomData[idx].lastMessage == null
            ? Container()
            : GestureDetector(
                onTap: () {
                  // if (!stompClient.connected) {
                  //   showToast(context: context, text: '네트워크 연결을 확인해주세요');
                  // } else {
                  amplitudeEvent('chat_room_click', {
                    'type': dataSaver.chatRoom!.roomData[idx].classInfo == null
                        ? ''
                        : dataSaver.chatRoom!.roomData[idx].classInfo!.type
                                    .toUpperCase() ==
                                'MADE'
                            ? 'class'
                            : 'request',
                    'user_name': dataSaver.profileGet!.nickName,
                    'user_id': dataSaver.profileGet!.memberUuid,
                    'other_user_name':
                        dataSaver.chatRoom!.roomData[idx].chatRoomMember == null
                            ? ''
                            : dataSaver.chatRoom!.roomData[idx].chatRoomMember!
                                .nickName!,
                    'other_user_id':
                        dataSaver.chatRoom!.roomData[idx].chatRoomMember == null
                            ? ''
                            : dataSaver.chatRoom!.roomData[idx].chatRoomMember!
                                .memberUuid
                  });
                  pushTransition(
                      context,
                      ChatDetailPage(
                        chatRoomUuid:
                            dataSaver.chatRoom!.roomData[idx].chatRoomUuid,
                      )).then((value) {
                    bloc.firstChat = false;
                    setState(() {});
                  });
                  // }
                },
                child: Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      Stack(children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          border: Border.all(
                                              color: AppColors.gray200)),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          child: (dataSaver
                                                          .chatRoom!
                                                          .roomData[idx]
                                                          .chatRoomMember ==
                                                      null ||
                                                  dataSaver
                                                          .chatRoom!
                                                          .roomData[idx]
                                                          .chatRoomMember!
                                                          .profile ==
                                                      null)
                                              ? Image.asset(
                                                  AppImages.dfProfile,
                                                  width: 32,
                                                  height: 32,
                                                )
                                              : Container(
                                                  width: 32,
                                                  height: 32,
                                                  child: CacheImage(
                                                    imageUrl: dataSaver
                                                        .chatRoom!
                                                        .roomData[idx]
                                                        .chatRoomMember!
                                                        .profile! + "?w=${MediaQuery.of(context).size.width.toInt()}",
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  spaceW(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            customText(
                                              dataSaver.chatRoom!.roomData[idx]
                                                          .chatRoomMember ==
                                                      null
                                                  ? ''
                                                  : dataSaver
                                                          .chatRoom!
                                                          .roomData[idx]
                                                          .chatRoomMember!
                                                          .nickName ??
                                                      '',
                                              style: TextStyle(
                                                  color: AppColors.gray900,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.BOLD),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T14)),
                                            ),
                                            spaceW(4),
                                            dataSaver.chatRoom!.roomData[idx]
                                                        .noticeReceiveFlag ==
                                                    0
                                                ? Image.asset(
                                                    AppImages.iAlarmKillG,
                                                    width: 12,
                                                    height: 12,
                                                  )
                                                : Container(),
                                            Flexible(child: Container()),
                                            customText(
                                              DateTime.now()
                                                          .difference(dataSaver
                                                              .chatRoom!
                                                              .roomData[idx]
                                                              .lastMessageDate)
                                                          .inMinutes >
                                                      14400
                                                  ? dataSaver
                                                      .chatRoom!
                                                      .roomData[idx]
                                                      .lastMessageDate
                                                      .yearMonthDay
                                                  : timeCalculationText(
                                                      DateTime.now()
                                                          .difference(dataSaver
                                                              .chatRoom!
                                                              .roomData[idx]
                                                              .lastMessageDate)
                                                          .inMinutes),
                                              style: TextStyle(
                                                  color: AppColors.gray400,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T10)),
                                            )
                                          ],
                                        ),
                                        spaceH(5),
                                        customText(
                                          dataSaver.chatRoom!.roomData[idx]
                                              .lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: AppColors.gray700,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              spaceH(20),
                              dataSaver.chatRoom!.roomData[idx].communityInfo ==
                                      null
                                  ? Container()
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: customText(
                                            '${dataSaver.chatRoom!.roomData[idx].communityInfo!.contentText.length > 14 ? dataSaver.chatRoom!.roomData[idx].communityInfo!.contentText.substring(0, 14) : dataSaver.chatRoom!.roomData[idx].communityInfo!.contentText}\u00B7${dataSaver.chatRoom!.roomData[idx].communityInfo!.hangNames}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: AppColors.gray400,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.MEDIUM),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T10)),
                                          ),
                                        ),
                                      ],
                                    ),
                              dataSaver.chatRoom!.roomData[idx].classInfo ==
                                      null
                                  ? Container()
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: customText(
                                            '${dataSaver.chatRoom!.roomData[idx].classInfo!.title}\u00B7${dataSaver.chatRoom!.roomData[idx].classInfo!.hangNames}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: AppColors.gray400,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.MEDIUM),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T10)),
                                          ),
                                        ),
                                        dataSaver.chatRoom!.roomData[idx]
                                                        .classInfo!.image ==
                                                    null ||
                                                dataSaver
                                                        .chatRoom!
                                                        .roomData[idx]
                                                        .classInfo!
                                                        .type ==
                                                    'REQUEST'
                                            ? Container()
                                            : spaceW(8),
                                        dataSaver.chatRoom!.roomData[idx]
                                                        .classInfo!.image ==
                                                    null ||
                                                dataSaver
                                                        .chatRoom!
                                                        .roomData[idx]
                                                        .classInfo!
                                                        .type ==
                                                    'REQUEST'
                                            ? Container()
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(3.3),
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  child: CacheImage(
                                                    imageUrl:
                                                        '${dataSaver.chatRoom!.roomData[idx].classInfo!.image!.toView(context: context, )}',
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                      ],
                                    )
                            ],
                          ),
                        ),
                        dataSaver.chatRoom!.roomData[idx].unreadCnt < 1
                            ? Container()
                            : Positioned(
                                top: 18,
                                left: 44,
                                child: Container(
                                  height: 16,
                                  constraints: BoxConstraints(minWidth: 16),
                                  padding: EdgeInsets.only(left: 4, right: 4),
                                  decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(18)),
                                  child: Center(
                                    child: customText(
                                      dataSaver.chatRoom!.roomData[idx]
                                                  .unreadCnt >
                                              99
                                          ? '99+'
                                          : dataSaver
                                              .chatRoom!.roomData[idx].unreadCnt
                                              .toString(),
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.BOLD),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T10)),
                                    ),
                                  ),
                                ))
                      ]),
                      dataSaver.chatRoom!.roomData.length - 1 == idx
                          ? Container()
                          : heightLine(height: 1)
                    ],
                  ),
                ),
              );
      },
      shrinkWrap: true,
      itemCount:
          dataSaver.chatRoom == null ? 0 : dataSaver.chatRoom!.roomData.length,
    );
  }

  introChat() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              120 +
              AppBar().preferredSize.height +
              MediaQuery.of(context).padding.bottom),
      child: Padding(
        padding: EdgeInsets.only(left: 48, right: 48),
        child: Column(
          children: [
            spaceH(MediaQuery.of(context).size.height / 7),
            Container(
              height: dataSaver.nonMember ? 240 : 294,
              decoration: BoxDecoration(
                  color: AppColors.secondaryLight40,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 0),
              child: Stack(
                children: [
                  AnimatedPositioned(
                      top: bloc.firstChat ? 30 : 60,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                          onEnd: () {
                            bloc.secondChat = true;
                            setState(() {});
                          },
                          duration: Duration(milliseconds: 1000),
                          opacity: bloc.firstChat ? 1 : 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              spaceW(296 * 0.06),
                              customText(
                                '10:09',
                                style: TextStyle(
                                    color: AppColors.gray600,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)),
                              ),
                              spaceW(4),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 12, right: 12, top: 8, bottom: 8),
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryLight50,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: customText(
                                    dataSaver.nonMember
                                        ? bloc.nonMemberChatData[0]
                                        : bloc.firstChatData[bloc.chatData],
                                    style: TextStyle(
                                        color: AppColors.primaryDark10,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14)),
                                  ),
                                ),
                              )
                            ],
                          )),
                      duration: Duration(milliseconds: 1000)),
                  AnimatedPositioned(
                      top: bloc.secondChat ? 112 : 142,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                          onEnd: () {
                            bloc.thirdChat = true;
                            setState(() {});
                          },
                          duration: Duration(milliseconds: 1000),
                          opacity: bloc.secondChat ? 1 : 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              dataSaver.nonMember
                                  ? Image.asset(
                                      AppImages.dfProfile,
                                      width: 32,
                                      height: 32,
                                    )
                                  : Container(),
                              dataSaver.nonMember ? spaceW(10) : Container(),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 12, right: 12, top: 8, bottom: 8),
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: AppColors.gray200)),
                                  child: customText(
                                    dataSaver.nonMember
                                        ? bloc.nonMemberChatData[1]
                                        : bloc.secondChatData[bloc.chatData],
                                    style: TextStyle(
                                        color: AppColors.gray600,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14)),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              spaceW(4),
                              customText(
                                '10:09',
                                style: TextStyle(
                                    color: AppColors.gray600,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)),
                              ),
                              spaceW(296 * 0.06),
                            ],
                          )),
                      duration: Duration(milliseconds: 1000)),
                  AnimatedPositioned(
                      top: dataSaver.nonMember
                          ? bloc.thirdChat
                              ? 176
                              : 206
                          : bloc.thirdChat
                              ? 212
                              : 242,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                          duration: Duration(milliseconds: 1000),
                          opacity: bloc.thirdChat ? 1 : 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              spaceW(296 * 0.06),
                              customText(
                                '10:09',
                                style: TextStyle(
                                    color: AppColors.gray600,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)),
                              ),
                              spaceW(4),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 12, right: 12, top: 8, bottom: 8),
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryLight50,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: customText(
                                    dataSaver.nonMember
                                        ? bloc.nonMemberChatData[2]
                                        : bloc.thirdChatData[bloc.chatData],
                                    style: TextStyle(
                                        color: AppColors.primaryDark10,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14)),
                                  ),
                                ),
                              )
                            ],
                          )),
                      duration: Duration(milliseconds: 1000))
                ],
              ),
            ),
            spaceH(8),
            customText(
              dataSaver.nonMember ? '지금 로그인해서 동네 이웃을 만나보세요!' : '이웃과 대화해보세요!',
              style: TextStyle(
                  color: AppColors.secondaryDark30,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T12)),
            ),
            dataSaver.nonMember ? spaceH(48) : Container(),
            dataSaver.nonMember
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 54,
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
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
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
                  )
                : Container(),
            Flexible(child: Container())
          ],
        ),
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
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: AppColors.white,
                  appBar: baseAppBar(
                    title: AppStrings.of(StringKey.chat),
                    context: context,
                    onPressed: () {},
                    action: Container(),
                    close: true,
                  ),
                  body: SingleChildScrollView(
                    child: dataSaver.chatRoom == null ||
                            dataSaver.chatRoom!.roomData.length == 0
                        ? introChat()
                        : Column(
                            children: [chatList()],
                          ),
                  ),
                ),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
  }

  bool check = false;

  @override
  blocListener(BuildContext context, state) {
    if (state is ChatInitState) {
      dataSaver.chatBloc = bloc;
      if (dataSaver.chatBloc != null && !check) {
        check = true;
        bloc.add(GetRoomDataEvent());
      }
    }

    if (state is ChatReloadState) {
      bloc.add(AnimationStartEvent());
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  ChatBloc initBloc() {
    return ChatBloc(context)..add(ChatInitEvent());
  }
}
