import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/profile/profile_dialog_page.dart';
import 'package:baeit/ui/signup/signup_page.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';

import 'gradient.dart';

customDialog(
    {required BuildContext context,
    required bool barrier,
    Color? barrierColor,
    required Widget widget,
    bool update = false,
    int? elevation}) {
  return showDialog(
      barrierDismissible: !barrier,
      context: (context),
      barrierColor: barrierColor == null
          ? AppColors.black.withOpacity(0.6)
          : barrierColor,
      builder: (_) {
        return WillPopScope(
            onWillPop: () {
              if (barrier) {
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Dialog(
              elevation: elevation == null ? 5 : elevation.toDouble(),
              insetPadding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
                top: MediaQuery.of(context).size.height * 0.15,
                bottom: MediaQuery.of(context).size.height * 0.15,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              // backgroundColor: AppColors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [update ? Flexible(child: widget) : widget],
              ),
            ));
      });
}

decisionDialog(
    {required BuildContext context,
    required bool barrier,
    required String text,
    required String allowText,
    required String disallowText,
    required VoidCallback allowCallback,
    required VoidCallback disallowCallback}) {
  return showDialog(
      barrierDismissible: !barrier,
      context: (context),
      barrierColor: AppColors.black.withOpacity(0.6),
      builder: (_) {
        return WillPopScope(
            onWillPop: () {
              if (barrier) {
                return Future.value(false);
              } else {
                return Future.value(true);
              }
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
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    children: [
                      spaceH(24),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 72,
                        child: Center(
                          child: customText(
                            text,
                            style: TextStyle(
                                color: AppColors.gray600,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.REGULAR),
                                fontSize: fontSizeSet(textSize: TextSize.T13)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      bottomGradient(
                          context: context, height: 20, color: AppColors.white),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: disallowCallback,
                              style: ElevatedButton.styleFrom(
                                primary: AppColors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: AppColors.primary)),
                              ),
                              child: Center(
                                child: customText(
                                  disallowText,
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                              ),
                            ),
                          )),
                          spaceW(12),
                          Expanded(
                              child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: allowCallback,
                              style: ElevatedButton.styleFrom(
                                  primary: AppColors.primary,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              child: Center(
                                child: customText(
                                  allowText,
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                              ),
                            ),
                          ))
                        ],
                      )
                    ],
                  )
                ],
              ),
            ));
      });
}

nonMemberDialog(
    {required BuildContext context,
    bool barrier = false,
    required String title,
    required String content}) {
  return showDialog(
      barrierDismissible: !barrier,
      context: (context),
      barrierColor: AppColors.black.withOpacity(0.6),
      builder: (_) {
        return WillPopScope(
            onWillPop: () {
              if (barrier) {
                return Future.value(false);
              } else {
                return Future.value(true);
              }
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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: Row(
                          children: [
                            spaceW(20),
                            spaceW(24),
                            Expanded(child: Container()),
                            customText(
                              title,
                              style: TextStyle(
                                  color: AppColors.gray900,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T15)),
                            ),
                            Expanded(child: Container()),
                            GestureDetector(
                              onTap: () {
                                popDialog(context);
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                color: AppColors.white,
                                child: Image.asset(
                                  AppImages.iX,
                                  width: 12.5,
                                  height: 12.5,
                                ),
                              ),
                            ),
                            spaceW(20)
                          ],
                        ),
                      ),
                      heightLine(height: 1),
                      spaceH(30),
                      customText(
                        content,
                        style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight:
                                weightSet(textWeight: TextWeight.REGULAR),
                            fontSize: fontSizeSet(textSize: TextSize.T13)),
                        textAlign: TextAlign.center,
                      ),
                      spaceH(30),
                      Padding(
                        padding: EdgeInsets.only(left: 12, right: 12),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 54,
                          color: AppColors.white,
                          child: ElevatedButton(
                            onPressed: () {
                              popDialog(context);
                              pushTransition(context, SignupPage());
                            },
                            style: ElevatedButton.styleFrom(
                                primary: AppColors.white,
                                elevation: 0,
                                padding: EdgeInsets.only(left: 16, right: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side:
                                        BorderSide(color: AppColors.gray300))),
                            child: Row(
                              children: [
                                customText(
                                  AppStrings.of(StringKey.doLogin),
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T13)),
                                ),
                                Expanded(child: Container()),
                                Container(
                                  width: 28,
                                  height: 28,
                                  child: Image.asset(
                                    AppImages.iKakaoCircle,
                                    width: 28,
                                    height: 28,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      spaceH(12)
                    ],
                  )
                ],
              ),
            ));
      });
}

profileDialog(
    {required BuildContext context,
    required String memberUuid,
    bool barrier = false}) {
  return showDialog(
      barrierDismissible: !barrier,
      context: (context),
      useSafeArea: false,
      barrierColor: AppColors.black.withOpacity(0.6),
      builder: (_) {
        return WillPopScope(
            onWillPop: () {
              if (barrier) {
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: SafeArea(
              bottom: false,
              child: Dialog(
                elevation: 5,
                insetPadding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 60,
                  bottom: 0,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: ProfileDialogPage(
                  memberUuid: memberUuid,
                ),
              ),
            ));
      });
}
