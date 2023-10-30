import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'neighborhood_cheer_bloc.dart';

class NeighborHoodCheerPage extends BlocStatefulWidget {
  final String uuid;
  final String member;

  NeighborHoodCheerPage({required this.uuid, required this.member});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return NeighborHoodCheerState();
  }
}

class NeighborHoodCheerState
    extends BlocState<NeighborHoodCheerBloc, NeighborHoodCheerPage>
    with TickerProviderStateMixin {
  AnimationController? thumbsUpAnimation;
  TextEditingController cheerController = TextEditingController();

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: baseAppBar(
                  title: AppStrings.of(StringKey.neighborhoodCheer),
                  context: context,
                  onPressed: () {
                    pop(context);
                  },
                  close: true),
              resizeToAvoidBottomInset: true,
              body: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height -
                      (60 +
                          MediaQuery.of(context).padding.top +
                          MediaQuery.of(context).padding.bottom),
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(AppImages.thumbsUpAnimation,
                                controller: thumbsUpAnimation,
                                width: 135,
                                height: 135, onLoaded: (composition) {
                              setState(() {
                                thumbsUpAnimation!
                                  ..duration = composition.duration;
                                thumbsUpAnimation!.reset();
                                thumbsUpAnimation!.forward();
                              });
                            }),
                            Container(
                              height: 24,
                              child: customText(
                                AppStrings.of(StringKey.cheerThanks),
                                style: TextStyle(
                                    color: AppColors.gray900,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T17)),
                              ),
                            ),
                            spaceH(20),
                            customText(
                              '${widget.member}${AppStrings.of(StringKey.cheerContent)}',
                              style: TextStyle(
                                  color: AppColors.secondaryDark30,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.MEDIUM),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T12)),
                              textAlign: TextAlign.center,
                            ),
                            spaceH(42),
                            Padding(
                              padding: EdgeInsets.only(left: 48, right: 48),
                              child: Container(
                                height: 24,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.iCheerWait,
                                      width: 16,
                                      height: 16,
                                    ),
                                    spaceW(4),
                                    customText(
                                      AppStrings.of(StringKey.wait),
                                      style: TextStyle(
                                          color: AppColors.gray900,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T10)),
                                    ),
                                    Expanded(child: Container()),
                                    customText(
                                      '${cheerController.text.characters.length}',
                                      style: TextStyle(
                                          color: AppColors.primaryDark10,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.BOLD),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12)),
                                    ),
                                    customText(
                                      ' / 500',
                                      style: TextStyle(
                                          color: AppColors.gray400,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            spaceH(12),
                            Container(
                              height: 146,
                              padding: EdgeInsets.only(left: 48, right: 48),
                              child: TextFormField(
                                  onChanged: (text) {
                                    blankCheck(
                                        text: text,
                                        controller: cheerController,
                                        multiline: true);
                                    setState(() {});
                                  },
                                  maxLength: 500,
                                  maxLines: null,
                                  controller: cheerController,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  onFieldSubmitted: (value) {},
                                  expands: true,
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    isCollapsed: true,
                                    hintText: AppStrings.of(
                                        StringKey.cheerPlaceHolder),
                                    hintMaxLines: 3,
                                    hintStyle: TextStyle(
                                        color: AppColors.primaryDark10
                                            .withOpacity(0.4),
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.REGULAR),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T13)),
                                    contentPadding: EdgeInsets.only(
                                        left: 10,
                                        top: 10,
                                        bottom: 10,
                                        right: 10),
                                    fillColor: AppColors.primaryLight60,
                                    filled: true,
                                    counterText: '',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: AppColors.gray200)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: AppColors.primaryLight40)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: AppColors.primaryLight40)),
                                  )),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: bottomButton(
                              context: context,
                              text: AppStrings.of(StringKey.check),
                              onPress: () {
                                bloc.add(SaveCheerContentEvent(
                                    uuid: widget.uuid,
                                    text: cheerController.text));
                              })),
                      loadingView(bloc.loading)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    thumbsUpAnimation!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    thumbsUpAnimation = AnimationController(vsync: this);
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is SaveCheerContentState) {
      pop(context);
    }
  }

  @override
  NeighborHoodCheerBloc initBloc() {
    return NeighborHoodCheerBloc(context)..add(NeighborHoodInitEvent());
  }
}
