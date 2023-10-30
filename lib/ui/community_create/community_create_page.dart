import 'dart:io';
import 'dart:math' as math;

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/variations_class.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/service/image_multiple_upload_service.dart';
import 'package:baeit/data/community/community_create.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/community_create/community_create_bloc.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/my_create_community/my_create_community_bloc.dart';
import 'package:baeit/ui/neighborhood_add/neighborhood_add_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
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
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class CommunityCreatePage extends BlocStatefulWidget {
  final int idx;
  final bool edit;
  final String? communityUuid;
  final bool myCreate;
  final bool stop;

  CommunityCreatePage(
      {required this.idx,
      this.edit = false,
      this.communityUuid,
      this.myCreate = false,
      this.stop = false});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return CommunityCreateState();
  }
}

class CommunityCreateState
    extends BlocState<CommunityCreateBloc, CommunityCreatePage>
    with TickerProviderStateMixin {
  TextEditingController contentController = TextEditingController();
  FocusNode contentFocus = FocusNode();
  bool contentPass = true;
  AnimationController? controller;
  ScrollController scrollController = ScrollController();
  bool tempCheck = false;

  List<FocusNode> informFocus = List.generate(5, (index) => FocusNode());
  List<bool> informTextCheck = List.generate(5, (index) => false);
  List<bool> informFocusCheck = List.generate(5, (index) => false);
  List<bool> informTextingCheck = List.generate(5, (index) => false);
  List<CommunityKeyword> informKeyword = [];
  bool informPass = true;

  List<FocusNode> learnFocus = List.generate(5, (index) => FocusNode());
  List<bool> learnTextCheck = List.generate(5, (index) => false);
  List<bool> learnFocusCheck = List.generate(5, (index) => false);
  List<bool> learnTextingCheck = List.generate(5, (index) => false);
  List<CommunityKeyword> learnKeyword = [];
  bool learnPass = true;

  List<FocusNode> meetFocus = List.generate(5, (index) => FocusNode());
  List<bool> meetTextCheck = List.generate(5, (index) => false);
  List<bool> meetFocusCheck = List.generate(5, (index) => false);
  List<bool> meetTextingCheck = List.generate(5, (index) => false);
  List<CommunityKeyword> meetKeyword = [];
  bool meetPass = true;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () {
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
              return Future.value(false);
            },
            child: GestureDetector(
              onTap: () {
                if (!bloc.typeHide) bloc.add(CommunityTypeViewEvent());
                FocusScope.of(context).unfocus();
              },
              child: Container(
                color: AppColors.white,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Scaffold(
                        backgroundColor: AppColors.white,
                        appBar: baseAppBar(
                            title: '',
                            context: context,
                            onPressed: () {
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
                            }),
                        resizeToAvoidBottomInset: true,
                        body: Container(
                          color: AppColors.white,
                          height: MediaQuery.of(context).size.height -
                              (60 +
                                  MediaQuery.of(context).padding.top +
                                  MediaQuery.of(context).padding.bottom),
                          child: Stack(
                            children: [
                              (bloc.communityDetail == null && widget.edit)
                                  ? Container()
                                  : SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          spaceH(10),
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: GestureDetector(
                                              onTap: () {
                                                bloc.add(
                                                    CommunityTypeViewEvent());
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  customText(
                                                      communityType(
                                                          bloc.communityType),
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .BOLD),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T16))),
                                                  spaceW(4),
                                                  Image.asset(
                                                    AppImages.iSelectACDown,
                                                    width: 16,
                                                    height: 16,
                                                    color: AppColors.gray400,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          spaceH(20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 48,
                                                child: Row(
                                                  children: [
                                                    spaceW(20),
                                                    customText('활동 동네',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .gray900,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .BOLD),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T14))),
                                                    Expanded(
                                                        child: Container()),
                                                    customText('최대 3개',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .secondaryDark30,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .MEDIUM),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T12))),
                                                    spaceW(20),
                                                  ],
                                                ),
                                              ),
                                              neighborHoodList(),
                                              communityTypeCreate(
                                                          bloc.communityType) ==
                                                      'EXCHANGE'
                                                  ? informView()
                                                  : Container(),
                                              communityTypeCreate(
                                                          bloc.communityType) ==
                                                      'EXCHANGE'
                                                  ? learnView()
                                                  : Container(),
                                              communityTypeCreate(
                                                          bloc.communityType) ==
                                                      'WITH_ME'
                                                  ? meetView()
                                                  : Container(),
                                              contentView(),
                                              spaceH(20),
                                              contentImage(),
                                              spaceH(120)
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                              Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 60,
                                  child: bottomGradient(
                                      context: context,
                                      height: 20,
                                      color: AppColors.white)),
                              Positioned(
                                  left: 12,
                                  right: 12,
                                  bottom: 0,
                                  child: Container(
                                    color: AppColors.white,
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        widget.edit
                                            ? Container()
                                            : Container(
                                                height: 48,
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                      communitySave(
                                                          type: 'TEMP');
                                                      dataSaver.learnBloc!.add(
                                                          CommunityReloadEvent());
                                                      if (dataSaver
                                                              .myCreateCommunityBloc !=
                                                          null) {
                                                        dataSaver
                                                            .myCreateCommunityBloc!
                                                            .add(
                                                                StatusChangeEvent());
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            AppColors.white,
                                                        elevation: 0,
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 24,
                                                                right: 24),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            side: BorderSide(
                                                                width: 1,
                                                                color: AppColors
                                                                    .gray200))),
                                                    child: Center(
                                                      child: customText('임시저장',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .gray500,
                                                              fontWeight: weightSet(
                                                                  textWeight:
                                                                      TextWeight
                                                                          .MEDIUM),
                                                              fontSize: fontSizeSet(
                                                                  textSize:
                                                                      TextSize
                                                                          .T13))),
                                                    )),
                                              ),
                                        widget.edit ? Container() : spaceW(10),
                                        Expanded(
                                            child: bottomButton(
                                                context: context,
                                                onPress: () {
                                                  bool move = false;

                                                  if (communityTypeCreate(
                                                          bloc.communityType) ==
                                                      'EXCHANGE') {
                                                    if (informTextingCheck
                                                            .indexWhere(
                                                                (element) =>
                                                                    element ==
                                                                    true) ==
                                                        -1) {
                                                      setState(() {
                                                        informPass = false;
                                                        if (!move) {
                                                          move = true;
                                                          FocusScope.of(context)
                                                              .requestFocus(
                                                                  informFocus[
                                                                      0]);
                                                        }
                                                      });
                                                    }

                                                    if (learnTextingCheck
                                                            .indexWhere(
                                                                (element) =>
                                                                    element ==
                                                                    true) ==
                                                        -1) {
                                                      setState(() {
                                                        learnPass = false;
                                                        if (!move) {
                                                          move = true;
                                                          FocusScope.of(context)
                                                              .requestFocus(
                                                                  learnFocus[
                                                                      0]);
                                                        }
                                                      });
                                                    }
                                                  }

                                                  if (contentController
                                                          .text.length <
                                                      7) {
                                                    setState(() {
                                                      contentPass = false;
                                                      if (!move) {
                                                        move = true;
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                contentFocus);
                                                      }
                                                    });
                                                  }
                                                  if (communityTypeCreate(
                                                          bloc.communityType) ==
                                                      'EXCHANGE') {
                                                    if (contentPass &&
                                                        informPass &&
                                                        learnPass) {
                                                      communitySave(
                                                          type: 'NORMAL');
                                                    }
                                                  } else if (communityTypeCreate(
                                                          bloc.communityType) ==
                                                      'WITH_ME') {
                                                    if (contentPass &&
                                                        meetPass) {
                                                      communitySave(
                                                          type: 'NORMAL');
                                                    }
                                                  }
                                                },
                                                text: '완료'))
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        left: 20,
                        top: 70 + MediaQuery.of(context).padding.top,
                        child: typeSelectView()),
                    loadingView(bloc.loading)
                  ],
                ),
              ),
            ),
          );
        });
  }

  communitySave({required String type}) async {
    setState(() {
      bloc.loading = true;
    });
    List<Area> areas = [];
    for (int i = 0; i < bloc.neighborHoodList.length; i++) {
      areas.add(Area(
          hangCode: bloc.neighborHoodList[i].hangCode!,
          buildingName: bloc.neighborHoodList[i].buildingName ?? '',
          lati: bloc.neighborHoodList[i].lati!,
          longi: bloc.neighborHoodList[i].longi!,
          roadAddress: bloc.neighborHoodList[i].roadAddress ?? null,
          zipAddress: bloc.neighborHoodList[i].zipAddress!,
          sidoName: bloc.neighborHoodList[i].sidoName,
          sigunguName: bloc.neighborHoodList[i].sigunguName,
          eupmyeondongName: bloc.neighborHoodList[i].eupmyeondongName));
    }

    bloc.imageRes = [];

    if (widget.edit) {
      if (bloc.communityDetail!.content.images!.length > 0) {
        for (int i = 0; i < bloc.communityDetail!.content.images!.length; i++) {
          if (bloc.communityDetail!.content.images![i].representativeFlag !=
              1) {
            bloc.imageRes.add(bloc.communityDetail!.content.images![i]);
          }
        }
      }
    }

    if (bloc.imageFiles.length != 0) {
      List<File> files = [];
      for (int i = 0; i < bloc.imageFiles.length; i++) {
        await bloc.imageFiles[i].getByteData(quality: 100).then((value) async {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          var filePath = tempPath +
              '/${Uuid().v4()}.${bloc.imageFiles[i].name!.split(".")[1]}';
          File file = await File(filePath).writeAsBytes(value.buffer
              .asUint8List(value.offsetInBytes, value.lengthInBytes));
          files.add(file);
        });
      }

      List<Data> data =
          await ImageMultipleUploadService(imageFiles: files).start();
      for (int i = 0; i < data.length; i++) {
        bloc.imageRes.add(data[i]);
      }
    }

    informKeyword = [];
    learnKeyword = [];
    meetKeyword = [];

    for (int i = 0; i < informTextingCheck.length; i++) {
      if (informTextingCheck[i]) {
        CommunityKeyword communityKeyword = CommunityKeyword(
            type: 'TEACH', text: bloc.informController[i].text);
        informKeyword.add(communityKeyword);
      }
    }

    for (int i = 0; i < learnTextingCheck.length; i++) {
      if (learnTextingCheck[i]) {
        CommunityKeyword communityKeyword =
            CommunityKeyword(type: 'LEARN', text: bloc.learnController[i].text);
        learnKeyword.add(communityKeyword);
      }
    }

    for (int i = 0; i < meetTextingCheck.length; i++) {
      if (meetTextingCheck[i]) {
        CommunityKeyword communityKeyword =
            CommunityKeyword(type: 'MEET', text: bloc.meetController[i].text);
        meetKeyword.add(communityKeyword);
      }
    }

    CommunityCreate communityCreate = CommunityCreate(
        areas: areas,
        category: communityTypeCreate(bloc.communityType),
        status: type,
        communityUuid: widget.edit
            ? bloc.communityDetail!.communityUuid
            : bloc.communityUuid == null
                ? null
                : bloc.communityUuid,
        contentText: contentController.text,
        files: bloc.imageRes,
        informKeyword: informKeyword.length == 0 ? null : informKeyword,
        learnKeyword: learnKeyword.length == 0 ? null : learnKeyword,
        meetKeyword: meetKeyword.length == 0 ? null : meetKeyword);
    if (type == 'TEMP') {
      bloc.add(CommunitySaveTempEvent(communityCreate: communityCreate));
    } else if (type == 'NORMAL') {
      bloc.add(CommunitySaveEvent(communityCreate: communityCreate));
    }
  }

  typeSelectView() {
    return AnimatedOpacity(
      opacity: bloc.typeHide ? 0 : 1,
      duration: Duration(milliseconds: 300),
      child: bloc.typeHide
          ? Container()
          : Container(
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.black.withOpacity(0.16),
                      blurRadius: 6,
                      offset: Offset(0, 0))
                ],
              ),
              child: Column(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, idx) {
                      return ElevatedButton(
                        onPressed: () {
                          bloc.add(CommunityTypeSelectEvent(idx: idx));
                          Future.delayed(Duration(milliseconds: 50), () {
                            bloc.add(CommunityTypeViewEvent());
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                customText(communityType(idx),
                                    style: TextStyle(
                                        color: bloc.communityType == idx
                                            ? AppColors.primary
                                            : AppColors.gray900,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T14))),
                                spaceW(4),
                                bloc.communityType == idx
                                    ? Image.asset(
                                        AppImages.iCheckC,
                                        width: 14,
                                        height: 14,
                                      )
                                    : Container()
                              ],
                            ),
                            spaceH(4),
                            customText(communityDescription(idx),
                                style: TextStyle(
                                    color: AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12)))
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.white,
                            elevation: 0,
                            padding: EdgeInsets.all(20),
                            shape: idx == 0 || idx == 3
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft:
                                            Radius.circular(idx == 0 ? 10 : 0),
                                        topRight:
                                            Radius.circular(idx == 0 ? 10 : 0),
                                        bottomLeft:
                                            Radius.circular(idx == 3 ? 10 : 0),
                                        bottomRight:
                                            Radius.circular(idx == 3 ? 10 : 0)))
                                : RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
                      );
                    },
                    shrinkWrap: true,
                    itemCount: 2,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ],
              )),
    );
  }

  neighborHoodListItem(int idx) {
    return Container(
      width: 200,
      height: 88,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200)),
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                customText(
                  bloc.neighborHoodList[idx].hangName ?? '',
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                ),
                spaceH(6),
                Flexible(
                  child: customText(
                    bloc.neighborHoodList[idx].roadAddress != null
                        ? bloc.neighborHoodList[idx].roadAddress!
                        : bloc.neighborHoodList[idx].zipAddress!,
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                        fontSize: fontSizeSet(textSize: TextSize.T12)),
                  ),
                )
              ],
            ),
          ),
          spaceW(16),
          GestureDetector(
            onTap: () {
              if (bloc.neighborHoodList.length == 1) {
                showToast(
                    context: context,
                    text: AppStrings.of(StringKey.removeNeighborHoodToast));
              } else {
                setState(() {
                  bloc.neighborHoodList.removeAt(idx);
                });
              }
            },
            child: Image.asset(
              AppImages.iTrashG,
              width: 20,
              height: 20,
            ),
          )
        ],
      ),
    );
  }

  neighborHoodListItemAdd() {
    return GestureDetector(
      onTap: () {
        pushTransition(
            context,
            NeighborHoodAddPage(
              signUpEnd: true,
              create: true,
            )).then((value) {
          if (value != null) {
            if (value is NeighborHood) {
              bloc.neighborHoodList.add(value);
              setState(() {});
            }
          }
        });
      },
      child: Container(
        height: 88,
        child: DottedBorder(
          strokeWidth: 1,
          dashPattern: [5, 3],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          color: AppColors.primary,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                spaceW(20),
                Image.asset(
                  AppImages.iPlusC,
                  width: 16,
                  height: 16,
                ),
                spaceW(4),
                customText(
                  AppStrings.of(StringKey.neighborhoodAdd),
                  style: TextStyle(
                      color: AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                ),
                spaceW(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  neighborHoodList() {
    return Container(
      constraints: BoxConstraints(minHeight: 88, maxHeight: 108),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 1, left: 20, right: 20),
        itemBuilder: (context, idx) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              neighborHoodListItem(idx),
              spaceW(12),
              (idx < 2 && idx == bloc.neighborHoodList.length - 1)
                  ? neighborHoodListItemAdd()
                  : Container()
            ],
          );
        },
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: bloc.neighborHoodList.length,
      ),
    );
  }

  informView() {
    List<Widget> keywords = [];
    for (int i = 0; i < 5; i++) {
      keywords.add(IntrinsicWidth(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: informTextCheck[i]
                  ? AppColors.accentLight50
                  : AppColors.white),
          child: DottedBorder(
            strokeWidth: informTextCheck[i]
                ? 1
                : informFocusCheck[i]
                    ? 2
                    : 0,
            dashPattern: informFocusCheck[i] ? [1, 0] : [5, 3],
            padding: EdgeInsets.only(left: 16, right: 11),
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: informTextCheck[i]
                ? AppColors.transparent
                : informFocusCheck[i]
                    ? AppColors.accentLight20
                    : AppColors.accentLight30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText('#',
                    style: TextStyle(
                        color: AppColors.accentLight30,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                Flexible(
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        informPass = true;
                        if (value != '') {
                          setState(() {
                            informTextingCheck[i] = true;
                          });
                        } else {
                          if (informTextingCheck[i]) {
                            setState(() {
                              informTextingCheck[i] = false;
                            });
                          }
                        }
                      },
                      controller: bloc.informController[i],
                      focusNode: informFocus[i],
                      onFieldSubmitted: (value) {},
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: informTextCheck[i]
                              ? AppColors.accentDark10
                              : AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T14)),
                      maxLines: 1,
                      maxLength: 8,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          counterText: '',
                          hintText: keywordHint(i),
                          hintStyle: TextStyle(
                              color: AppColors.gray400,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(right: 12)),
                    ),
                  ),
                ),
                informTextCheck[i]
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              bloc.informController[i].text = '';
                              informTextCheck[i] = false;
                              informTextingCheck[i] = false;
                            });
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left: 1,
                                right: 1,
                                top: 1,
                                bottom: 1,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                              Image.asset(
                                AppImages.iInputClearTrans,
                                width: 20,
                                height: 20,
                                color: AppColors.accentLight20,
                              )
                            ],
                          ),
                        ),
                      )
                    : informFocusCheck[i]
                        ? informTextingCheck[i]
                            ? Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.accentDark10,
                                ),
                              )
                            : Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: Color(0xFF808080).withOpacity(0.8),
                                ),
                              )
                        : Image.asset(
                            AppImages.iEditUnderG,
                            width: 16,
                            height: 16,
                          )
              ],
            ),
          ),
        ),
      ));
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            child: Align(
                alignment: Alignment.centerLeft,
                child: customText('알려 드려요',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T14)))),
          ),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: keywords,
          ),
          informPass
              ? Container()
              : issueMessage(title: '이웃에게 알려줄 것을 1개 이상 입력해주세요'),
          spaceH(20),
        ],
      ),
    );
  }

  learnView() {
    List<Widget> keywords = [];
    for (int i = 0; i < 5; i++) {
      keywords.add(IntrinsicWidth(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: learnTextCheck[i]
                  ? AppColors.primaryLight50
                  : AppColors.white),
          child: DottedBorder(
            strokeWidth: learnTextCheck[i]
                ? 1
                : learnFocusCheck[i]
                    ? 2
                    : 0,
            dashPattern: learnFocusCheck[i] ? [1, 0] : [5, 3],
            padding: EdgeInsets.only(left: 16, right: 11),
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: learnTextCheck[i]
                ? AppColors.transparent
                : learnFocusCheck[i]
                    ? AppColors.primaryLight20
                    : AppColors.primaryLight30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText('#',
                    style: TextStyle(
                        color: AppColors.primaryLight30,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                Flexible(
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        learnPass = true;
                        if (value != '') {
                          setState(() {
                            learnTextingCheck[i] = true;
                          });
                        } else {
                          if (learnTextingCheck[i]) {
                            setState(() {
                              learnTextingCheck[i] = false;
                            });
                          }
                        }
                      },
                      controller: bloc.learnController[i],
                      focusNode: learnFocus[i],
                      onFieldSubmitted: (value) {},
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: learnTextCheck[i]
                              ? AppColors.primaryDark10
                              : AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T14)),
                      maxLines: 1,
                      maxLength: 8,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          counterText: '',
                          hintText: keywordHint(i),
                          hintStyle: TextStyle(
                              color: AppColors.gray400,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(right: 12)),
                    ),
                  ),
                ),
                learnTextCheck[i]
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              bloc.learnController[i].text = '';
                              learnTextCheck[i] = false;
                              learnTextingCheck[i] = false;
                            });
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left: 1,
                                right: 1,
                                top: 1,
                                bottom: 1,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                              Image.asset(
                                AppImages.iInputClearTrans,
                                width: 20,
                                height: 20,
                                color: AppColors.primaryLight20,
                              )
                            ],
                          ),
                        ),
                      )
                    : learnFocusCheck[i]
                        ? learnTextingCheck[i]
                            ? Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.primaryDark10,
                                ),
                              )
                            : Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: Color(0xFF808080).withOpacity(0.8),
                                ),
                              )
                        : Image.asset(
                            AppImages.iEditUnderG,
                            width: 16,
                            height: 16,
                          )
              ],
            ),
          ),
        ),
      ));
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: customText('배우고 싶어요',
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T14))),
            ),
          ),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: keywords,
          ),
          learnPass
              ? Container()
              : issueMessage(title: '이웃에게 배우고 싶은 것을 1개 이상 입력해주세요'),
          spaceH(20),
        ],
      ),
    );
  }

  meetView() {
    List<Widget> keywords = [];
    for (int i = 0; i < 5; i++) {
      keywords.add(IntrinsicWidth(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: meetTextCheck[i]
                  ? AppColors.primaryLight50
                  : AppColors.white),
          child: DottedBorder(
            strokeWidth: meetTextCheck[i]
                ? 1
                : meetFocusCheck[i]
                    ? 2
                    : 0,
            dashPattern: meetFocusCheck[i] ? [1, 0] : [5, 3],
            padding: EdgeInsets.only(left: 16, right: 11),
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: meetTextCheck[i]
                ? AppColors.transparent
                : meetFocusCheck[i]
                    ? AppColors.primaryLight20
                    : AppColors.primaryLight30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText('#',
                    style: TextStyle(
                        color: AppColors.primaryLight30,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                Flexible(
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        meetPass = true;
                        if (value != '') {
                          setState(() {
                            meetTextingCheck[i] = true;
                          });
                        } else {
                          if (meetTextingCheck[i]) {
                            setState(() {
                              meetTextingCheck[i] = false;
                            });
                          }
                        }
                      },
                      controller: bloc.meetController[i],
                      focusNode: meetFocus[i],
                      onFieldSubmitted: (value) {},
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: meetTextCheck[i]
                              ? AppColors.primaryDark10
                              : AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T14)),
                      maxLines: 1,
                      maxLength: 8,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          counterText: '',
                          hintText: keywordHint(i),
                          hintStyle: TextStyle(
                              color: AppColors.gray400,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(right: 12)),
                    ),
                  ),
                ),
                meetTextCheck[i]
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              bloc.meetController[i].text = '';
                              meetTextCheck[i] = false;
                              meetTextingCheck[i] = false;
                            });
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left: 1,
                                right: 1,
                                top: 1,
                                bottom: 1,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                              Image.asset(
                                AppImages.iInputClearTrans,
                                width: 20,
                                height: 20,
                                color: AppColors.primaryLight20,
                              )
                            ],
                          ),
                        ),
                      )
                    : meetFocusCheck[i]
                        ? meetTextingCheck[i]
                            ? Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.primaryDark10,
                                ),
                              )
                            : Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: Color(0xFF808080).withOpacity(0.8),
                                ),
                              )
                        : Image.asset(
                            AppImages.iEditUnderG,
                            width: 16,
                            height: 16,
                          )
              ],
            ),
          ),
        ),
      ));
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: customText('모임 주제',
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T14))),
            ),
          ),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: keywords,
          ),
          meetPass
              ? Container()
              : issueMessage(title: '이웃에게 배우고 싶은 것을 1개 이상 입력해주세요'),
          spaceH(20),
        ],
      ),
    );
  }

  contentView() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Container(
            height: 48,
            child: Row(
              children: [
                customText('추가 내용',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                Expanded(child: Container()),
                customText('${contentController.text.length}',
                    style: TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
                customText(' / 7 ~ 1000',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12)))
              ],
            ),
          ),
          Container(
            height: 182,
            child: TextFormField(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).requestFocus(contentFocus);
                if (!contentFocus.hasFocus) {
                  Future.delayed(Duration(milliseconds: 700), () {
                    scrollController.animateTo(scrollController.offset + 120,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  });
                }
              },
              onChanged: (value) {
                blankCheck(
                    text: value,
                    controller: contentController,
                    multiline: true);
                setState(() {
                  contentPass = true;
                });
              },
              maxLength: 1000,
              maxLines: null,
              controller: contentController,
              focusNode: contentFocus,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              expands: true,
              style: TextStyle(
                  color: AppColors.primaryDark10,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
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
                        BorderSide(width: 2, color: AppColors.primaryLight40)),
              ),
            ),
          ),
          contentPass ? Container() : issueMessage(title: '최소 7자 이상 적어주세요')
        ],
      ),
    );
  }

  contentImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText('관련 이미지',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                customText(' (선택)',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
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
                      bloc.imageFiles.length <
                          (widget.edit
                              ? 9 -
                                  (bloc.communityDetail!.content.images!
                                              .length >
                                          0
                                      ? bloc.communityDetail!.content.images!
                                              .length -
                                          1
                                      : bloc.communityDetail!.content.images!
                                          .length)
                              : 9)) {
                    resultList = await MultiImagePicker.pickImages(
                        maxImages: 9 -
                            bloc.imageFiles.length -
                            (widget.edit
                                ? (bloc.communityDetail!.content.images!
                                            .length >
                                        0
                                    ? (widget.edit
                                        ? bloc.communityDetail!.content.images!
                                                .length -
                                            1
                                        : 0)
                                    : 0)
                                : 0),
                        enableCamera: false,
                        selectedAssets: resultList);

                    if (!mounted) return;

                    for (int i = 0; i < resultList.length; i++) {
                      bloc.imageFiles.add(resultList[i]);
                    }
                    systemColorSetting();
                    bloc.add(CommunityGetFileEvent());
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
                      '${AppStrings.of(StringKey.registration)}  ${widget.edit ? bloc.imageFiles.length + (bloc.communityDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) != -1 ? bloc.communityDetail!.content.images!.length - 1 : bloc.communityDetail!.content.images!.length) : bloc.imageFiles.length == 0 ? 0 : bloc.imageFiles.length.toString()}',
                      style: TextStyle(
                          color: AppColors.primaryDark10,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T13)),
                    ),
                    customText(
                      ' / 9',
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
                  (widget.edit == true &&
                      bloc.communityDetail!.content.images!.length == 0)
              ? Container()
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 54,
                  child: ListView.builder(
                    itemBuilder: (context, idx) {
                      if (widget.edit) {
                        if (idx <
                            ((bloc.communityDetail!.content.images!.indexWhere(
                                        (element) =>
                                            element.representativeFlag == 1) ==
                                    -1)
                                ? bloc.communityDetail!.content.images!.length
                                : bloc.communityDetail!.content.images!.length -
                                    1)) {
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  bloc.communityDetail!.content.images!
                                      .removeAt(((bloc.communityDetail!.content
                                                  .images!
                                                  .indexWhere((element) =>
                                                      element
                                                          .representativeFlag ==
                                                      1) ==
                                              -1)
                                          ? idx
                                          : idx + 1));
                                  bloc.add(CommunityGetFileEvent());
                                },
                                child: Container(
                                  width: 96,
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: CacheImage(
                                        imageUrl:
                                            '${bloc.communityDetail!.content.images![((bloc.communityDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1) ? idx : idx + 1)].toView(
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
                                                      .communityDetail!
                                                      .content
                                                      .images!
                                                      .indexWhere((element) =>
                                                          element.representativeFlag ==
                                                          1) ==
                                                  -1)
                                              ? bloc.communityDetail!.content
                                                  .images!.length
                                              : (bloc.communityDetail!.content
                                                      .images!.length -
                                                  1)) >
                                          idx + 1)
                                      ? (bloc.communityDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                          ? bloc.communityDetail!.content.images!.length - idx + 1
                                          : (bloc.communityDetail!.content.images!.length - 1) - idx + 1
                                      : (bloc.communityDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                          ? idx - (bloc.communityDetail!.content.images!.length)
                                          : idx - (bloc.communityDetail!.content.images!.length - 1));
                                  bloc.add(CommunityGetFileEvent());
                                },
                                child: Container(
                                  width: 96,
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: AssetThumb(
                                        asset: bloc.imageFiles[((bloc.communityDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                                    ? bloc.communityDetail!
                                                        .content.images!.length
                                                    : bloc
                                                            .communityDetail!
                                                            .content
                                                            .images!
                                                            .length -
                                                        1) >
                                                idx
                                            ? (bloc.communityDetail!.content
                                                        .images!
                                                        .indexWhere((element) =>
                                                            element.representativeFlag == 1) ==
                                                    -1)
                                                ? bloc.communityDetail!.content.images!.length - idx
                                                : (bloc.communityDetail!.content.images!.length - 1) - idx
                                            : (bloc.communityDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                                ? idx - (bloc.communityDetail!.content.images!.length)
                                                : idx - (bloc.communityDetail!.content.images!.length - 1)],
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
                                bloc.add(CommunityGetFileEvent());
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
                    },
                    shrinkWrap: true,
                    itemCount: widget.edit
                        ? (bloc.communityDetail!.content.images!.indexWhere(
                                        (element) =>
                                            element.representativeFlag == 1) !=
                                    -1
                                ? bloc.communityDetail!.content.images!.length -
                                    1
                                : bloc
                                    .communityDetail!.content.images!.length) +
                            bloc.imageFiles.length
                        : bloc.imageFiles.length,
                    scrollDirection: Axis.horizontal,
                  ),
                )
        ],
      ),
    );
  }

  finishCommunityCreateDialog(String communityUuid) {
    return ListView(
      shrinkWrap: true,
      children: [
        spaceH(widget.stop ? 28 : 40),
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
        widget.stop
            ? Column(
                children: [
                  Container(
                    height: 24,
                    child: customText(
                      '조금만 기다려주세요!',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T17)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  spaceH(20),
                  customText(
                    '검수는 영업일 기준 3일 이내에\n완료될 예정입니다.',
                    style: TextStyle(
                        color: AppColors.gray600,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12)),
                    textAlign: TextAlign.center,
                  ),
                  spaceH(20),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2.67)),
                                child: Center(
                                  child: customText(
                                    '영업일',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T10)),
                                  ),
                                ),
                              ),
                              spaceW(10),
                              customText('평일 10~17시',
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)))
                            ],
                          ),
                          spaceH(6),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2.67)),
                                child: Center(
                                  child: customText(
                                    '고객센터',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T10)),
                                  ),
                                ),
                              ),
                              spaceW(10),
                              customText('1661-2322',
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  spaceH(40),
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: bottomButton(
                        context: context,
                        text: AppStrings.of(StringKey.check),
                        onPress: () {
                          popDialog(context);
                          if (widget.edit) {
                            if (dataSaver.myCreateCommunityBloc != null) {
                              dataSaver.myCreateCommunityBloc!
                                  .add(MyCreateCommunityInitEvent());
                            }
                            popWithResult(context, true);
                          } else {
                            if (widget.myCreate) {
                              dataSaver.myCreateCommunityBloc!
                                  .add(MyCreateCommunityInitEvent());
                            }
                            popDialog(context);
                            pushTransition(
                                context,
                                CommunityDetailPage(
                                    communityUuid: communityUuid));
                          }
                        }),
                  )
                ],
              )
            : Column(
                children: [
                  Center(
                    child: customText('완료되었어요!',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T17))),
                  ),
                  spaceH(60),
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: bottomButton(
                        context: context,
                        text: AppStrings.of(StringKey.check),
                        onPress: () {
                          popDialog(context);
                          if (widget.edit) {
                            if (dataSaver.myCreateCommunityBloc != null) {
                              dataSaver.myCreateCommunityBloc!
                                  .add(MyCreateCommunityInitEvent());
                            }
                            popWithResult(context, true);
                          } else {
                            if (widget.myCreate) {
                              dataSaver.myCreateCommunityBloc!
                                  .add(MyCreateCommunityInitEvent());
                            }
                            popDialog(context);
                            pushTransition(
                                context,
                                CommunityDetailPage(
                                    communityUuid: communityUuid));
                          }
                        }),
                  )
                ],
              )
      ],
    );
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this);

    for (int i = 0; i < 5; i++) {
      informFocus[i].addListener(() {
        if (!informFocus[i].hasFocus) {
          informFocusCheck[i] = false;
          if (bloc.informController[i].text != '') {
            informTextCheck[i] = true;
          } else {
            informTextCheck[i] = false;
          }
        } else {
          informFocusCheck[i] = true;
        }
      });
    }

    for (int i = 0; i < 5; i++) {
      learnFocus[i].addListener(() {
        if (!learnFocus[i].hasFocus) {
          learnFocusCheck[i] = false;
          if (bloc.learnController[i].text != '') {
            learnTextCheck[i] = true;
          } else {
            learnTextCheck[i] = false;
          }
        } else {
          learnFocusCheck[i] = true;
        }
      });
    }

    for (int i = 0; i < 5; i++) {
      meetFocus[i].addListener(() {
        if (!meetFocus[i].hasFocus) {
          meetFocusCheck[i] = false;
          if (bloc.meetController[i].text != '') {
            meetTextCheck[i] = true;
          } else {
            meetTextCheck[i] = false;
          }
        } else {
          meetFocusCheck[i] = true;
        }
      });
    }

    super.initState();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is CommunityCreateInitState) {
      if (widget.edit) {
        contentController.text =
            bloc.communityDetail!.content.contentText ?? '';
        for (int i = 0;
            i < bloc.communityDetail!.content.teachKeywords!.length;
            i++) {
          bloc.informController[i].text =
              bloc.communityDetail!.content.teachKeywords![i].text;
          informTextingCheck[i] = true;
          informTextCheck[i] = true;
        }
        for (int i = 0;
            i < bloc.communityDetail!.content.learnKeywords!.length;
            i++) {
          bloc.learnController[i].text =
              bloc.communityDetail!.content.learnKeywords![i].text;
          learnTextingCheck[i] = true;
          learnTextCheck[i] = true;
        }
        for (int i = 0;
            i < bloc.communityDetail!.content.meetKeywords!.length;
            i++) {
          bloc.meetController[i].text =
              bloc.communityDetail!.content.meetKeywords![i].text;
          meetTextingCheck[i] = true;
          meetTextCheck[i] = true;
        }
        setState(() {});
      }
    }

    if (state is CommunitySaveTempState) {
      tempCheck = true;
      showToast(context: context, text: AppStrings.of(StringKey.tempSave));
    }

    if (state is CommunitySaveState) {
      if (widget.edit) {
        amplitudeEvent('community_edit_completed', {
          'type': communityTypeCreate(bloc.communityType),
          'town_sido': dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .sidoName,
          'town_sigungu': dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .sigunguName,
          'town_dongeupmyeon': dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .eupmyeondongName,
          'name': dataSaver.profileGet!.nickName
        });
      } else {
        if (production == 'prod-release' && kReleaseMode) {
          Airbridge.event.send(
              ViewProductDetailEvent(option: EventOption(action: 'view_item')));
        }
        amplitudeRevenue(productId: 'community_register_completed', price: 6);
        amplitudeEvent('community_register_completed', {
          'type': communityTypeCreate(bloc.communityType),
          'town_sido': dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .sidoName,
          'town_sigungu': dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .sigunguName,
          'town_dongeupmyeon': dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .eupmyeondongName,
          'temporary_storage': tempCheck,
          'name': dataSaver.profileGet!.nickName,
          'keyword_teach': informKeyword.length == 0
              ? ''
              : informKeyword
                  .map((e) {
                    return e.text;
                  })
                  .toList()
                  .join(','),
          'keyword_learn': learnKeyword.length == 0
              ? ''
              : learnKeyword
                  .map((e) {
                    return e.text;
                  })
                  .toList()
                  .join(','),
          'keyword_gather': meetKeyword.length == 0
              ? ''
              : meetKeyword
                  .map((e) {
                    return e.text;
                  })
                  .toList()
                  .join(',')
        });
      }
      if (widget.myCreate) {
        dataSaver.myCreateCommunityBloc!.add(StatusChangeEvent());
      }
      dataSaver.learnBloc!.add(CommunityReloadEvent());
      customDialog(
          context: context,
          barrier: true,
          widget: finishCommunityCreateDialog(state.communityUuid));
    }
  }

  @override
  CommunityCreateBloc initBloc() {
    return CommunityCreateBloc(context)
      ..add(CommunityCreateInitEvent(
          type: widget.idx,
          edit: widget.edit,
          communityUuid: widget.communityUuid));
  }
}
