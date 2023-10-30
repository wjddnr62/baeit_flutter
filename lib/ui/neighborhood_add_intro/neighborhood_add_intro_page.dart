import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/neighborhood_add/neighborhood_add_page.dart';
import 'package:baeit/ui/neighborhood_add_intro/neighborhood_add_intro_bloc.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NeighborHoodAddIntroPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return NeighborHoodAddIntroState();
  }
}

class NeighborHoodAddIntroState
    extends BlocState<NeighborHoodAddIntroBloc, NeighborHoodAddIntroPage> {
  double height = 212;
  bool hide = false;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    width: MediaQuery.of(context).size.width,
                    height: height,
                    onEnd: () {
                      pushAndRemoveUntilTransition(
                          context, NeighborHoodAddPage(), fade: false);
                    },
                    child: Column(
                      children: [
                        hide ? Container() : spaceH(80),
                        hide
                            ? Container()
                            : Container(
                                height: 52,
                                child: customText(
                                  '내 주변 클래스\n먼저 구경해볼까요?',
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T20),
                                      decoration: TextDecoration.none),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                        hide ? Container() : spaceH(80),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: GestureDetector(
                      onTap: () {
                        height = 70;
                        hide = true;
                        setState(() {});
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gray200)),
                        child: Row(
                          children: [
                            spaceW(10),
                            Image.asset(
                              AppImages.iSearchC,
                              width: 24,
                              height: 24,
                            ),
                            spaceW(8),
                            customText(
                              AppStrings.of(StringKey.addressSearchPlaceHolder),
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: AppColors.gray400,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.REGULAR),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T13)),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  NeighborHoodAddIntroBloc initBloc() {
    return NeighborHoodAddIntroBloc(context)
      ..add(NeighborHoodAddIntroInitEvent());
  }
}
