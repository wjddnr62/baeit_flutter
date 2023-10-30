import 'dart:math' as math;

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/splash/splash_page.dart';
import 'package:baeit/ui/view_more/view_more_bloc.dart';
import 'package:baeit/ui/webview/webview_page.dart';
import 'package:baeit/ui/withdrawal/withdrawal_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store_redirect/store_redirect.dart';

class ViewMorePage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ViewMoreState();
  }
}

class ViewMoreState extends BlocState<ViewMoreBloc, ViewMorePage> {
  List<String> viewMoreTexts = [
    AppStrings.of(StringKey.termsAndConditionsOfService),
    AppStrings.of(StringKey.personalInformationProcessingPolicy),
    AppStrings.of(StringKey.locationBasedServiceTermsAndConditions),
    AppStrings.of(StringKey.version)
  ];

  viewMoreItem(idx) {
    return GestureDetector(
      onTap: () async {
        if (idx == 0) {
          pushTransition(
              context,
              WebviewPage(
                  url:
                      'https://terms.baeit.co.kr/59f4716b-01ab-48e1-ba81-43be6bcf8382', title: '서비스 이용약관',));
        } else if (idx == 1) {
          pushTransition(
              context,
              WebviewPage(
                  url:
                      'https://terms.baeit.co.kr/617e8c24-1108-4c10-8a06-459ceb46b756', title: '개인정보 처리방침',));
        } else if (idx == 2) {
          pushTransition(
              context,
              WebviewPage(
                  url:
                      'https://terms.baeit.co.kr/7dcf6715-2544-4cf8-a34f-9ea7e04a5d7b', title: '위치기반 서비스 이용약관',));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: idx == 3 && dataSaver.forceUpdate ? AppColors.accentLight60 : AppColors.white,
          borderRadius: BorderRadius.circular(10)
        ),
        height: 54,
        child: Row(
          children: [
            spaceW(10),
            customText(
              viewMoreTexts[idx] +
                  (idx == 3
                      ? " ${dataSaver.packageInfo != null ? dataSaver.packageInfo!.version : ""}"
                      : ""),
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
            ),
            Expanded(child: Container()),
            idx == 3
                ? int.parse(dataSaver.packageInfo!.version.replaceAll('.', '')) <
                        bloc.versionSet
                    ? Container(
                        height: 24,
                        child: ElevatedButton(
                          onPressed: () {
                            StoreRedirect.redirect(
                                androidAppId: "com.noahnomad.baeit",
                                iOSAppId: "1578611254");
                          },
                          style: ElevatedButton.styleFrom(
                              primary: AppColors.accent,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24))),
                          child: Center(
                            child: customText(
                              AppStrings.of(StringKey.goUpdate),
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize: fontSizeSet(textSize: TextSize.T10)),
                            ),
                          ),
                        ),
                      )
                    : customText(
                        AppStrings.of(StringKey.finalVersion),
                        style: TextStyle(
                            color: AppColors.primaryDark10,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T10)),
                      )
                : Transform.rotate(
                    angle: 180 * math.pi / 180,
                    child: Image.asset(
                      AppImages.iChevronPrev,
                      width: 16,
                      height: 16,
                    ),
                  ),
            spaceW(10),
          ],
        ),
      ),
    );
  }

  viewMoreList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          child: viewMoreItem(idx),
        );
      },
      shrinkWrap: true,
      itemCount: 4,
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
                      title: AppStrings.of(StringKey.plusMore),
                      context: context,
                      onPressed: () {
                        pop(context);
                      }),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          dataSaver.packageInfo == null || bloc.version == null
                              ? Container()
                              : viewMoreList(),
                          spaceH(20),
                          heightLine(height: 1, color: AppColors.gray100),
                          spaceH(20),
                          GestureDetector(
                            onTap: () {
                              decisionDialog(
                                  context: context,
                                  barrier: false,
                                  text: AppStrings.of(StringKey.doLogout),
                                  allowText: AppStrings.of(StringKey.check),
                                  disallowText: AppStrings.of(StringKey.cancel),
                                  allowCallback: () async {
                                    popDialog(context);
                                    bloc.add(LogoutEvent());
                                  },
                                  disallowCallback: () {
                                    popDialog(context);
                                  });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 54,
                              padding: EdgeInsets.only(left: 10),
                              child: customText(
                                AppStrings.of(StringKey.logout),
                                style: TextStyle(
                                    color: AppColors.primaryLight10,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.REGULAR),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T14)),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              pushTransition(context, WithdrawalPage());
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 54,
                              padding: EdgeInsets.only(left: 10),
                              child: customText(
                                AppStrings.of(StringKey.withdrawal),
                                style: TextStyle(
                                    color: AppColors.gray400,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.REGULAR),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T14)),
                              ),
                            ),
                          )
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
  blocListener(BuildContext context, state) {
    if (state is LogoutState) {
      dataSaver.logout = true;
      pushAndRemoveUntil(context, SplashPage());
    }
  }

  @override
  ViewMoreBloc initBloc() {
    return ViewMoreBloc(context)..add(ViewMoreInitEvent());
  }
}
