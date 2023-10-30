import 'dart:async';
import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/main/main_page.dart';
import 'package:baeit/ui/neighborhood_add_intro/neighborhood_add_intro_page.dart';
import 'package:baeit/ui/permission/permission_check_page.dart';
import 'package:baeit/ui/set_goal/set_goal_page.dart';
import 'package:baeit/ui/signup/signup_page.dart';
import 'package:baeit/ui/splash/splash_bloc.dart';
import 'package:baeit/ui/webview/webview_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/subjects.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:uni_links/uni_links.dart';

class SplashPage extends BlocStatefulWidget {
  final String? stopText;

  SplashPage({this.stopText});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return SplashState();
  }
}

class SplashState extends BlocState<SplashBloc, SplashPage>
    with TickerProviderStateMixin {
  late AnimationController splashController;
  AnimationController? lottieAnimation;

  splashCheck() {
    if (splashController.isCompleted) {
      bloc.add(SplashInitEvent());
    }
  }

  @override
  void initState() {
    super.initState();
    lottieAnimation = AnimationController(vsync: this);
    splashController = AnimationController(vsync: this);
    splashController.addListener(splashCheck);

    _handleInitialUri();
  }

  bool _initialUriIsHandled = false;

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;

      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          if (uri.toString().contains('fbinsta') &&
              !uri.toString().contains('web')) {
            amplitudeEvent('channel_route', {'type': 'fbinsta'}, init: false);
          }
        }
      } on PlatformException {
        print('failed to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri : $err');
      }
    }
  }

  @override
  void dispose() {
    splashController.dispose();
    super.dispose();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: AppColors.white,
                body: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.2),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 104,
                          height: 94,
                          child: Lottie.asset(AppImages.splashAnimation,
                              controller: splashController,
                              onLoaded: (composition) async {
                            splashController.reset();
                            splashController..duration = composition.duration;
                            setState(() {});
                            await splashController.forward();
                          }),
                        ),
                      ),
                    ),
                    loadingView(bloc.isLoading)
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) async {
    if (state is SplashCheckState) {
      dataSaver.splashBloc = bloc;
    }

    if (state is SplashInitState) {
      if (prefs!.getBool('permission') ?? false) {
        if (prefs!.getString('userData') != null) {
          await identifyInit();
          bloc.add(AutoLoginEvent());
        } else {
          if (prefs!.getBool('guest') ?? false) {
            // try {
            //   await ChannelTalk.setDebugMode(flag: false);
            //   await ChannelTalk.boot(
            //       pluginKey: '641678df-f344-4037-b309-44b3bb05bc59',
            //       memberHash: '.',
            //       language: 'korean');
            // } on PlatformException catch (error) {
            //   debugPrint('channel talk error : $error');
            // } catch (err) {}
            dataSaver.nonMember = true;
            pushAndRemoveUntil(context, MainPage());
          } else {
            pushAndRemoveUntil(
                context,
                SignupPage(
                  stopText: widget.stopText,
                ));
          }
        }
      } else {
        pushAndRemoveUntil(context, PermissionCheckPage());
      }
    }

    if (state is AutoLoginNeighborHoodState) {
      pushAndRemoveUntil(context, NeighborHoodAddIntroPage());
    }

    if (state is NonSetGoalState) {
      pushAndRemoveUntil(context, SetGoalPage(sign: false));
    }

    if (state is AutoLoginState) {
      selectNotificationSubject = PublishSubject<String?>();
      pushAndRemoveUntil(context, MainPage());
    }

    if (state is AutoLoginFailState) {
      pushAndRemoveUntil(context, SignupPage());
    }

    if (state is ForceUpdateState) {
      amplitudeEvent('force_update_open', {});
      customDialog(
          context: context,
          barrier: true,
          widget: forceUpdateDialog(),
          update: true);
    }
  }

  forceUpdateDialog() {
    return IntrinsicHeight(
      child: Container(
        // height: 450,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: Column(
          children: [
            Flexible(
              child: Container(
                height: 310,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: Stack(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: [
                        spaceH(20),
                        bloc.version!.image == null
                            ? Container()
                            : bloc.version!.image!.contentType.contains('json')
                                ? Lottie.network(
                                    bloc.version!.image!.toView(context: context, image: false),
                                    controller: lottieAnimation,
                                    width: 135,
                                    height: 135, onLoaded: (composition) {
                                    setState(() {
                                      lottieAnimation!
                                        ..duration = composition.duration;
                                      lottieAnimation!.reset();
                                      lottieAnimation!.forward();
                                    });
                                  })
                                : Container(
                                    width: 135,
                                    height: 135,
                                    child: CacheImage(
                                      imageUrl: bloc.version!.image!.toView(context: context, ),
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                        Center(
                          child: customText('새로운 기능이 도착했어요!',
                              style: TextStyle(
                                  color: AppColors.gray900,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.MEDIUM),
                                  fontSize: fontSizeSet(textSize: TextSize.T17))),
                        ),
                        spaceH(20),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accentLight60,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(20),
                            child: customText(bloc.version!.contentText ?? '',
                                style: TextStyle(
                                    color: AppColors.accentDark10,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T14))),
                          ),
                        ),
                        spaceH(20)
                      ],
                    ),
                    Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: bottomGradient(
                            context: context, height: 20, color: AppColors.white))
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  height: 36,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        amplitudeEvent('force_update_qna', {});
                        pushTransition(
                            context,
                            WebviewPage(
                                url: Platform.isAndroid
                                    ? 'https://notice.baeit.co.kr/f311514f-8ce8-44d3-89f8-1feb51c08e1f'
                                    : 'https://notice.baeit.co.kr/86250c8d-7f89-4a09-b7da-4ce783743187',
                                title: '업데이트가 안 될때'));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.iTipExclamationG,
                            width: 12,
                            height: 12,
                          ),
                          spaceW(4),
                          customText('업데이트가 안 되나요?',
                              style: TextStyle(
                                  color: AppColors.gray600,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.MEDIUM),
                                  fontSize: fontSizeSet(textSize: TextSize.T12),
                                  decoration: TextDecoration.underline))
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: bottomButton(
                      context: context,
                      elevation: 0,
                      text: '업데이트',
                      onPress: () {
                        amplitudeEvent('force_update_market', {});
                        StoreRedirect.redirect(
                            androidAppId: "com.noahnomad.baeit",
                            iOSAppId: "1578611254");
                      }),
                ),
                !dataSaver.updatePass && bloc.version!.forceFlag == 1 ? spaceH(20) : Container(
                  height: 48,
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        await prefs!.setString(
                            'forceUpdateData', dataSaver.packageInfo!.version);
                        amplitudeEvent('force_update_close', {});
                        popDialog(context);
                        bloc.isLoading = true;
                        setState(() {});
                        if (prefs!.getBool('permission') ?? false) {
                          if (prefs!.getString('userData') != null) {
                            await identifyInit();
                            bloc.add(AutoLoginEvent());
                          } else {
                            if (prefs!.getBool('guest') ?? false) {
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
                              dataSaver.nonMember = true;
                              pushAndRemoveUntil(context, MainPage());
                            } else {
                              pushAndRemoveUntil(
                                  context,
                                  SignupPage(
                                    stopText: widget.stopText,
                                  ));
                            }
                          }
                        } else {
                          pushAndRemoveUntil(context, PermissionCheckPage());
                        }
                      },
                      child: customText(
                        '닫기',
                        style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12),
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  SplashBloc initBloc() {
    return SplashBloc(context)..add(SplashCheckEvent());
  }
}
