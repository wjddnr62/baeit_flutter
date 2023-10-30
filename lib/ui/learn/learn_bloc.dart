import 'dart:convert';
import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/map_data.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/polygon.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/repository/community_repository.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/data/reword/repository/reward_repository.dart';
import 'package:baeit/data/reword/reword.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class LearnBloc extends BaseBloc {
  LearnBloc(BuildContext context) : super(BaseLearnState()) {
    on<LearnInitEvent>(onLearnInitEvent);
    on<GetMarkerDataEvent>(onGetMarkerDataEvent);
    on<SelectMarkerEvent>(onSelectMarkerEvent);
    on<ReloadLearnEvent>(onReloadLearnEvent);
    on<NewDataEvent>(onNewDataEvent);
    on<ScrollEndEvent>(onScrollEndEvent);
    on<ReloadClassEvent>(onReloadClassEvent);
    on<NeighborHoodChangeEvent>(onNeighborHoodChangeEvent);
    on<SaveFilterEvent>(onSaveFilterEvent);
    on<FilterSetAllEvent>(onFilterSetAllEvent);
    on<LearnTypeChangeEvent>(onLearnTypeChangeEvent);
    on<GetKeywordCountEvent>(onGetKeywordCountEvent);
    on<SearchChangeEvent>(onSearchChangeEvent);
    on<NeighborHoodSelecterViewOpenEvent>(onNeighborHoodSelecterViewOpenEvent);
    on<ChangeViewEvent>(onChangeViewEvent);
    on<NotificationAnimationEvent>(onNotificationAnimationEvent);
    on<CommunityNewDataEvent>(onCommunityNewDataEvent);
    on<CommunityReloadEvent>(onCommunityReloadEvent);
    on<CommunityTabChangeEvent>(onCommunityTabChangeEvent);
    on<CommunityFirstInEvent>(onCommunityFirstInEvent);
  }

  // Public
  int learnType = 0;

  bool loading = false;
  NeighborHood? mainNeighborHood;
  dynamic vsync;

  bool neighborhoodSelecterView = false;
  bool neighborhoodSelecterAnimationEnd = true;

  bool search = false;

  NaverMapController? naverMapController;
  bool markerLoad = false;

  bool closeNeighborhoodSelecter = true;

  bool notificationAnimation = false;
  bool notificationAnimationClose = false;

  bool getData = true;

  //

  // Class
  List<bool> openFilterValues = [];
  List<bool> filterValues = [];

  List<String> filterData = [];
  List<String> openFilterData = [];
  List<String> filterItemName = [];
  List<String> filterItemCheckImage = [];
  List<String> filterItemUnCheckImage = [];

  bool saveIng = false;
  bool categoryFilter = false;

  double mapLevel = 10.0;
  List<MapData> mapDatas = [];
  List<Marker> markers = [];
  List<PolygonOverlay> polygonOverlay = [];
  bool selectMarker = false;
  Marker? selectMarkerData;

  bool sidoMarkerAdd = false;
  bool sigunguMarkerAdd = false;
  bool eupmyeondongMarkerAdd = false;

  int snapIndex = 1;
  bool gesture = false;

  bool listLoading = true;
  String selectLocation = '전국';

  double bottomOffset = 0;
  bool scrollUnder = false;

  bool scrollUp = true;
  bool scrollEnd = false;

  bool startScroll = false;
  bool upDownCheck = false;
  double startPixels = 0;

  int orderType = 1;

  int nextData = 1;

  ClassList? selectClass;

  double selectBottomOffset = 0;
  bool selectScrollUnder = false;

  bool selectScrollUp = true;
  bool selectScrollEnd = false;

  bool selectStartScroll = false;
  bool selectUpDownCheck = false;
  double selectStartPixels = 0;

  int selectNextData = 1;

  //

  // community
  PanelController communityPanelController = PanelController();

  int communityOrderType = 1;

  String communityLastCursor = '';

  double communityBottomOffset = 0;
  bool communityScrollUnder = false;

  bool communityScrollUp = true;
  bool communityScrollEnd = false;

  bool communityStartScroll = false;
  bool communityUpDownCheck = false;
  double communityStartPixels = 0;

  int communityNextData = 1;

  CommunityList? communityList;

  bool communityLoading = false;

  int communityTabIndex = 0;

  //

  setSelectDefaultData() {
    selectClass = null;

    selectBottomOffset = 0;
    selectScrollUnder = false;
    dataSaver.lastNextCursor = '';

    selectScrollUp = true;
    selectScrollEnd = false;

    selectStartScroll = false;
    selectUpDownCheck = false;
    selectStartPixels = 0;

    selectNextData = 1;
  }

  setPublicClassData() {
    dataSaver.classFilterValues = [];
    dataSaver.classFilterValues!.addAll(filterValues);
  }

  onReloadClassEvent(ReloadClassEvent event, emit) async {
    if (selectMarker) {
      setSelectDefaultData();
      listLoading = true;
      emit(LoadingState());

      MapData mapData =
          MapData.fromJson(jsonDecode(selectMarkerData!.markerId));

      polygonOverlay = [];

      ReturnData polygonData = await CommonRepository.getPolygonV2(
          int.parse(mapData.addressSidoNo.toString()),
          mapData.addressSigunguNo == null
              ? null
              : int.parse(mapData.addressSigunguNo.toString()),
          mapData.addressEupmyeondongNo == null
              ? null
              : int.parse(mapData.addressEupmyeondongNo.toString()));

      if (polygonData.data != null) {
        Polygon polygon = Polygon.fromJson(polygonData.data);

        if (polygon.geometry.type == 'MultiPolygon') {
          for (int i = 0; i < polygon.geometry.coordinates.length; i++) {
            List<dynamic> polygonData = polygon.geometry.coordinates[i][0];
            List<LatLng> latLngs = [];
            for (int j = 0; j < polygonData.length; j++) {
              latLngs.add(LatLng(polygonData[j][1], polygonData[j][0]));
            }
            polygonOverlay.add(PolygonOverlay(
              i.toString(),
              latLngs,
              color: AppColors.primary.withOpacity(0.1),
              outlineColor: AppColors.primary,
              outlineWidth: 2,
            ));
          }
        } else {
          List<dynamic> polygonData = polygon.geometry.coordinates;
          List<LatLng> latLngs = [];
          for (int j = 0; j < polygonData.length; j++) {
            latLngs.add(LatLng(polygonData[j][1], polygonData[j][0]));
          }
          polygonOverlay.add(PolygonOverlay(
            polygon.hangCode.toString(),
            latLngs,
            color: AppColors.primary.withOpacity(0.1),
            outlineColor: AppColors.primary,
            outlineWidth: 2,
          ));
        }
      }

      ReturnData returnData = await ClassRepository.getMapClass(
          categories: filterData.join(","),
          lati: mainNeighborHood!.lati!,
          longi: mainNeighborHood!.longi!,
          orderType: orderType == 2
              ? 3
              : orderType == 0
                  ? 2
                  : 1,
          addressSidoNo: mapData.addressSidoNo.toString(),
          addressSigunguNo: mapData.addressSigunguNo.toString(),
          addressEupmyeondongNo: mapData.addressEupmyeondongNo.toString(),
          type: 'MADE');

      if (returnData.code == 1) {
        selectClass = ClassList.fromJson(returnData.data);
      }

      listLoading = false;
      emit(ReloadClassState());
    } else {
      nextData = 1;
      scrollEnd = false;
      scrollUnder = false;
      listLoading = true;
      emit(LoadingState());

      dataSaver.neighborHoodClass = null;
      dataSaver.lastNextCursor = '';

      mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
          .indexWhere((element) => element.representativeFlag == 1)];

      ReturnData returnData = await ClassRepository.getMapClass(
          categories: filterData.join(","),
          lati: mainNeighborHood!.lati!,
          longi: mainNeighborHood!.longi!,
          orderType: orderType == 2
              ? 3
              : orderType == 0
                  ? 2
                  : 1,
          type: 'MADE');

      if (returnData.code == 1) {
        dataSaver.neighborHoodClass = ClassList.fromJson(returnData.data);
        listLoading = false;
        emit(ReloadClassState());
      } else {
        listLoading = false;
        emit(ErrorState());
      }
    }
  }

  onScrollEndEvent(ScrollEndEvent event, emit) {
    if (learnType == 0) {
      scrollEnd = true;
    } else {}
    emit(ScrollEndState());
  }

  onNewDataEvent(NewDataEvent event, emit) async {
    if (learnType == 0) {
      if (selectMarker) {
        MapData mapData =
            MapData.fromJson(jsonDecode(selectMarkerData!.markerId));

        if (selectClass!.classData.length == selectNextData * 10 &&
            !selectScrollUnder &&
            dataSaver.lastNextCursor != selectClass!.classData.last.cursor &&
            getData) {
          getData = false;
          if (Platform.isAndroid) {
            Future.delayed(Duration(milliseconds: 500), () {
              getData = true;
            });
          } else if (Platform.isIOS) {
            Future.delayed(Duration(milliseconds: 2000), () {
              getData = true;
            });
          }
          selectScrollUnder = true;
          emit(CheckState());

          dataSaver.lastNextCursor = selectClass!.classData.last.cursor!;

          ReturnData returnData = await ClassRepository.getMapClass(
              categories: filterData.join(","),
              lati: mainNeighborHood!.lati!,
              longi: mainNeighborHood!.longi!,
              orderType: orderType == 2
                  ? 3
                  : orderType == 0
                      ? 2
                      : 1,
              addressSidoNo: mapData.addressSidoNo.toString(),
              addressSigunguNo: mapData.addressSigunguNo.toString(),
              addressEupmyeondongNo: mapData.addressEupmyeondongNo.toString(),
              nextCursor: selectClass!.classData.last.cursor,
              type: 'MADE');

          if (returnData.code == 1) {
            selectClass!.classData
                .addAll(ClassList.fromJson(returnData.data).classData);
            selectNextData += 1;
            selectScrollUnder = false;
            emit(NewDataState());
          }
        }
      } else {
        if (dataSaver.neighborHoodClass!.classData.length == nextData * 10 &&
            !scrollUnder &&
            dataSaver.lastNextCursor !=
                dataSaver.neighborHoodClass!.classData.last.cursor &&
            getData) {
          getData = false;
          if (Platform.isAndroid) {
            Future.delayed(Duration(milliseconds: 500), () {
              getData = true;
            });
          } else if (Platform.isIOS) {
            Future.delayed(Duration(milliseconds: 2000), () {
              getData = true;
            });
          }
          scrollUnder = true;
          emit(CheckState());

          dataSaver.lastNextCursor =
              dataSaver.neighborHoodClass!.classData.last.cursor!;

          ReturnData returnData = await ClassRepository.getMapClass(
              categories: filterData.join(","),
              lati: mainNeighborHood!.lati!,
              longi: mainNeighborHood!.longi!,
              orderType: orderType == 2
                  ? 3
                  : orderType == 0
                      ? 2
                      : 1,
              nextCursor: dataSaver.neighborHoodClass!.classData.last.cursor,
              type: 'MADE');

          if (returnData.code == 1) {
            dataSaver.neighborHoodClass!.classData
                .addAll(ClassList.fromJson(returnData.data).classData);
            nextData += 1;
            scrollUnder = false;
            emit(NewDataState());
          }
        }
      }
    } else {}
  }

  onCommunityNewDataEvent(CommunityNewDataEvent event, emit) async {
    if (communityList!.communityData.length == communityNextData * 20 &&
        !communityScrollUnder &&
        communityLastCursor != communityList!.communityData.last.cursor) {
      communityScrollUnder = true;

      communityLastCursor = communityList!.communityData.last.cursor;

      ReturnData communityRes = await CommunityRepository.getCommunity(
        lati: mainNeighborHood!.lati!,
        longi: mainNeighborHood!.longi!,
        orderType: communityOrderType == 0 ? 2 : 1,
        category: communityTypeCreate(communityTabIndex),
        nextCursor: communityLastCursor,
      );

      communityList!.communityData
          .addAll(CommunityList.fromJson(communityRes.data).communityData);
      communityNextData += 1;
      communityScrollUnder = false;
      emit(CommunityNewDataState());
    }
  }

  onLearnInitEvent(LearnInitEvent event, emit) async {
    loading = true;
    emit(LearnInitState());

    if (prefs!.getBool('guest') ?? false) {
      dataSaver.nonMember = true;
    }
    ReturnData rewardData = await RewardRepository.getDetailReward();
    if (rewardData.data != null)
      dataSaver.reward = Reward.fromJson(rewardData.data);

    add(GetKeywordCountEvent());

    if (dataSaver.category.length == 0) {
      ReturnData categoryData = await ClassRepository.getCategory();

      dataSaver.category =
          (categoryData.data as List).map((e) => Category.fromJson(e)).toList();
    }

    filterValues = List.generate(dataSaver.category.length, (index) => true);

    if (dataSaver.classFilterValues != null) {
      filterValues = [];
      filterValues.addAll(dataSaver.classFilterValues!);
    }

    setPublicClassData();

    for (int i = 0; i < dataSaver.category.length; i++) {
      filterData.add(dataSaver.category[i].classCategoryId!);
      filterItemName.add(dataSaver.category[i].name!);
      filterItemCheckImage
          .add(filterCheckImage(dataSaver.category[i].classCategoryId));
      filterItemUnCheckImage
          .add(filterUnCheckImage(dataSaver.category[i].classCategoryId));
    }

    filterData = [];

    for (int i = 0; i < filterValues.length; i++) {
      if (filterValues[i]) {
        filterData.add(dataSaver.category[i].classCategoryId!);
      }
    }

    openFilterValues = filterValues;
    openFilterData = filterData;

    vsync = event.vsync;

    if (prefs!.getBool('guest') != null &&
        prefs!.getString('guestNeighborHood') != null &&
        prefs!.getString('guestNeighborHood') != '') {
      List data = jsonDecode(prefs!.getString('guestNeighborHood')!);
      dataSaver.neighborHood =
          data.map((e) => NeighborHood.fromJson(jsonDecode(e))).toList();
      await identifyInit();
    }

    if (dataSaver.neighborHood.length == 0) {
      if (!dataSaver.nonMember) {
        ReturnData returnData =
            await NeighborHoodSelectRepository.getNeighborHoodList();
        for (dynamic data in returnData.data) {
          dataSaver.neighborHood.add(NeighborHood.fromJson(data));
        }
      } else {
        ReturnData returnData =
            await NeighborHoodSelectRepository.nonMemberArea();
        if (dataSaver.neighborHood.length == 0) {
          dataSaver.neighborHood.add(NeighborHood.fromJson(returnData.data));
        }

        List<String> data = [];

        for (int i = 0; i < dataSaver.neighborHood.length; i++) {
          data.add(jsonEncode(dataSaver.neighborHood[i].toMapAll()));
        }

        if (prefs!.getString('guestNeighborHood') == null) {
          await prefs!.setString('guestNeighborHood', jsonEncode(data));
        }
      }
    }

    mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
        .indexWhere((element) => element.representativeFlag == 1)];

    loading = false;
    emit(LearnInitState());

    listLoading = true;
    communityLoading = true;
    emit(LearnInitState());
    if (dataSaver.neighborHoodClass == null) {
      ReturnData returnData = await ClassRepository.getMapClass(
          categories: filterData.join(","),
          lati: mainNeighborHood!.lati!,
          longi: mainNeighborHood!.longi!,
          orderType: orderType == 2
              ? 3
              : orderType == 0
                  ? 2
                  : 1,
          type: 'MADE');

      if (returnData.code == 1) {
        dataSaver.neighborHoodClass = ClassList.fromJson(returnData.data);
      }

      ReturnData communityRes = await CommunityRepository.getCommunity(
          lati: mainNeighborHood!.lati!,
          longi: mainNeighborHood!.longi!,
          category: communityTypeCreate(communityTabIndex),
          orderType: communityOrderType == 0 ? 2 : 1);

      communityList = CommunityList.fromJson(communityRes.data);
    }

    listLoading = false;
    communityLoading = false;
    emit(LearnInitState());

    emit(CheckState());
  }

  getMarker(int mapLevel) async {
    ReturnData data = await ClassRepository.getMapMarker(
      dataSaver
          .neighborHood[dataSaver.neighborHood
              .indexWhere((element) => element.representativeFlag == 1)]
          .lati!,
      dataSaver
          .neighborHood[dataSaver.neighborHood
              .indexWhere((element) => element.representativeFlag == 1)]
          .longi!,
      mapLevel,
      categories: filterData.join(","),
    );

    List<dynamic> dataList = data.data;
    List<MapData> datas = dataList.map((e) => MapData.fromJson(e)).toList();
    for (int i = 0; i < datas.length; i++) {
      if (mapDatas.indexWhere((element) =>
                  element.addressSidoNo == datas[i].addressSidoNo) ==
              -1 ||
          mapDatas.indexWhere((element) =>
                  element.addressSigunguNo == datas[i].addressSigunguNo) ==
              -1 ||
          mapDatas.indexWhere((element) =>
                  element.addressEupmyeondongNo ==
                  datas[i].addressEupmyeondongNo) ==
              -1 ||
          mapDatas.indexWhere((element) => element.name == datas[i].name) ==
              -1) {
        mapDatas.add(datas[i]);
      }
    }

    for (int i = 0; i < mapDatas.length; i++) {
      await OverlayImage.fromAssetImage(
              assetName: mapDatas[i].addressEupmyeondongNo == null
                  ? mapDatas[i].addressSigunguNo == null
                      ? AppImages.pinSi
                      : AppImages.pinGu
                  : AppImages.pinDong)
          .then((value) {
        if (selectMarker &&
            jsonEncode(mapDatas[i].toMap()) == selectMarkerData!.markerId) {
          return;
        }
        if (markers.indexWhere((element) =>
                element.markerId == jsonEncode(mapDatas[i].toMap())) ==
            -1)
          markers.add(Marker(
              markerId: jsonEncode(mapDatas[i].toMap()),
              position: LatLng(mapDatas[i].lati, mapDatas[i].longi),
              icon: value,
              captionText:
                  (mapDatas[i].cnt > 999 ? '999+' : mapDatas[i].cnt).toString(),
              captionColor: AppColors.white,
              captionTextSize: 14,
              subCaptionText: '\n' + mapDatas[i].name,
              subCaptionColor: AppColors.primary,
              captionPerspectiveEnabled: true,
              subCaptionTextSize: 14,
              captionHaloColor: AppColors.transparent,
              subCaptionHaloColor: AppColors.white,
              anchor: AnchorPoint(0.5, 0.5),
              captionOffset: mapDatas[i].addressEupmyeondongNo == null
                  ? mapDatas[i].addressSigunguNo == null
                      ? -32
                      : -32
                  : -30,
              minZoom: mapDatas[i].addressEupmyeondongNo == null
                  ? mapDatas[i].addressSigunguNo == null
                      ? 6
                      : 6
                  : 11.6,
              maxZoom: mapDatas[i].addressEupmyeondongNo == null
                  ? mapDatas[i].addressSigunguNo == null
                      ? 11.5999
                      : 11.5999
                  : 18,
              width: 48,
              height: 48,
              onMarkerTab: markerTap));
      });
    }

    if (selectMarker) {
      int index = markers.indexWhere(
          (element) => element.markerId == selectMarkerData!.markerId);
      markers[index] = selectMarkerData!;
      // add(ReloadLearnEvent());
    }

    add(ChangeViewEvent());
  }

  markerTap(Marker? marker, dynamic iconSize) async {
    if (selectMarkerData != null &&
        (marker!.markerId != selectMarkerData!.markerId)) {
      MapData mapData =
          MapData.fromJson(jsonDecode(selectMarkerData!.markerId));
      selectLocation = mapData.name;
      int index = markers.indexWhere(
          (element) => element.markerId == selectMarkerData!.markerId);
      markers.removeAt(index);
      await OverlayImage.fromAssetImage(
              assetName: mapData.addressEupmyeondongNo == null
                  ? mapData.addressSigunguNo == null
                      ? AppImages.pinSi
                      : AppImages.pinGu
                  : AppImages.pinDong)
          .then((value) {
        markers.insert(
            index,
            Marker(
                markerId: jsonEncode(mapData.toMap()),
                position: LatLng(mapData.lati, mapData.longi),
                icon: value,
                captionText:
                    (mapData.cnt > 999 ? '999+' : mapData.cnt).toString(),
                captionColor: AppColors.white,
                captionTextSize: 14,
                subCaptionText: '\n' + mapData.name,
                subCaptionColor: AppColors.primary,
                captionPerspectiveEnabled: true,
                subCaptionTextSize: 14,
                captionHaloColor: AppColors.transparent,
                subCaptionHaloColor: AppColors.white,
                anchor: AnchorPoint(0.5, 0.5),
                captionOffset: mapData.addressEupmyeondongNo == null
                    ? mapData.addressSigunguNo == null
                        ? -32
                        : -32
                    : -30,
                minZoom: mapData.addressEupmyeondongNo == null
                    ? mapData.addressSigunguNo == null
                        ? 6
                        : 6
                    : 11.6,
                maxZoom: mapData.addressEupmyeondongNo == null
                    ? mapData.addressSigunguNo == null
                        ? 11.5999
                        : 11.5999
                    : 18,
                width: 48,
                height: 48,
                onMarkerTab: markerTap));
      });
    }

    selectMarker = true;
    MapData mapData = MapData.fromJson(jsonDecode(marker!.markerId));
    selectLocation = mapData.name;
    int index =
        markers.indexWhere((element) => element.markerId == marker.markerId);
    await OverlayImage.fromAssetImage(
            assetName: mapData.addressEupmyeondongNo == null
                ? mapData.addressSigunguNo == null
                    ? AppImages.pinSiOn
                    : AppImages.pinGuOn
                : AppImages.pinDongOn)
        .then((value) {
      selectMarkerData = Marker(
          markerId: jsonEncode(mapData.toMap()),
          position: marker.position,
          icon: value,
          captionText: '\u00d7',
          captionColor: marker.captionColor,
          subCaptionText: '\n' + mapData.name,
          subCaptionColor: AppColors.accent,
          subCaptionTextSize: 14,
          captionOffset: mapData.addressEupmyeondongNo == null
              ? mapData.addressSigunguNo == null
                  ? -36
                  : -36
              : -34,
          minZoom: marker.minZoom,
          maxZoom: marker.maxZoom,
          width: 48,
          height: 48,
          subCaptionHaloColor: marker.subCaptionHaloColor,
          captionHaloColor: marker.captionHaloColor,
          captionTextSize: 18,
          onMarkerTab: selectedMarkerTap);
      markers.removeAt(index);
      markers.insert(index, selectMarkerData!);
      add(ReloadLearnEvent(firstTap: true));
    });
  }

  selectedMarkerTap(Marker? marker, dynamic iconSize) async {
    markerLoad = true;
    selectMarker = false;
    selectLocation = '전국';
    selectMarkerData = null;
    MapData mapData = MapData.fromJson(jsonDecode(marker!.markerId));
    int index =
        markers.indexWhere((element) => element.markerId == marker.markerId);
    await OverlayImage.fromAssetImage(
            assetName: mapData.addressEupmyeondongNo == null
                ? mapData.addressSigunguNo == null
                    ? AppImages.pinSi
                    : AppImages.pinGu
                : AppImages.pinDong)
        .then((value) async {
      markers.removeAt(index);
      markers.insert(
          index,
          Marker(
              markerId: jsonEncode(mapData.toMap()),
              position: LatLng(mapData.lati, mapData.longi),
              icon: value,
              captionText:
                  (mapData.cnt > 999 ? '999+' : mapData.cnt).toString(),
              captionColor: AppColors.white,
              captionTextSize: 14,
              subCaptionText: '\n' + mapData.name,
              subCaptionColor: AppColors.primary,
              captionPerspectiveEnabled: true,
              subCaptionTextSize: 14,
              captionHaloColor: AppColors.transparent,
              subCaptionHaloColor: AppColors.white,
              anchor: AnchorPoint(0.5, 0.5),
              captionOffset: mapData.addressEupmyeondongNo == null
                  ? mapData.addressSigunguNo == null
                      ? -32
                      : -32
                  : -30,
              minZoom: mapData.addressEupmyeondongNo == null
                  ? mapData.addressSigunguNo == null
                      ? 6
                      : 6
                  : 11.5999,
              maxZoom: mapData.addressEupmyeondongNo == null
                  ? mapData.addressSigunguNo == null
                      ? 11.6
                      : 11.6
                  : 18,
              width: 48,
              height: 48,
              onMarkerTab: markerTap));
      markerLoad = false;
      add(ReloadLearnEvent());
    });
  }

  onReloadLearnEvent(ReloadLearnEvent event, emit) async {
    if (selectMarker) {
      setSelectDefaultData();
      listLoading = true;
      polygonOverlay = [];
      emit(LoadingState());

      MapData mapData =
          MapData.fromJson(jsonDecode(selectMarkerData!.markerId));

      ReturnData polygonData = await CommonRepository.getPolygonV2(
          int.parse(mapData.addressSidoNo.toString()),
          mapData.addressSigunguNo != null
              ? int.parse(mapData.addressSigunguNo.toString())
              : null,
          mapData.addressEupmyeondongNo != null
              ? int.parse(mapData.addressEupmyeondongNo.toString())
              : null);

      if (polygonData.data != null) {
        Polygon polygon = Polygon.fromJson(polygonData.data);

        if (polygon.geometry.type == 'MultiPolygon') {
          for (int i = 0; i < polygon.geometry.coordinates.length; i++) {
            List<dynamic> polygonData = polygon.geometry.coordinates[i][0];
            List<LatLng> latLngs = [];
            for (int j = 0; j < polygonData.length; j++) {
              latLngs.add(LatLng(polygonData[j][1], polygonData[j][0]));
            }
            polygonOverlay.add(PolygonOverlay(
              i.toString(),
              latLngs,
              color: AppColors.primary.withOpacity(0.1),
              outlineColor: AppColors.primary,
              outlineWidth: 2,
            ));
          }
        } else {
          List<dynamic> polygonData = polygon.geometry.coordinates;
          List<LatLng> latLngs = [];
          for (int j = 0; j < polygonData.length; j++) {
            latLngs.add(LatLng(polygonData[j][1], polygonData[j][0]));
          }
          polygonOverlay.add(PolygonOverlay(
            polygon.hangCode.toString(),
            latLngs,
            color: AppColors.primary.withOpacity(0.1),
            outlineColor: AppColors.primary,
            outlineWidth: 2,
          ));
        }
      }

      ReturnData returnData = await ClassRepository.getMapClass(
          categories: filterData.join(","),
          lati: mainNeighborHood!.lati!,
          longi: mainNeighborHood!.longi!,
          orderType: orderType == 2
              ? 3
              : orderType == 0
                  ? 2
                  : 1,
          addressSidoNo: mapData.addressSidoNo.toString(),
          addressSigunguNo: mapData.addressSigunguNo.toString(),
          addressEupmyeondongNo: mapData.addressEupmyeondongNo.toString(),
          type: 'MADE');

      if (returnData.code == 1) {
        selectClass = ClassList.fromJson(returnData.data);
      }

      if (event.firstTap) {
        amplitudeEvent('pin', {
          'town_name': mapData.name,
          'class_volume': selectClass!.classData.length,
          'map_level': mapLevel
        });
      }
      listLoading = false;
      emit(ReloadLearnState());
    } else {
      emit(ReloadLearnState());
    }
  }

  onGetMarkerDataEvent(GetMarkerDataEvent event, emit) {
    // if (mapLevel >= 6 && mapLevel < 10) {
    //   // sigunguMarkerAdd = false;
    //   // eupmyeondongMarkerAdd = false;
    //   if (!sidoMarkerAdd) {
    //     sidoMarkerAdd = true;
    //     getMarker();
    //   }
    // } else
    if (mapLevel >= 6 && mapLevel < 11.6) {
      // sidoMarkerAdd = false;
      // eupmyeondongMarkerAdd = false;
      if (!sigunguMarkerAdd) {
        loading = true;
        emit(GetMarkerDataState());
        sigunguMarkerAdd = true;
        getMarker(2);
        loading = false;
        emit(GetMarkerDataState());
      }
    } else if (mapLevel >= 11.6 && mapLevel < 18) {
      // sidoMarkerAdd = false;
      // sigunguMarkerAdd = false;
      if (!eupmyeondongMarkerAdd) {
        loading = true;
        emit(GetMarkerDataState());
        eupmyeondongMarkerAdd = true;
        getMarker(3);
        loading = false;
        emit(GetMarkerDataState());
      }
    }
  }

  onSelectMarkerEvent(SelectMarkerEvent event, emit) {
    emit(SelectMarkerState());
  }

  filterCheckImage(classCategoryId) {
    switch (classCategoryId) {
      case 'CAREER':
        return AppImages.iCategoryCCareer;
      case 'CERTIFICATE':
        return AppImages.iCategoryCTest;
      case 'ETC':
        return AppImages.iCategoryCEtc;
      case 'HEALTH':
        return AppImages.iCategoryCSports;
      case 'HOBBY':
        return AppImages.iCategoryCHobby;
      case 'HOME_BASED':
        return AppImages.iCategoryCNJob;
      case 'LANGUAGE':
        return AppImages.iCategoryCLanguage;
      case 'LESSON':
        return AppImages.iCategoryCLesson;
      case 'LIFE':
        return AppImages.iCategoryCLife;
    }
  }

  filterUnCheckImage(classCategoryId) {
    switch (classCategoryId) {
      case 'CAREER':
        return AppImages.iCategoryLCareer;
      case 'CERTIFICATE':
        return AppImages.iCategoryLTest;
      case 'ETC':
        return AppImages.iCategoryLEtc;
      case 'HEALTH':
        return AppImages.iCategoryLSports;
      case 'HOBBY':
        return AppImages.iCategoryLHobby;
      case 'HOME_BASED':
        return AppImages.iCategoryLNJob;
      case 'LANGUAGE':
        return AppImages.iCategoryLLanguage;
      case 'LESSON':
        return AppImages.iCategoryLLesson;
      case 'LIFE':
        return AppImages.iCategoryLLife;
    }
  }

  onSaveFilterEvent(SaveFilterEvent event, emit) {
    if (learnType == 0) {
      saveIng = false;
      openFilterData = filterData;
      openFilterValues = filterValues;
    } else {}
    emit(SaveFilterState());
  }

  onFilterSetAllEvent(FilterSetAllEvent event, emit) {
    if (learnType == 0) {
      if (event.check) {
        filterData = [];
        for (int i = 0; i < dataSaver.category.length; i++) {
          filterValues[i] = true;
          filterData.add(dataSaver.category[i].classCategoryId!);
        }
      } else {
        filterData = [];
        for (int i = 0; i < dataSaver.category.length - 1; i++) {
          filterValues[i + 1] = false;
        }
        filterData.add(dataSaver.category[0].classCategoryId!);
      }
      emit(FilterSetAllState());
    } else {}
  }

  onNeighborHoodChangeEvent(NeighborHoodChangeEvent event, emit) async {
    loading = true;
    emit(LoadingState());
    for (int i = 0; i < dataSaver.neighborHood.length; i++) {
      dataSaver.neighborHood[i].representativeFlag = 0;
    }
    dataSaver.neighborHood[event.index].representativeFlag = 1;
    if (!dataSaver.nonMember) {
      await NeighborHoodSelectRepository.setNeighborHoodRepresentative(
          dataSaver.neighborHood[event.index].memberAreaUuid!);
    } else {
      if (dataSaver.nonMember) {
        List<String> data = [];

        for (int i = 0; i < dataSaver.neighborHood.length; i++) {
          data.add(jsonEncode(dataSaver.neighborHood[i].toMapAll()));
        }
        await prefs!.setString('guestNeighborHood', jsonEncode(data));
      }
    }

    mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
        .indexWhere((element) => element.representativeFlag == 1)];

    loading = false;
    emit(NeighborHoodChangeState());
  }

  onLearnTypeChangeEvent(LearnTypeChangeEvent event, emit) {
    learnType = event.type;
    emit(LearnTypeChangeState());
  }

  onGetKeywordCountEvent(GetKeywordCountEvent event, emit) async {
    // if (!dataSaver.nonMember) {
    //   await NotificationRepository.getNotificationAllCount().then((value) {
    //     if (value.data != null) {
    //       dataSaver.alarmCount = value.data;
    //     }
    //     emit(GetKeywordCountState());
    //   });
    // }
    emit(GetKeywordCountState());
  }

  onSearchChangeEvent(SearchChangeEvent event, emit) {
    search = !search;
    emit(SearchChangeState());
  }

  onNeighborHoodSelecterViewOpenEvent(
      NeighborHoodSelecterViewOpenEvent event, emit) {
    neighborhoodSelecterView = true;
    neighborhoodSelecterAnimationEnd = false;
    emit(NeighborHoodSelecterViewOpenState());
  }

  onChangeViewEvent(ChangeViewEvent event, emit) {
    emit(ChangeViewState());
  }

  onNotificationAnimationEvent(NotificationAnimationEvent event, emit) {
    notificationAnimation = true;
    Future.delayed(Duration(milliseconds: 500), () {
      notificationAnimationClose = true;
    });
    emit(NotificationAnimationState());
  }

  onCommunityReloadEvent(CommunityReloadEvent event, emit) async {
    communityLoading = true;
    emit(LoadingState());

    ReturnData communityRes = await CommunityRepository.getCommunity(
        lati: mainNeighborHood!.lati!,
        longi: mainNeighborHood!.longi!,
        orderType: communityOrderType == 0 ? 2 : 1,
        category: communityTypeCreate(communityTabIndex));

    communityNextData = 1;

    communityList = null;
    communityList = CommunityList.fromJson(communityRes.data);
    communityLoading = false;
    emit(CommunityReloadState());
  }

  onCommunityTabChangeEvent(CommunityTabChangeEvent event, emit) {
    communityTabIndex = event.selectTab;
    amplitudeEvent('change_community_view',
        {'view': communityChangeType(communityTabIndex)});
    emit(CommunityTabChangeState());
    add(CommunityReloadEvent());
  }

  onCommunityFirstInEvent(CommunityFirstInEvent event, emit) {
    emit(CommunityFirstInState());
  }
}

