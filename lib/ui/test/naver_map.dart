import 'dart:async';

import 'package:baeit/config/base_service.dart';
import 'package:baeit/data/class/map_data.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/polygon.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NaverMapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NaverMapState();
  }
}

class NaverMapState extends State<NaverMapView> {
  NaverMapController? naverMapController;

  PanelController pc = PanelController();
  int mapLevel = 15;
  List<MapData> mapDatas = [];
  List<Marker> markers = [];
  bool drag = false;
  bool sidoMarkerAdd = false;
  bool sigunguMarkerAdd = false;
  bool eupmyeondongMarkerAdd = false;
  LocationTrackingMode trackingMode = LocationTrackingMode.Follow;
  ScrollController? scrollController;
  List<PolygonOverlay> polygonOverlay = [];
  int snapIndex = 1;
  bool gesture = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pc.animatePanelToSnapPoint(
          duration: Duration(milliseconds: 200), curve: Curves.ease);
    });

    getPolygon();
    getMarker();
  }

  getMarker() {
    // ClassRepository.getMap(
    //         dataSaver
    //             .neighborHood[dataSaver.neighborHood
    //                 .indexWhere((element) => element.representativeFlag == 1)]
    //             .lati!,
    //         dataSaver
    //             .neighborHood[dataSaver.neighborHood
    //                 .indexWhere((element) => element.representativeFlag == 1)]
    //             .longi!,
    //         mapLevel)
    //     .then((value) {
    //   List<dynamic> data = value.data;
    //   List<MapData> datas = data.map((e) => MapData.fromJson(e)).toList();
    //   for (int i = 0; i < datas.length; i++) {
    //     if (mapDatas.indexWhere((element) =>
    //                 element.addressSidoNo == datas[i].addressSidoNo) ==
    //             -1 ||
    //         mapDatas.indexWhere((element) =>
    //                 element.addressSigunguNo == datas[i].addressSigunguNo) ==
    //             -1 ||
    //         mapDatas.indexWhere((element) =>
    //                 element.addressEupmyeondongNo ==
    //                 datas[i].addressEupmyeondongNo) ==
    //             -1 ||
    //         mapDatas.indexWhere((element) => element.name == datas[i].name) ==
    //             -1) {
    //       setState(() {
    //         mapDatas.add(datas[i]);
    //       });
    //     }
    //   }
    //
    //   for (int i = 0; i < mapDatas.length; i++) {
    //     OverlayImage.fromAssetImage(assetName: AppImages.iPushAds)
    //         .then((value) {
    //       setState(() {
    //         markers.add(Marker(
    //             markerId: jsonEncode(mapDatas[i].toMap()),
    //             position: LatLng(mapDatas[i].lati, mapDatas[i].longi),
    //             icon: value,
    //             captionText: mapDatas[i].cnt.toString() + "\n\n\n\n",
    //             captionColor: AppColors.primary,
    //             subCaptionText: "\n\n\n\n" + markers.length.toString(),
    //             subCaptionColor: AppColors.transparent,
    //             subCaptionTextSize: 0,
    //             captionOffset: -30,
    //             minZoom: mapDatas[i].addressEupmyeondongNo == null
    //                 ? mapDatas[i].addressSigunguNo == null
    //                     ? 6
    //                     : 10
    //                 : 13,
    //             maxZoom: mapDatas[i].addressEupmyeondongNo == null
    //                 ? mapDatas[i].addressSigunguNo == null
    //                     ? 10
    //                     : 13
    //                 : 18,
    //             width: 40,
    //             height: 40,
    //             onMarkerTab: markerTap));
    //       });
    //     });
    //   }
    // });
  }

  getPolygon() {
    CommonRepository.getPolygon(
            dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .lati
                .toString(),
            dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .longi
                .toString(),
            3)
        .then((value) {
      setState(() {
        Polygon polygon = Polygon.fromJson(value.data);
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
              color: AppColors.transparent,
              outlineColor: AppColors.accent,
              outlineWidth: 2,
            ));
            setState(() {});
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
            color: AppColors.transparent,
            outlineColor: AppColors.accent,
            outlineWidth: 2,
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 32,
            child: NaverMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    double.parse(dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .lati!),
                    double.parse(dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .longi!)),
                zoom: mapLevel.toDouble(),
              ),
              polygons: polygonOverlay,
              onMapCreated: (NaverMapController controller) async {
                naverMapController = controller;
                Timer(Duration(milliseconds: 100), () async {
                  setState(() {
                    trackingMode = LocationTrackingMode.NoFollow;
                  });
                });
              },
              maxZoom: 18,
              minZoom: 6,
              mapType: MapType.Basic,
              initLocationTrackingMode: LocationTrackingMode.None,
              indoorEnable: true,
              liteModeEnable: false,
              markers: markers,
              onCameraChange: (LatLng? latLng, CameraChangeReason reason,
                  bool? isAnimated) {
                naverMapController!.getCameraPosition().then((value) {
                  // print(value.zoom);
                  mapLevel = value.zoom.toInt();
                  if (value.zoom.toInt() > 6 && value.zoom.toInt() < 10) {
                    sigunguMarkerAdd = false;
                    eupmyeondongMarkerAdd = false;
                    if (!sidoMarkerAdd) {
                      sidoMarkerAdd = true;
                      getMarker();
                    }
                  } else if (value.zoom.toInt() > 10 &&
                      value.zoom.toInt() < 13) {
                    sidoMarkerAdd = false;
                    eupmyeondongMarkerAdd = false;
                    if (!sigunguMarkerAdd) {
                      sigunguMarkerAdd = true;
                      getMarker();
                    }
                  } else if (value.zoom.toInt() > 13 &&
                      value.zoom.toInt() < 18) {
                    sidoMarkerAdd = false;
                    sigunguMarkerAdd = false;
                    if (!eupmyeondongMarkerAdd) {
                      eupmyeondongMarkerAdd = true;
                      getMarker();
                    }
                  }
                });
                // print('카메라 움직임 >>> 위치 : ${latLng?.latitude}, ${latLng?.longitude}'
                //     '\n원인: $reason'
                //     '\n에니메이션 여부: $isAnimated');
              },
              onCameraIdle: () {
                print("STOP CAMERA");
              },
            ),
          ),
          SlidingUpPanel(
            boxShadow: [
              BoxShadow(
                  color: AppColors.black12,
                  blurRadius: 2,
                  offset: Offset(0, -4))
            ],
            header: GestureDetector(
              onVerticalDragStart: (_) {
                gesture = true;
              },
              onVerticalDragUpdate: (details) async {
                setState(() {
                  if (gesture) {
                    if (details.delta.dy > 2) {
                      // Down Swipe
                      if (snapIndex == 2) {
                        snapIndex = 1;
                        gesture = false;
                        if (scrollController!.position.maxScrollExtent ==
                            scrollController!.offset) {
                          Future.delayed(Duration(milliseconds: 200), () {
                            scrollController!.animateTo(
                                scrollController!.position.maxScrollExtent,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.ease);
                          });
                        }
                        pc.animatePanelToSnapPoint(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.ease);
                      } else if (snapIndex == 1) {
                        snapIndex = 0;
                        gesture = false;
                        pc.animatePanelToPosition(0.0);
                      }
                    } else if (details.delta.dy < -2) {
                      // Up Swipe
                      if (snapIndex == 1) {
                        snapIndex = 2;
                        gesture = false;
                        pc.animatePanelToPosition(1.0);
                      } else if (snapIndex == 0) {
                        snapIndex = 1;
                        gesture = false;
                        if (scrollController!.position.maxScrollExtent ==
                            scrollController!.offset) {
                          Future.delayed(Duration(milliseconds: 200), () {
                            scrollController!.animateTo(
                                scrollController!.position.maxScrollExtent,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.ease);
                          });
                        }
                        pc.animatePanelToSnapPoint(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.ease);
                      }
                    }
                  }
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    spaceH(14),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.greenGray300,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    spaceH(14)
                  ],
                ),
              ),
            ),
            // isDraggable: drag,
            panelBuilder: (sc) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: snapIndex == 1
                        ? MediaQuery.of(context).size.height * 0.43
                        : 120 + dataSaver.iosBottom),
                child: Column(
                  children: [
                    spaceH(32),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        controller: scrollController,
                        itemCount: 55,
                        itemBuilder: (BuildContext context, int i) {
                          return Container(
                            padding: const EdgeInsets.all(12.0),
                            child: Text("$i"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            isDraggable: false,
            controller: pc,
            snapPoint: 0.55,
            minHeight: 32,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: AppColors.white,
            maxHeight: MediaQuery.of(context).size.height,
          ),
        ],
      ),
    ));
  }

  markerTap(Marker? marker, dynamic iconSize) {
    OverlayImage.fromAssetImage(assetName: AppImages.iEditG).then((value) {
      setState(() {
        int index = markers
            .indexWhere((element) => element.markerId == marker!.markerId);
        markers.removeAt(int.parse(marker!.subCaptionText!));
        markers.insert(
            int.parse(marker.subCaptionText!),
            Marker(
                markerId: marker.markerId,
                position: marker.position,
                icon: value,
                captionText: marker.captionText,
                captionColor: marker.captionColor,
                subCaptionText: (index + 1).toString(),
                subCaptionColor: marker.subCaptionColor,
                subCaptionTextSize: 0,
                captionOffset: -30,
                minZoom: marker.minZoom,
                maxZoom: marker.maxZoom,
                width: 40,
                height: 40,
                onMarkerTab: markerTap));
      });
    });
  }
}
