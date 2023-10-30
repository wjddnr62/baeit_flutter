import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/review/create_review_bloc.dart';
import 'package:baeit/ui/review/review_detail_bloc.dart';
import 'package:baeit/ui/review/review_finish_page.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateReviewPage extends BlocStatefulWidget {
  final String classUuid;
  final String nickName;
  final String? classReviewUuid;
  final bool edit;

  CreateReviewPage(
      {required this.classUuid,
      required this.nickName,
      this.classReviewUuid,
      this.edit = false});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return CreateReviewState();
  }
}

class CreateReviewState extends BlocState<CreateReviewBloc, CreateReviewPage> {
  ScrollController scrollController = ScrollController();

  TextEditingController experienceController = TextEditingController();
  FocusNode experienceFocus = FocusNode();

  bool typePass = true;
  bool reviewPass = true;

  typeSelect() {
    List<Widget> types = [];
    for (int i = 0; i < bloc.reviewType.length; i++) {
      types.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                typePass = true;
              });
              bloc.add(
                  TypeSelectEvent(index: i, typeSelect: bloc.reviewSelect[i]));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 6.5, bottom: 6.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    spaceW(20),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                          value: bloc.reviewSelect[i],
                          onChanged: (value) {
                            setState(() {
                              typePass = true;
                            });
                            bloc.add(TypeSelectEvent(
                                index: i, typeSelect: bloc.reviewSelect[i]));
                          },
                          activeColor: AppColors.primary,
                          side: BorderSide(
                              width: bloc.reviewSelect[i] ? 0 : 1,
                              color: AppColors.gray300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          )),
                    ),
                    spaceW(8),
                    customText(reviewTypeText(bloc.reviewType[i]),
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T15)))
                  ],
                )),
          ),
          spaceH(10)
        ],
      ));
    }

    return types;
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
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                widget.edit && bloc.reviewDetail == null
                    ? Container()
                    : Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Scaffold(
                            resizeToAvoidBottomInset: true,
                            appBar: baseAppBar(
                                title: '후기 남기기',
                                centerTitle: true,
                                context: context,
                                onPressed: () => pop(context)),
                            backgroundColor: AppColors.white,
                            body: Container(
                              height: MediaQuery.of(context).size.height,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    bottom: 80,
                                    left: 0,
                                    right: 0,
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 48,
                                            child: Row(
                                              children: [
                                                spaceW(20),
                                                customText('어떤 클래스였나요?',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray900,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .BOLD),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T15)))
                                              ],
                                            ),
                                          ),
                                          ListView(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            children:
                                                bloc.reviewSelect.length == 0
                                                    ? []
                                                    : typeSelect(),
                                            padding: EdgeInsets.zero,
                                          ),
                                          typePass
                                              ? Container()
                                              : Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  child: issueMessage(
                                                      title: '1개 이상 선택해주세요')),
                                          spaceH(30),
                                          Container(
                                            height: 48,
                                            child: Row(
                                              children: [
                                                spaceW(20),
                                                customText('경험을 들려주세요!',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray900,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .BOLD),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T15))),
                                                Expanded(
                                                  child: Container(),
                                                ),
                                                customText(
                                                    experienceController.text ==
                                                            ''
                                                        ? '0'
                                                        : experienceController
                                                            .text.length
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryDark10,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .MEDIUM),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T12))),
                                                customText(' / 5 ~ 300',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray500,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .MEDIUM),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T12))),
                                                spaceW(20)
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 182,
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: TextFormField(
                                                onChanged: (text) {
                                                  blankCheck(
                                                      text: text,
                                                      controller:
                                                          experienceController,
                                                      multiline: true);
                                                  reviewPass = true;
                                                  setState(() {});
                                                },
                                                maxLength: 300,
                                                maxLines: null,
                                                controller:
                                                    experienceController,
                                                focusNode: experienceFocus,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                textInputAction:
                                                    TextInputAction.newline,
                                                onFieldSubmitted: (value) {},
                                                expands: true,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryDark10,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T14)),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  isCollapsed: true,
                                                  hintText:
                                                      '다른 이웃에게 도움이 될 수 있는\n클래스 과정과 결과에 대해 적어주세요',
                                                  hintMaxLines: 3,
                                                  hintStyle: TextStyle(
                                                      color: AppColors
                                                          .primaryDark10
                                                          .withOpacity(0.4),
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .REGULAR),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T13)),
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 10,
                                                          top: 10,
                                                          bottom: 10,
                                                          right: 10),
                                                  fillColor:
                                                      AppColors.primaryLight60,
                                                  filled: true,
                                                  counterText: '',
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: AppColors
                                                              .gray200)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: AppColors
                                                              .primaryLight40)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          width: 2,
                                                          color: AppColors
                                                              .primaryLight30)),
                                                )),
                                          ),
                                          reviewPass
                                              ? Container()
                                              : Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  child: issueMessage(
                                                      title: '5글자 이상 적어주세요')),
                                          reviewImage(),
                                          spaceH(30),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 80,
                                      child: bottomGradient(
                                          context: context,
                                          height: 20,
                                          color: AppColors.white)),
                                  Positioned(
                                      bottom: 32,
                                      left: 12,
                                      right: 12,
                                      child: bottomButton(
                                          context: context,
                                          text: '저장',
                                          onPress: () {
                                            saveReview();
                                          })),
                                ],
                              ),
                            )),
                      ),
                loadingView(bloc.loading)
              ],
            ),
          ),
        );
      },
    );
  }

  saveReview() async {
    if (bloc.reviewSelect.indexWhere((element) => element == true) == -1) {
      setState(() {
        typePass = false;
        scrollController.animateTo(0,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
      });
    }

    if (experienceController.text.length < 5) {
      setState(() {
        reviewPass = false;
      });
        if (typePass) {
          FocusScope.of(context).requestFocus(experienceFocus);
          await Future.delayed(Duration(milliseconds: 1000));
          scrollController.jumpTo(0);
          scrollController.animateTo(scrollController.offset + 240, duration: Duration(milliseconds: 300), curve: Curves.ease);
        }

    }

    if (typePass && reviewPass) {
      bloc.add(SaveReviewEvent(
          classUuid: widget.classUuid, review: experienceController.text));
    }
  }

  reviewImage() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          spaceH(24),
          Container(
            height: 48,
            child: Row(
              children: [
                customText(
                  '첨부 이미지',
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
                      '${AppStrings.of(StringKey.registration)}  ${widget.edit ? bloc.imageFiles.length + (bloc.reviewDetail!.images!.indexWhere((element) => element.representativeFlag == 1) != -1 ? bloc.reviewDetail!.images!.length - 1 : bloc.reviewDetail!.images!.length) : bloc.imageFiles.length == 0 ? 0 : bloc.imageFiles.length.toString()}',
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
          bloc.imageFiles.length == 0 &&
                  (widget.edit && bloc.reviewDetail!.images!.length == 0)
              ? Container()
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 54,
                  child: ListView.builder(
                    itemBuilder: (context, idx) {
                      if (widget.edit) {
                        if (idx <
                            ((bloc.reviewDetail!.images!.indexWhere((element) =>
                                        element.representativeFlag == 1) ==
                                    -1)
                                ? bloc.reviewDetail!.images!.length
                                : bloc.reviewDetail!.images!.length - 1)) {
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  bloc.reviewDetail!.images!.removeAt(((bloc
                                              .reviewDetail!.images!
                                              .indexWhere((element) =>
                                                  element.representativeFlag ==
                                                  1) ==
                                          -1)
                                      ? idx
                                      : idx + 1));
                                  bloc.add(GetFileEvent());
                                },
                                child: Container(
                                  width: 96,
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: CacheImage(
                                        imageUrl:
                                            '${bloc.reviewDetail!.images![((bloc.reviewDetail!.images!.indexWhere((element) => element.representativeFlag == 1) == -1) ? idx : idx + 1)].toView(
                                          context: context,
                                        )}',
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                        placeholder: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary),
                                          ),
                                        ),
                                      )),
                                      Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Image.asset(
                                            AppImages.iInputClear,
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
                        } else {
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  bloc.imageFiles.removeAt((((bloc
                                                      .reviewDetail!.images!
                                                      .indexWhere((element) =>
                                                          element.representativeFlag ==
                                                          1) ==
                                                  -1)
                                              ? bloc
                                                  .reviewDetail!.images!.length
                                              : (bloc.reviewDetail!.images!.length -
                                                  1)) >
                                          idx + 1)
                                      ? (bloc.reviewDetail!.images!.indexWhere(
                                                  (element) => element.representativeFlag == 1) ==
                                              -1)
                                          ? bloc.reviewDetail!.images!.length - idx + 1
                                          : (bloc.reviewDetail!.images!.length - 1) - idx + 1
                                      : (bloc.reviewDetail!.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                          ? idx - (bloc.reviewDetail!.images!.length)
                                          : idx - (bloc.reviewDetail!.images!.length - 1));
                                  bloc.add(GetFileEvent());
                                },
                                child: Container(
                                  width: 96,
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: AssetThumb(
                                        asset: bloc.imageFiles[((bloc
                                                            .reviewDetail!
                                                            .images!
                                                            .indexWhere((element) =>
                                                                element
                                                                    .representativeFlag ==
                                                                1) ==
                                                        -1)
                                                    ? bloc.reviewDetail!.images!
                                                        .length
                                                    : bloc.reviewDetail!.images!
                                                            .length -
                                                        1) >
                                                idx
                                            ? (bloc.reviewDetail!.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                                ? bloc.reviewDetail!.images!.length - idx
                                                : (bloc.reviewDetail!.images!.length - 1) - idx
                                            : (bloc.reviewDetail!.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                                ? idx - (bloc.reviewDetail!.images!.length)
                                                : idx - (bloc.reviewDetail!.images!.length - 1)],
                                        spinner: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary),
                                          ),
                                        ),
                                        width: MediaQuery.of(context)
                                            .size
                                            .width
                                            .toInt(),
                                        height: MediaQuery.of(context)
                                            .size
                                            .width
                                            .toInt(),
                                      )),
                                      Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Image.asset(
                                            AppImages.iInputClear,
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
                        }
                      } else {
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
                                      width: MediaQuery.of(context)
                                          .size
                                          .width
                                          .toInt(),
                                      height: MediaQuery.of(context)
                                          .size
                                          .width
                                          .toInt(),
                                      spinner: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                      }
                    },
                    shrinkWrap: true,
                    itemCount: widget.edit
                        ? (bloc.reviewDetail!.images!.indexWhere((element) =>
                                        element.representativeFlag == 1) !=
                                    -1
                                ? bloc.reviewDetail!.images!.length - 1
                                : bloc.reviewDetail!.images!.length) +
                            bloc.imageFiles.length
                        : bloc.imageFiles.length,
                    scrollDirection: Axis.horizontal,
                  ),
                )
        ],
      ),
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is CreateReviewInitState) {
      if (widget.edit) {
        experienceController.text = bloc.reviewDetail!.contentText;
      }
    }

    if (state is SaveReviewState) {
      if (dataSaver.reviewDetailBloc != null) {
        dataSaver.reviewDetailBloc!.add(ReviewDetailInitEvent(
            classUuid: dataSaver.reviewDetailBloc!.classUuid));
        pop(context);
      } else {
        popWithResult(context, true);
      }
      pushTransition(
          context,
          ReviewFinishPage(
              nickName: widget.nickName,
              types: state.types,
              classUuid: widget.classUuid));
    }
  }

  @override
  CreateReviewBloc initBloc() {
    return CreateReviewBloc(context)
      ..add(CreateReviewInitEvent(
          edit: widget.edit, classReviewUuid: widget.classReviewUuid));
  }
}
