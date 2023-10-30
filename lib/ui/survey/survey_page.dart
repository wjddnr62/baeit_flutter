import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/survey/survey_bloc.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyPage extends BlocStatefulWidget {
  final String surveyUuid;
  final String url;

  SurveyPage({required this.url, required this.surveyUuid});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return SurveyState();
  }
}

class SurveyState extends BlocState<SurveyBloc, SurveyPage>
    with TickerProviderStateMixin {
  late WebViewController webViewController;
  AnimationController? controller;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        return Container(
          color: AppColors.white,
          child: SafeArea(
            child: Stack(
              children: [
                Scaffold(
                  appBar: baseAppBar(
                      context: context,
                      title: '투표하기',
                      onPressed: () {
                        pop(context);
                      }),
                  body: Stack(
                    children: [
                      bloc.surveyFinish
                          ? Container()
                          : WebView(
                              initialUrl: widget.url,
                              javascriptMode: JavascriptMode.unrestricted,
                              zoomEnabled: false,
                              onWebViewCreated: (controller) async {
                                webViewController = controller;
                              },
                              onPageStarted: (url) {
                                if (url.contains('formResponse')) {
                                  bloc.add(SurveyFinishEvent(surveyUuid: widget.surveyUuid));
                                }
                              }),
                    ],
                  ),
                ),
                bloc.surveyFinish
                    ? Positioned.fill(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: surveyFinishView(),
                      )
                    : Container(),
                loadingView(bloc.loading)
              ],
            ),
          ),
        );
      },
    );
  }

  surveyFinishView() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          spaceH(100),
          SizedBox(
            width: 135,
            height: 135,
            child: Lottie.asset(AppImages.checkAnimation,
                controller: controller, onLoaded: (composition) {
              setState(() {
                controller!.reset();
                controller!..duration = composition.duration;
                controller!.forward();
              });
            }),
          ),
          customText('투표를 완료하셨어요!',
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T20))),
          spaceH(20),
          customText('내용을 바탕으로 더 좋은 배움을 위해\n개선하는 배잇이 되겠습니다 :)',
              style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                  fontSize: fontSizeSet(textSize: TextSize.T14))),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: bottomButton(
                context: context,
                onPress: () {
                  pop(context);
                },
                text: '확인'),
          )
        ],
      ),
    );
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  SurveyBloc initBloc() {
    return SurveyBloc(context)..add(SurveyInitEvent());
  }
}
