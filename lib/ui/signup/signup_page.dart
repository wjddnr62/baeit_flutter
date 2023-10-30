import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/main/main_page.dart';
import 'package:baeit/ui/manager/manager_page.dart';
import 'package:baeit/ui/profile/profile_page.dart';
import 'package:baeit/ui/set_goal/set_goal_page.dart';
import 'package:baeit/ui/signup/signup_bloc.dart';
import 'package:baeit/ui/splash/splash_page.dart';
import 'package:baeit/ui/webview/webview_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends BlocStatefulWidget {
  final String? stopText;

  SignupPage({this.stopText});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return SignupState();
  }
}

class SignupState extends BlocState<SignupBloc, SignupPage> {
  List<String> tutorialImage = [
    AppImages.imgTutorialPage1,
    AppImages.imgTutorialPage2,
    AppImages.imgTutorialPage3
  ];

  List<String> tutorialImageB = [
    AppImages.imgTutorialPage4,
    AppImages.imgTutorialPage5,
    AppImages.imgTutorialPage6
  ];

  progressBar() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        if (idx != 2) {
          return Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 100),
                width: idx == bloc.idx ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: idx == bloc.idx
                      ? (production != 'prod-release' && !kReleaseMode)
                          ? flavor == Flavor.DEV
                              ? AppColors.primary
                              : AppColors.accent
                          : AppColors.primary
                      : AppColors.gray200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              spaceW(10)
            ],
          );
        } else {
          return AnimatedContainer(
            duration: Duration(milliseconds: 100),
            width: idx == bloc.idx ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: idx == bloc.idx
                  ? (production != 'prod-release' && !kReleaseMode)
                      ? flavor == Flavor.DEV
                          ? AppColors.primary
                          : AppColors.accent
                      : AppColors.primary
                  : AppColors.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }
      },
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: 3,
    );
  }

  appleAgeAgreeDialog({dynamic decodeToken, String? name, Device? device}) {
    return showDialog(
        barrierDismissible: true,
        context: (context),
        barrierColor: AppColors.black.withOpacity(0.6),
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) {
              return WillPopScope(
                  onWillPop: () {
                    return Future.value(true);
                  },
                  child: Dialog(
                    elevation: 5,
                    insetPadding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.15,
                      right: MediaQuery.of(context).size.width * 0.15,
                      top: MediaQuery.of(context).size.height * 0.15,
                      bottom: MediaQuery.of(context).size.height * 0.15,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: AppColors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            spaceH(24),
                            Padding(
                              padding: EdgeInsets.only(left: 26, right: 26),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  customText(
                                    '\'${AppStrings.of(StringKey.baeitStart)}\' 버튼을 누름으로써',
                                    style: TextStyle(
                                        color: AppColors.gray400,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T12)),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          pushTransition(
                                              context,
                                              WebviewPage(
                                                url:
                                                    'https://terms.baeit.co.kr/59f4716b-01ab-48e1-ba81-43be6bcf8382',
                                                title: '서비스 이용약관',
                                              ));
                                        },
                                        child: customText(
                                          '이용약관',
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AppColors.primaryDark10,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T13)),
                                        ),
                                      ),
                                      customText(
                                        ', ',
                                        style: TextStyle(
                                            color: AppColors.primaryDark10,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.REGULAR),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T13)),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          pushTransition(
                                              context,
                                              WebviewPage(
                                                url:
                                                    'https://terms.baeit.co.kr/617e8c24-1108-4c10-8a06-459ceb46b756',
                                                title: '개인정보 처리방침',
                                              ));
                                        },
                                        child: customText(
                                          '개인정보 처리방침',
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AppColors.primaryDark10,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T13)),
                                        ),
                                      ),
                                      customText(
                                        ', ',
                                        style: TextStyle(
                                            color: AppColors.primaryDark10,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.REGULAR),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T13)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          pushTransition(
                                              context,
                                              WebviewPage(
                                                url:
                                                    'https://terms.baeit.co.kr/7dcf6715-2544-4cf8-a34f-9ea7e04a5d7b',
                                                title: '위치기반 서비스 이용약관',
                                              ));
                                        },
                                        child: customText(
                                          '위치기반 서비스 이용약관',
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AppColors.primaryDark10,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T13)),
                                        ),
                                      ),
                                      customText(
                                        '에 동의하는',
                                        style: TextStyle(
                                            color: AppColors.gray400,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.REGULAR),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T13)),
                                      )
                                    ],
                                  ),
                                  customText(
                                    '것으로 간주합니다',
                                    style: TextStyle(
                                        color: AppColors.gray400,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.REGULAR),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T13)),
                                  ),
                                  spaceH(32),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: bloc.ageCheck,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          side: BorderSide(
                                              width: 1,
                                              color: AppColors.gray200),
                                          onChanged: (value) {
                                            setState(() {
                                              bloc.ageCheck = value!;
                                            });
                                          },
                                          activeColor: AppColors.primary,
                                        ),
                                      ),
                                      spaceW(6),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bloc.ageCheck = !bloc.ageCheck;
                                          });
                                        },
                                        child: customText(
                                          AppStrings.of(StringKey.ageCheck)
                                              .replaceAll(' (필수)', ''),
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T13)),
                                        ),
                                      )
                                    ],
                                  ),
                                  spaceH(12)
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12),
                              child: bottomButton(
                                  context: context,
                                  text: AppStrings.of(StringKey.baeitStart),
                                  onPress: bloc.ageCheck
                                      ? () {
                                          bloc.add(GoingSignUpEvent(
                                              decodeToken: decodeToken,
                                              name: name ?? '',
                                              device: device!));
                                        }
                                      : null),
                            )
                          ],
                        )
                      ],
                    ),
                  ));
            },
          );
        });
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
                SafeArea(
                  child: Scaffold(
                    backgroundColor: AppColors.white,
                    body: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (!kReleaseMode &&
                                  (production == 'prod-debug' ||
                                      flavor == Flavor.PROD)) {
                                pushTransition(context, ManagerPage());
                              }
                            },
                            child: Container(
                              height: 106,
                              color: AppColors.white,
                            ),
                          ),
                          Expanded(
                              child: PageView.builder(
                            itemBuilder: (context, idx) {
                              return GestureDetector(
                                onTap: () async {
                                  if (!kReleaseMode) {
                                    setState(() {
                                      if (flavor == Flavor.DEV) {
                                        flavor = Flavor.PROD;
                                        prefs!.setString('FLAVOR', 'PROD');
                                        common();
                                      } else {
                                        flavor = Flavor.DEV;
                                        prefs!.setString('FLAVOR', 'DEV');
                                        common();
                                      }
                                    });
                                  }
                                },
                                child: Image.asset(
                                  tutorialImage[idx],
                                  width: MediaQuery.of(context).size.width - 68,
                                ),
                              );
                            },
                            itemCount: tutorialImage.length,
                            onPageChanged: (idx) {
                              bloc.idx = idx;
                              amplitudeEvent(
                                  'tutorial_scroll', {'scroll_index': idx});
                              setState(() {});
                            },
                          )),
                          spaceH(56),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 6,
                            child: Center(
                              child: progressBar(),
                            ),
                          ),
                          spaceH(40),
                          Container(
                            height: 48,
                            padding: EdgeInsets.only(left: 30, right: 30),
                            child: ElevatedButton(
                              onPressed: () {
                                bloc.add(SignupAuthEvent(auth: 'KAKAO'));
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Color(0xFFFEE500),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  spaceW(6),
                                  customText(
                                    AppStrings.of(StringKey.kakaoStart),
                                    style: TextStyle(
                                        color:
                                            AppColors.black.withOpacity(0.85),
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T15)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Platform.isIOS
                              ? SizedBox(
                                  height: 12,
                                )
                              : Container(),
                          Platform.isIOS
                              ? Container(
                                  height: 48,
                                  padding: EdgeInsets.only(left: 30, right: 30),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      bloc.add(SignupAuthEvent(auth: 'APPLE'));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: AppColors.black,
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        spaceW(6),
                                        customText(
                                          AppStrings.of(StringKey.appleStart),
                                          style: TextStyle(
                                              color: AppColors.white,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T15)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          spaceH(24),
                          dataSaver.touring ? GestureDetector(
                            onTap: () async {
                              await dataSaver.clear();
                              dataSaver.nonMember = true;
                              if (prefs!.getBool('guest') ?? false == false) {
                                amplitudeEvent('look_around', {});
                              }
                              // try {
                              //   await ChannelTalk.setDebugMode(flag: false);
                              //   await ChannelTalk.boot(
                              //       pluginKey:
                              //           '641678df-f344-4037-b309-44b3bb05bc59',
                              //       memberHash: '.',
                              //       language: 'korean');
                              // } on PlatformException catch (error) {
                              //   debugPrint('channel talk error : $error');
                              // } catch (err) {}
                              await prefs!.setBool('guest', true);
                              await prefs!.remove('memberLoad');
                              pushAndRemoveUntil(context, MainPage());
                            },
                            child: customText(
                              AppStrings.of(StringKey.touring),
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: AppColors.gray600,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.MEDIUM),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T12)),
                            ),
                          ) : Container(),
                          spaceH(24)
                        ],
                      ),
                    ),
                  ),
                ),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) async {
    if (state is AgeCheckState) {
      bloc.ageCheck = false;
      appleAgeAgreeDialog(
          decodeToken: state.decodeToken,
          name: state.name,
          device: state.device);
    }

    if (state is SignupInitState) {
      if (widget.stopText != null) {
        // customDialog(context: context, barrier: false, widget: Container(
        //   width: 100,
        //   height: 100,
        //   child: customText("테스트"),
        // ));
      }
    }

    if (state is SignupAuthState) {
      push(
          context,
          ProfilePage(
            signUp: true,
            kakaoInfo: state.kakaoInfo,
            appleInfo: state.appleInfo,
            accessId: state.accessId,
            device: state.device,
            email: state.email,
            type: state.type,
            image: state.image,
          ));
    }

    if (state is LoginAuthState) {
      stompClient.deactivate();
      stompClient.activate();
      pushAndRemoveUntil(context, SplashPage());
    }

    if (state is SignUpFinishState) {
      pushAndRemoveUntil(context, SetGoalPage());
    }

    if (state is BanUserState) {
      customDialog(
          context: context,
          barrier: false,
          widget: ListView(
            shrinkWrap: true,
            children: [
              spaceH(20),
              Center(
                child: customText('관리자에서 회원정지\n처리하였습니다',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T17)),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.only(left: 26, right: 26, top: 20),
                child: Center(
                  child: customText(
                    state.banMean,
                    style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  ),
                ),
              ),
              spaceH(32),
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: bottomButton(
                    context: context,
                    onPress: () {
                      popDialog(context);
                    },
                    text: '확인'),
              ),
              spaceH(12)
            ],
          ));
    }
  }

  @override
  SignupBloc initBloc() {
    // TODO: implement initBloc
    return SignupBloc(context)..add(SignupInitEvent());
  }
}
