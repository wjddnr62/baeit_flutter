import 'dart:convert';
import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/neighborhood/neighborhood_add.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/main_navigation/main_navigation_page.dart';
import 'package:baeit/ui/name_the_neighborhood/name_the_neighborhood_bloc.dart';
import 'package:baeit/ui/splash/splash_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/hint_message.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameTheNeighborHoodPage extends BlocStatefulWidget {
  final Juso? juso;
  final AddressPointData? addressPointData;
  final NeighborHood? neighborHood;
  final bool myLocation;
  final bool signUpEnd;
  final bool edit;

  NameTheNeighborHoodPage(
      {this.juso,
      this.addressPointData,
      this.neighborHood,
      required this.myLocation,
      required this.signUpEnd,
      required this.edit});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    // TODO: implement buildState
    return NameTheNeighborHoodState();
  }
}

class NameTheNeighborHoodState
    extends BlocState<NameTheNeighborHoodBloc, NameTheNeighborHoodPage> {
  TextEditingController nameController = TextEditingController();
  bool namePass = true;

  nameTheNeighborHoodBar() {
    return Container(
      height: 48,
      child: TextFormField(
          autofocus: true,
          maxLines: 1,
          maxLength: 6,
          controller: nameController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: TextStyle(
              color: AppColors.gray900,
              fontWeight: weightSet(textWeight: TextWeight.BOLD),
              fontSize: fontSizeSet(textSize: TextSize.T13)),
          onChanged: (text) {
            namePass = true;
            blankCheck(
                text: text,
                controller: nameController);
            setState(() {});
          },
          decoration: InputDecoration(
            counterText: '',
            suffixIcon: nameController.text.length > 0
                ? Padding(
                    padding: EdgeInsets.only(top: 14, bottom: 14),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          nameController.text = '';
                        });
                      },
                      child: Image.asset(AppImages.iInputClear,
                          width: 20, height: 20),
                    ),
                  )
                : null,
            hintText: AppStrings.of(StringKey.nameTheNeighborhoodPlaceHolder),
            hintStyle: TextStyle(
                color: AppColors.gray500,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T13)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(width: 1, color: AppColors.gray200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(width: 1, color: AppColors.gray200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(width: 2, color: AppColors.primary)),
            contentPadding: EdgeInsets.only(left: 10),
          )),
    );
  }

  selectItem() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryLight20)),
      padding: const EdgeInsets.all(20),
      child: widget.myLocation
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.addressPointData!.roadAddress == null
                    ? Container()
                    : widget.addressPointData!.roadAddress!.buildingName ==
                                '' ||
                            widget.addressPointData!.roadAddress!
                                    .buildingName ==
                                null
                        ? Container()
                        : customText(
                            widget.addressPointData!.roadAddress!.buildingName!,
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T14)),
                          ),
                widget.addressPointData!.roadAddress == null
                    ? Container()
                    : widget.addressPointData!.roadAddress!.buildingName ==
                                '' ||
                            widget.addressPointData!.roadAddress!
                                    .buildingName ==
                                null
                        ? Container()
                        : spaceH(12),
                widget.addressPointData!.roadAddress == null
                    ? Container()
                    : customText(
                        '[도로명] ${widget.addressPointData!.roadAddress!.addressName} ${widget.addressPointData!.roadAddress!.buildingName}',
                        style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                      ),
                widget.addressPointData!.roadAddress == null
                    ? Container()
                    : spaceH(5),
                customText(widget.addressPointData!.address!.addressName!,
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
              ],
            )
          : !widget.edit
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.juso!.bdNm == '' || widget.juso!.bdNm == null
                        ? Container()
                        : customText(
                            widget.juso!.bdNm!,
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T14)),
                          ),
                    widget.juso!.bdNm == '' || widget.juso!.bdNm == null
                        ? Container()
                        : spaceH(12),
                    customText(
                      '[도로명] ${widget.juso!.roadAddrPart1} ${widget.juso!.bdNm}',
                      style: TextStyle(
                          color: AppColors.gray600,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12)),
                    ),
                    widget.juso!.jibunAddr == '' ? Container() : spaceH(5),
                    widget.juso!.jibunAddr == ''
                        ? Container()
                        : customText(widget.juso!.jibunAddr!,
                            style: TextStyle(
                                color: AppColors.gray400,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.neighborHood!.buildingName == ''
                        ? Container()
                        : customText(
                            widget.neighborHood!.buildingName!,
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T14)),
                          ),
                    widget.neighborHood!.buildingName == ''
                        ? Container()
                        : spaceH(12),
                    customText(
                      '[도로명] ${widget.neighborHood!.roadAddress} ${widget.neighborHood!.buildingName}',
                      style: TextStyle(
                          color: AppColors.gray600,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12)),
                    ),
                    spaceH(5),
                    customText(widget.neighborHood!.zipAddress!,
                        style: TextStyle(
                            color: AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12))),
                  ],
                ),
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
                    backgroundColor: AppColors.white,
                    appBar: baseAppBar(
                        title: AppStrings.of(StringKey.nameTheNeighborhood),
                        context: context,
                        onPressed: () {
                          pop(context);
                        }),
                    body: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height -
                                60 -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom,
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                spaceH(36),
                                customText(
                                  AppStrings.of(
                                      StringKey.selectTheNeighborhoodNameWrite),
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T20)),
                                  textAlign: TextAlign.center,
                                ),
                                spaceH(48),
                                nameTheNeighborHoodBar(),
                                namePass
                                    ? Container()
                                    : issueMessage(
                                        title: AppStrings.of(
                                            StringKey.neighborHoodNameIssue)),
                                spaceH(4),
                                hintMessage(
                                    text: AppStrings.of(
                                        StringKey.nameTheNeighborhoodHint)),
                                spaceH(20),
                                selectItem()
                              ],
                            ),
                          ),
                          Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: bottomButton(
                                  context: context,
                                  onPress: () {
                                    if (nameController.text.length == 0) {
                                      namePass = false;
                                    } else {
                                      namePass = true;
                                    }
                                    setState(() {});

                                    if (namePass) {
                                      if (!widget.signUpEnd) {
                                        if (Platform.isIOS && dataSaver.userData != null) {
                                          amplitude.setUserId(dataSaver.userData!.memberUuid);
                                        }

                                        amplitudeEvent('baeit_start_clicks', {
                                          'town_sido': widget.myLocation
                                              ? widget.addressPointData!
                                              .address!.region1depthName
                                              : widget.juso!.siNm,
                                          'town_sigungu': widget.myLocation
                                              ? widget.addressPointData!
                                              .address!.region2depthName
                                              : widget.juso!.sggNm,
                                          'town_dongeupmyeon': widget.myLocation
                                              ? widget.addressPointData!
                                              .address!.region3depthHName
                                              : widget.juso!.emdNm,
                                          'login_type': dataSaver.userData == null ? '' : dataSaver.userData!.type
                                        });
                                      }

                                      bloc.add(NameSaveEvent(
                                          townName: nameController.text,
                                          juso: widget.juso != null
                                              ? widget.juso
                                              : null,
                                          addressPointData:
                                              widget.addressPointData != null
                                                  ? widget.addressPointData
                                                  : null,
                                          myLocation: widget.myLocation,
                                          edit: widget.edit,
                                          neighborHood: widget.edit
                                              ? widget.neighborHood
                                              : null));
                                    }
                                  },
                                  text: widget.signUpEnd
                                      ? AppStrings.of(StringKey.save)
                                      : '배잇 시작하기')),
                        ],
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
    if (state is NameTheNeighborHoodInitState) {
      if (widget.edit) {
        nameController.text = widget.neighborHood!.townName!;
        nameController.selection = TextSelection.fromPosition(
            TextPosition(offset: nameController.text.characters.length));
        setState(() {});
      }
    }

    if (state is NameSaveState) {
      if (widget.edit) {
        popWithResult(context, state.neighborHood);
      } else if (widget.signUpEnd) {
        popWithResult(context, bloc.neighborHood);
      } else {
        pushAndRemoveUntil(context, SplashPage());
      }
    }
  }

  @override
  NameTheNeighborHoodBloc initBloc() {
    return NameTheNeighborHoodBloc(context)
      ..add(NameTheNeighborHoodInitEvent(signUpEnd: widget.signUpEnd));
  }
}