class CommunityFirstInEvent extends BaseBlocEvent {}

class CommunityFirstInState extends BaseBlocState {}

class CommunityTabChangeEvent extends BaseBlocEvent {
  final int selectTab;

  CommunityTabChangeEvent({required this.selectTab});
}

class CommunityTabChangeState extends BaseBlocState {}

class CommunityReloadEvent extends BaseBlocEvent {}

class CommunityReloadState extends BaseBlocState {}

class CommunityNewDataEvent extends BaseBlocEvent {}

class CommunityNewDataState extends BaseBlocState {}

class NotificationAnimationEvent extends BaseBlocEvent {}

class NotificationAnimationState extends BaseBlocState {}

class ChangeViewEvent extends BaseBlocEvent {}

class ChangeViewState extends BaseBlocState {}

class NeighborHoodSelecterViewOpenEvent extends BaseBlocEvent {}

class NeighborHoodSelecterViewOpenState extends BaseBlocState {}

class SearchChangeEvent extends BaseBlocEvent {}

class SearchChangeState extends BaseBlocState {}

class GetKeywordCountEvent extends BaseBlocEvent {}

class GetKeywordCountState extends BaseBlocState {}

class LearnTypeChangeEvent extends BaseBlocEvent {
  final int type;

  LearnTypeChangeEvent({required this.type});
}

