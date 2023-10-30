import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/notification_setting/notification_setting_bloc.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:notification_permissions/notification_permissions.dart';

class NotificationSettingPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return NotificationSettingState();
  }
}

class NotificationSettingState
    extends BlocState<NotificationSettingBloc, NotificationSettingPage> {
  iosNotification() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 98,
      decoration: BoxDecoration(
          color: AppColors.primaryLight60,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                AppStrings.of(StringKey.iosPushAllow),
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              ),
              spaceH(4),
              customText(
                AppStrings.of(StringKey.disallowNoPush),
                style: TextStyle(
                    color: AppColors.greenGray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              )
            ],
          ),
          Expanded(child: Container()),
          Container(
            width: 72,
            height: 42,
            child: ElevatedButton(
              onPressed: () async {
                bloc.permission =
                    NotificationPermissions.requestNotificationPermissions(
                            openSettings: true)
                        .then((value) {
                  return value;
                });
                await bloc.permission.then((value) {
                  bloc.permissionStatus = value.toString();
                });

                if (bloc.permissionStatus == 'PermissionStatus.granted') {
                  identifyAdd('push_ios_allowed', true);
                  PushConfig().initializeLocalNotification();
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: AppColors.primary,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: Center(
                child: customText(
                  AppStrings.of(StringKey.allow),
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T14)),
                ),
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
                      title: AppStrings.of(StringKey.notificationSetting),
                      context: context,
                      onPressed: () {
                        pop(context);
                      }),
                  body: bloc.setting == null
                      ? Container()
                      : Column(
                          children: [
                            Platform.isIOS &&
                                    bloc.permissionStatus !=
                                        'PermissionStatus.granted'
                                ? spaceH(10)
                                : Container(),
                            Platform.isIOS &&
                                    bloc.permissionStatus !=
                                        'PermissionStatus.granted'
                                ? iosNotification()
                                : Container(),
                            spaceH(10),
                            Container(
                              height: 81,
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customText(
                                        '마케팅 정보 수신동의',
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14)),
                                      ),
                                      spaceH(4),
                                      customText(
                                        '마케팅 정보 수신 ${bloc.marketing ? '동의' : '거부'} ${bloc.setting!.marketingReceptionDate.yearMonthDay}',
                                        style: TextStyle(
                                            color: AppColors.gray400,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12)),
                                      )
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  FlutterSwitch(
                                    width: 46,
                                    height: 24,
                                    onToggle: (value) {
                                      bloc.marketing = value;
                                      bloc.add(ChangeSettingEvent());
                                    },
                                    padding: 2,
                                    borderRadius: 49,
                                    duration: Duration(milliseconds: 100),
                                    activeColor: AppColors.accent,
                                    inactiveColor: AppColors.gray100,
                                    value: bloc.marketing,
                                    toggleSize: 20,
                                    inactiveIcon: ClipOval(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
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
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 81,
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customText(
                                        '채팅 알림',
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14)),
                                      ),
                                      spaceH(4),
                                      customText(
                                        '채팅방 내에서 개별 설정 가능',
                                        style: TextStyle(
                                            color: AppColors.gray400,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12)),
                                      )
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  FlutterSwitch(
                                    width: 46,
                                    height: 24,
                                    onToggle: (value) {
                                      bloc.chatting = value;
                                      bloc.add(ChangeSettingEvent());
                                    },
                                    padding: 2,
                                    borderRadius: 49,
                                    duration: Duration(milliseconds: 100),
                                    activeColor: AppColors.accent,
                                    inactiveColor: AppColors.gray100,
                                    value: bloc.chatting,
                                    toggleSize: 20,
                                    inactiveIcon: ClipOval(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
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
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customText('키워드 알림',
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T14))),
                                      spaceH(4),
                                      customText('키워드에 맞는 클래스,커뮤니티 글 등록 시 알림',
                                          style: TextStyle(
                                              color: AppColors.gray400,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12))),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  FlutterSwitch(
                                    width: 46,
                                    height: 24,
                                    onToggle: (value) {
                                      bloc.keywordClass = value;
                                      bloc.add(ChangeSettingEvent());
                                    },
                                    padding: 2,
                                    borderRadius: 49,
                                    duration: Duration(milliseconds: 100),
                                    activeColor: AppColors.accent,
                                    inactiveColor: AppColors.gray100,
                                    value: bloc.keywordClass,
                                    toggleSize: 20,
                                    inactiveIcon: ClipOval(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
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
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      customText('댓글 알림',
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                  TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T14))),
                                      spaceH(4),
                                      customText('커뮤니티 댓글 등록 시 알림',
                                          style: TextStyle(
                                              color: AppColors.gray400,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                  TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12))),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  FlutterSwitch(
                                    width: 46,
                                    height: 24,
                                    onToggle: (value) {
                                      bloc.communityComment = value;
                                      bloc.add(ChangeSettingEvent());
                                    },
                                    padding: 2,
                                    borderRadius: 49,
                                    duration: Duration(milliseconds: 100),
                                    activeColor: AppColors.accent,
                                    inactiveColor: AppColors.gray100,
                                    value: bloc.communityComment,
                                    toggleSize: 20,
                                    inactiveIcon: ClipOval(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
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
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            spaceH(10),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: heightLine(height: 1),
                            ),
                            spaceH(10),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 98,
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customText(
                                        '방해 금지 시간',
                                        style: TextStyle(
                                            color: AppColors.secondaryDark30,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14)),
                                      ),
                                      spaceH(4),
                                      customText(
                                        '오후 9시 ~ 오전 8시에는 모든 알림 받지 않을게요',
                                        style: TextStyle(
                                            color: AppColors.gray600,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12)),
                                      ),
                                      customText(
                                        '(단, 알림내역, 채팅 내역에서는 확인 가능)',
                                        style: TextStyle(
                                            color: AppColors.gray400,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12)),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  FlutterSwitch(
                                    width: 46,
                                    height: 24,
                                    onToggle: (value) {
                                      bloc.prohibit = value;
                                      bloc.add(ChangeSettingEvent());
                                    },
                                    padding: 2,
                                    borderRadius: 49,
                                    duration: Duration(milliseconds: 100),
                                    activeColor: AppColors.secondaryDark30,
                                    inactiveColor: AppColors.gray100,
                                    value: bloc.prohibit,
                                    toggleSize: 20,
                                    inactiveIcon: ClipOval(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
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
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2))
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
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
  blocListener(BuildContext context, state) {}

  @override
  void initState() {
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        bloc.permission =
            NotificationPermissions.getNotificationPermissionStatus();
        await bloc.permission.then((value) {
          bloc.permissionStatus = value.toString();
        });
        if (bloc.permissionStatus == 'PermissionStatus.granted') {
          PushConfig().initializeLocalNotification();
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  NotificationSettingBloc initBloc() {
    return NotificationSettingBloc(context)
      ..add(NotificationSettingInitEvent());
  }
}
