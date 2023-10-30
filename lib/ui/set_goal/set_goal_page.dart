import 'dart:math' as math;

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/profile/goal.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/main/main_page.dart';
import 'package:baeit/ui/neighborhood_add_intro/neighborhood_add_intro_page.dart';
import 'package:baeit/ui/set_goal/set_goal_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_tooltip.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetGoalPage extends BlocStatefulWidget {
  final bool sign;

  SetGoalPage({this.sign = true});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return SetGoalPageState();
  }
}

class SetGoalPageState extends BlocState<SetGoalBloc, SetGoalPage> {
  ScrollController scrollController = ScrollController();

  List<String> activityText = [
    '선택해주세요',
    '생각없어요',
    '한 번 해볼래요',
    '가끔 해볼래요',
    '자주 할 거에요'
  ];

  TextEditingController learnController = TextEditingController();
  TextEditingController teachingController = TextEditingController();

  FocusNode learnFocus = FocusNode();
  FocusNode teachingFocus = FocusNode();

  bool activityStudentPass = true;
  bool activityTeachingPass = true;
  bool learnPass = true;
  bool learnLengthPass = true;
  bool teachingPass = true;
  bool teachingLengthPass = true;

  bool learnEvent = false;
  bool teachingEvent = false;

  bool move = false;

  List<FocusNode> keywordFocusMade = List.generate(5, (index) => FocusNode());
  List<bool> keywordTextCheckMade = List.generate(5, (index) => false);
  List<bool> keywordFocusCheckMade = List.generate(5, (index) => false);
  List<bool> keywordTextingCheckMade = List.generate(5, (index) => false);

