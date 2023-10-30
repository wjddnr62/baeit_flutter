import 'dart:io';
import 'dart:math' as math;

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/feedback/feedback_bloc.dart';
import 'package:baeit/ui/feedback/feedback_detail_page.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:permission_handler/permission_handler.dart';

class FeedbackPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return FeedbackState();
  }
}

class FeedbackState extends BlocState<FeedbackBloc, FeedbackPage>
    with TickerProviderStateMixin {
  ScrollController typeController = ScrollController();
  bool typePass = true;

  TextEditingController contentController = TextEditingController();
  FocusNode contentFocus = FocusNode();
  bool contentPass = true;

  AnimationController? controller;

  ScrollController? feedScroll;

  selectTap() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Container(
        height: 36,
        child: Row(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    bloc.add(FeedbackTapChangeEvent(select: 0));
                  },
                  child: Center(
                    child: customText(
                      '들려주기',
                      style: TextStyle(
                          color: bloc.selectTap == 0
                              ? AppColors.white
                              : AppColors.gray400,
                          fontWeight: weightSet(
                              textWeight: bloc.selectTap == 0
                                  ? TextWeight.BOLD
                                  : TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T13)),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: bloc.selectTap == 0
                          ? AppColors.primary
                          : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6)),
                        side: bloc.selectTap == 0
                            ? BorderSide.none
                            : BorderSide(color: AppColors.gray200),
                      )),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    bloc.type = null;
                    bloc.typeSelect = false;
                    bloc.typeAnimationEnd = false;
                    contentController.text = '';
                    bloc.imageFiles = [];
                    bloc.add(FeedbackTapChangeEvent(select: 1));
                  },
                  child: Center(
                    child: customText(
                      '나의 소리함',
                      style: TextStyle(
                          color: bloc.selectTap == 1
                              ? AppColors.white
                              : AppColors.gray400,
                          fontWeight: weightSet(
                              textWeight: bloc.selectTap == 1
                                  ? TextWeight.BOLD
                                  : TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T13)),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: bloc.selectTap == 1
                          ? AppColors.primary
                          : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6)),
                        side: bloc.selectTap == 1
                            ? BorderSide.none
                            : BorderSide(color: AppColors.gray200),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  type() {
    return AnimatedContainer(
      onEnd: () {
        bloc.typeAnimationEnd = true;
        setState(() {});
      },
      duration: Duration(milliseconds: 300),
      height: bloc.typeSelect ? 260 : 48,
      decoration: bloc.typeSelect
          ? BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 2))
          : null,
      child: bloc.typeSelect && bloc.typeAnimationEnd
          ? Column(
              children: [
                spaceH(15),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      customText(
                        bloc.type == null ? '선택해주세요' : bloc.type!,
                        style: TextStyle(
                            color: bloc.type == null
                                ? AppColors.gray400
                                : AppColors.gray900,
                            fontWeight: weightSet(
                                textWeight: bloc.type == null
                                    ? TextWeight.REGULAR
                                    : TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T13)),
                      ),
                      Expanded(child: Container()),
                      Transform.rotate(
                        angle: 180 * math.pi / 180,
                        child: Image.asset(
                          AppImages.iSelectACDown,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                spaceH(15),
                heightLine(color: AppColors.primaryLight40, height: 1),
                spaceH(9),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Scrollbar(
                    isAlwaysShown: true,
                    controller: typeController,
                    child: ListView.builder(
                      controller: typeController,
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: GestureDetector(
                            onTap: () {
                              bloc.typeSelect = false;
                              bloc.typeAnimationEnd = false;
                              bloc.type = bloc.typeItems[idx];
                              typePass = true;
                              bloc.selectItem = idx;
                              setState(() {});
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: bloc.type == bloc.typeItems[idx]
                                      ? AppColors.primaryLight60
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.only(
                                  top: 15, bottom: 15, left: 10),
                              child: customText(
                                bloc.typeItems[idx],
                                style: TextStyle(
                                    color: bloc.type == bloc.typeItems[idx]
                                        ? AppColors.primaryDark10
                                        : AppColors.gray900,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T13)),
                              ),
                            ),
                          ),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: bloc.typeItems.length,
                    ),
                  ),
                )
              ],
            )
          : Align(
              alignment: Alignment.topLeft,
              child: bloc.typeSelect
                  ? Container()
                  : ElevatedButton(
                      onPressed: () {
                        bloc.typeSelect = true;
                        bloc.typeAnimationEnd = false;
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.white,
                          elevation: 0,
                          padding: EdgeInsets.only(
                              top: 15, bottom: 15, left: 10, right: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: AppColors.gray200))),
                      child: Row(
                        children: [
                          customText(
                            bloc.type == null ? '선택해주세요' : bloc.type!,
                            style: TextStyle(
                                color: bloc.type == null
                                    ? AppColors.gray400
                                    : AppColors.gray900,
                                fontWeight: weightSet(
                                    textWeight: bloc.type == null
                                        ? TextWeight.REGULAR
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T13)),
                          ),
                          Expanded(child: Container()),
                          Image.asset(
                            AppImages.iSelectACDown,
                            width: 16,
                            height: 16,
                          )
                        ],
                      ),
                    ),
            ),
    );
  }

  relatedImage() {
    return Column(
      children: [
        spaceH(24),
        Container(
          height: 48,
          child: Row(
            children: [
              customText(
                AppStrings.of(StringKey.relatedImages),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              ),
              spaceW(4),
              customText(
                '(${AppStrings.of(StringKey.choice)})',
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              )
            ],
          ),
        ),
        Container(
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              if (Platform.isAndroid
                  ? await Permission.storage.isGranted
                  : await Permission.photos.isGranted ||
                      await Permission.photos.isLimited) {
                List<Asset> resultList = [];
                if (bloc.imageFiles.length == 0 ||
                    bloc.imageFiles.length < 10) {
                  resultList = await MultiImagePicker.pickImages(
                      maxImages: 10 - bloc.imageFiles.length,
                      enableCamera: false,
                      selectedAssets: resultList);

                  if (!mounted) return;

                  for (int i = 0; i < resultList.length; i++) {
                    bloc.imageFiles.add(resultList[i]);
                  }
                  systemColorSetting();
                  bloc.add(GetFileEvent());
                }
              } else if (Platform.isAndroid
                  ? await Permission.storage.isDenied ||
                      await Permission.storage.isPermanentlyDenied
                  : await Permission.photos.isDenied ||
                      await Permission.photos.isPermanentlyDenied) {
                decisionDialog(
                    context: context,
                    barrier: false,
                    text: Platform.isAndroid
                        ? AppStrings.of(StringKey.storageCheckText)
                        : AppStrings.of(StringKey.photoCheckText),
                    allowText: AppStrings.of(StringKey.check),
                    disallowText: AppStrings.of(StringKey.cancel),
                    allowCallback: () async {
                      popDialog(context);
                      await openAppSettings();
                    },
                    disallowCallback: () {
                      popDialog(context);
                    });
              }
            },
            style: ElevatedButton.styleFrom(
                primary: AppColors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.primary))),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  customText(
                    '${AppStrings.of(StringKey.registration)}  ${bloc.imageFiles.length == 0 ? 0 : bloc.imageFiles.length}',
                    style: TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  ),
                  customText(
                    ' / 10',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  )
                ],
              ),
            ),
          ),
        ),
        spaceH(12),
        bloc.imageFiles.length == 0
            ? Container()
            : Container(
                width: MediaQuery.of(context).size.width,
                height: 54,
                child: ListView.builder(
                  itemBuilder: (context, idx) {
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            bloc.imageFiles.removeAt(idx);
                            bloc.add(GetFileEvent());
                          },
                          child: Container(
                            width: 96,
                            height: 54,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                    child: AssetThumb(
                                  asset: bloc.imageFiles[idx],
                                      width: MediaQuery.of(context).size.width.toInt(),
                                      height: MediaQuery.of(context).size.width.toInt(),
                                  spinner: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                    ),
                                  ),
                                )),
                                Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Image.asset(
                                      AppImages.iInputClearTrans,
                                      width: 16,
                                      height: 16,
                                    ))
                              ],
                            ),
                          ),
                        ),
                        spaceW(10)
                      ],
                    );
                  },
                  shrinkWrap: true,
                  itemCount: bloc.imageFiles.length,
                  scrollDirection: Axis.horizontal,
                ),
              )
      ],
    );
  }

  toTell() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          spaceH(44),
          Center(
            child: Image.asset(
              AppImages.imgFeedback,
              width: 200,
              height: 112,
            ),
          ),
          spaceH(74),
          Container(
            height: 20,
            child: customText(
              '유형',
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
            ),
          ),
          spaceH(14),
          type(),
          typePass ? Container() : issueMessage(title: '유형을 선택해주세요'),
          spaceH(34),
          Row(
            children: [
              customText(
                AppStrings.of(StringKey.content),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              ),
              Expanded(child: Container()),
              customText(
                contentController.text.characters.length.toString(),
                style: TextStyle(
                    color: AppColors.primaryDark10,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              ),
              customText(
                ' / 1 ~ 1000',
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              ),
            ],
          ),
          spaceH(14),
          Container(
            height: 182,
            child: TextFormField(
                onChanged: (text) {
                  contentPass = true;
                  blankCheck(
                      text: text,
                      controller: contentController,
                      multiline: true);
                  setState(() {});
                },
                maxLength: 1000,
                maxLines: null,
                controller: contentController,
                focusNode: contentFocus,
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
                  hintText: '동네 배움을 실천하면서 느낀 점을 들려주시면 더 나은 환경을 제공하도록 할게요 :)',
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
                      borderSide:
                          BorderSide(width: 1, color: AppColors.gray200)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 1, color: AppColors.primaryLight40)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 2, color: AppColors.primaryLight30)),
                )),
          ),
          contentPass
              ? Container()
              : issueMessage(title: '피드백 내용은 최소 1자 ~ 최대 1000자로 적어주세요'),
          relatedImage(),
          spaceH(48)
        ],
      ),
    );
  }

  typeText(text) {
    switch (text) {
      case 'NOT_WORK':
        return '작동하지 않아요';
      case 'UPGRADE':
        return '이렇게 바꿔주세요';
      case 'LIKE':
        return '이런 점 좋아요';
      case 'REQUEST':
        return '할 말 있어요';
    }
  }

  feedbackItem(idx) {
    return GestureDetector(
      onTap: () {
        pushTransition(
            context,
            FeedbackDetailPage(
                feedbackUuid: bloc.feedback!.feedbackData[idx].feedbackUuid));
      },
      child: Container(
        color: AppColors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 53,
                    height: 24,
                    decoration: BoxDecoration(
                        color: bloc.feedback!.feedbackData[idx].answerFlag == 0
                            ? AppColors.gray600
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(4)),
                    child: Center(
                      child: customText(
                        bloc.feedback!.feedbackData[idx].answerFlag == 0
                            ? '답변대기'
                            : '답변완료',
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T10)),
                      ),
                    ),
                  ),
                  spaceW(6),
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.gray100),
                        borderRadius: BorderRadius.circular(4)),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: customText(
                        typeText(bloc.feedback!.feedbackData[idx].type),
                        style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T10)),
                      ),
                    ),
                  )
                ],
              ),
              spaceH(12),
              customText(
                bloc.feedback!.feedbackData[idx].feedbackText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              ),
              spaceH(4),
              customText(
                DateTime.now()
                            .difference(
                                bloc.feedback!.feedbackData[idx].createDate)
                            .inMinutes >
                        14400
                    ? bloc.feedback!.feedbackData[idx].createDate.yearMonthDay
                    : timeCalculationText(DateTime.now()
                        .difference(bloc.feedback!.feedbackData[idx].createDate)
                        .inMinutes),
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              )
            ],
          ),
        ),
      ),
    );
  }

  mySoundBox() {
    return bloc.feedback == null
        ? Container()
        : Column(
            children: [
              spaceH(26),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    customText(
                      '총 ${bloc.feedback!.totalRow ?? 0} 건',
                      style: TextStyle(
                          color: AppColors.gray400,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12)),
                    ),
                    Expanded(child: Container()),
                    GestureDetector(
                      onTap: () {
                        bloc.add(FeedbackTypeChangeEvent(idx: 0));
                      },
                      child: customText(
                        AppStrings.of(StringKey.all),
                        style: TextStyle(
                            color: bloc.feedbackType == 0
                                ? AppColors.gray900
                                : AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                      ),
                    ),
                    spaceW(8),
                    widthOneLine(10),
                    spaceW(8),
                    GestureDetector(
                      onTap: () {
                        bloc.add(FeedbackTypeChangeEvent(idx: 2));
                      },
                      child: customText(
                        '답변완료',
                        style: TextStyle(
                            color: bloc.feedbackType == 2
                                ? AppColors.gray900
                                : AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                      ),
                    ),
                    spaceW(8),
                    widthOneLine(10),
                    spaceW(8),
                    GestureDetector(
                      onTap: () {
                        bloc.add(FeedbackTypeChangeEvent(idx: 1));
                      },
                      child: customText(
                        '답변대기',
                        style: TextStyle(
                            color: bloc.feedbackType == 1
                                ? AppColors.gray900
                                : AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                      ),
                    ),
                  ],
                ),
              ),
              spaceH(16),
              bloc.feedback!.feedbackData.length == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        spaceH(MediaQuery.of(context).size.height / 6),
                        Image.asset(
                          AppImages.imgEmptySomething,
                          width: 135,
                          height: 135,
                        ),
                        customText(
                          '피드백을 남겨주시면\n보다 좋은 동네 배움을 하실 수 있어요',
                          style: TextStyle(
                              color: AppColors.gray400,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.REGULAR),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                          textAlign: TextAlign.center,
                        )
                      ],
                    )
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, idx) {
                        return Column(
                          children: [
                            spaceH(20),
                            feedbackItem(idx),
                            spaceH(20),
                            heightLine(height: 1)
                          ],
                        );
                      },
                      shrinkWrap: true,
                      itemCount: bloc.feedback == null
                          ? 0
                          : bloc.feedback!.feedbackData.length,
                    )
            ],
          );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: (bloc.selectTap == 0 &&
                    (contentController.text.length != 0 ||
                        bloc.typeSelect ||
                        bloc.imageFiles.length != 0))
                ? () {
                    if (bloc.selectTap == 0 &&
                        (contentController.text.length != 0 ||
                            bloc.typeSelect ||
                            bloc.imageFiles.length != 0)) {
                      decisionDialog(
                          context: context,
                          barrier: false,
                          text: AppStrings.of(StringKey.exitCheckText),
                          allowText: AppStrings.of(StringKey.check),
                          disallowText: AppStrings.of(StringKey.cancel),
                          allowCallback: () {
                            popDialog(context);

                            pop(context);
                          },
                          disallowCallback: () {
                            popDialog(context);
                          });
                    } else {
                      return Future.value(true);
                    }
                    return Future.value(false);
                  }
                : null,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                bloc.typeSelect = false;
                bloc.typeAnimationEnd = false;
                setState(() {});
              },
              child: Container(
                color: AppColors.white,
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: 0,
                      bottom: MediaQuery.of(context).viewInsets.bottom != 0
                          ? 0
                          : bloc.selectTap == 0
                              ? 60
                              : 0,
                      child: Scaffold(
                        backgroundColor: AppColors.white,
                        appBar: baseAppBar(
                            title: AppStrings.of(StringKey.feedback),
                            context: context,
                            onPressed: () {
                              if (bloc.selectTap == 0) {
                                decisionDialog(
                                    context: context,
                                    barrier: false,
                                    text:
                                        AppStrings.of(StringKey.exitCheckText),
                                    allowText: AppStrings.of(StringKey.check),
                                    disallowText:
                                        AppStrings.of(StringKey.cancel),
                                    allowCallback: () {
                                      popDialog(context);

                                      pop(context);
                                    },
                                    disallowCallback: () {
                                      popDialog(context);
                                    });
                              } else {
                                pop(context);
                              }
                            }),
                        resizeToAvoidBottomInset: true,
                        body: SingleChildScrollView(
                          controller: feedScroll,
                          child: Column(
                            children: [
                              spaceH(10),
                              selectTap(),
                              bloc.selectTap == 0 ? toTell() : mySoundBox()
                            ],
                          ),
                        ),
                      ),
                    ),
                    bloc.selectTap == 0
                        ? Positioned(
                            bottom: 60 + MediaQuery.of(context).padding.bottom,
                            child: bottomGradient(
                                context: context,
                                height: 20,
                                color: AppColors.white))
                        : Container(),
                    bloc.selectTap == 0
                        ? Positioned(
                            bottom: 12 + MediaQuery.of(context).padding.bottom,
                            left: 12,
                            right: 12,
                            child: bottomButton(
                                context: context,
                                text: '보내기',
                                onPress: () {
                                  bool move = false;
                                  if (bloc.type == null) {
                                    typePass = false;
                                    if (!bloc.typeSelect) {
                                      bloc.typeAnimationEnd = false;
                                    }
                                    bloc.typeSelect = true;
                                    move = true;
                                    setState(() {});
                                  }

                                  if (contentController.text.length == 0) {
                                    contentPass = false;
                                    if (!move) {
                                      FocusScope.of(context)
                                          .requestFocus(contentFocus);
                                    }
                                    setState(() {});
                                  }

                                  if (typePass && contentPass) {
                                    bloc.add(FeedbackSendEvent(
                                        feedback: contentController.text));
                                  }
                                }))
                        : Container(),
                    loadingView(bloc.loading)
                  ],
                ),
              ),
            ),
          );
        });
  }

  finishFeedbackDialog() {
    return ListView(
      shrinkWrap: true,
      children: [
        spaceH(28),
        SizedBox(
          width: 135,
          height: 135,
          child: Lottie.asset(AppImages.checkAnimation, controller: controller,
              onLoaded: (composition) {
            setState(() {
              controller!.reset();
              controller!..duration = composition.duration;
              controller!.forward();
            });
          }),
        ),
        Container(
          height: 24,
          child: customText(
            '소중한 의견 감사합니다!',
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T17)),
            textAlign: TextAlign.center,
          ),
        ),
        spaceH(20),
        customText(
          '의견을 바탕으로 더 좋은 배움을 위해\n개선하는 배잇이 되겠습니다 :)',
          style: TextStyle(
              color: AppColors.gray600,
              fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
              fontSize: fontSizeSet(textSize: TextSize.T12)),
          textAlign: TextAlign.center,
        ),
        spaceH(60),
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: bottomButton(
              context: context,
              text: AppStrings.of(StringKey.check),
              onPress: () {
                bloc.type = null;
                bloc.typeSelect = false;
                bloc.typeAnimationEnd = false;
                contentController.text = '';
                bloc.imageFiles = [];
                bloc.feedbackType = 0;
                popDialog(context);
                bloc.add(FeedbackTapChangeEvent(select: 1));
              }),
        )
      ],
    );
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    super.initState();
    feedScroll = ScrollController()
      ..addListener(() {
        if (bloc.feedback != null && bloc.feedback!.feedbackData.length > 2) {
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < feedScroll!.offset) &&
              feedScroll!.offset >= feedScroll!.position.maxScrollExtent &&
              !feedScroll!.position.outOfRange) {
            bloc.scrollUnder = true;
            bloc.bottomOffset = feedScroll!.offset;
          }
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < feedScroll!.offset) &&
              feedScroll!.offset >=
                  (feedScroll!.position.maxScrollExtent * 0.7) &&
              !feedScroll!.position.outOfRange) {
            bloc.add(GetDataEvent());
          }
          if (feedScroll!.position.userScrollDirection ==
              ScrollDirection.forward) {
            bloc.bottomOffset = 0;
            bloc.scrollUnder = false;
          }
        }
      });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is FeedbackInitState) {}

    if (state is FeedbackSendState) {
      customDialog(
          context: context, barrier: true, widget: finishFeedbackDialog());
    }

    if (state is FeedbackTypeChangeState) {
      bloc.add(FeedbackReloadEvent());
    }

    if (state is FeedbackTapChangeState) {
      feedScroll!.jumpTo(0);
    }

    if (state is ScrollTopState) {
      feedScroll!.jumpTo(0);
    }
  }

  @override
  FeedbackBloc initBloc() {
    return FeedbackBloc(context)..add(FeedbackInitEvent());
  }
}
