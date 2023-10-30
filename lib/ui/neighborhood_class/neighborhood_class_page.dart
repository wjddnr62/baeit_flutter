// import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
// import 'package:baeit/config/base_bloc.dart';
// import 'package:baeit/config/base_service.dart';
// import 'package:baeit/config/common.dart';
// import 'package:baeit/config/config.dart';
// import 'package:baeit/resource/app_colors.dart';
// import 'package:baeit/resource/app_images.dart';
// import 'package:baeit/resource/app_strings.dart';
// import 'package:baeit/resource/app_text_style.dart';
// import 'package:baeit/ui/class_detail/class_detail_page.dart';
// import 'package:baeit/ui/create_class/create_class_page.dart';
// import 'package:baeit/ui/create_request/create_request_page.dart';
// import 'package:baeit/ui/feedback/feedback_page.dart';
// import 'package:baeit/ui/main_navigation/main_navigation_bloc.dart';
// import 'package:baeit/ui/neighborhood_cheer/neighborhood_cheer_page.dart';
// import 'package:baeit/ui/neighborhood_class/neighborhood_class_bloc.dart';
// import 'package:baeit/ui/neighborhood_select/neighborhood_select_page.dart';
// import 'package:baeit/ui/request_detail/request_detail_page.dart';
// import 'package:baeit/utils/category.dart';
// import 'package:baeit/utils/data_saver.dart';
// import 'package:baeit/utils/double_back_press.dart';
// import 'package:baeit/utils/event.dart';
// import 'package:baeit/utils/number_format.dart';
// import 'package:baeit/utils/page_move.dart';
// import 'package:baeit/utils/text_field_utils.dart';
// import 'package:baeit/widgets/bottom_button.dart';
// import 'package:baeit/widgets/custom_dialog.dart';
// import 'package:baeit/widgets/gradient.dart';
// import 'package:baeit/widgets/line.dart';
// import 'package:baeit/widgets/loading.dart';
// import 'package:baeit/widgets/space.dart';
// import 'package:baeit/widgets/toast.dart';
// import 'package:baeit/utils/cache_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
//
// class NeighborHoodClassPage extends BlocStatefulWidget {
//   final MainNavigationBloc navigationBloc;
//   final bool keyword;
//
//   NeighborHoodClassPage({required this.navigationBloc, this.keyword = false});
//
//   @override
//   BlocState<BaseBloc, BlocStatefulWidget> buildState() {
//     // TODO: implement buildState
//     return NeighborHoodClassState();
//   }
// }
//
// class NeighborHoodClassState
//     extends BlocState<NeighborHoodClassBloc, NeighborHoodClassPage>
//     with TickerProviderStateMixin {
//   PanelController panelController = PanelController();
//   ScrollController? scrollController;
//   TextEditingController searchController = TextEditingController();
//   FocusNode searchFocus = FocusNode();
//   final GlobalKey<AnimatedListState> listKey = GlobalKey();
//
//   late final AnimationController closeController = AnimationController(
//     duration: const Duration(milliseconds: 200),
//     vsync: this,
//   );
//
//   late final Animation<double> closeAnimation =
//       Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(
//           parent: closeController, curve: Curves.fastOutSlowIn));
//
//   AnimationController? loadingController;
//
//   distanceBackgroundImageHeight() {
//     switch (bloc.sliderSelectValue) {
//       case 0:
//         return 62.toDouble();
//       case 1:
//         return 106.toDouble();
//       case 2:
//         return 150.toDouble();
//       case 3:
//         return 194.toDouble();
//     }
//   }
//
//   distanceIcon() {
//     switch (bloc.sliderSelectValue) {
//       case 0:
//         return AppImages.iDistanceWalk10M;
//       case 1:
//         return AppImages.iDistanceWalk20M;
//       case 2:
//         return AppImages.iDistanceBicycle;
//       case 3:
//         return AppImages.iDistanceCar;
//     }
//   }
//
//   distanceExampleText(value) {
//     switch (value) {
//       case 0:
//         return AppStrings.of(StringKey.tenMinutesOnFoot);
//       case 1:
//         return AppStrings.of(StringKey.twentyMinutesOnFoot);
//       case 2:
//         return AppStrings.of(StringKey.tenMinutesBikeRide);
//       case 3:
//         return AppStrings.of(StringKey.tenMinutesForVehicle);
//     }
//   }
//
//   distanceText(value) {
//     switch (value) {
//       case 0:
//         return '(700m)';
//       case 1:
//         return '(1.4km)';
//       case 2:
//         return '(3km)';
//       case 3:
//         return '(8km)';
//     }
//   }
//
//   panelViewTitle(text) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width,
//             padding: EdgeInsets.only(top: 20, bottom: 20),
//             child: Stack(
//               children: [
//                 Align(
//                   alignment: Alignment.center,
//                   child: customText(
//                     text,
//                     style: TextStyle(
//                         fontSize: fontSizeSet(textSize: TextSize.T15),
//                         fontWeight: weightSet(textWeight: TextWeight.BOLD),
//                         color: AppColors.gray900),
//                   ),
//                 ),
//                 Positioned(
//                   right: 20,
//                   child: GestureDetector(
//                       onTap: () async {
//                         await closeController.forward();
//                         closeController.reset();
//                         await panelController.close();
//                         bloc.add(PanelOpenEvent(open: false));
//                         setState(() {
//                           if (!bloc.search)
//                             widget.navigationBloc.add(BottomEvent(view: true));
//                         });
//                       },
//                       child: Image.asset(
//                         AppImages.iX,
//                         width: 24,
//                         height: 24,
//                       )
//                       // hoverWidget(
//                       //     Image.asset(
//                       //       AppImages.iX,
//                       //       width: 24,
//                       //       height: 24,
//                       //     ),
//                       //     closeAnimation)
//                       ),
//                 ),
//               ],
//             ),
//           ),
//           heightLine(color: AppColors.gray100, height: 1),
//         ],
//       ),
//     );
//   }
//
//   panelSpecifyNeighborhood() {
//     return Stack(
//       children: [
//         Positioned(
//             left: 0,
//             right: 0,
//             bottom: 90,
//             child: AnimatedContainer(
//                 duration: Duration(milliseconds: 100),
//                 height: distanceBackgroundImageHeight(),
//                 child: Image.asset(AppImages.distanceBackground))),
//         Positioned(
//           top: 100,
//           right: 40,
//           child: Container(
//             width: 78,
//             child: ListView.builder(
//               itemBuilder: (context, idx) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     customText(
//                       distanceExampleText(idx),
//                       style: TextStyle(
//                           color: bloc.sliderSelectValue == idx
//                               ? AppColors.primary
//                               : AppColors.gray900,
//                           fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
//                           fontSize: fontSizeSet(textSize: TextSize.T12)),
//                     ),
//                     customText(
//                       distanceText(idx),
//                       style: TextStyle(
//                           color: AppColors.gray400,
//                           fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
//                           fontSize: fontSizeSet(textSize: TextSize.T10)),
//                     ),
//                     spaceH(14)
//                   ],
//                 );
//               },
//               reverse: true,
//               shrinkWrap: true,
//               itemCount: 4,
//               physics: NeverScrollableScrollPhysics(),
//             ),
//           ),
//         ),
//         Positioned(
//             top: 181,
//             bottom: 135,
//             left: 49,
//             child: Image.asset(distanceIcon())),
//         Positioned(
//             top: 100,
//             left: 0,
//             right: 0,
//             bottom: 140,
//             child: Container(
//                 color: AppColors.transparent,
//                 child: SfSliderTheme(
//                   data: SfSliderThemeData(
//                       activeTrackHeight: 4,
//                       overlayRadius: 13,
//                       overlayColor: Color(0xFF33343b38),
//                       thumbRadius: 12),
//                   child: SfSlider.vertical(
//                     onChanged: (value) {
//                       bloc.add(SliderValueChangeEvent(value: value.toInt()));
//                     },
//                     value: bloc.sliderSelectValue,
//                     min: 0.0,
//                     max: 3.0,
//                     interval: 1,
//                     stepSize: 1,
//                     activeColor: AppColors.black08,
//                     inactiveColor: AppColors.black08,
//                     showTicks: false,
//                     showLabels: false,
//                     enableTooltip: false,
//                     minorTicksPerInterval: 1,
//                     thumbIcon: Image.asset(AppImages.iRangeMarker),
//                   ),
//                 ))),
//       ],
//     );
//   }
//
//   panelFilter() {
//     return Stack(
//       children: [
//         bloc.filterValues.length == 0
//             ? Container()
//             : Positioned(
//                 top: 60,
//                 left: 20,
//                 right: 20,
//                 bottom: 60,
//                 child: Column(
//                   children: [
//                     spaceH(10),
//                     Container(
//                       height: 48,
//                       child: Row(
//                         children: [
//                           customText(
//                             AppStrings.of(StringKey.category),
//                             style: TextStyle(
//                                 color: AppColors.gray900,
//                                 fontWeight:
//                                     weightSet(textWeight: TextWeight.BOLD),
//                                 fontSize: fontSizeSet(textSize: TextSize.T14)),
//                           ),
//                           Expanded(child: Container()),
//                           GestureDetector(
//                             onTap: () {
//                               if (!bloc.filterValues.contains(false)) {
//                                 bloc.add(FilterSetAllEvent(check: false));
//                               } else {
//                                 bloc.add(FilterSetAllEvent(check: true));
//                               }
//                             },
//                             child: Container(
//                               height: 30,
//                               color: AppColors.white,
//                               child: Row(
//                                 children: [
//                                   customText(
//                                     AppStrings.of(StringKey.selectAll),
//                                     style: TextStyle(
//                                         color: AppColors.black,
//                                         fontWeight: weightSet(
//                                             textWeight: TextWeight.MEDIUM),
//                                         fontSize: fontSizeSet(
//                                             textSize: TextSize.T12)),
//                                   ),
//                                   spaceW(6),
//                                   Image.asset(
//                                     bloc.filterValues.contains(false)
//                                         ? AppImages.iCheckG
//                                         : AppImages.iCheckCSmall,
//                                     width: 12,
//                                     height: 12,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     Flexible(
//                       child: Container(
//                           height: 296,
//                           child: GridView.count(
//                             physics: ClampingScrollPhysics(),
//                             crossAxisCount: 3,
//                             childAspectRatio:
//                                 (((MediaQuery.of(context).size.width - 72) /
//                                         3) /
//                                     80),
//                             padding: EdgeInsets.only(bottom: 18),
//                             shrinkWrap: true,
//                             mainAxisSpacing: 18,
//                             crossAxisSpacing: 16,
//                             children: List.generate(bloc.filterItemName.length,
//                                 (index) {
//                               return GestureDetector(
//                                 onTap: () {
//                                   if (bloc.filterValues.indexWhere(
//                                               (element) => element == true) !=
//                                           bloc.filterValues.lastIndexWhere(
//                                               (element) => element == true) ||
//                                       !bloc.filterValues[index]) {
//                                     setState(() {
//                                       if (!bloc.filterValues[index]) {
//                                         bloc.filterData.add(dataSaver
//                                             .category[index].classCategoryId!);
//                                       } else {
//                                         bloc.filterData.remove(dataSaver
//                                             .category[index].classCategoryId);
//                                       }
//                                       bloc.filterValues[index] =
//                                           !bloc.filterValues[index];
//                                     });
//                                   } else {
//                                     showToast(
//                                         context: context,
//                                         text: AppStrings.of(
//                                             StringKey.filterToast));
//                                   }
//                                 },
//                                 child: Container(
//                                   width: 96,
//                                   height: 80,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       color: bloc.filterValues[index]
//                                           ? AppColors.primary.withOpacity(0.14)
//                                           : AppColors.white),
//                                   child: Column(
//                                     children: [
//                                       spaceH(8.5),
//                                       Image.asset(
//                                         bloc.filterValues[index]
//                                             ? bloc.filterItemCheckImage[index]
//                                             : bloc
//                                                 .filterItemUnCheckImage[index],
//                                         width: 42,
//                                         height: 42,
//                                       ),
//                                       spaceH(4),
//                                       customText(
//                                         bloc.filterItemName[index],
//                                         style: TextStyle(
//                                             color: AppColors.black20,
//                                             fontWeight: weightSet(
//                                                 textWeight: TextWeight.MEDIUM),
//                                             fontSize: fontSizeSet(
//                                                 textSize: TextSize.T12)),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }),
//                           )),
//                     ),
//                     bloc.categoryFilter
//                         ? Container()
//                         : Container(
//                             height: 48,
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 customText(
//                                   AppStrings.of(StringKey.sort),
//                                   style: TextStyle(
//                                       color: AppColors.gray900,
//                                       fontWeight: weightSet(
//                                           textWeight: TextWeight.BOLD),
//                                       fontSize:
//                                           fontSizeSet(textSize: TextSize.T14)),
//                                 ),
//                                 Expanded(child: Container()),
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: customText(
//                                     AppStrings.of(StringKey.distanceOrder),
//                                     style: TextStyle(
//                                         color: AppColors.primaryDark10,
//                                         fontWeight: weightSet(
//                                             textWeight: TextWeight.BOLD),
//                                         fontSize: fontSizeSet(
//                                             textSize: TextSize.T12)),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//       ],
//     );
//   }
//
//   panelView() {
//     return Stack(
//       children: [
//         bloc.specifyNeighborhoodOpen
//             ? panelViewTitle(AppStrings.of(StringKey.specifyNeighborhoodRadius))
//             : panelViewTitle(AppStrings.of(StringKey.filter)),
//         bloc.specifyNeighborhoodOpen
//             ? panelSpecifyNeighborhood()
//             : panelFilter(),
//         Positioned(
//             left: 12,
//             right: 12,
//             bottom: 12,
//             child: bottomButton(
//                 context: context,
//                 text: AppStrings.of(StringKey.save),
//                 onPress: () async {
//                   bloc.saveIng = true;
//                   await panelController.close();
//                   if (bloc.specifyNeighborhoodOpen) {
//                     amplitudeEvent('area_distance_set', {
//                       'distance': bloc.sliderSelectValue == 0
//                           ? 'onfoot_10'
//                           : bloc.sliderSelectValue == 1
//                               ? 'onfoot_20'
//                               : bloc.sliderSelectValue == 2
//                                   ? 'bicycle'
//                                   : 'car'
//                     });
//                     bloc.add(SaveDistanceEvent(value: bloc.sliderSelectValue));
//                   } else if (bloc.filterOpen) {
//                     bloc.add(SaveFilterEvent());
//                   }
//                   bloc.add(PanelOpenEvent(open: false));
//                 }))
//       ],
//     );
//   }
//
//   floatingActionButton() {
//     return Positioned(
//         bottom: 12,
//         right: 12,
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 200),
//           curve: Curves.easeInOut,
//           onEnd: () {
//             setState(() {
//               bloc.floatingAnimationEnd = true;
//             });
//           },
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(!bloc.scrollUp ? 48 : 24),
//           ),
//           padding: EdgeInsets.zero,
//           width: !bloc.scrollUp ? 48 : 141,
//           height: 48,
//           child: ElevatedButton(
//             onPressed: () {
//               if (bloc.mineClassCnt != null) {
//                 if (bloc.mineClassCnt == 7) {
//                   showToast(
//                       context: context,
//                       text: AppStrings.of(StringKey.addMaxClassToast));
//                 } else {
//                   if (!dataSaver.nonMember) {
//                     amplitudeEvent(
//                         'class_register', {'inflow_page': 'main_register'});
//                     if (production == 'prod-release' && kReleaseMode) {
//                       Airbridge.event.send(ViewHomeEvent(
//                           option: EventOption(label: 'home_screen')));
//                       Airbridge.event.send(Event('class_register_start'));
//                     }
//                     pushTransition(
//                         context,
//                         CreateClassPage(
//                           classBloc: bloc,
//                           profileGet: dataSaver.profileGet!,
//                           floating: true,
//                           previousPage: 'main_register',
//                         )).then((value) {
//                       if (value != null) {
//                         pushTransition(
//                             context,
//                             ClassDetailPage(
//                               classUuid: value,
//                               bloc: bloc,
//                               mainNeighborHood: bloc.mainNeighborHood!,
//                               profileGet: dataSaver.nonMember
//                                   ? null
//                                   : dataSaver.profileGet,
//                             )).then((value) {
//                           searchController.text = '';
//                           bloc.add(
//                               ReloadClassEvent(search: searchController.text));
//                         });
//                       }
//                     });
//                   } else {
//                     nonMemberDialog(
//                         context: context,
//                         title: AppStrings.of(StringKey.alertClassAdd),
//                         content: AppStrings.of(StringKey.alertClassAddContent));
//                   }
//                 }
//               } else {
//                 nonMemberDialog(
//                     context: context,
//                     title: AppStrings.of(StringKey.alertClassAdd),
//                     content: AppStrings.of(StringKey.alertClassAddContent));
//               }
//             },
//             style: ElevatedButton.styleFrom(
//                 primary: AppColors.primary,
//                 elevation: 0,
//                 padding: !bloc.scrollUp
//                     ? EdgeInsets.zero
//                     : EdgeInsets.only(left: 12),
//                 shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(!bloc.scrollUp ? 48 : 24))),
//             child: Center(
//               child: !bloc.scrollUp
//                   ? Image.asset(
//                       AppImages.iPlusW,
//                       width: 24,
//                       height: 24,
//                     )
//                   : Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.add,
//                           size: 24,
//                         ),
//                         spaceW(10),
//                         Expanded(
//                           child: bloc.floatingAnimationEnd
//                               ? customText(
//                                   AppStrings.of(StringKey.madeClass),
//                                   style: TextStyle(
//                                       color: AppColors.white,
//                                       fontWeight: weightSet(
//                                           textWeight: TextWeight.BOLD),
//                                       fontSize:
//                                           fontSizeSet(textSize: TextSize.T14)),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.clip,
//                                 )
//                               : Container(),
//                         )
//                       ],
//                     ),
//             ),
//           ),
//         ));
//   }
//
//   slidingUpPanel() {
//     return SlidingUpPanel(
//       color: AppColors.white,
//       controller: panelController,
//       panel: panelView(),
//       backdropTapClosesPanel: true,
//       backdropEnabled: true,
//       isDraggable: false,
//       boxShadow: null,
//       onPanelClosed: () {
//         setState(() {
//           if (!bloc.search) widget.navigationBloc.add(BottomEvent(view: true));
//           bloc.add(PanelOpenEvent(open: false));
//           if (bloc.scrollUnder) {
//             scrollController!.animateTo(bloc.bottomOffset,
//                 duration: Duration(milliseconds: 300), curve: Curves.easeIn);
//             bloc.bottomOffset = 0;
//             bloc.scrollUnder = false;
//           }
//           if (!bloc.saveIng) {
//             bloc.sliderSelectValue = bloc.openValue;
//             if (bloc.openFilterValues.length != 0) {
//               bloc.filterValues = bloc.openFilterValues;
//             }
//           }
//         });
//       },
//       backdropColor: AppColors.black,
//       backdropOpacity: 0.6,
//       borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//       minHeight: panelController.isAttached
//           ? panelController.isPanelClosed
//               ? 0
//               : bloc.filterOpen
//                   ? bloc.categoryFilter
//                       ? 474
//                       : 542
//                   : 396
//           : 0,
//       maxHeight: bloc.filterOpen
//           ? bloc.categoryFilter
//               ? 474
//               : 542
//           : 396,
//     );
//   }
//
//   filterOpen() {
//     if (panelController.isPanelClosed && !bloc.isLoading) {
//       bloc.categoryFilter = false;
//       setState(() {
//         widget.navigationBloc.add(BottomEvent(view: false));
//       });
//       bloc.openFilterValues = bloc.filterValues.toList();
//       bloc.add(PanelOpenEvent(open: true));
//       bloc.specifyNeighborhoodOpen = false;
//       bloc.filterOpen = true;
//       panelController.open();
//     }
//   }
//
//   title() {
//     return bloc.filterValues.length == 0
//         ? Container()
//         : Column(
//             children: [
//               Row(
//                 children: [
//                   customText(
//                     '총 ${dataSaver.neighborHoodClass!.totalRow > 99 ? '99+' : dataSaver.neighborHoodClass!.totalRow} 건',
//                     style: TextStyle(
//                         color: AppColors.gray400,
//                         fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
//                         fontSize: fontSizeSet(textSize: TextSize.T12)),
//                   ),
//                   Expanded(child: Container()),
//                   bloc.search
//                       ? customText('거리순',
//                           style: TextStyle(
//                               color: AppColors.primaryDark10,
//                               fontWeight:
//                                   weightSet(textWeight: TextWeight.MEDIUM),
//                               fontSize: fontSizeSet(textSize: TextSize.T12)))
//                       : InkWell(
//                           onTap: filterOpen,
//                           child: Row(
//                             children: [
//                               Image.asset(
//                                 AppImages.iListFilter,
//                                 width: 12,
//                                 height: 12,
//                                 color: bloc.filterValues.contains(false)
//                                     ? AppColors.primaryDark10
//                                     : AppColors.gray900,
//                               ),
//                               spaceW(4),
//                               customText(
//                                 AppStrings.of(StringKey.filter),
//                                 style: TextStyle(
//                                     color: bloc.filterValues.contains(false)
//                                         ? AppColors.primaryDark10
//                                         : AppColors.gray900,
//                                     fontWeight: weightSet(
//                                         textWeight: TextWeight.MEDIUM),
//                                     fontSize:
//                                         fontSizeSet(textSize: TextSize.T12)),
//                               )
//                             ],
//                           ),
//                         )
//                 ],
//               )
//             ],
//           );
//   }
//
//   hoverWidget(Widget widget, animation) {
//     return ScaleTransition(scale: animation, child: widget);
//   }
//
//   bookmarkHeart(int index, AnimationController controller, bool bookmark) {
//     return SizedBox(
//       width: 45,
//       height: 45,
//       child: GestureDetector(
//         onTap: () async {
//           if (!dataSaver.nonMember) {
//             if (dataSaver.neighborHoodClass!.classData[index].likeFlag == 1) {
//               controller.reset();
//               bloc.add(BookmarkEvent(index: index, flag: 1, bookmark: false));
//             } else {
//               classEvent(
//                   'class_bookmark_clicks',
//                   dataSaver.neighborHoodClass!.classData[index].classUuid,
//                   bloc.mainNeighborHood!.lati!,
//                   bloc.mainNeighborHood!.longi!,
//                   bloc.mainNeighborHood!.sidoName!,
//                   bloc.mainNeighborHood!.sigunguName!,
//                   bloc.mainNeighborHood!.eupmyeondongName!);
//               controller.forward();
//               bloc.add(BookmarkEvent(index: index, flag: 0, bookmark: true));
//             }
//           } else {
//             nonMemberDialog(
//                 context: context,
//                 title: AppStrings.of(StringKey.alertBookmark),
//                 content: AppStrings.of(StringKey.alertBookmarkContent));
//           }
//         },
//         child: Lottie.asset(AppImages.heartAnimation, controller: controller,
//             onLoaded: (composition) {
//           setState(() {
//             controller..duration = composition.duration * 0.4;
//             if (dataSaver.neighborHoodClass!.classData[index].likeFlag == 1) {
//               controller.forward();
//             } else {
//               controller.value = 0;
//             }
//           });
//         }),
//       ),
//     );
//   }
//
//   classListItem(int index, animation) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: 180,
//       color: AppColors.transparent,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: ElevatedButton(
//           onPressed: () {
//             if (dataSaver.neighborHoodClass!.classData[index].mineFlag != 1) {
//               classEvent(
//                   'class_clicks',
//                   dataSaver.neighborHoodClass!.classData[index].classUuid,
//                   bloc.mainNeighborHood!.lati!,
//                   bloc.mainNeighborHood!.longi!,
//                   bloc.mainNeighborHood!.sidoName!,
//                   bloc.mainNeighborHood!.sigunguName!,
//                   bloc.mainNeighborHood!.eupmyeondongName!);
//             }
//             pushTransition(
//                 context,
//                 ClassDetailPage(
//                   heroTag: 'listImage$index',
//                   classUuid:
//                       dataSaver.neighborHoodClass!.classData[index].classUuid,
//                   mainNeighborHood: bloc.mainNeighborHood!,
//                   bloc: bloc,
//                   selectIndex: index,
//                   profileGet: dataSaver.nonMember ? null : dataSaver.profileGet,
//                   inputPage: 'main',
//                 )).then((value) {
//               if (value != null) {
//                 bloc.add(ReloadClassEvent());
//               }
//             });
//           },
//           style: ElevatedButton.styleFrom(
//               elevation: 0,
//               primary: AppColors.transparent,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14)),
//               padding: EdgeInsets.zero),
//           child: Stack(
//             children: [
//               Hero(
//                   tag: 'listImage$index',
//                   child: CachedNetworkImage(
//                     imageUrl:
//                         '${dataSaver.neighborHoodClass!.classData[index].content.image!.prefixUrl}/${dataSaver.neighborHoodClass!.classData[index].content.image!.path}/${dataSaver.neighborHoodClass!.classData[index].content.image!.storedName}',
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.height,
//                     fit: BoxFit.cover,
//                     placeholder: (context, a) => Container(),
//                   )),
//               Positioned(
//                   top: 94,
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: bottomGradient(
//                       context: context, height: 86, color: AppColors.gray100)),
//               Positioned(
//                 top: 0,
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(left: 12, top: 12),
//                       child: Row(
//                         children: [
//                           Container(
//                             height: 24,
//                             padding: EdgeInsets.only(left: 8, right: 8),
//                             decoration: BoxDecoration(
//                                 color: AppColors.accentLight40,
//                                 borderRadius: BorderRadius.circular(4)),
//                             child: Center(
//                               child: customText(
//                                 '${double.parse(dataSaver.neighborHoodClass!.classData[index].content.distance).toString().split('.')[0].length > 3 ? '${double.parse(dataSaver.neighborHoodClass!.classData[index].content.distance).toString().split('.')[0].substring(0, 1)}.${double.parse(dataSaver.neighborHoodClass!.classData[index].content.distance).toString().split('.')[0].substring(1, 2)}km\u00B7${dataSaver.neighborHoodClass!.classData[index].content.hangNames.split(',')[0]}' : '${double.parse(dataSaver.neighborHoodClass!.classData[index].content.distance).toString().split('.')[0].length == 3 ? (double.parse(dataSaver.neighborHoodClass!.classData[index].content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(dataSaver.neighborHoodClass!.classData[index].content.distance).toString().split('.')[0]}m\u00B7${dataSaver.neighborHoodClass!.classData[index].content.hangNames.split(',')[0]}'}',
//                                 style: TextStyle(
//                                     color: AppColors.accentDark10,
//                                     fontWeight:
//                                         weightSet(textWeight: TextWeight.BOLD),
//                                     fontSize:
//                                         fontSizeSet(textSize: TextSize.T10)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(child: Container()),
//                     Stack(
//                       children: [
//                         Padding(
//                           padding:
//                               EdgeInsets.only(left: 4, right: 4, bottom: 4),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width,
//                             padding: EdgeInsets.only(
//                                 left: 12, right: 12, top: 12, bottom: 10),
//                             decoration: BoxDecoration(
//                                 color: AppColors.white,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       categoryImage(dataSaver
//                                           .neighborHoodClass!
//                                           .classData[index]
//                                           .content
//                                           .category!
//                                           .classCategoryId),
//                                       height: 13,
//                                     ),
//                                     spaceW(4),
//                                     customText(
//                                       categorySet(dataSaver
//                                           .neighborHoodClass!
//                                           .classData[index]
//                                           .content
//                                           .category!
//                                           .classCategoryId),
//                                       style: TextStyle(
//                                           color: AppColors.primaryDark10,
//                                           fontWeight: weightSet(
//                                               textWeight: TextWeight.BOLD),
//                                           fontSize: fontSizeSet(
//                                               textSize: TextSize.T10)),
//                                     ),
//                                   ],
//                                 ),
//                                 spaceH(6),
//                                 Container(
//                                   height: 20,
//                                   child: customText(
//                                     dataSaver.neighborHoodClass!
//                                         .classData[index].content.title!,
//                                     style: TextStyle(
//                                         color: AppColors.gray900,
//                                         fontWeight: weightSet(
//                                             textWeight: TextWeight.MEDIUM),
//                                         fontSize: fontSizeSet(
//                                             textSize: TextSize.T14)),
//                                   ),
//                                 ),
//                                 spaceH(6),
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(30),
//                                       child: dataSaver
//                                                   .neighborHoodClass!
//                                                   .classData[index]
//                                                   .member
//                                                   .profile !=
//                                               null
//                                           ? Image.network(
//                                               dataSaver
//                                                   .neighborHoodClass!
//                                                   .classData[index]
//                                                   .member
//                                                   .profile!,
//                                               width: 14,
//                                               height: 14,
//                                               errorBuilder:
//                                                   (context, builder, _) {
//                                                 return Container();
//                                               },
//                                               fit: BoxFit.cover,
//                                             )
//                                           : Image.asset(
//                                               AppImages.dfProfile,
//                                               width: 14,
//                                               height: 14,
//                                             ),
//                                     ),
//                                     spaceW(6),
//                                     customText(
//                                       dataSaver.neighborHoodClass!
//                                           .classData[index].member.nickName,
//                                       style: TextStyle(
//                                           color: AppColors.gray400,
//                                           fontWeight: weightSet(
//                                               textWeight: TextWeight.REGULAR),
//                                           fontSize: fontSizeSet(
//                                               textSize: TextSize.T11)),
//                                     ),
//                                     Expanded(child: Container()),
//                                     customText(
//                                       '${numberFormatter(dataSaver.neighborHoodClass!.classData[index].content.minCost!)}원 ~',
//                                       style: TextStyle(
//                                           color: AppColors.gray600,
//                                           fontWeight: weightSet(
//                                               textWeight: TextWeight.MEDIUM),
//                                           fontSize: fontSizeSet(
//                                               textSize: TextSize.T11)),
//                                     ),
//                                     spaceW(4),
//                                     customText(AppStrings.of(StringKey.timePay),
//                                         style: TextStyle(
//                                             color: AppColors.gray400,
//                                             fontWeight: weightSet(
//                                                 textWeight: TextWeight.MEDIUM),
//                                             fontSize: fontSizeSet(
//                                                 textSize: TextSize.T10))),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               dataSaver.neighborHoodClass!.classData[index].mineFlag == 1
//                   ? Container()
//                   : Positioned(
//                       top: 0,
//                       right: 0,
//                       child: bloc.animationControllers.length != 0 &&
//                               bloc.bookmarkChecks.length != 0
//                           ? bookmarkHeart(
//                               index,
//                               bloc.animationControllers[index],
//                               bloc.bookmarkChecks[index])
//                           : Container())
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   classList() {
//     int listSet = dataSaver.neighborHoodClass == null
//         ? 0
//         : dataSaver.neighborHoodClass!.classData.length;
//     return AnimatedList(
//       key: listKey,
//       initialItemCount: listSet,
//       itemBuilder: (context, idx, animation) {
//         return Column(
//           children: [classListItem(idx, animation), spaceH(20)],
//         );
//       },
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//     );
//   }
//
//   distanceOpen() async {
//     if (panelController.isPanelClosed && !bloc.isLoading) {
//       setState(() {
//         widget.navigationBloc.add(BottomEvent(view: false));
//       });
//       bloc.add(
//           OpenSpecifyNeighborhoodRadiusEvent(value: bloc.distanceSelectValue));
//       bloc.add(PanelOpenEvent(open: true));
//       bloc.specifyNeighborhoodOpen = true;
//       bloc.filterOpen = false;
//       panelController.open();
//     }
//   }
//
//   appBar() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: 60,
//       padding: EdgeInsets.only(left: 20, right: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           GestureDetector(
//             onTap: () {
//               pushTransition(context, NeighborHoodSelectPage()).then((value) {
//                 if (value != null && value) {
//                   bloc.add(ReloadClassEvent());
//                 }
//               });
//             },
//             child: Container(
//               height: 30,
//               child: Row(
//                 children: [
//                   customText(
//                     dataSaver.neighborHood.length == 0
//                         ? ''
//                         : bloc.mainNeighborHood == null
//                             ? ''
//                             : bloc.mainNeighborHood!.townName ?? '',
//                     style: TextStyle(
//                         color: AppColors.primary,
//                         fontWeight: weightSet(textWeight: TextWeight.BOLD),
//                         fontSize: fontSizeSet(textSize: TextSize.T20)),
//                   ),
//                   spaceW(4),
//                   Image.asset(
//                     AppImages.iSelectACDown,
//                     width: 16,
//                     height: 16,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           spaceW(10),
//           dataSaver.neighborHoodClass == null
//               ? Container()
//               : Container(
//                   height: 30,
//                   child: ElevatedButton(
//                     onPressed: distanceOpen,
//                     style: ElevatedButton.styleFrom(
//                         primary: AppColors.gray100,
//                         elevation: 0,
//                         padding: EdgeInsets.only(left: 10, right: 10),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30))),
//                     child: Row(
//                       children: [
//                         customText(
//                             distanceExampleText(bloc.distanceSelectValue),
//                             style: TextStyle(
//                                 color: AppColors.gray600,
//                                 fontWeight:
//                                     weightSet(textWeight: TextWeight.BOLD),
//                                 fontSize: fontSizeSet(textSize: TextSize.T11))),
//                         spaceW(4),
//                         Image.asset(
//                           AppImages.iChangeDistance,
//                           width: 12,
//                           height: 12,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//           Expanded(child: Container()),
//           SizedBox(
//               width: 24,
//               height: 24,
//               child: RawMaterialButton(
//                 onPressed: bloc.isLoading
//                     ? null
//                     : () {
//                         // bloc.setDefaultData();
//                         amplitudeEvent('list_search_button', {'type': 'class'});
//                         searchController.text = '';
//                         bloc.add(SearchViewEvent(search: true));
//                         widget.navigationBloc.add(BottomEvent(view: false));
//                         scrollController!.jumpTo(0);
//                       },
//                 shape: CircleBorder(),
//                 child: Center(
//                     child: Image.asset(
//                   AppImages.iSearch,
//                   width: 24,
//                   height: 24,
//                 )),
//               ))
//         ],
//       ),
//     );
//   }
//
//   searchBarItemName(int index) {
//     if (index == 0) {
//       return bloc.mainNeighborHood!.townName;
//     } else if (index == 1) {
//       return '${distanceExampleText(bloc.distanceSelectValue)}';
//     } else if (index == 2) {
//       return '${bloc.filterItemName[bloc.filterValues.indexOf(true)]}';
//     }
//   }
//
//   searchBar() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: 121,
//       color: AppColors.white,
//       child: Column(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: 60,
//             child: Row(
//               children: [
//                 spaceW(16),
//                 SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: RawMaterialButton(
//                       onPressed: bloc.isLoading
//                           ? null
//                           : () {
//                               if (widget.keyword) {
//                                 pop(context);
//                                 dataSaver.classBloc!
//                                     .add(SearchViewEvent(search: false));
//                                 dataSaver.mainNavigationBloc!
//                                     .add(BottomEvent(view: true));
//                                 dataSaver.classBloc!.add(ReloadClassEvent());
//                               } else {
//                                 bloc.add(SearchViewEvent(search: false));
//                                 widget.navigationBloc
//                                     .add(BottomEvent(view: true));
//                                 bloc.add(ReloadClassEvent());
//                               }
//                             },
//                       shape: CircleBorder(),
//                       child: Center(
//                           child: Image.asset(
//                         AppImages.iChevronPrev,
//                         width: 24,
//                         height: 24,
//                       )),
//                     )),
//                 spaceW(16),
//                 Expanded(
//                     child: Container(
//                   height: 40,
//                   decoration: BoxDecoration(
//                       color: AppColors.primaryLight50,
//                       borderRadius: BorderRadius.circular(8)),
//                   child: Stack(
//                     children: [
//                       TextFormField(
//                           onChanged: (text) {
//                             blankCheck(
//                                 text: text, controller: searchController);
//                             setState(() {});
//                           },
//                           maxLines: 1,
//                           controller: searchController,
//                           focusNode: searchFocus,
//                           autofocus: true,
//                           keyboardType: TextInputType.text,
//                           textInputAction: TextInputAction.search,
//                           onFieldSubmitted: (value) {
//                             amplitudeEvent('search_button',
//                                 {'type': 'class', 'search': value});
//                             bloc.add(ClassSearchEvent(search: value));
//                             FocusScope.of(context).unfocus();
//                           },
//                           style: TextStyle(
//                               color: AppColors.primaryDark10,
//                               fontWeight:
//                                   weightSet(textWeight: TextWeight.MEDIUM),
//                               fontSize: fontSizeSet(textSize: TextSize.T14)),
//                           decoration: InputDecoration(
//                             hintText:
//                                 AppStrings.of(StringKey.searchPlaceHolder),
//                             hintStyle: TextStyle(
//                                 color: AppColors.primaryDark10.withOpacity(0.4),
//                                 fontWeight:
//                                     weightSet(textWeight: TextWeight.MEDIUM),
//                                 fontSize: fontSizeSet(textSize: TextSize.T14)),
//                             isDense: true,
//                             isCollapsed: true,
//                             contentPadding: EdgeInsets.only(
//                                 left: 10, top: 12, bottom: 0, right: 40),
//                             border: InputBorder.none,
//                             enabledBorder: InputBorder.none,
//                             focusedBorder: InputBorder.none,
//                           )),
//                       Positioned(
//                         right: 8,
//                         top: 8,
//                         bottom: 8,
//                         child: GestureDetector(
//                           onTap: () {
//                             FocusScope.of(context).unfocus();
//                             amplitudeEvent('search_button', {
//                               'type': 'class',
//                               'search': searchController.text
//                             });
//                             bloc.add(ClassSearchEvent(
//                                 search: searchController.text));
//                           },
//                           child: Image.asset(
//                             AppImages.iSearchC,
//                             width: 24,
//                             height: 24,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 )),
//                 spaceW(20),
//               ],
//             ),
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: 60,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 spaceH(8),
//                 Container(
//                   height: 52,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (context, idx) {
//                       return Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           idx == 0 ? spaceW(20) : Container(),
//                           Container(
//                             height: 36,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(36)),
//                             child: ElevatedButton(
//                                 onPressed: () {
//                                   FocusScope.of(context).unfocus();
//                                   if (idx == 0) {
//                                     pushTransition(
//                                             context, NeighborHoodSelectPage())
//                                         .then((value) {
//                                       if (value != null && value) {
//                                         bloc.add(ReloadClassEvent(
//                                             search: searchController.text));
//                                       }
//                                     });
//                                   } else if (idx == 1) {
//                                     distanceOpen();
//                                   } else if (idx == 2) {
//                                     filterOpen();
//                                     bloc.categoryFilter = true;
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                     primary: AppColors.white,
//                                     elevation: 0,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(36),
//                                         side: BorderSide(
//                                             width: 1,
//                                             color: AppColors.gray200)),
//                                     padding:
//                                         EdgeInsets.only(left: 12, right: 12)),
//                                 child: Row(
//                                   children: [
//                                     customText(
//                                       searchBarItemName(idx),
//                                       style: TextStyle(
//                                           color: AppColors.gray900,
//                                           fontWeight: weightSet(
//                                               textWeight: TextWeight.MEDIUM),
//                                           fontSize: fontSizeSet(
//                                               textSize: TextSize.T12)),
//                                     ),
//                                     spaceW(4),
//                                     idx == 2 &&
//                                             bloc.filterValues
//                                                         .where((element) =>
//                                                             element == true)
//                                                         .toList()
//                                                         .length -
//                                                     1 !=
//                                                 0
//                                         ? Container(
//                                             width: 19,
//                                             height: 14,
//                                             decoration: BoxDecoration(
//                                                 color: AppColors.accentLight40,
//                                                 borderRadius:
//                                                     BorderRadius.circular(2.3)),
//                                             child: Center(
//                                               child: customText(
//                                                 '+${bloc.filterValues.where((element) => element == true).toList().length - 1}',
//                                                 style: TextStyle(
//                                                     color: AppColors.accent,
//                                                     fontWeight: weightSet(
//                                                         textWeight:
//                                                             TextWeight.BOLD),
//                                                     fontSize: fontSizeSet(
//                                                         textSize: TextSize.T8)),
//                                               ),
//                                             ),
//                                           )
//                                         : Container(),
//                                     idx == 2 &&
//                                             bloc.filterValues
//                                                         .where((element) =>
//                                                             element == true)
//                                                         .toList()
//                                                         .length -
//                                                     1 !=
//                                                 0
//                                         ? spaceW(8)
//                                         : Container(),
//                                     Image.asset(
//                                       AppImages.iSelectACDown,
//                                       width: 12,
//                                       height: 12,
//                                     )
//                                   ],
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                 )),
//                           ),
//                           idx == 2 ? spaceW(20) : spaceW(10)
//                         ],
//                       );
//                     },
//                     shrinkWrap: true,
//                     itemCount: 3,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           heightLine(height: 1)
//         ],
//       ),
//     );
//   }
//
//   notContainerArea() {
//     return bloc.search
//         ? Container()
//         : Padding(
//             padding: EdgeInsets.only(top: 8, bottom: 8),
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                   color: AppColors.secondaryLight40,
//                   border: bloc.cheerFinish
//                       ? null
//                       : Border.all(color: AppColors.secondaryLight10),
//                   borderRadius: BorderRadius.circular(10)),
//               child: bloc.cheerFinish
//                   ? Stack(
//                       children: [
//                         Align(
//                           alignment: Alignment.center,
//                           child: Column(
//                             children: [
//                               spaceH(20),
//                               customText(
//                                 '응원 인원이 모두 모였어요!',
//                                 style: TextStyle(
//                                     color: AppColors.secondaryDark30,
//                                     fontWeight:
//                                         weightSet(textWeight: TextWeight.BOLD),
//                                     fontSize:
//                                         fontSizeSet(textSize: TextSize.T15)),
//                               ),
//                               spaceH(6),
//                               customText(
//                                 '보답으로 알려주신 의견에 맞는 이웃을 찾아볼게요',
//                                 style: TextStyle(
//                                     color: AppColors.gray500,
//                                     fontWeight: weightSet(
//                                         textWeight: TextWeight.MEDIUM),
//                                     fontSize:
//                                         fontSizeSet(textSize: TextSize.T10)),
//                               ),
//                               spaceH(20)
//                             ],
//                           ),
//                         ),
//                         Positioned(
//                           top: 6,
//                           right: 6,
//                           child: GestureDetector(
//                             onTap: () async {
//                               if (prefs!.getStringList('cheerFinish') == null ||
//                                   prefs!.getStringList('cheerFinish')!.length ==
//                                       0) {
//                                 List<String> cheerFinish = [];
//                                 cheerFinish.add(bloc
//                                     .mainNeighborHood!.addressEupmyeondongNo!
//                                     .toString());
//                                 await prefs!
//                                     .setStringList('cheerFinish', cheerFinish);
//                               } else {
//                                 List<String> cheerFinish = [];
//                                 cheerFinish
//                                     .addAll(prefs!.getStringList('cheerNot')!);
//                                 cheerFinish.add(bloc
//                                     .mainNeighborHood!.addressEupmyeondongNo!
//                                     .toString());
//                                 await prefs!
//                                     .setStringList('cheerFinish', cheerFinish);
//                               }
//                               setState(() {});
//                             },
//                             child: Image.asset(
//                               AppImages.iX,
//                               width: 20,
//                               height: 20,
//                               color: AppColors.secondaryDark30,
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//                   : Column(
//                       children: [
//                         spaceH(20),
//                         customText(
//                           AppStrings.of(StringKey.cheeringTitle),
//                           style: TextStyle(
//                               color: AppColors.secondaryDark30,
//                               fontWeight:
//                                   weightSet(textWeight: TextWeight.BOLD),
//                               fontSize: fontSizeSet(textSize: TextSize.T15)),
//                         ),
//                         spaceH(6),
//                         customText(
//                           "${bloc.mainNeighborHood!.hangName ?? ''}︎${AppStrings.of(StringKey.cheeringContent)}",
//                           style: TextStyle(
//                               color: AppColors.gray500,
//                               fontWeight:
//                                   weightSet(textWeight: TextWeight.MEDIUM),
//                               fontSize: fontSizeSet(textSize: TextSize.T10)),
//                           textAlign: TextAlign.center,
//                         ),
//                         spaceH(14),
//                         Padding(
//                           padding: EdgeInsets.only(left: 30, right: 30),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   height: 24,
//                                   child: Column(
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Image.asset(
//                                             AppImages.iCheerSprout,
//                                             width: 12,
//                                             height: 12,
//                                           ),
//                                           spaceW(4),
//                                           customText(
//                                             AppStrings.of(
//                                                 StringKey.wantToLearn),
//                                             style: TextStyle(
//                                                 color: AppColors.primaryDark10,
//                                                 fontWeight: weightSet(
//                                                     textWeight:
//                                                         TextWeight.BOLD),
//                                                 fontSize: fontSizeSet(
//                                                     textSize: TextSize.T9)),
//                                           ),
//                                           Expanded(child: Container()),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               customText(
//                                                 bloc.cheeringData!.cheeringCnt
//                                                     .toString(),
//                                                 style: TextStyle(
//                                                     color:
//                                                         AppColors.primaryDark10,
//                                                     fontWeight: weightSet(
//                                                         textWeight:
//                                                             TextWeight.BOLD),
//                                                     fontSize: fontSizeSet(
//                                                         textSize: TextSize.T9)),
//                                               ),
//                                               customText(
//                                                 ' / ${bloc.cheeringData!.goalCnt.toString()}',
//                                                 style: TextStyle(
//                                                     color: AppColors.gray400,
//                                                     fontWeight: weightSet(
//                                                         textWeight:
//                                                             TextWeight.BOLD),
//                                                     fontSize: fontSizeSet(
//                                                         textSize: TextSize.T9)),
//                                               )
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                       Expanded(child: Container()),
//                                       ClipRRect(
//                                         borderRadius:
//                                             BorderRadius.circular(8.5),
//                                         child: LinearProgressIndicator(
//                                           backgroundColor:
//                                               AppColors.primaryLight30,
//                                           valueColor:
//                                               AlwaysStoppedAnimation<Color>(
//                                                   AppColors.primary),
//                                           value:
//                                               bloc.cheeringData!.cheeringCnt /
//                                                   bloc.cheeringData!.goalCnt,
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               spaceW(18),
//                               Container(
//                                 width: 92,
//                                 height: 36,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(6)),
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     if (!dataSaver.nonMember) {
//                                       if (bloc.cheeringData!.selfCheeringFlag ==
//                                           1) {
//                                         if (bloc.share != '') {
//                                           if (!dataSaver.share) {
//                                             dataSaver.share = true;
//                                             await Share.share(bloc.share).then((value) {
//                                               dataSaver.share = false;
//                                             });
//                                           }
//
//                                         }
//                                       } else {
//                                         bloc.add(CheeringEvent());
//                                       }
//                                     } else {
//                                       nonMemberDialog(
//                                           context: context,
//                                           title: AppStrings.of(
//                                               StringKey.alertCheering),
//                                           content: AppStrings.of(
//                                               StringKey.alertCheeringContent));
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                       primary: AppColors.secondaryDark20,
//                                       elevation: 0,
//                                       padding: EdgeInsets.zero,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(6))),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       customText(
//                                         bloc.cheeringData!.selfCheeringFlag == 1
//                                             ? '공유하기'
//                                             : AppStrings.of(StringKey.cheering),
//                                         style: TextStyle(
//                                             color: AppColors.white,
//                                             fontWeight: weightSet(
//                                                 textWeight: TextWeight.BOLD),
//                                             fontSize: fontSizeSet(
//                                                 textSize: TextSize.T13)),
//                                       ),
//                                       bloc.cheeringData!.selfCheeringFlag == 1
//                                           ? Container()
//                                           : spaceW(4),
//                                       bloc.cheeringData!.selfCheeringFlag == 1
//                                           ? Container()
//                                           : Image.asset(
//                                               AppImages.iCheerConfetti,
//                                               width: 16,
//                                               height: 16,
//                                             )
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         spaceH(20)
//                       ],
//                     ),
//             ),
//           );
//   }
//
//   cheerNotView() {
//     return bloc.search
//         ? Container()
//         : Stack(
//             children: [
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 padding:
//                     EdgeInsets.only(left: 18, right: 18, top: 20, bottom: 20),
//                 decoration: BoxDecoration(
//                     color: AppColors.secondaryLight30,
//                     borderRadius: BorderRadius.circular(10)),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     customText(
//                       '배잇은 지금 서울 강서구와 함께하고 있어요',
//                       style: TextStyle(
//                           color: AppColors.secondaryDark30,
//                           fontWeight: weightSet(textWeight: TextWeight.BOLD),
//                           fontSize: fontSizeSet(textSize: TextSize.T15)),
//                     ),
//                     spaceH(6),
//                     customText(
//                       '조금만 기다려주시면 더 많은 동네와 함께할게요 :)',
//                       style: TextStyle(
//                           color: AppColors.gray500,
//                           fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
//                           fontSize: fontSizeSet(textSize: TextSize.T10)),
//                     )
//                   ],
//                 ),
//               ),
//               Positioned(
//                 top: 6,
//                 right: 6,
//                 child: GestureDetector(
//                   onTap: () async {
//                     if (prefs!.getStringList('cheerNot') == null ||
//                         prefs!.getStringList('cheerNot')!.length == 0) {
//                       List<String> cheerNot = [];
//                       cheerNot.add(bloc.mainNeighborHood!.addressEupmyeondongNo!
//                           .toString());
//                       await prefs!.setStringList('cheerNot', cheerNot);
//                     } else {
//                       List<String> cheerNot = [];
//                       cheerNot.addAll(prefs!.getStringList('cheerNot')!);
//                       cheerNot.add(bloc.mainNeighborHood!.addressEupmyeondongNo!
//                           .toString());
//                       await prefs!.setStringList('cheerNot', cheerNot);
//                     }
//                     setState(() {});
//                   },
//                   child: Image.asset(
//                     AppImages.iX,
//                     width: 20,
//                     height: 20,
//                     color: AppColors.secondaryDark30,
//                   ),
//                 ),
//               )
//             ],
//           );
//   }
//
//   body() {
//     return Padding(
//       padding: EdgeInsets.only(left: 20, right: 20),
//       child: RefreshIndicator(
//         color: AppColors.primary,
//         onRefresh: () async {
//           bloc.add(ReloadClassEvent(search: searchController.text));
//         },
//         child: SingleChildScrollView(
//           controller: scrollController,
//           physics: AlwaysScrollableScrollPhysics(),
//           child: dataSaver.neighborHoodClass == null
//               ? Container()
//               : Column(
//                   children: [
//                     bloc.getCheering
//                         ? Container()
//                         : (bloc.search || !bloc.notContainArea)
//                             ? prefs!.getStringList('cheerNot') == null
//                                 ? cheerNotView()
//                                 : prefs!.getStringList('cheerNot')!.contains(
//                                         bloc.mainNeighborHood!
//                                             .addressEupmyeondongNo!
//                                             .toString())
//                                     ? Container()
//                                     : cheerNotView()
//                             : bloc.cheeringData == null
//                                 ? cheerNotView()
//                                 : bloc.cheeringData!.status == 'ACTIVE'
//                                     ? Container()
//                                     : prefs!.getStringList('cheerFinish') ==
//                                             null
//                                         ? notContainerArea()
//                                         : prefs!
//                                                 .getStringList('cheerFinish')!
//                                                 .contains(bloc.mainNeighborHood!
//                                                     .addressEupmyeondongNo!
//                                                     .toString())
//                                             ? Container()
//                                             : notContainerArea(),
//                     spaceH(16),
//                     title(),
//                     spaceH(16),
//                     !bloc.view
//                         ? Container()
//                         : dataSaver.neighborHoodClass!.classData.length == 0
//                             ? Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   spaceH(40),
//                                   Container(
//                                     height: 160,
//                                     child: Image.asset(bloc.search
//                                         ? AppImages.imgEmptySearch
//                                         : bloc.filterValues.contains(false)
//                                             ? AppImages.imgEmptyFilter
//                                             : AppImages.imgEmptyList),
//                                   ),
//                                   customText(
//                                     AppStrings.of(bloc.search
//                                         ? StringKey.notSearchClass
//                                         : bloc.filterValues.contains(false)
//                                             ? StringKey.wantClassNotYet
//                                             : StringKey.classNotYet),
//                                     style: TextStyle(
//                                         color: AppColors.gray900,
//                                         fontWeight: weightSet(
//                                             textWeight: TextWeight.MEDIUM),
//                                         fontSize: fontSizeSet(
//                                             textSize: TextSize.T14)),
//                                   ),
//                                   spaceH(20),
//                                   dataSaver.nonMember
//                                       ? customText(
//                                           '로그인하고 우리 동네 쌤을 만나보세요!',
//                                           style: TextStyle(
//                                               color: AppColors.gray400,
//                                               fontWeight: weightSet(
//                                                   textWeight:
//                                                       TextWeight.REGULAR),
//                                               fontSize: fontSizeSet(
//                                                   textSize: TextSize.T14)),
//                                           textAlign: TextAlign.center,
//                                         )
//                                       : RichText(
//                                           textAlign: TextAlign.center,
//                                           text: TextSpan(children: [
//                                             TextSpan(
//                                                 text: AppStrings.of(
//                                                     StringKey.requestClass),
//                                                 style: TextStyle(
//                                                     color:
//                                                         AppColors.accentLight20,
//                                                     fontWeight: weightSet(
//                                                         textWeight:
//                                                             TextWeight.REGULAR),
//                                                     fontSize: fontSizeSet(
//                                                         textSize:
//                                                             TextSize.T14))),
//                                             TextSpan(
//                                                 text: AppStrings.of(StringKey
//                                                     .requestClassVisitTeacher),
//                                                 style: TextStyle(
//                                                     color: AppColors.gray400,
//                                                     fontWeight: weightSet(
//                                                         textWeight:
//                                                             TextWeight.REGULAR),
//                                                     fontSize: fontSizeSet(
//                                                         textSize:
//                                                             TextSize.T14)))
//                                           ]),
//                                         ),
//                                   spaceH(20),
//                                   Container(
//                                     width: dataSaver.nonMember
//                                         ? MediaQuery.of(context).size.width
//                                         : 96,
//                                     height: 48,
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         if (dataSaver.nonMember) {
//                                           nonMemberDialog(
//                                               context: context,
//                                               title: '요청하러 가기',
//                                               content: '카톡으로 로그인하고\n요청할 수 있어요');
//                                         } else {
//                                           widget.navigationBloc
//                                               .add(BottomEvent(view: true));
//                                           pushTransition(
//                                               context,
//                                               CreateRequestPage(
//                                                 profileGet:
//                                                     dataSaver.profileGet,
//                                                 floating: true,
//                                                 previousPage: 'made_register',
//                                               )).then((value) {
//                                             if (value != null) {
//                                               widget.navigationBloc.add(
//                                                   ChangeViewEvent(
//                                                       viewIndex: 1));
//                                               pushTransition(
//                                                   context,
//                                                   RequestDetailPage(
//                                                     profileGet:
//                                                         dataSaver.profileGet,
//                                                     classUuid: value,
//                                                     mainNeighborHood:
//                                                         bloc.mainNeighborHood!,
//                                                     my: true,
//                                                   ));
//                                             }
//                                           });
//                                         }
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                           padding: EdgeInsets.only(
//                                               left: 10, right: 10),
//                                           primary: AppColors.white,
//                                           elevation: 0,
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               side: BorderSide(
//                                                   color: AppColors.primary))),
//                                       child: Center(
//                                         child: customText(
//                                           dataSaver.nonMember
//                                               ? '로그인하고 요청하러 가기'
//                                               : AppStrings.of(
//                                                   StringKey.goRequest),
//                                           style: TextStyle(
//                                               color: AppColors.primaryDark10,
//                                               fontWeight: weightSet(
//                                                   textWeight:
//                                                       TextWeight.MEDIUM),
//                                               fontSize: fontSizeSet(
//                                                   textSize: TextSize.T13)),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   spaceH(20)
//                                 ],
//                               )
//                             : classList()
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget blocBuilder(BuildContext context, state) {
//     return BlocBuilder(
//         bloc: bloc,
//         builder: (context, state) {
//           return WillPopScope(
//             onWillPop: () async {
//               if (bloc.panelOpen) {
//                 panelController.close();
//               } else if (bloc.search) {
//                 if (widget.keyword) {
//                   pop(context);
//                   dataSaver.classBloc!.add(SearchViewEvent(search: false));
//                   dataSaver.mainNavigationBloc!.add(BottomEvent(view: true));
//                   dataSaver.classBloc!.add(ReloadClassEvent());
//                 } else {
//                   bloc.add(SearchViewEvent(search: false));
//                   widget.navigationBloc.add(BottomEvent(view: true));
//                   bloc.add(ReloadClassEvent());
//                 }
//                 scrollController!.jumpTo(0);
//               } else if (scrollController!.offset > 0) {
//                 scrollController!.animateTo(0,
//                     duration: Duration(milliseconds: 300),
//                     curve: Curves.easeInOut);
//               } else {
//                 return await appExitBackPress(context);
//               }
//               return Future.value(false);
//             },
//             child: GestureDetector(
//               onTap: () {
//                 FocusScope.of(context).unfocus();
//               },
//               child: Stack(children: [
//                 Scaffold(
//                   resizeToAvoidBottomInset: true,
//                   backgroundColor: AppColors.white,
//                   body: Stack(
//                     children: [
//                       Positioned(
//                           top: 0,
//                           child: AnimatedCrossFade(
//                             firstChild: appBar(),
//                             secondChild:
//                                 bloc.search ? searchBar() : Container(),
//                             duration: Duration(milliseconds: 300),
//                             crossFadeState: bloc.search
//                                 ? CrossFadeState.showSecond
//                                 : CrossFadeState.showFirst,
//                           )),
//                       Positioned.fill(
//                           left: 0,
//                           right: 0,
//                           top: bloc.search ? 120 : 60,
//                           child: body()),
//                       slidingUpPanel(),
//                       bloc.panelOpen || bloc.scrollEnd || bloc.search
//                           ? Container()
//                           : floatingActionButton(),
//                       ((prefs!.getBool('memberLoad') == null ||
//                                   !prefs!.getBool('memberLoad')!) &&
//                               dataSaver.nonMember)
//                           ? Container()
//                           : loadingView(bloc.isLoading)
//                     ],
//                   ),
//                 ),
//                 prefs!.getBool('nonMemberNeighborHoodTutorial') ?? false
//                     ? Container()
//                     : !dataSaver.nonMember
//                         ? Container()
//                         : Positioned.fill(
//                             left: 0,
//                             top: 0,
//                             child: Container(
//                               color: AppColors.white.withOpacity(0.8),
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     top: 60,
//                                     left: 20,
//                                     right: 20,
//                                     child: Container(
//                                       padding: EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.primary,
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           customText(
//                                               '동네를 선택하고,\n나만의 이름으로 저장할 수 있어요!',
//                                               style: TextStyle(
//                                                   color: AppColors.white,
//                                                   fontWeight: weightSet(
//                                                       textWeight:
//                                                           TextWeight.BOLD),
//                                                   fontSize: fontSizeSet(
//                                                       textSize: TextSize.T14))),
//                                           spaceH(20),
//                                           Container(
//                                             width: MediaQuery.of(context)
//                                                 .size
//                                                 .width,
//                                             height: 42,
//                                             child: ElevatedButton(
//                                               onPressed: () async {
//                                                 widget.navigationBloc.add(
//                                                     BottomEvent(view: true));
//                                                 await prefs!.setBool(
//                                                     'nonMemberNeighborHoodTutorial',
//                                                     true);
//                                                 setState(() {});
//                                               },
//                                               style: ElevatedButton.styleFrom(
//                                                   primary: AppColors.white,
//                                                   elevation: 0,
//                                                   shape: RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               42))),
//                                               child: Center(
//                                                 child: customText(
//                                                   '알겠어요',
//                                                   style: TextStyle(
//                                                       color: AppColors.primary,
//                                                       fontWeight: weightSet(
//                                                           textWeight:
//                                                               TextWeight.BOLD),
//                                                       fontSize: fontSizeSet(
//                                                           textSize:
//                                                               TextSize.T13)),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                 ((prefs!.getBool('memberLoad') == null ||
//                             !prefs!.getBool('memberLoad')!) &&
//                         dataSaver.nonMember)
//                     ? nonMemberLoad()
//                     : Container()
//               ]),
//             ),
//           );
//         });
//   }
//
//   nonMemberLoad() {
//     return Center(
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         color: AppColors.black.withOpacity(0.6),
//         child: Center(
//           child: Container(
//             width: 144,
//             height: 196,
//             decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(10)),
//             padding: EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 Lottie.asset(
//                   AppImages.nonMemberLoad,
//                   width: 104,
//                   height: 104,
//                   controller: loadingController,
//                   onLoaded: (composition) {
//                     setState(() {
//                       loadingController!..duration = composition.duration;
//                       loadingController!.forward().then((value) async {
//                         await prefs!.setBool('memberLoad', true);
//                         setState(() {});
//                       });
//                     });
//                   },
//                 ),
//                 spaceH(18),
//                 customText(
//                   '다른 동네로\n구경가는 중이에요',
//                   style: TextStyle(
//                       color: AppColors.gray600,
//                       fontWeight: weightSet(textWeight: TextWeight.REGULAR),
//                       fontSize: fontSizeSet(textSize: TextSize.T13)),
//                   textAlign: TextAlign.center,
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   blocListener(BuildContext context, state) {
//     if (state is NeighborHoodClassInitState) {
//       if (dataSaver.feedbackBanner) {
//         dataSaver.feedbackBanner = false;
//         feedbackBanner();
//       }
//       if (!widget.keyword) {
//         dataSaver.classBloc = bloc;
//       }
//       if (widget.keyword) {
//         searchController.text = dataSaver.searchText;
//         bloc.add(ReloadClassEvent(search: searchController.text));
//       }
//       widget.navigationBloc
//           .add(NeighborHoodSaveEvent(neighborHood: dataSaver.neighborHood));
//       scrollController!.jumpTo(dataSaver.mainScrollOffset);
//     }
//
//     if (state is SaveDistanceState) {
//       bloc.setPublicData();
//       bloc.add(ReloadClassEvent(search: searchController.text));
//     }
//
//     if (state is SearchViewState) {
//       bloc.setPublicData();
//     }
//
//     if (state is SaveFilterState) {
//       bloc.setPublicData();
//       bloc.add(ReloadClassEvent(search: searchController.text));
//     }
//
//     if (state is NeighborHoodChangeState) {
//       widget.navigationBloc
//           .add(NeighborHoodSaveEvent(neighborHood: dataSaver.neighborHood));
//     }
//
//     if (state is ReloadClassState) {
//       setState(() {});
//     }
//
//     if (state is ScrollUpState) {
//       scrollController!.animateTo(0,
//           duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//     }
//
//     if (state is GetDataState) {
//       if (state.offset != null && state.index != null) {
//         for (int i = 0; i < state.offset!; i++) {
//           listKey.currentState!.insertItem(state.index! + i);
//           setState(() {});
//         }
//       }
//     }
//
//     if (state is CheeringState) {
//       amplitudeEvent('cheer_completed', {
//         'town_sido': bloc.mainNeighborHood!.sidoName,
//         'town_sigungu': bloc.mainNeighborHood!.sigunguName,
//         'town_dongeupmyeon': bloc.mainNeighborHood!.eupmyeondongName
//       });
//       pushTransition(
//           context,
//           NeighborHoodCheerPage(
//             uuid: state.uuid,
//             member: dataSaver.profileGet!.nickName,
//           ));
//     }
//   }
//
//   @override
//   NeighborHoodClassBloc initBloc() {
//     return NeighborHoodClassBloc(context)
//       ..add(NeighborHoodClassInitEvent(
//           animationVsync: this, keyword: widget.keyword));
//   }
//
//   feedbackBanner() {
//     return customDialog(
//         context: context,
//         barrier: true,
//         widget: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10)),
//               child: Image.asset(
//                 AppImages.bnrFeedbackModal,
//                 height: ((MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.30)) > 300) ? 252 : null,
//                 fit: BoxFit.fill,
//               ),
//             ),
//             spaceH(12),
//             Padding(
//               padding: EdgeInsets.only(left: 12, right: 12),
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     amplitudeEvent('go_feedback', {});
//                     popDialog(context);
//                     pushTransition(context, FeedbackPage());
//                   },
//                   style: ElevatedButton.styleFrom(
//                       primary: AppColors.secondaryLight20,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       )),
//                   child: Center(
//                     child: customText(
//                       '피드백 하러가기',
//                       style: TextStyle(
//                           color: AppColors.secondaryDark30,
//                           fontWeight:
//                               weightSet(textWeight: TextWeight.BOLD),
//                           fontSize: fontSizeSet(textSize: TextSize.T14)),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 amplitudeEvent('banner_close', {});
//                 popDialog(context);
//               },
//               child: Container(
//                 width: 48,
//                 height: 48,
//                 color: AppColors.white,
//                 child: Center(
//                   child: customText(
//                     '닫기',
//                     style: TextStyle(
//                         color: AppColors.gray600,
//                         fontWeight:
//                             weightSet(textWeight: TextWeight.MEDIUM),
//                         fontSize: fontSizeSet(textSize: TextSize.T12),
//                         decoration: TextDecoration.underline),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ));
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     if (dataSaver.nonMember &&
//         !(prefs!.getBool('nonMemberNeighborHoodTutorial') ?? false)) {
//       widget.navigationBloc.add(BottomEvent(view: false));
//     }
//
//     loadingController = AnimationController(vsync: this);
//     scrollController = ScrollController()
//       ..addListener(() {
//         dataSaver.mainScrollOffset = scrollController!.offset;
//         if (dataSaver.neighborHoodClass != null &&
//             dataSaver.neighborHoodClass!.classData.length > 2) {
//           if (bloc.scrollEnd) {
//             bloc.scrollEnd = false;
//             setState(() {});
//           }
//           if (!bloc.scrollUnder &&
//               (bloc.bottomOffset == 0 ||
//                   bloc.bottomOffset < scrollController!.offset) &&
//               scrollController!.offset >=
//                   scrollController!.position.maxScrollExtent &&
//               !scrollController!.position.outOfRange) {
//             bloc.scrollUnder = true;
//             bloc.bottomOffset = scrollController!.offset;
//             bloc.add(ScrollEndEvent());
//           }
//           if (!bloc.scrollUnder &&
//               (bloc.bottomOffset == 0 ||
//                   bloc.bottomOffset < scrollController!.offset) &&
//               scrollController!.offset >=
//                   (scrollController!.position.maxScrollExtent * 0.7) &&
//               !scrollController!.position.outOfRange) {
//             bloc.add(GetDataEvent(key: listKey));
//           }
//           if (scrollController!.offset <=
//                   scrollController!.position.minScrollExtent &&
//               !scrollController!.position.outOfRange) {
//             bloc.floatingAnimationEnd = true;
//             bloc.add(ScrollEvent(scroll: true));
//           }
//           if (scrollController!.position.userScrollDirection ==
//               ScrollDirection.forward) {
//             bloc.bottomOffset = 0;
//             bloc.scrollUnder = false;
//             if (!bloc.upDownCheck) {
//               bloc.upDownCheck = true;
//               bloc.startPixels = scrollController!.offset;
//             }
//             // 스크롤 다운
//           } else if (scrollController!.position.userScrollDirection ==
//               ScrollDirection.reverse) {
//             if (bloc.upDownCheck) {
//               bloc.upDownCheck = false;
//               bloc.startPixels = scrollController!.offset;
//             }
//             // 스크롤 업
//           }
//         }
//       });
//   }
//
//   @override
//   void dispose() {
//     closeController.dispose();
//     for (int i = 0; i < bloc.animationControllers.length; i++) {
//       bloc.animationControllers[i].dispose();
//     }
//     super.dispose();
//   }
// }