  List<FocusNode> keywordFocusRequest =
      List.generate(5, (index) => FocusNode());
  List<bool> keywordTextCheckRequest = List.generate(5, (index) => false);
  List<bool> keywordFocusCheckRequest = List.generate(5, (index) => false);
  List<bool> keywordTextingCheckRequest = List.generate(5, (index) => false);

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
                      resizeToAvoidBottomInset: true,
                      backgroundColor: AppColors.white,
                      body: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 60 +
                                  MediaQuery.of(context).padding.bottom +
                                  60,
                              child: SingleChildScrollView(
                                controller: scrollController,
                                physics: ClampingScrollPhysics(),
                                child: Column(
                                  children: [
                                    spaceH(80),
                                    title(),
                                    spaceH(60),
                                    activity(),
                                    spaceH((activityStudentPass &&
                                            activityTeachingPass)
                                        ? 34
                                        : 10),
                                    Container(
                                      height: 144,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          customText('키워드를 추가해주세요',
                                              style: TextStyle(
                                                  color: AppColors.gray900,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T20))),
                                          spaceH(8),
                                          customText(
                                              '관련 글이 등록되면, 푸시알림을 드려요\n(알림설정에서 변경 가능)',
                                              style: TextStyle(
                                                  color: AppColors.gray600,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.REGULAR),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T14)),
                                              textAlign: TextAlign.center)
                                        ],
                                      ),
                                    ),
                                    whatWant('STUDENT'),
                                    spaceH(learnPass ? 34 : 10),
                                    whatWant('TEACHER'),
                                    spaceH(teachingPass ? 52 : 28)
                                  ],
                                ),
                              )),
                          Positioned(
                              bottom: 60 + 60,
                              child: bottomGradient(
                                  context: context,
                                  height: 20,
                                  color: AppColors.white)),
                          Positioned(
                            bottom: 12 + 60,
                            left: 12,
                            right: 12,
                            child: bottomButton(
                                context: context,
                                text: '저장',
                                onPress: saveGoal),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              color: AppColors.white,
                              child: Center(
                                child: GestureDetector(
                                  onTap: skip,
                                  child: customText(
                                    '건너뛰기',
                                    style: TextStyle(
                                        color: AppColors.gray600,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize:
                                            fontSizeSet(textSize: TextSize.T12),
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
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

  skip() {
    Goal goal = Goal(
        ssamType: 'GOAL_4',
        studentType: 'GOAL_4',
        ssamKeywords: bloc.saveTeachingKeyword,
        studentKeywords: bloc.saveLearnKeyword);

    amplitudeEvent('set_goal_skip', goal.toMap());

    bloc.add(SkipGoalEvent(goal: goal));
  }

  saveGoal() {
    setState(() {
      move = false;
      if (bloc.activityStudentIndex == 0 || bloc.activityTeacherIndex == 0) {
        if (bloc.activityStudentIndex == 0) {
          activityStudentPass = false;
        }
        if (bloc.activityTeacherIndex == 0) {
          activityTeachingPass = false;
        }
        scrollController.animateTo(
            scrollController.position.minScrollExtent + 30,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut);
        return;
      }

      if ((bloc.activityStudentIndex != 0 && bloc.activityStudentIndex != 1)) {
        learnPass = false;
        for (int i = 0; i < bloc.keywordControllerMade.length; i++) {
          if (bloc.keywordControllerMade[i].text != '') {
            learnPass = true;
            break;
          }
        }
        if (!learnPass && !move) {
          move = true;
          FocusScope.of(context).requestFocus(keywordFocusMade[0]);
          Future.delayed(Duration(milliseconds: 500), () {
            scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 100),
                curve: Curves.ease);
          });
        }
      }

      if ((bloc.activityTeacherIndex != 0 && bloc.activityTeacherIndex != 1)) {
        teachingPass = false;
        for (int i = 0; i < bloc.keywordControllerRequest.length; i++) {
          if (bloc.keywordControllerRequest[i].text != '') {
            teachingPass = true;
            break;
          }
        }
        if (!teachingPass && !move) {
          move = true;
          FocusScope.of(context).requestFocus(keywordFocusRequest[0]);
          Future.delayed(Duration(milliseconds: 500), () {
            scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 100),
                curve: Curves.ease);
          });
        }
      }
    });

    if (activityStudentPass &&
        activityTeachingPass &&
        learnPass &&
        teachingPass) {
      List<String> keywordStudent = [];
      for (int i = 0; i < bloc.keywordControllerMade.length; i++) {
        if (bloc.keywordControllerMade[i].text != '') {
          keywordStudent.add(bloc.keywordControllerMade[i].text);
        }
      }

      List<String> keywordTeaching = [];
      for (int i = 0; i < bloc.keywordControllerRequest.length; i++) {
        if (bloc.keywordControllerRequest[i].text != '') {
          keywordTeaching.add(bloc.keywordControllerRequest[i].text);
        }
      }
      Goal goal = Goal(
          ssamType: teacherType(bloc.activityTeacherIndex),
          studentType: studentType(bloc.activityStudentIndex),
          ssamKeywords: keywordTeaching,
          studentKeywords: keywordStudent);

      amplitudeEvent('set_goal_save', goal.toMap());

      bloc.add(SaveGoalEvent(goal: goal));
    }
  }

  teacherType(int index) {
    switch (index) {
      case 1:
        return 'GOAL_0';
      case 2:
        return 'GOAL_1';
      case 3:
        return 'GOAL_2';
      case 4:
        return 'GOAL_3';
    }
  }

  studentType(int index) {
    switch (index) {
      case 1:
        return 'GOAL_0';
      case 2:
        return 'GOAL_1';
      case 3:
        return 'GOAL_2';
      case 4:
        return 'GOAL_3';
    }
  }

  title() {
    return Column(
      children: [
        customText('어떤 활동을 원하시나요?',
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T20))),
        spaceH(8),
        customText('(최초 1회 설정)',
            style: TextStyle(
                color: AppColors.gray600,
                fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
            textAlign: TextAlign.center)
      ],
    );
  }

  activity() {
    return Column(
      children: [
        Row(
          children: [
            spaceW(20),
            Expanded(
              child: Column(
                children: [
                  customText('학생활동',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T14))),
                  spaceH(14),
                  activitySelect('STUDENT')
                ],
              ),
            ),
            spaceW(20),
            Expanded(
              child: Column(
                children: [
                  customText('쌤활동',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T14))),
                  spaceH(14),
                  activitySelect('TEACHER')
                ],
              ),
            ),
            spaceW(20)
          ],
        ),
        (activityStudentPass && activityTeachingPass)
            ? Container()
            : Padding(
                padding: EdgeInsets.only(left: 20, bottom: 10),
                child: issueMessage(title: '활동 목표를 설정해주세요'),
              ),
      ],
    );
  }

  activitySelect(String type) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: type == 'STUDENT'
                  ? !activityStudentPass
                      ? AppColors.error
                      : AppColors.primaryLight40
                  : !activityTeachingPass
                      ? AppColors.error
                      : AppColors.accentLight40,
              width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: CarouselSlider(
        options: CarouselOptions(
            height: 130,
            initialPage: type == 'STUDENT'
                ? bloc.activityStudentIndex
                : bloc.activityTeacherIndex,
            onPageChanged: (idx, _) {
              if (type == 'STUDENT') {
                activityStudentPass = true;
                if (idx == 1) {
                  learnPass = true;
                }
              } else if (type == 'TEACHER') {
                activityTeachingPass = true;
                if (idx == 1) {
                  teachingPass = true;
                }
              }
              bloc.add(SetActivityEvent(
                  index: idx, type: type, selectValue: activityText[idx]));
            },
            scrollDirection: Axis.vertical,
            viewportFraction: 0.35,
            enableInfiniteScroll: false,
            aspectRatio: 1.0,
            enlargeCenterPage: true),
        items: [0, 1, 2, 3, 4].map((e) {
          return Builder(
            builder: (context) {
              return Stack(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 48,
                      color: e == 0
                          ? AppColors.transparent
                          : (type == 'STUDENT'
                                      ? bloc.activityStudentIndex
                                      : bloc.activityTeacherIndex) ==
                                  e
                              ? type == 'STUDENT'
                                  ? AppColors.primaryLight60
                                  : AppColors.accentLight60
                              : AppColors.white,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customText(
                            activityText[e],
                            style: TextStyle(
                                color: e == 0
                                    ? type == 'STUDENT'
                                        ? activityStudentPass
                                            ? AppColors.greenGray400
                                            : AppColors.greenGray900
                                        : activityTeachingPass
                                            ? AppColors.greenGray400
                                            : AppColors.greenGray900
                                    : type == 'STUDENT'
                                        ? AppColors.primary
                                        : AppColors.accent,
                                fontWeight: weightSet(
                                    textWeight: e == 0
                                        ? TextWeight.MEDIUM
                                        : TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T14)),
                          ),
                        ],
                      ))),
                  (type == 'STUDENT'
                              ? bloc.activityStudentIndex
                              : bloc.activityTeacherIndex) !=
                          e
                      ? Container(
                          height: 48,
                          color: AppColors.white.withOpacity(0.3),
                        )
                      : Container(),
                  (type == 'STUDENT'
                              ? bloc.activityStudentIndex
                              : bloc.activityTeacherIndex) ==
                          e
                      ? Positioned(
                          top: 0,
                          left: 10,
                          right: 10,
                          child: heightLine(
                              color: type == 'STUDENT'
                                  ? AppColors.primary
                                  : AppColors.accent,
                              height: 1),
                        )
                      : Container(),
                  (type == 'STUDENT'
                              ? bloc.activityStudentIndex
                              : bloc.activityTeacherIndex) ==
                          e
                      ? Positioned(
                          bottom: 0,
                          left: 10,
                          right: 10,
                          child: heightLine(
                              color: type == 'STUDENT'
                                  ? AppColors.primary
                                  : AppColors.accent,
                              height: 1),
                        )
                      : Container(),
                ],
              );
            },
          );
        }).toList(),
      ),
    );
  }

  whatWant(String type) {
    List<Widget> keywords = [];
    for (int i = 0; i < 5; i++) {
      keywords.add(IntrinsicWidth(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: (type == 'STUDENT'
                      ? keywordTextCheckMade[i]
                      : keywordTextCheckRequest[i])
                  ? type == 'STUDENT'
                      ? AppColors.accentLight50
                      : AppColors.primaryLight50
                  : AppColors.white),
          child: DottedBorder(
            strokeWidth: (type == 'STUDENT'
                    ? keywordTextCheckMade[i]
                    : keywordTextCheckRequest[i])
                ? 1
                : (type == 'STUDENT'
                        ? keywordFocusCheckMade[i]
                        : keywordFocusCheckRequest[i])
                    ? 2
                    : 0,
            dashPattern: (type == 'STUDENT'
                    ? keywordFocusCheckMade[i]
                    : keywordFocusCheckRequest[i])
                ? [1, 0]
                : [5, 3],
            padding: EdgeInsets.only(left: 16, right: 11),
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: (type == 'STUDENT'
                    ? keywordTextCheckMade[i]
                    : keywordTextCheckRequest[i])
                ? AppColors.transparent
                : (type == 'STUDENT'
                        ? keywordFocusCheckMade[i]
                        : keywordFocusCheckRequest[i])
                    ? type == 'STUDENT'
                        ? AppColors.accentLight20
                        : AppColors.primaryLight20
                    : type == 'STUDENT'
                        ? AppColors.accentLight30
                        : AppColors.primaryLight30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText('#',
                    style: TextStyle(
                        color: type == 'STUDENT'
                            ? AppColors.accentLight30
                            : AppColors.primaryLight30,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                Flexible(
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        if (value != '') {
                          setState(() {
                            type == 'STUDENT'
                                ? keywordTextingCheckMade[i] = true
                                : keywordTextingCheckRequest[i] = true;
                          });
                        } else {
                          if (type == 'STUDENT'
                              ? keywordTextingCheckMade[i] == true
                              : keywordTextingCheckRequest[i] == true) {
                            setState(() {
                              type == 'STUDENT'
                                  ? keywordTextingCheckMade[i] = false
                                  : keywordTextingCheckRequest[i] = false;
                            });
                          }
                        }
                      },
                      controller: (type == 'STUDENT'
                          ? bloc.keywordControllerMade[i]
                          : bloc.keywordControllerRequest[i]),
                      focusNode: (type == 'STUDENT'
                          ? keywordFocusMade[i]
                          : keywordFocusRequest[i]),
                      onFieldSubmitted: (value) {},
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: (type == 'STUDENT'
                                  ? keywordTextCheckMade[i]
                                  : keywordTextCheckRequest[i])
                              ? type == 'STUDENT'
                                  ? AppColors.accentDark10
                                  : AppColors.primaryDark10
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
                (type == 'STUDENT'
                        ? keywordTextCheckMade[i]
                        : keywordTextCheckRequest[i])
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (type == 'STUDENT') {
                                bloc.keywordControllerMade[i].text = '';
                                keywordTextCheckMade[i] = false;
                                keywordTextingCheckMade[i] = false;
                              } else {
                                bloc.keywordControllerRequest[i].text = '';
                                keywordTextCheckRequest[i] = false;
                                keywordTextingCheckRequest[i] = false;
                              }
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
                                color: type == 'STUDENT'
                                    ? AppColors.accentLight20
                                    : AppColors.primaryLight20,
                              )
                            ],
                          ),
                        ),
                      )
                    : (type == 'STUDENT'
                            ? keywordFocusCheckMade[i]
                            : keywordFocusCheckRequest[i])
                        ? (type == 'STUDENT'
                                ? keywordTextingCheckMade[i]
                                : keywordTextingCheckRequest[i])
                            ? Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: type == 'STUDENT'
                                      ? AppColors.accentDark10
                                      : AppColors.primaryDark10,
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

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            child: Row(
              children: [
                customText(type == 'STUDENT' ? '배우고 싶은 것' : '알려주고 싶은 것',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                spaceW(6),
                CustomTooltip(
                    message:
                        '관련 ${type == 'STUDENT' ? '클래스를' : '요청글을'} 찾아드려요\n한 단어로 작성해주시면\n매칭율이 높아집니다 :)'),
              ],
            ),
          ),
          // Container(
          //     height: 48,
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: TextFormField(
          //               maxLines: 1,
          //               maxLength: 8,
          //               controller: type == 'STUDENT'
          //                   ? learnController
          //                   : teachingController,
          //               focusNode:
          //                   type == 'STUDENT' ? learnFocus : teachingFocus,
          //               keyboardType: TextInputType.text,
          //               textInputAction: TextInputAction.done,
          //               style: TextStyle(
          //                   color: AppColors.gray900,
          //                   fontWeight: weightSet(textWeight: TextWeight.BOLD),
          //                   fontSize: fontSizeSet(textSize: TextSize.T13)),
          //               onChanged: (text) {
          //                 if (type == 'STUDENT') {
          //                   learnLengthPass = true;
          //                 } else if (type == 'TEACHER') {
          //                   teachingLengthPass = true;
          //                 }
          //                 blankCheck(
          //                     text: text,
          //                     controller: type == 'STUDENT'
          //                         ? learnController
          //                         : teachingController,
          //                     multiline: true);
          //                 setState(() {});
          //               },
          //               decoration: InputDecoration(
          //                 counterText: '',
          //                 suffixIcon: (type == 'STUDENT'
          //                                 ? learnController
          //                                 : teachingController)
          //                             .text
          //                             .length >
          //                         0
          //                     ? Padding(
          //                         padding: EdgeInsets.only(top: 14, bottom: 14),
          //                         child: GestureDetector(
          //                           onTap: () {
          //                             setState(() {
          //                               (type == 'STUDENT'
          //                                       ? learnController
          //                                       : teachingController)
          //                                   .text = '';
          //                             });
          //                           },
          //                           child: Image.asset(AppImages.iInputClear,
          //                               width: 20, height: 20),
          //                         ),
          //                       )
          //                     : null,
          //                 hintText: AppStrings.of(StringKey.keywordPlaceHolder),
          //                 hintStyle: TextStyle(
          //                     color: AppColors.gray500,
          //                     fontWeight:
          //                         weightSet(textWeight: TextWeight.MEDIUM),
          //                     fontSize: fontSizeSet(textSize: TextSize.T13)),
          //                 border: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(8),
          //                     borderSide: BorderSide(
          //                         width: 1, color: AppColors.gray200)),
          //                 enabledBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(8),
          //                     borderSide: BorderSide(
          //                         width: 1, color: AppColors.gray200)),
          //                 focusedBorder: OutlineInputBorder(
          //                     borderRadius: BorderRadius.circular(8),
          //                     borderSide: BorderSide(
          //                         width: 2, color: AppColors.primary)),
          //                 contentPadding: EdgeInsets.only(left: 10),
          //               )),
          //         ),
          //         spaceW(10),
          //         Container(
          //           width: 80,
          //           height: 48,
          //           child: ElevatedButton(
          //             onPressed: () {
          //               if (type == 'STUDENT') {
          //                 learnPass = true;
          //                 if (!learnEvent) {
          //                   learnEvent = true;
          //                   amplitudeEvent(
          //                       'set_goal_keyword', {'type': 'learn'});
          //                 }
          //               } else if (type == 'TEACHER') {
          //                 teachingPass = true;
          //                 if (!teachingEvent) {
          //                   teachingEvent = true;
          //                   amplitudeEvent(
          //                       'set_goal_keyword', {'type': 'teaching'});
          //                 }
          //               }
          //
          //               if ((type == 'STUDENT'
          //                           ? learnController
          //                           : teachingController)
          //                       .text
          //                       .length ==
          //                   0) {
          //                 if (type == 'STUDENT') {
          //                   learnLengthPass = false;
          //                   FocusScope.of(context).requestFocus(learnFocus);
          //                   Future.delayed(Duration(milliseconds: 500), () {
          //                     scrollController.animateTo(
          //                         scrollController.position.maxScrollExtent,
          //                         duration: Duration(milliseconds: 100),
          //                         curve: Curves.ease);
          //                   });
          //                 } else if (type == 'TEACHER') {
          //                   teachingLengthPass = false;
          //                   FocusScope.of(context).requestFocus(teachingFocus);
          //                   Future.delayed(Duration(milliseconds: 500), () {
          //                     scrollController.animateTo(
          //                         scrollController.position.maxScrollExtent,
          //                         duration: Duration(milliseconds: 100),
          //                         curve: Curves.ease);
          //                   });
          //                 }
          //                 setState(() {});
          //               }
          //
          //               if ((type == 'STUDENT'
          //                               ? learnController
          //                               : teachingController)
          //                           .text
          //                           .length >
          //                       0 &&
          //                   (type == 'STUDENT'
          //                               ? bloc.learnKeyword
          //                               : bloc.teachingKeyword)
          //                           .length <
          //                       5) {
          //                 String keyword = (type == 'STUDENT'
          //                             ? learnController
          //                             : teachingController)
          //                         .text +
          //                     "●" +
          //                     Uuid().v4();
          //                 addKeywordItem(keyword, type);
          //                 bloc.add(KeywordItemAddEvent(
          //                     keyword: keyword, type: type));
          //                 (type == 'STUDENT'
          //                         ? learnController
          //                         : teachingController)
          //                     .text = '';
          //               }
          //             },
          //             style: ElevatedButton.styleFrom(
          //                 primary: AppColors.white,
          //                 elevation: 0,
          //                 padding: EdgeInsets.zero,
          //                 shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(8),
          //                     side: BorderSide(color: AppColors.primary))),
          //             child: Center(
          //               child: customText(
          //                 AppStrings.of(StringKey.save),
          //                 style: TextStyle(
          //                     color: AppColors.primaryDark10,
          //                     fontWeight:
          //                         weightSet(textWeight: TextWeight.BOLD),
          //                     fontSize: fontSizeSet(textSize: TextSize.T13)),
          //               ),
          //             ),
          //           ),
          //         )
          //       ],
          //     )),
          // type == 'STUDENT'
          //     ? learnLengthPass
          //         ? Container()
          //         : issueMessage(title: '최소 1자 이상 입력해주세요')
          //     : teachingLengthPass
          //         ? Container()
          //         : issueMessage(title: '최소 1자 이상 입력해주세요'),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: keywords,
          ),
          type == 'STUDENT'
              ? learnPass
                  ? Container()
                  : learnLengthPass
                      ? issueMessage(title: '배우고 싶은 것을 1개 이상 입력해주세요')
                      : Container()
              : teachingPass
                  ? Container()
                  : teachingLengthPass
                      ? issueMessage(title: '알려주고 싶은 것을 1개 이상 입력해주세요')
                      : Container(),
          (type == 'STUDENT'
                          ? bloc.learnKeywordItems
                          : bloc.teachingKeywordItems)
                      .length ==
                  0
              ? Container()
              : spaceH(12),
          // (type == 'STUDENT'
          //                 ? bloc.learnKeywordItems
          //                 : bloc.teachingKeywordItems)
          //             .length ==
          //         0
          //     ? Container()
          //     : Wrap(
          //         runSpacing: 10,
          //         spacing: 10,
          //         crossAxisAlignment: WrapCrossAlignment.start,
          //         children: (type == 'STUDENT'
          //             ? bloc.learnKeywordItems
          //             : bloc.teachingKeywordItems),
          //       ),
        ],
      ),
    );
  }

  addKeywordItem(String keyword, String type) {
    (type == 'STUDENT' ? bloc.learnKeywordItems : bloc.teachingKeywordItems)
        .add(GestureDetector(
      onTap: () {
        bloc.add(KeywordItemRemoveEvent(keyword: keyword, type: type));
      },
      child: Container(
        height: 30,
        color: AppColors.white,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            customText(
              keyword.split('●')[0],
              style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T12)),
            ),
            spaceW(4),
            Image.asset(
              AppImages.iInputClear,
              width: 16,
              height: 16,
            )
          ],
        ),
      ),
    ));
  }

  @override
  void initState() {
    for (int i = 0; i < 5; i++) {
      keywordFocusMade[i].addListener(() {
        if (!keywordFocusMade[i].hasFocus) {
          keywordFocusCheckMade[i] = false;
          bloc.add(KeywordSetEvent());
          if (bloc.keywordControllerMade[i].text != '') {
            keywordTextCheckMade[i] = true;
          } else {
            keywordTextCheckMade[i] = false;
          }
          bloc.add(KeywordSetEvent());
        } else {
          keywordTextCheckMade[i] = true;
          bloc.add(KeywordSetEvent());
        }
      });
    }
    for (int i = 0; i < 5; i++) {
      keywordFocusRequest[i].addListener(() {
        if (!keywordFocusRequest[i].hasFocus) {
          keywordTextCheckRequest[i] = false;
          bloc.add(KeywordSetEvent());
          if (bloc.keywordControllerRequest[i].text != '') {
            keywordTextCheckRequest[i] = true;
          } else {
            keywordTextCheckRequest[i] = false;
          }
          bloc.add(KeywordSetEvent());
        } else {
          keywordTextCheckRequest[i] = true;
          bloc.add(KeywordSetEvent());
        }
      });
    }
    super.initState();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is SetGoalInitState) {
      amplitudeEvent('set_goal_in', {});
    }

    if (state is SaveGoalState) {
      if (widget.sign) {
        pushAndRemoveUntil(context, NeighborHoodAddIntroPage());
      } else {
        dataSaver.feedbackBanner = true;
        if (dataSaver.neighborHood.length == 0) {
          pushAndRemoveUntil(context, NeighborHoodAddIntroPage());
        } else {
          pushAndRemoveUntil(context, MainPage());
        }
      }
    }

    if (state is SkipGoalState) {
      if (widget.sign) {
        pushAndRemoveUntil(context, NeighborHoodAddIntroPage());
      } else {
        dataSaver.feedbackBanner = true;
        if (dataSaver.neighborHood.length == 0) {
          pushAndRemoveUntil(context, NeighborHoodAddIntroPage());
        } else {
          pushAndRemoveUntil(context, MainPage());
        }
      }
    }

    if (state is SkipGoalState) {
      if (widget.sign) {
        pushAndRemoveUntil(context, NeighborHoodAddIntroPage());
      } else {
        dataSaver.feedbackBanner = true;
        if (dataSaver.neighborHood.length == 0) {
          pushAndRemoveUntil(context, NeighborHoodAddIntroPage());
        } else {
          pushAndRemoveUntil(context, MainPage());
        }
      }
    }
  }

  @override
  SetGoalBloc initBloc() {
    return SetGoalBloc(context)..add(SetGoalInitEvent());
  }
}
