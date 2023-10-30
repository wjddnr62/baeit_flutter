import 'dart:io';
import 'dart:math' as math;

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/data/keyword/keyword.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/keyword_setting/keyword_setting_bloc.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/neighborhood_select/neighborhood_select_page.dart';
import 'package:baeit/ui/notification_setting/notification_setting_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_permissions/notification_permissions.dart';

import '../../resource/app_strings.dart';

class KeywordSettingPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return KeywordSettingState();
  }
}

class KeywordSettingState
    extends BlocState<KeywordSettingBloc, KeywordSettingPage> {
  List<FocusNode> keywordFocusMade = List.generate(10, (index) => FocusNode());
  List<bool> keywordTextCheckMade = List.generate(10, (index) => false);
  List<bool> keywordFocusCheckMade = List.generate(10, (index) => false);
  List<bool> keywordTextingCheckMade = List.generate(10, (index) => false);

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              color: AppColors.white,
              child: SafeArea(
                child: Stack(
                  children: [
                    Scaffold(
                      appBar: baseAppBar(
                          title: '키워드 설정',
                          context: context,
                          onPressed: () {
                            pop(context);
                          }),
                      backgroundColor: AppColors.white,
                      resizeToAvoidBottomInset: true,
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            Platform.isIOS &&
                                    bloc.permissionStatus !=
                                        'PermissionStatus.granted'
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                        top: 10,
                                        bottom: 10),
                                    child: iosNotification(),
                                  )
                                : Container(),
                            Container(
                              color: AppColors.accentLight60,
                              child: keywordSetting('MADE'),
                            ),
                            keywordNotice()
                          ],
                        ),
                      ),
                    ),
                    loadingView(bloc.loading)
                  ],
                ),
              ),
            ),
          );
        });
  }

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

  keywordNotice() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200, width: 1),
          boxShadow: [
            BoxShadow(
                color: AppColors.black.withOpacity(0.16),
                blurRadius: 6,
                offset: Offset(0, 0))
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              AppImages.iTipExclamationG,
              width: 24,
              height: 24,
            ),
            spaceH(10),
            customText('키워드를 추가하면 푸시 알림을 보내드려요 :)',
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T14))),
            spaceH(4),
            customText('언제든 알림 설정에서 해제할 수 있어요',
                style: TextStyle(
                    color: AppColors.gray500,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12))),
            spaceH(24),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  amplitudeEvent(
                      'notification_set_enter', {'type': 'keyword_set'});
                  pushTransition(context, NotificationSettingPage())
                      .then((value) {
                    bloc.add(KeywordSettingInitEvent(first: false));
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(width: 1, color: AppColors.primary)),
                  elevation: 0,
                ),
                child: Center(
                  child: customText('알림 설정 바로가기',
                      style: TextStyle(
                          color: AppColors.primaryDark10,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T13))),
                ),
              ),
            ),
            spaceH(10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  amplitudeEvent('town_set_enter', {'type': 'keyword_set'});
                  pushTransition(context, NeighborHoodSelectPage())
                      .then((value) {
                    bloc.add(KeywordSettingInitEvent(first: false));
                    if (value != null && value) {
                      dataSaver.learnBloc!.add(ReloadClassEvent());

                      if (dataSaver.learnBloc!.neighborhoodSelecterView) {
                        dataSaver.learnBloc!.neighborhoodSelecterAnimationEnd =
                            false;
                      }
                      dataSaver.learnBloc!.neighborhoodSelecterView = false;
                      dataSaver.learnBloc!.add(NeighborHoodChangeEvent(
                          index: dataSaver.neighborHood.indexWhere(
                              (element) => element.representativeFlag == 1)));
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(width: 1, color: AppColors.primary)),
                  elevation: 0,
                ),
                child: Center(
                  child: customText('동네 변경하러 가기',
                      style: TextStyle(
                          color: AppColors.primaryDark10,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T13))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  keywordSetting(String type) {
    List<Widget> keywords = [];
    for (int i = 0; i < 10; i++) {
      keywords.add(IntrinsicWidth(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: keywordTextCheckMade[i]
                  ? AppColors.accentLight50
                  : AppColors.white),
          child: DottedBorder(
            strokeWidth: keywordTextCheckMade[i]
                ? 1
                : keywordFocusCheckMade[i]
                    ? 2
                    : 0,
            dashPattern: keywordFocusCheckMade[i] ? [1, 0] : [5, 3],
            padding: EdgeInsets.only(left: 16, right: 11),
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: keywordTextCheckMade[i]
                ? AppColors.transparent
                : keywordFocusCheckMade[i]
                    ? AppColors.accentLight20
                    : AppColors.accentLight30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText('#',
                    style: TextStyle(
                        color: AppColors.accentLight30,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                Flexible(
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        if (value != '') {
                          setState(() {
                            keywordTextingCheckMade[i] = true;
                          });
                        } else {
                          if (keywordTextingCheckMade[i]) {
                            setState(() {
                              keywordTextingCheckMade[i] = false;
                            });
                          }
                        }
                      },
                      controller: bloc.keywordControllerMade[i],
                      focusNode: keywordFocusMade[i],
                      onFieldSubmitted: (value) {},
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: keywordTextCheckMade[i]
                              ? AppColors.accentDark10
                              : AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T14)),
                      maxLines: 1,
                      maxLength: 8,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          counterText: '',
                          hintText: keywordHint(i),
                          hintStyle: TextStyle(
                              color: AppColors.gray400,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(right: 12)),
                    ),
                  ),
                ),
                keywordTextCheckMade[i]
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              bloc.keywordControllerMade[i].text = '';
                              keywordTextCheckMade[i] = false;
                              keywordTextingCheckMade[i] = false;
                              bloc.add(KeywordRemoveEvent(
                                  memberClassKeywordUuid: bloc.uuidMade[i],
                                  index: i,
                                  type: 'MADE'));
                            });
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left: 1,
                                right: 1,
                                top: 1,
                                bottom: 1,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                              Image.asset(
                                AppImages.iInputClearTrans,
                                width: 20,
                                height: 20,
                                color: AppColors.accentLight20,
                              )
                            ],
                          ),
                        ),
                      )
                    : keywordFocusCheckMade[i]
                        ? keywordTextingCheckMade[i]
                            ? Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.accentDark10,
                                ),
                              )
                            : Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: Color(0xFF808080).withOpacity(0.8),
                                ),
                              )
                        : Image.asset(
                            AppImages.iEditUnderG,
                            width: 16,
                            height: 16,
                          )
              ],
            ),
          ),
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heightLine(height: 1, color: AppColors.accentLight40),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 35,
          color: AppColors.accentLight60,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Image.asset(
                AppImages.iAlarmFull,
                width: 14,
                height: 14,
                color: AppColors.accent,
              ),
              spaceW(4),
              customText('배우고 싶은 것',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T12))),
            ],
          ),
        ),
        spaceH(20),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: keywords,
          ),
        ),
        spaceH(4),
        dataSaver.classKeywordNotification != null &&
                dataSaver.classKeywordNotification!.keywords.length != 0
            ? spaceH(10)
            : Container(),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 48,
          color: AppColors.accentLight60,
          padding: EdgeInsets.only(left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: customText('알림 받을 동네',
                style: TextStyle(
                    color: AppColors.greenGray500,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T13)),
                textAlign: TextAlign.start),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: dataSaver.classKeywordNotification != null &&
                  dataSaver.classKeywordNotification!.areas.length != 0
              ? Wrap(
                  runSpacing: 6,
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: keywordNeighborhood(type),
                )
              : Container(),
        ),
        spaceH(30)
      ],
    );
  }

  keywordNeighborhood(type) {
    Keyword keyword = dataSaver.classKeywordNotification!;

    List<Widget> neighborhoodWidget = [];

    for (int i = 0; i < keyword.areas.length; i++) {
      neighborhoodWidget.add(GestureDetector(
        onTap: () {
          bloc.add(KeywordNotificationChangeEvent(
              index: i,
              memberAreaUuid: keyword.areas[i].memberAreaUuid,
              type: type,
              alarmFlag: keyword.areas[i].alarmFlag == 1 ? 0 : 1));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Positioned(
                  left: 2,
                  right: 2,
                  top: 2,
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: keyword.areas[i].alarmFlag == 1 ? true : false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                      side: BorderSide(width: 1, color: AppColors.gray200),
                      onChanged: (value) {
                        bloc.add(KeywordNotificationChangeEvent(
                            index: i,
                            memberAreaUuid: keyword.areas[i].memberAreaUuid,
                            type: type,
                            alarmFlag:
                                keyword.areas[i].alarmFlag == 1 ? 0 : 1));
                      },
                      activeColor: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            spaceW(8),
            customText(keyword.areas[i].eupmyeondongName,
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T13)))
          ],
        ),
      ));
    }

    return neighborhoodWidget;
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is KeywordLoadState) {
      if (state.type == 'MADE') {
        for (int i = 0;
            i < dataSaver.classKeywordNotification!.keywords.length;
            i++) {
          keywordTextCheckMade[i] = true;
        }
      }
    }
  }

  @override
  void initState() {
    for (int i = 0; i < 10; i++) {
      keywordFocusMade[i].addListener(() {
        if (!keywordFocusMade[i].hasFocus) {
          keywordFocusCheckMade[i] = false;
          bloc.add(KeywordSetEvent());
          if (bloc.keywordControllerMade[i].text != '') {
            keywordTextCheckMade[i] = true;
            bloc.add(KeywordAddEvent(
                type: 'MADE',
                keyword: bloc.keywordControllerMade[i].text,
                idx: i));
          } else {
            keywordTextCheckMade[i] = false;
            bloc.add(KeywordRemoveEvent(
                memberClassKeywordUuid: bloc.uuidMade[i],
                index: i,
                type: 'MADE'));
          }
          bloc.add(KeywordSetEvent());
        } else {
          keywordFocusCheckMade[i] = true;
          bloc.add(KeywordSetEvent());
        }
      });
    }

    super.initState();
  }

  @override
  KeywordSettingBloc initBloc() {
    return KeywordSettingBloc(context)..add(KeywordSettingInitEvent());
  }
}
