import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/chat/chat_help.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/chat_help/chat_help_bloc.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHelpPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ChatHelpState();
  }
}

class ChatHelpState extends BlocState<ChatHelpBloc, ChatHelpPage> {
  String learnChangeText = '안녕하세요 :)\n혹시 첫 클래스는 배움교환으로 가능할까요?';
  String costQuestionText = '안녕하세요 :)\n클래스 너무 관심이 가는데,\n혹시';
  String costQuestionText2 = '으로도 가능할까요?';

  TextEditingController costQuestionController = TextEditingController();
  FocusNode costQuestionFocus = FocusNode();
  bool costQuestionPass = true;

  String nonFaceToFaceText = '안녕하세요 ;)\n혹시 비대면 클래스도\n가능한가요?';

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: AppColors.white,
                appBar: baseAppBar(
                    title: '',
                    context: context,
                    close: true,
                    onPressed: () {
                      pop(context);
                    }),
                body: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        spaceH(10),
                        customText('배잇생활, 시작이 어렵다면\n이건 어떠세요?',
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T20)),
                            textAlign: TextAlign.center),
                        spaceH(50),
                        learnChange(),
                        spaceH(40),
                        costQuestion(),
                        spaceH(40),
                        nonFaceToFace(),
                        spaceH(50)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  learnChange() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText('1. 배움교환 물어보기',
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T15))),
          spaceH(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200, width: 1)),
                  padding: EdgeInsets.all(12),
                  child: customText(learnChangeText,
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                          fontSize: fontSizeSet(textSize: TextSize.T14))),
                ),
              ),
              spaceW(10),
              Container(
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    popWithResult(context,
                        ChatHelp(msg: '$learnChangeText', subType: 'EXCHANGE'));
                  },
                  child: Center(
                    child: Row(
                      children: [
                        customText('문의해보기',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T15))),
                        spaceW(3),
                        Image.asset(
                          AppImages.iChatSendingW,
                          width: 18,
                          height: 18,
                        )
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.primary,
                      elevation: 0,
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              )
            ],
          ),
          spaceH(10),
          customText('이웃과 공유할 재능이 있다면!',
              style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                  fontSize: fontSizeSet(textSize: TextSize.T14)))
        ],
      ),
    );
  }

  costQuestion() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText('2. 비용 물어보기',
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T15))),
          spaceH(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200, width: 1)),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText(costQuestionText,
                          style: TextStyle(
                              color: AppColors.gray900,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.REGULAR),
                              fontSize: fontSizeSet(textSize: TextSize.T14))),
                      spaceH(4),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        child: Stack(
                          children: [
                            TextFormField(
                                onChanged: (text) {
                                  costQuestionPass = true;
                                  setState(() {});
                                },
                                maxLines: 1,
                                maxLength: 7,
                                controller: costQuestionController,
                                focusNode: costQuestionFocus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {},
                                style: TextStyle(
                                    color: AppColors.primaryDark10,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T13)),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  suffixIcon: costQuestionController
                                              .text.length >
                                          0
                                      ? Padding(
                                          padding: EdgeInsets.only(right: 30),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                costQuestionController.text =
                                                    '';
                                              });
                                            },
                                            child: Image.asset(
                                                AppImages.iInputClear,
                                                width: 20,
                                                height: 20),
                                          ),
                                        )
                                      : null,
                                  fillColor: AppColors.primaryLight50,
                                  filled: true,
                                  hintText: '희망 비용',
                                  hintStyle: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.REGULAR),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                  contentPadding:
                                      EdgeInsets.only(left: 10, right: 10),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          width: 0,
                                          color: AppColors.transparent)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          width: 0,
                                          color: AppColors.transparent)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          width: 0,
                                          color: AppColors.transparent)),
                                )),
                            Positioned(
                                top: 15,
                                bottom: 0,
                                right: 10,
                                child: customText(
                                  '원',
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T13)),
                                ))
                          ],
                        ),
                      ),
                      costQuestionPass
                          ? Container()
                          : issueMessage(title: '최소 3,000원 이상 입력해주세요'),
                      spaceH(4),
                      customText(costQuestionText2,
                          style: TextStyle(
                              color: AppColors.gray900,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.REGULAR),
                              fontSize: fontSizeSet(textSize: TextSize.T14))),
                    ],
                  ),
                ),
              ),
              spaceW(10),
              Container(
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    if (costQuestionController.text.length == 0 ||
                        costQuestionController.text == '' ||
                        int.parse(costQuestionController.text) < 3000) {
                      costQuestionPass = false;
                      FocusScope.of(context).requestFocus(costQuestionFocus);
                      setState(() {});
                    }

                    if (costQuestionPass) {
                      popWithResult(
                          context,
                          ChatHelp(
                              msg:
                                  '$costQuestionText ${costQuestionController.text}원$costQuestionText2',
                              subType: 'PRICE'));
                    }
                  },
                  child: Center(
                    child: Row(
                      children: [
                        customText('문의해보기',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T15))),
                        spaceW(3),
                        Image.asset(
                          AppImages.iChatSendingW,
                          width: 18,
                          height: 18,
                        )
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.primary,
                      elevation: 0,
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              )
            ],
          ),
          spaceH(10),
          customText('배우고 싶지만 비용이 부담스럽다면!',
              style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                  fontSize: fontSizeSet(textSize: TextSize.T14)))
        ],
      ),
    );
  }

  nonFaceToFace() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText('3. 비대면 문의',
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T15))),
          spaceH(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200, width: 1)),
                  padding: EdgeInsets.all(12),
                  child: customText(nonFaceToFaceText,
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                          fontSize: fontSizeSet(textSize: TextSize.T14))),
                ),
              ),
              spaceW(10),
              Container(
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    popWithResult(context,
                        ChatHelp(msg: '$nonFaceToFaceText', subType: 'UNTACT'));
                  },
                  child: Center(
                    child: Row(
                      children: [
                        customText('문의해보기',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T15))),
                        spaceW(3),
                        Image.asset(
                          AppImages.iChatSendingW,
                          width: 18,
                          height: 18,
                        )
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.primary,
                      elevation: 0,
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              )
            ],
          ),
          spaceH(10),
          customText('대면수업이 어렵다면!',
              style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                  fontSize: fontSizeSet(textSize: TextSize.T14)))
        ],
      ),
    );
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  ChatHelpBloc initBloc() {
    return ChatHelpBloc(context)..add(ChatHelpInitEvent());
  }
}
