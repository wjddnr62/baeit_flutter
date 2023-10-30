import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/splash/splash_page.dart';
import 'package:baeit/ui/withdrawal/withdrawal_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class WithdrawalPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return WithdrawalState();
  }
}

class WithdrawalState extends BlocState<WithdrawalBloc, WithdrawalPage>
    with TickerProviderStateMixin {
  AnimationController? controller;
  TextEditingController withdrawalController = TextEditingController();
  FocusNode withdrawalFocus = FocusNode();
  bool pass = true;

  bottomSet() {
    return Column(
      children: [
        Container(
            height: 36,
            child: customText(
              AppStrings.of(StringKey.withdrawalIssue),
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T12)),
            )),
        Row(
          children: [
            Expanded(
                child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (withdrawalController.text.length < 5) {
                    pass = false;
                    FocusScope.of(context).requestFocus(withdrawalFocus);
                    return;
                  } else {
                    bloc.add(
                        WithdrawalEvent(reasonText: withdrawalController.text));
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8))),
                child: Center(
                  child: customText(
                    AppStrings.of(StringKey.withdrawal),
                    style: TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T14)),
                  ),
                ),
              ),
            )),
            spaceW(12),
            Expanded(
                child: bottomButton(
                    context: context,
                    onPress: () {
                      pop(context);
                    },
                    text: AppStrings.of(StringKey.moreUse))),
          ],
        )
      ],
    );
  }

  withdrawalMean() {
    return Column(
      children: [
        Container(
          height: 48,
          padding: EdgeInsets.only(left: 48, right: 48),
          child: Row(
            children: [
              customText(
                '삭제 이유',
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              ),
              Expanded(child: Container()),
              customText(
                withdrawalController.text.characters.length.toString(),
                style: TextStyle(
                    color: AppColors.primaryDark10,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              ),
              customText(
                ' / 5 ~ 50',
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              )
            ],
          ),
        ),
        Container(
          height: 73,
          padding: EdgeInsets.only(left: 48, right: 48),
          child: TextFormField(
              onChanged: (text) {
                pass = true;
                blankCheck(
                    text: text,
                    controller: withdrawalController,
                    multiline: true);
                setState(() {});
              },
              maxLength: 50,
              maxLines: null,
              controller: withdrawalController,
              focusNode: withdrawalFocus,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onFieldSubmitted: (value) {},
              expands: true,
              style: TextStyle(
                  color: AppColors.primaryDark10,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                hintText: AppStrings.of(StringKey.withdrawalPlaceHolder),
                hintMaxLines: 3,
                hintStyle: TextStyle(
                    color: AppColors.primaryDark10.withOpacity(0.4),
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T13)),
                contentPadding:
                    EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                fillColor: AppColors.primaryLight60,
                filled: true,
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 1, color: AppColors.gray200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(width: 1, color: AppColors.primaryLight40)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(width: 2, color: AppColors.primaryLight30)),
              )),
        ),
        !pass
            ? Padding(
                padding: EdgeInsets.only(left: 48),
                child: issueMessage(title: '최소 5자 이상 적어주세요'),
              )
            : Container()
      ],
    );
  }

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
              child: Stack(
                children: [
                  Scaffold(
                    resizeToAvoidBottomInset: true,
                    appBar: baseAppBar(
                        title: AppStrings.of(StringKey.withdrawal),
                        context: context,
                        onPressed: () {
                          pop(context);
                        },
                        close: true),
                    body: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height -
                            (60 +
                                MediaQuery.of(context).padding.top +
                                MediaQuery.of(context).padding.bottom),
                        color: AppColors.white,
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 173,
                                  height: 135,
                                  child: Lottie.asset(
                                      AppImages.withdrawalAnimation,
                                      controller: controller,
                                      onLoaded: (composition) {
                                    setState(() {
                                      controller!.reset();
                                      controller!
                                        ..duration = composition.duration;
                                      controller!.forward();
                                    });
                                  }),
                                ),
                                RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: dataSaver.profileGet == null
                                              ? ''
                                              : dataSaver.profileGet!.nickName,
                                          style: TextStyle(
                                              color: AppColors.greenGray300,
                                              fontWeight: weightSet(
                                                  textWeight: TextWeight.BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T17))),
                                      TextSpan(
                                          text: AppStrings.of(StringKey.bye),
                                          style: TextStyle(
                                              color: AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T17)))
                                    ])),
                                spaceH(30),
                                customText('실수로 삭제하지 않도록\n이유를 필수로 적어주세요',
                                    style: TextStyle(
                                        color: AppColors.gray900,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T17)), textAlign: TextAlign.center),
                                spaceH(30),
                                withdrawalMean(),
                              ],
                            ),
                            Expanded(child: Container()),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12),
                              child: bottomSet(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  loadingView(bloc.loading)
                ],
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is WithdrawalFinishState) {
      pushAndRemoveUntil(context, SplashPage());
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  WithdrawalBloc initBloc() {
    return WithdrawalBloc(context)..add(WithdrawalInitEvent());
  }
}
