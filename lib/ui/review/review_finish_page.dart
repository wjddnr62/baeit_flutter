import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/review/review_detail_page.dart';
import 'package:baeit/ui/review/review_finish_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class ReviewFinishPage extends BlocStatefulWidget {
  final String nickName;
  final List<String> types;
  final String classUuid;

  ReviewFinishPage(
      {required this.nickName, required this.types, required this.classUuid});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ReviewFinishPageState();
  }
}

class ReviewFinishPageState
    extends BlocState<ReviewFinishBloc, ReviewFinishPage>
    with TickerProviderStateMixin {
  AnimationController? clapAnimation;

  typeView() {
    List<Widget> types = [];

    for (int i = 0; i < widget.types.length; i++) {
      types.add(Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Center(
                child: customText(reviewTypeTextFinish(widget.types[i]),
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
              ),
            ),
            heightLine(height: 1, color: AppColors.primaryLight30)
          ],
        ),
      ));
    }

    return types;
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        return Container(
          color: AppColors.white,
          child: Scaffold(
            appBar: baseAppBar(
                context: context,
                onPressed: () {
                  pop(context);
                },
                title: ''),
            backgroundColor: AppColors.white,
            body: Container(
              height: MediaQuery.of(context).size.height -
                  (dataSaver.statusTop +
                      dataSaver.iosBottom +
                      AppBar().preferredSize.height),
              child: Column(
                children: [
                  spaceH(40),
                  Lottie.asset(AppImages.clap,
                      controller: clapAnimation,
                      width: 180,
                      height: 180, onLoaded: (composition) {
                    setState(() {
                      clapAnimation!..duration = composition.duration;
                      clapAnimation!.forward();
                    });
                  }),
                  customText('${widget.nickName}님의 클래스에\n도움이 될 후기를 남겼어요',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T20))),
                  spaceH(30),
                  Column(
                    children: typeView(),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: bottomButton(
                          context: context,
                          onPress: () {
                            if (dataSaver.chatDetailContext == null) {
                              pop(context);
                              return;
                            } else if (dataSaver.chatDetailContext != null) {
                              pop(dataSaver.chatDetailContext!);
                            }
                            if (dataSaver.reviewDetailBloc == null) {
                              pushTransition(
                                  context,
                                  ReviewDetailPage(
                                    classUuid: widget.classUuid,
                                    nickName: widget.nickName,
                                    myClass: widget.nickName ==
                                            dataSaver.profileGet!.nickName
                                        ? true
                                        : false,
                                  ));
                            }
                          },
                          text: '확인',
                          elevation: 0)),
                  spaceH(32)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    clapAnimation = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    clapAnimation!.dispose();
    super.dispose();
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  ReviewFinishBloc initBloc() {
    return ReviewFinishBloc(context)
      ..add(ReviewFinishInitEvent(classUuid: widget.classUuid));
  }
}
