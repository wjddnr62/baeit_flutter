import 'dart:async';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/name_the_neighborhood/name_the_neighborhood_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

// import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import 'neighborhood_add_bloc.dart';

class NeighborHoodAddPage extends BlocStatefulWidget {
  final bool signUpEnd;
  final bool create;

  NeighborHoodAddPage({this.signUpEnd = false, this.create = false});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    // TODO: implement buildState
    return NeighborHoodAddState();
  }
}

class NeighborHoodAddState
    extends BlocState<NeighborHoodAddBloc, NeighborHoodAddPage> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  Timer? searchTimer;
  String search = '';

  searchOnChange() {
    if (search != searchController.text) {
      search = searchController.text;
      bloc.myLocation = false;
      bloc.searching = true;
      setState(() {});
      if (searchController.text != '') {
        if (searchTimer != null) {
          searchTimer!.cancel();
        }
        searchTimer = Timer(Duration(milliseconds: 500), () async {
          bloc.searching = false;
          bloc.add(NeighborHoodSearchEvent(keyword: searchController.text));
        });
      }
    }
  }

  addressSearchBar() {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
          autofocus: true,
          maxLines: 1,
          onChanged: (text) {
            blankCheck(
                text: text,
                controller: searchController);
            setState(() {});
          },
          controller: searchController,
          focusNode: searchFocus,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: TextStyle(
              color: AppColors.gray900,
              fontWeight: weightSet(textWeight: TextWeight.BOLD),
              fontSize: fontSizeSet(textSize: TextSize.T13)),
          decoration: InputDecoration(
            suffixIcon: searchController.text.length > 0
                ? Padding(
                    padding: EdgeInsets.only(top: 14, bottom: 14),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          searchController.text = '';
                          search = '';
                        });
                      },
                      child: Image.asset(AppImages.iInputClear,
                          width: 20, height: 20),
                    ),
                  )
                : null,
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 12, bottom: 12),
              child: Image.asset(AppImages.iSearchC, width: 24, height: 24),
            ),
            hintText: AppStrings.of(StringKey.addressSearchPlaceHolder),
            hintStyle: TextStyle(
                color: AppColors.gray500,
                fontWeight: weightSet(textWeight: TextWeight.REGULAR),
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
            contentPadding: EdgeInsets.zero,
          )),
    );
  }

  title() {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          customText(
            bloc.searchKeyword.length > 8
                ? '\'${bloc.searchKeyword.substring(0, 8)}...\''
                : '\'${bloc.searchKeyword}\'',
            style: TextStyle(
                color: AppColors.primaryDark10,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T12)),
          ),
          customText(
            ' ${AppStrings.of(StringKey.searchResult)}',
            style: TextStyle(
                color: AppColors.gray400,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T12)),
          ),
          Expanded(child: Container()),
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              bloc.loading = true;
              searchController.text = '';
              bloc.juso = [];
              setState(() {});
              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                bloc.loading = false;
                setState(() {});

                decisionDialog(
                    context: context,
                    barrier: false,
                    text: AppStrings.of(StringKey.gpsCheckText),
                    allowText: AppStrings.of(StringKey.check),
                    disallowText: AppStrings.of(StringKey.cancel),
                    allowCallback: () async {
                      popDialog(context);
                      await Geolocator.openLocationSettings();
                    },
                    disallowCallback: () {
                      popDialog(context);
                    });
                return;
              } else {
                if (await Permission.location.isGranted) {
                  Geolocator.getLastKnownPosition().then((value) {
                    if (value != null && value.latitude.toInt() != 0 && value.longitude.toInt() != 0) {
                      bloc.add(NeighborHoodMyLocationEvent(
                          lat: value.latitude.toString(),
                          lon: value.longitude.toString()));
                      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) {
                        bloc.add(NeighborHoodMyLocationEvent(
                            lat: value.latitude.toString(),
                            lon: value.longitude.toString()));
                      });
                    } else {
                      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) {
                        bloc.add(NeighborHoodMyLocationEvent(
                            lat: value.latitude.toString(),
                            lon: value.longitude.toString()));
                      });
                    }
                  });
                  // Location().getLocation().then((value) {
                  //   print("CHECK : $value");
                  //   // bloc.add(NeighborHoodMyLocationEvent(
                  //   //     lat: value.latitude.toString(),
                  //   //     lon: value.longitude.toString()));
                  // });
                  // var location = await Geolocator.getCurrentPosition();
                  // bloc.add(NeighborHoodMyLocationEvent(
                  //     lat: location.latitude.toString(),
                  //     lon: location.longitude.toString()));
                } else if (await Permission.location.isDenied ||
                    await Permission.location.isPermanentlyDenied) {
                  bloc.loading = false;
                  setState(() {});
                  decisionDialog(
                      context: context,
                      barrier: false,
                      text: AppStrings.of(StringKey.locationCheckText),
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
              }
            },
            child: Container(
              height: 30,
              color: AppColors.white,
              child: Row(
                children: [
                  Image.asset(
                    AppImages.iFocusLotation,
                    width: 12,
                    height: 12,
                  ),
                  spaceW(4),
                  customText(
                    AppStrings.of(StringKey.myLocationSearch),
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  itemContent(int idx) {
    return bloc.myLocation
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bloc.addressPointData!.roadAddress == null
                  ? Container()
                  : bloc.addressPointData!.roadAddress!.buildingName == ''
                      ? Container()
                      : customText(
                          bloc.addressPointData!.roadAddress!.buildingName!,
                          style: TextStyle(
                              color: AppColors.gray900,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                        ),
              bloc.addressPointData!.roadAddress == null
                  ? Container()
                  : bloc.addressPointData!.roadAddress!.buildingName == ''
                      ? Container()
                      : spaceH(12),
              bloc.addressPointData!.roadAddress == null
                  ? Container()
                  : customText(
                      '[도로명] ${bloc.addressPointData!.roadAddress!.addressName} ${bloc.addressPointData!.roadAddress!.buildingName}',
                      style: TextStyle(
                          color: AppColors.gray600,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12)),
                    ),
              bloc.addressPointData!.roadAddress == null
                  ? Container()
                  : spaceH(5),
              bloc.addressPointData!.address != null ? customText(bloc.addressPointData!.address!.addressName!,
                  style: TextStyle(
                      color: AppColors.gray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12))) : Container(),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bloc.juso[idx].bdNm == ''
                  ? Container()
                  : customText(
                      bloc.juso[idx].bdNm!,
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T14)),
                    ),
              bloc.juso[idx].bdNm == '' ? Container() : spaceH(12),
              customText(
                '[도로명] ${bloc.juso[idx].roadAddrPart1} ${bloc.juso[idx].bdNm}',
                style: TextStyle(
                    color: AppColors.gray600,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              ),
              bloc.juso[idx].jibunAddr == '' ? Container() : spaceH(5),
              bloc.juso[idx].jibunAddr == ''
                  ? Container()
                  : customText(bloc.juso[idx].jibunAddr!,
                      style: TextStyle(
                          color: AppColors.gray400,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
            ],
          );
  }

  searchResultListItem(int idx) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (widget.create) {
            bloc.add(GetCreateAreaEvent(idx: idx));
            return;
          }

          if (widget.signUpEnd) {
            if (bloc.myLocation) {
              List<String> addressList =
                  bloc.addressPointData!.address!.addressName!.split(" ");
              String address = '';
              for (int i = 0; i < addressList.length; i++) {
                if (i != 0) {
                  address += addressList[i];
                }
              }
              if (dataSaver.neighborHood.indexWhere((element) => element
                      .zipAddress!
                      .replaceAll(' ', '')
                      .contains(address)) !=
                  -1) {
                showToast(
                    context: context,
                    text: AppStrings.of(StringKey.neighborHoodAddToast));
                return;
              }
            } else {
              List<String> addressList =
                  bloc.juso[idx].roadAddrPart1!.split(" ");
              String address = '';
              for (int i = 0; i < addressList.length; i++) {
                if (i != 0) {
                  address += addressList[i];
                }
              }

              if (dataSaver.neighborHood.indexWhere((element) =>
                      element.roadAddress != null &&
                      element.roadAddress!
                          .replaceAll(' ', '')
                          .contains(address)) !=
                  -1) {
                showToast(
                    context: context,
                    text: AppStrings.of(StringKey.neighborHoodAddToast));
                return;
              }
            }
          }
          pushTransition(
              context,
              NameTheNeighborHoodPage(
                juso: bloc.juso.length == 0 ? null : bloc.juso[idx],
                addressPointData: bloc.addressPointData,
                myLocation: bloc.myLocation,
                signUpEnd: widget.signUpEnd,
                edit: false,
              )).then((value) {
            if (value != null) {
              popWithResult(context, value);
            }
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gray200)),
          padding: EdgeInsets.all(20),
          child: itemContent(idx),
        ),
      ),
    );
  }

  searchResultList() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return Column(
          children: [
            searchResultListItem(idx),
            bloc.myLocation
                ? spaceH(20)
                : bloc.juso.length - 1 == idx
                    ? spaceH(20)
                    : spaceH(12)
          ],
        );
      },
      shrinkWrap: true,
      itemCount: bloc.myLocation ? 1 : bloc.juso.length,
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
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
                  title: AppStrings.of(StringKey.neighborhoodAdd),
                  context: context,
                  onPressed: () {
                    pop(context);
                  },
                  close: !widget.signUpEnd ? true : false,
                  action: Container()),
              body: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      spaceH(10),
                      addressSearchBar(),
                      title(),
                      bloc.juso.length != 0 ||
                              bloc.myLocation ||
                              searchController.text != '' ||
                              bloc.search
                          ? Container()
                          : spaceH(40),
                      bloc.juso.length == 0 && !bloc.search && bloc.addressPointData == null
                          ? Image.asset(
                              AppImages.imgEmptySearch,
                              height: 180,
                            )
                          : Container(),
                      bloc.juso.length == 0 && !bloc.myLocation
                          ? Container()
                          : SingleChildScrollView(
                              child: Container(
                              height: MediaQuery.of(context).size.height -
                                  (MediaQuery.of(context).padding.top +
                                      MediaQuery.of(context).padding.bottom +
                                      166 +
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: bloc.addressPointData == null &&
                                      bloc.juso.length == 0
                                  ? Container()
                                  : searchResultList(),
                            )),
                      bloc.juso.length == 0 && !bloc.search && bloc.addressPointData == null
                          ? RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                customTextSpan(
                                    text: '도로명, 건물명',
                                    style: TextStyle(
                                        color: AppColors.accentLight20,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.REGULAR),
                                        fontSize:
                                            fontSizeSet(textSize: TextSize.T14))),
                                customTextSpan(
                                    text: ' 또는 ',
                                    style: TextStyle(
                                        color: AppColors.gray400,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.REGULAR),
                                        fontSize:
                                            fontSizeSet(textSize: TextSize.T14))),
                                TextSpan(
                                    text: '지번',
                                    style: TextStyle(
                                        color: AppColors.accentLight20,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.REGULAR),
                                        fontSize:
                                            fontSizeSet(textSize: TextSize.T14))),
                                TextSpan(
                                  text: '으로\n검색해주세요',
                                  style: TextStyle(
                                      color: AppColors.gray400,
                                      fontWeight:
                                          weightSet(textWeight: TextWeight.REGULAR),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                )
                              ]),
                            )
                          : Container(),
                      bloc.juso.length == 0 &&
                              !bloc.myLocation &&
                              bloc.search && !bloc.loading && !bloc.searching
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.imgEmptySearch,
                                  height: 180,
                                ),
                                customText(
                                  '\'${searchController.text}\'의 검색결과가 없어요',
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight:
                                          weightSet(textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                )
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
            loadingView(bloc.loading)
          ],
        ),
      ),
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is GetCreateAreaState) {
      popWithResult(context, state.neighborHood);
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(searchOnChange);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  initBloc() {
    return NeighborHoodAddBloc(context)..add(NeighborHoodAddInitEvent());
  }
}