class LearnTypeChangeState extends BaseBlocState {}

class NeighborHoodChangeEvent extends BaseBlocEvent {
  final int index;

  NeighborHoodChangeEvent({required this.index});
}

class NeighborHoodChangeState extends BaseBlocState {}

class FilterSetAllEvent extends BaseBlocEvent {
  final bool check;

  FilterSetAllEvent({required this.check});
}

class FilterSetAllState extends BaseBlocState {}

class SaveFilterEvent extends BaseBlocEvent {}

class SaveFilterState extends BaseBlocState {}

class ReloadClassEvent extends BaseBlocEvent {}

class ReloadClassState extends BaseBlocState {}

class ScrollEndEvent extends BaseBlocEvent {}

class ScrollEndState extends BaseBlocState {}

class NewDataEvent extends BaseBlocEvent {}

class NewDataState extends BaseBlocState {}

class ReloadLearnEvent extends BaseBlocEvent {
  final bool firstTap;

  ReloadLearnEvent({this.firstTap = false});
}

class ReloadLearnState extends BaseBlocState {}

class SelectMarkerEvent extends BaseBlocEvent {}

class SelectMarkerState extends BaseBlocState {}

class GetMarkerDataEvent extends BaseBlocEvent {}

class GetMarkerDataState extends BaseBlocState {}

class LearnInitEvent extends BaseBlocEvent {
  final dynamic vsync;

  LearnInitEvent({required this.vsync});
}

class LearnInitState extends BaseBlocState {}

class BaseLearnState extends BaseBlocState {}
