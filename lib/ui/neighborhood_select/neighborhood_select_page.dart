import 'dart:convert';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/name_the_neighborhood/name_the_neighborhood_page.dart';
import 'package:baeit/ui/neighborhood_add/neighborhood_add_page.dart';
import 'package:baeit/ui/neighborhood_class/neighborhood_class_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'neighborhood_select_bloc.dart';

class NeighborHoodSelectPage extends BlocStatefulWidget {
  final bool select;

  NeighborHoodSelectPage({this.select = false});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    // TODO: implement buildState
    return NeighborHoodSelectState();
  }
}

class NeighborHoodSelectState
    extends BlocState<NeighborHoodSelectBloc, NeighborHoodSelectPage> {
  neighborHoodListItem(int idx, bool data) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: DottedBorder(
        strokeWidth: 1,
        dashPattern: [5, 3],
        color: data ? AppColors.transparent : AppColors.gray200,
        borderType: BorderType.RRect,
        radius: Radius.circular(10),
        child: Container(
          height: 124,
          child: Stack(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (data) {
                    if (widget.select) {
                      popWithResult(context, dataSaver.neighborHood[idx]);
                    } else {
                      if (dataSaver.neighborHood.indexWhere(
                              (element) => element.representativeFlag == 1) ==
                          idx) {
                        pop(context);
                      } else {
                        bloc.add(NeighborHoodSelectEvent(index: idx));
                      }
                    }
                  } else {
                    pushTransition(
                        context,
                        NeighborHoodAddPage(
                          signUpEnd: true,
                        )).then((value) async {
                      if (value != null) {
                        setState(() {
                          dataSaver.neighborHood.add(value);
                        });
                        await identifyInit();
                        if (dataSaver.nonMember) {
                          List<String> data = [];

                          for (int i = 0;
                              i < dataSaver.neighborHood.length;
                              i++) {
                            data.add(jsonEncode(
                                dataSaver.neighborHood[i].toMapAll()));
                          }
                          await prefs!
                              .setString('guestNeighborHood', jsonEncode(data));
                        }
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: data
                            ? BorderSide(
                                width: dataSaver.neighborHood[idx]
                                            .representativeFlag ==
                                        1
                                    ? 2
                                    : 1,
                                color: dataSaver.neighborHood[idx]
                                            .representativeFlag ==
                                        1
                                    ? AppColors.primary
                                    : AppColors.gray200,
                              )
                            : BorderSide(style: BorderStyle.none)),
                    padding: EdgeInsets.only(
                        top: data ? 16 : 45, bottom: data ? 16 : 45)),
                child: data
                    ? Stack(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  customText(
                                    dataSaver.neighborHood[idx].townName!,
                                    style: TextStyle(
                                        color: AppColors.primaryDark10,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T16)),
                                  )
                                ],
                              ),
                              spaceH(11),
                              Container(
                                width: 220,
                                child: customText(
                                  dataSaver.neighborHood[idx].roadAddress ==
                                          null
                                      ? dataSaver.neighborHood[idx].zipAddress!
                                      : dataSaver
                                          .neighborHood[idx].roadAddress!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.gray400,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)),
                                ),
                              ),
                              Expanded(child: Container()),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    color: AppColors.transparent,
                                    child: GestureDetector(
                                        onTap: () async {
                                          await pushTransition(
                                              context,
                                              NameTheNeighborHoodPage(
                                                neighborHood:
                                                    dataSaver.neighborHood[idx],
                                                myLocation: false,
                                                signUpEnd: true,
                                                edit: true,
                                              )).then((value) {
                                            if (value != null) {
                                              bloc.add(NeighborHoodEditEvent(
                                                  neighborHood: value,
                                                  idx: idx));
                                            }
                                          });
                                        },
                                        child: Image.asset(
                                          AppImages.iEditG,
                                          width: 24,
                                          height: 24,
                                        )),
                                  ),
                                  spaceW(20),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    color: AppColors.transparent,
                                    child: GestureDetector(
                                        onTap: () {
                                          if (dataSaver.neighborHood.length ==
                                              1) {
                                            showToast(
                                                context: context,
                                                text: AppStrings.of(StringKey
                                                    .removeNeighborHoodToast));
                                          } else {
                                            if (data) {
                                              decisionDialog(
                                                  context: context,
                                                  barrier: false,
                                                  text: AppStrings.of(StringKey
                                                      .removeSelectNeighborHood),
                                                  allowText: AppStrings.of(
                                                      StringKey.remove),
                                                  disallowText: AppStrings.of(
                                                      StringKey.cancel),
                                                  allowCallback: () {
                                                    bloc.add(NeighborHoodRemoveEvent(
                                                        memberAreaUuid: dataSaver
                                                                    .neighborHood[
                                                                        idx]
                                                                    .memberAreaUuid ==
                                                                null
                                                            ? ''
                                                            : dataSaver
                                                                .neighborHood[
                                                                    idx]
                                                                .memberAreaUuid!,
                                                        idx: idx));
                                                    popDialog(context);
                                                  },
                                                  disallowCallback: () {
                                                    popDialog(context);
                                                  });
                                            }
                                          }
                                        },
                                        child: Image.asset(
                                          AppImages.iTrashG,
                                          width: 24,
                                          height: 24,
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ),
                          dataSaver.neighborHood[idx].representativeFlag == 1
                              ? Positioned(
                                  right: 16,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.iCheckC,
                                        width: 20,
                                        height: 20,
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      )
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.iPlusC,
                              width: 16,
                              height: 16,
                            ),
                            spaceW(8),
                            customText(
                              AppStrings.of(StringKey.neighborhoodAdd),
                              style: TextStyle(
                                  color: AppColors.primaryDark10,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T14)),
                            )
                          ],
                        ),
                      ),
              ),
              dataSaver.neighborHood.length > idx
                  ? Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        height: 28,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                            color: dataSaver
                                        .neighborHood[idx].representativeFlag ==
                                    1
                                ? AppColors.primary
                                : AppColors.gray200),
                        child: Center(
                          child: customText(
                              dataSaver.neighborHood[idx].eupmyeondongName!,
                              style: TextStyle(
                                  color: dataSaver.neighborHood[idx]
                                              .representativeFlag ==
                                          1
                                      ? AppColors.white
                                      : AppColors.gray500,
                                  fontWeight: weightSet(
                                      textWeight: dataSaver.neighborHood[idx]
                                                  .representativeFlag ==
                                              1
                                          ? TextWeight.BOLD
                                          : TextWeight.MEDIUM),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T11))),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  neighborHoodList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        if (idx < dataSaver.neighborHood.length) {
          return Column(
            children: [neighborHoodListItem(idx, true), spaceH(12)],
          );
        } else {
          return Column(
            children: [neighborHoodListItem(idx, false), spaceH(12)],
          );
        }
      },
      shrinkWrap: true,
      itemCount: 3,
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: Stack(
              children: [
                Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: AppColors.white,
                  appBar: baseAppBar(
                      title: AppStrings.of(StringKey.neighborhoodSelect),
                      context: context,
                      onPressed: () {
                        pop(context);
                      }),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        spaceH(12),
                        dataSaver.neighborHood.length == 0
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: neighborHoodList(),
                              )
                      ],
                    ),
                  ),
                ),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is NeighborHoodSelectCheckState) {
      dataSaver.learnBloc!.add(ReloadClassEvent());
      popWithResult(context, true);
    }

    if (state is NeighborHoodRemoveState) {
      dataSaver.learnBloc!.add(ReloadClassEvent());
    }
  }

  @override
  NeighborHoodSelectBloc initBloc() {
    // TODO: implement initBloc
    return NeighborHoodSelectBloc(context)..add(NeighborHoodSelectInitEvent());
  }
}
