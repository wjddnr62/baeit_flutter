import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/community_report/community_report_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:permission_handler/permission_handler.dart';

class CommunityReportPage extends BlocStatefulWidget {
  final int type;
  final String? communityUuid;
  final String? communityCommentUuid;

  CommunityReportPage(
      {required this.type, this.communityUuid, this.communityCommentUuid});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return CommunityReportState();
  }
}

class CommunityReportState
    extends BlocState<CommunityReportBloc, CommunityReportPage> {
  TextEditingController reportTextController = TextEditingController();

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
                    backgroundColor: AppColors.white,
                    resizeToAvoidBottomInset: true,
                    appBar: baseAppBar(
                        title: '신고하기',
                        context: context,
                        onPressed: () {
                          pop(context);
                        },
                        close: true),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 16, bottom: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                customText(
                                  '신고 이유',
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                                customText(
                                  ' (선택)',
                                  style: TextStyle(
                                      color: AppColors.gray400,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                                Expanded(child: Container()),
                                customText(
                                  reportTextController.text.characters.length
                                      .toString(),
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)),
                                ),
                                customText(
                                  ' / 2000',
                                  style: TextStyle(
                                      color: AppColors.gray400,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)),
                                )
                              ],
                            ),
                            spaceH(16),
                            Container(
                              height: 182,
                              child: TextFormField(
                                  onChanged: (text) {
                                    blankCheck(
                                        text: text,
                                        controller: reportTextController,
                                        multiline: true);
                                    setState(() {});
                                  },
                                  maxLength: 2000,
                                  maxLines: null,
                                  controller: reportTextController,
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
                                    hintText:
                                        '신고하려는 이유를 말씀해 주시면, 꼼꼼히 살펴 편하게 이용할 수 있도록 처리하겠습니다',
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
                                            width: 2,
                                            color: AppColors.primaryLight30)),
                                  )),
                            ),
                            spaceH(20),
                            relatedImage()
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 12 + dataSaver.iosBottom,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: AppColors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: AppColors.primary))),
                                child: Center(
                                  child: customText(
                                    AppStrings.of(StringKey.cancel),
                                    style: TextStyle(
                                        color: AppColors.primaryDark10,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          spaceW(12),
                          Expanded(
                              child: bottomButton(
                                  context: context,
                                  onPress: () {
                                    bloc.add(ReportEvent(
                                        communityUuid: widget.communityUuid,
                                        communityCommentUuid:
                                            widget.communityCommentUuid,
                                        reportText: reportTextController.text,
                                        type: widget.type));
                                  },
                                  text: '신고하기'))
                        ],
                      )),
                  loadingView(bloc.loading)
                ],
              ),
            ),
          );
        });
  }

  relatedImage() {
    return Column(
      children: [
        spaceH(14),
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
                  setState(() {});
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
                            setState(() {});
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

  @override
  blocListener(BuildContext context, state) {
    if (state is ReportState) {
      showToast(context: context, text: '신고 처리되었습니다');
      popWithResult(context, true);
    }

    if (state is DuplicateReportState) {
      if (widget.type == 0) {
        showToast(context: context, text: '이미 신고한 커뮤니티입니다');
      } else {
        showToast(context: context, text: '이미 신고한 댓글입니다');
      }
    }
  }

  @override
  CommunityReportBloc initBloc() {
    return CommunityReportBloc(context)..add(CommunityReportInitEvent());
  }
}
