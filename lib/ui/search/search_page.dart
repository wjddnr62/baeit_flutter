import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/learn/learn_bloc.dart' as learnBloc;
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/neighborhood_select/neighborhood_select_page.dart';
import 'package:baeit/ui/search/search_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SearchPage extends BlocStatefulWidget {
  final int learnType;
  final int? keywordDetailType;
  final VoidCallback? filterOpen;
  final VoidCallback? dayOpen;

  SearchPage(
      {required this.learnType,
      this.filterOpen,
      this.dayOpen,
      this.keywordDetailType});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return SearchState();
  }
}

class SearchState extends BlocState<SearchBloc, SearchPage> {
  ScrollController? classController;
  ScrollController? exchangeController;
  ScrollController? withMeController;
  PanelController filterController = PanelController();

  filterOpen() async {
    if (filterController.isPanelClosed && !bloc.loading) {
      setState(() {
        bloc.categoryFilter = true;
        bloc.openFilterValues = bloc.filterValues.toList();
        bloc.openFilterData = bloc.filterData.toList();
      });

      amplitudeEvent('category', {
        'type': widget.keywordDetailType == 0
            ? 'class'
            : widget.keywordDetailType == 1
                ? 'exchange'
                : 'gather'
      });
      await filterController.open();
    }
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: WillPopScope(
              onWillPop: () {
                if (Navigator.of(context).canPop()) {
                  dataSaver.keyword = true;
                }
                if (dataSaver.keyword) {
                  dataSaver.keyword = false;
                  FocusScope.of(context).unfocus();
                  bloc.searchController.text = '';
                  bloc.classList = null;
                  pop(context);
                } else {
                  FocusScope.of(context).unfocus();
                  bloc.searchController.text = '';
                  bloc.classList = null;
                  dataSaver.mainBloc!.add(MenuBarHideEvent(hide: false));
                  dataSaver.learnBloc!.add(learnBloc.SearchChangeEvent());
                }
                return Future.value(true);
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (dataSaver.keyword) {
                      if (bloc.neighborhoodSelecterView) {
                        bloc.neighborhoodSelecterAnimationEnd = false;
                      }
                      bloc.neighborhoodSelecterView = false;
                    } else {
                      if (dataSaver.learnBloc!.neighborhoodSelecterView) {
                        dataSaver.learnBloc!.neighborhoodSelecterAnimationEnd =
                            false;
                      }
                      dataSaver.learnBloc!.neighborhoodSelecterView = false;
                      dataSaver.learnBloc!.add(learnBloc.ChangeViewEvent());
                    }
                    FocusScope.of(context).unfocus();
                  });
                },
                child: SafeArea(
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: AppColors.white,
                    body: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height -
                            dataSaver.statusTop -
                            dataSaver.iosBottom,
                        child: Stack(
                          children: [
                            searchBar(),
                            bloc.mostSearchList.length != 0
                                ? mostSearch()
                                : Container(),
                            settingBar(),
                            line(),
                            content(),
                            filterSlidingUpPanel(),
                            neighborHoodSelecter(),
                            searchSetKeyword(),
                            loadingView(bloc.loading)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  searchSetKeyword() {
    return AnimatedPositioned(
      bottom: bloc.setKeywordAlarmView ? 58 : -48,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 48,
          child: Center(
            child: IntrinsicWidth(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    bloc.setKeywordAlarmView = false;
                    if (bloc.setKeywordAlarmViewTimer != null) {
                      bloc.setKeywordAlarmViewTimer!.cancel();
                    }
                  });

                  if (bloc.keyword!.keywords.length == 10) {
                    showToast(context: context, text: '키워드는 10개까지만 설정가능해요');
                    return;
                  } else {
                    if (bloc.keyword!.keywords.indexWhere((element) =>
                            element.keywordText ==
                            bloc.searchController.text) ==
                        -1) {
                      bloc.add(
                          SetKeywordEvent(keyword: bloc.searchController.text));
                      showToast(
                          context: context,
                          text: '알림을 설정했어요!\n(알림 > 키워드 알림 > 키워드 설정에서 확인)');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.primary,
                    elevation: 0,
                    padding: EdgeInsets.only(left: 16, right: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      customText('\'${bloc.searchController.text == '' ? bloc.searchText : bloc.searchController.text}\'',
                          style: TextStyle(
                              color: AppColors.white,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T15))),
                      customText('로 알림 설정하기',
                          style: TextStyle(
                              color: AppColors.white.withOpacity(0.6),
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T15)))
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  filterSlidingUpPanel() {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: SlidingUpPanel(
          color: AppColors.white,
          controller: filterController,
          panel: panelView(),
          backdropTapClosesPanel: true,
          backdropEnabled: true,
          isDraggable: false,
          boxShadow: null,
          onPanelClosed: () {
            setState(() {
              bloc.categoryFilter = false;
              if (!bloc.saveIng) {
                if (bloc.openFilterValues.length != 0) {
                  bloc.filterValues = [];
                  bloc.filterValues = bloc.openFilterValues;
                  bloc.filterData = [];
                  bloc.filterData = bloc.openFilterData;
                }
              }
            });
          },
          backdropColor: AppColors.black,
          backdropOpacity: 0.6,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          minHeight: filterController.isAttached
              ? filterController.isPanelClosed
                  ? 0
                  : bloc.categoryFilter
                      ? 534
                      : 542
              : 0,
          maxHeight: bloc.categoryFilter ? 534 : 542,
        ));
  }

  panelView() {
    return Stack(
      children: [
        panelViewTitle(dataSaver.keyword
            ? bloc.categoryFilter
                ? '카테고리'
                : '희망요일'
            : dataSaver.learnBloc!.categoryFilter
                ? '카테고리'
                : '희망요일'),
        bloc.categoryFilter ? panelFilter() : Container(),
        Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: bottomButton(
                context: context,
                text: AppStrings.of(StringKey.save),
                onPress: () async {
                  bloc.saveIng = true;
                  if (filterController.isPanelOpen) {
                    amplitudeEvent('category_set_completed', {
                      'type': widget.keywordDetailType == 0
                          ? 'class'
                          : widget.keywordDetailType == 1
                              ? 'exchange'
                              : 'gather',
                      'category': bloc.filterData.join(',')
                    });
                    await filterController.close();
                  }
                  bloc.add(SaveFilterEvent());
                  bloc.add(SearchReloadClassEvent());
                  FocusScope.of(context).unfocus();
                }))
      ],
    );
  }

  panelFilter() {
    return Stack(
      children: [
        bloc.filterValues.length == 0
            ? Container()
            : Positioned(
                top: 72,
                left: 20,
                right: 20,
                bottom: 60,
                child: Column(
                  children: [
                    spaceH(10),
                    GestureDetector(
                      onTap: () {
                        if (!bloc.filterValues.contains(false)) {
                          bloc.add(FilterSetAllEvent(check: false));
                        } else {
                          bloc.add(FilterSetAllEvent(check: true));
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: (bloc.filterValues.contains(false)
                              ? AppColors.white
                              : AppColors.primary.withOpacity(0.14)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                bloc.filterValues.contains(false)
                                    ? AppImages.iCategoryLAll
                                    : AppImages.iCategoryCAll,
                                width: 42,
                                height: 42,
                              ),
                              spaceH(4),
                              customText('모든 카테고리',
                                  style: TextStyle(
                                      color: AppColors.black.withOpacity(0.4),
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)))
                            ],
                          ),
                        ),
                      ),
                    ),
                    spaceH(18),
                    Flexible(
                      child: Container(
                          height: 296,
                          child: GridView.count(
                            physics: ClampingScrollPhysics(),
                            crossAxisCount: 3,
                            childAspectRatio:
                                (((MediaQuery.of(context).size.width - 72) /
                                        3) /
                                    80),
                            padding: EdgeInsets.only(bottom: 18),
                            shrinkWrap: true,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 16,
                            children: List.generate(bloc.filterItemName.length,
                                (index) {
                              return GestureDetector(
                                onTap: () {
                                  if (!bloc.filterValues.contains(false)) {
                                    bloc.filterData = [];
                                    bloc.filterValues =
                                        List.generate(9, (index) => false);
                                  }

                                  if (bloc.filterValues.indexWhere(
                                              (element) => element == true) !=
                                          bloc.filterValues.lastIndexWhere(
                                              (element) => element == true) ||
                                      !bloc.filterValues[index]) {
                                    setState(() {
                                      if (!bloc.filterValues[index]) {
                                        bloc.filterData.add(dataSaver
                                            .category[index].classCategoryId!);
                                      } else {
                                        bloc.filterData.remove(dataSaver
                                            .category[index].classCategoryId);
                                      }
                                      bloc.filterValues[index] =
                                          !bloc.filterValues[index];
                                    });
                                  } else {
                                    showToast(
                                        context: context,
                                        text: AppStrings.of(
                                            StringKey.filterToast));
                                  }
                                },
                                child: Container(
                                  width: 96,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: bloc.filterValues.contains(false)
                                          ? bloc.filterValues[index]
                                              ? AppColors.primary
                                                  .withOpacity(0.14)
                                              : AppColors.white
                                          : AppColors.white),
                                  child: Column(
                                    children: [
                                      spaceH(8.5),
                                      Image.asset(
                                        bloc.filterValues.contains(false)
                                            ? bloc.filterValues[index]
                                                ? bloc
                                                    .filterItemCheckImage[index]
                                                : bloc.filterItemUnCheckImage[
                                                    index]
                                            : bloc
                                                .filterItemUnCheckImage[index],
                                        width: 42,
                                        height: 42,
                                      ),
                                      spaceH(4),
                                      customText(
                                        bloc.filterItemName[index],
                                        style: TextStyle(
                                            color: AppColors.black
                                                .withOpacity(0.4),
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12)),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          )),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  panelViewTitle(text) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: customText(
                    text,
                    style: TextStyle(
                        fontSize: fontSizeSet(textSize: TextSize.T15),
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        color: AppColors.gray900),
                  ),
                ),
                Positioned(
                  right: 20,
                  child: GestureDetector(
                      onTap: () async {
                        await filterController.close();
                      },
                      child: Image.asset(
                        AppImages.iX,
                        width: 24,
                        height: 24,
                      )),
                ),
              ],
            ),
          ),
          heightLine(color: AppColors.gray100, height: 1),
        ],
      ),
    );
  }

  searchBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        child: Row(
          children: [
            spaceW(20),
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    dataSaver.keyword = true;
                  }
                  if (dataSaver.keyword) {
                    dataSaver.keyword = false;
                    FocusScope.of(context).unfocus();
                    bloc.searchController.text = '';
                    bloc.classList = null;
                    pop(context);
                  } else {
                    FocusScope.of(context).unfocus();
                    bloc.searchController.text = '';
                    bloc.classList = null;
                    dataSaver.mainBloc!.add(MenuBarHideEvent(hide: false));
                    dataSaver.learnBloc!.add(learnBloc.SearchChangeEvent());
                  }
                },
                icon: Image.asset(
                  AppImages.iChevronPrev,
                  width: 24,
                  height: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            spaceW(20),
            Expanded(
                child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight50,
                  borderRadius: BorderRadius.circular(8)),
              child: Stack(
                children: [
                  TextFormField(
                      onChanged: (text) {
                        blankCheck(
                            text: text, controller: bloc.searchController);
                        setState(() {});
                      },
                      maxLines: 1,
                      controller: bloc.searchController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) {
                        if (bloc.searchController.text.length != 0) {
                          amplitudeEvent('search_button', {
                            'type': widget.keywordDetailType == 0
                                ? 'class'
                                : widget.keywordDetailType == 1
                                    ? 'exchange'
                                    : 'gather',
                            'search': value
                          });
                          bloc.add(SearchEvent());
                          FocusScope.of(context).unfocus();
                        }
                      },
                      style: TextStyle(
                          color: AppColors.primaryDark10,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T14)),
                      decoration: InputDecoration(
                        hintText: AppStrings.of(StringKey.searchPlaceHolder),
                        hintStyle: TextStyle(
                            color: AppColors.primaryDark10.withOpacity(0.4),
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)),
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.only(
                            left: 10, top: 12, bottom: 0, right: 40),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      )),
                  bloc.searchController.text.length > 0
                      ? Positioned(
                          right: 38,
                          top: 8,
                          bottom: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                bloc.searchController.text = '';
                              });
                            },
                            child: Image.asset(
                              AppImages.iInputClearTrans,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        )
                      : Container(),
                  Positioned(
                    right: 10,
                    top: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: () {
                        if (bloc.searchController.text.length != 0) {
                          setState(() {
                            bloc.search = true;
                          });
                          FocusScope.of(context).unfocus();
                          bloc.add(SearchEvent());
                          amplitudeEvent('search_button', {
                            'type': widget.keywordDetailType == 0
                                ? 'class'
                                : widget.keywordDetailType == 1
                                    ? 'exchange'
                                    : 'gather',
                            'search': bloc.searchController.text
                          });
                        }
                      },
                      child: Image.asset(
                        AppImages.iSearchC,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  )
                ],
              ),
            )),
            spaceW(10)
          ],
        ),
      ),
    );
  }

  mostSearch() {
    List<Widget> mostSearchWidget = [];
    for (int i = -1; i < bloc.mostSearchList.length; i++) {
      if (i >= 0) {
        mostSearchWidget.add(Row(
          children: [
            GestureDetector(
              onTap: () {
                bloc.search = true;
                bloc.searchController.text = bloc.mostSearchList[i];
                amplitudeEvent('recent_keyword', {
                  'type': widget.keywordDetailType == 0
                      ? 'class'
                      : widget.keywordDetailType == 1
                          ? 'exchange'
                          : 'gather',
                  'keyword': bloc.mostSearchList[i]
                });
                bloc.add(SearchEvent(mostSearch: true));
              },
              child: Container(
                height: 30,
                color: AppColors.white,
                child: Center(
                  child: Row(
                    children: [
                      spaceW(2),
                      customText('#',
                          style: TextStyle(
                              color: AppColors.accentLight30,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T11))),
                      customText(
                          bloc.mostSearchList[i].length > 8
                              ? bloc.mostSearchList[i].substring(0, 8) + ".."
                              : bloc.mostSearchList[i],
                          style: TextStyle(
                              color: AppColors.gray900,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T11))),
                      spaceW(2),
                    ],
                  ),
                ),
              ),
            ),
            spaceW(10),
          ],
        ));
      }

      if (i == -1) {
        mostSearchWidget.add(Row(
          children: [
            Container(
              width: 1,
              height: 16,
              color: AppColors.gray300,
            ),
            spaceW(10),
            GestureDetector(
              onTap: () {
                bloc.add(MostSearchRemoveAllEvent());
              },
              child: Container(
                height: 30,
                color: AppColors.white,
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.iTrashG,
                      width: 12,
                      height: 12,
                    ),
                    spaceW(2),
                    customText('전체 삭제',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T11)))
                  ],
                ),
              ),
            ),
            spaceW(20)
          ],
        ));
      }
    }
    return Positioned(
      left: 0,
      right: 0,
      top: 60,
      child: Container(
        height: 54,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spaceW(20),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Container(
                  height: 30,
                  child: customText('최근 검색어',
                      style: TextStyle(
                          color: AppColors.gray500,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T11))),
                ),
              ),
              spaceW(10),
              Row(
                children: mostSearchWidget.reversed.toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  neighborHoodSelecter() {
    return Positioned(
      top: bloc.search
          ? (dataSaver.searchBloc!.mostSearchList.length == 0 ? 60 : 104)
          : 12,
      left: 20,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
        opacity: bloc.neighborhoodSelecterView ? 1.0 : 0.0,
        onEnd: () {
          setState(() {
            bloc.neighborhoodSelecterAnimationEnd = true;
          });
        },
        child: Container(
          width: bloc.neighborhoodSelecterView
              ? 180
              : bloc.neighborhoodSelecterAnimationEnd
                  ? 0
                  : 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                  color: AppColors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 0))
            ],
          ),
          child: Column(
            children: [
              spaceH(10),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, idx) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (dataSaver.neighborHood[idx].representativeFlag !=
                            1) {
                          if (bloc.neighborhoodSelecterView) {
                            bloc.neighborhoodSelecterAnimationEnd = false;
                          }
                          bloc.neighborhoodSelecterView = false;
                          bloc.add(NeighborHoodChangeEvent(index: idx));
                          dataSaver.learnBloc!.add(
                              learnBloc.NeighborHoodChangeEvent(index: idx));
                          FocusScope.of(context).unfocus();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.white, elevation: 0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customText(dataSaver.neighborHood[idx].townName!,
                                style: TextStyle(
                                    color: dataSaver.neighborHood[idx]
                                                .representativeFlag ==
                                            1
                                        ? AppColors.gray900
                                        : AppColors.gray400,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T14))),
                            dataSaver.neighborHood[idx].representativeFlag == 1
                                ? spaceW(4)
                                : Container(),
                            dataSaver.neighborHood[idx].representativeFlag == 1
                                ? Image.asset(
                                    AppImages.iCheckC,
                                    width: 14,
                                    height: 14,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: dataSaver.neighborHood.length,
              ),
              spaceH(10),
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      amplitudeEvent('town_set_enter', {
                        'type': widget.keywordDetailType == 0
                            ? 'class'
                            : widget.keywordDetailType == 1
                                ? 'exchange'
                                : 'gather'
                      });
                      pushTransition(context, NeighborHoodSelectPage())
                          .then((value) {
                        if (value != null && value) {
                          dataSaver.learnBloc!
                              .add(learnBloc.ReloadClassEvent());
                          bloc.add(SearchReloadClassEvent());

                          if (bloc.neighborhoodSelecterView) {
                            bloc.neighborhoodSelecterAnimationEnd = false;
                          }
                          bloc.neighborhoodSelecterView = false;
                          bloc.add(NeighborHoodChangeEvent(
                              index: dataSaver.neighborHood.indexWhere(
                                  (element) =>
                                      element.representativeFlag == 1)));
                          dataSaver.learnBloc!.add(
                              learnBloc.NeighborHoodChangeEvent(
                                  index: dataSaver.neighborHood.indexWhere(
                                      (element) =>
                                          element.representativeFlag == 1)));
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryLight40,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.iSetting,
                            width: 16,
                            height: 16,
                            color: AppColors.primary,
                          ),
                          spaceW(4),
                          customText('동네설정',
                              style: TextStyle(
                                  color: AppColors.primaryDark10,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T13)))
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  selectTypeLength(idx) {
    switch (idx) {
      case 0:
        return bloc.classList == null ? 0 : bloc.classList!.totalRow;
      case 1:
        return bloc.exchangeList == null ? 0 : bloc.exchangeList!.totalRow;
      case 2:
        return bloc.withMeList == null ? 0 : bloc.withMeList!.totalRow;
    }
  }

  settingBar() {
    List<Widget> settingItem = [];
    for (int i = 0; i < 1; i++) {
      settingItem.add(Row(
        children: [
          Container(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                if (dataSaver.keyword) {
                  if (i == 0) {
                    bloc.add(NeighborHoodSelecterViewOpenEvent());
                    amplitudeEvent('town_select', {
                      'type': widget.keywordDetailType == 0
                          ? 'class'
                          : widget.keywordDetailType == 1
                              ? 'exchange'
                              : 'gather'
                    });
                  } else if (i == 1) {
                    filterOpen();
                  }
                } else {
                  if (i == 0) {
                    dataSaver.learnBloc!.closeNeighborhoodSelecter = false;
                    Future.delayed(Duration(milliseconds: 1500), () {
                      dataSaver.learnBloc!.closeNeighborhoodSelecter = true;
                    });
                    dataSaver.learnBloc!
                        .add(learnBloc.NeighborHoodSelecterViewOpenEvent());
                    amplitudeEvent('town_select', {
                      'type': widget.keywordDetailType == 0
                          ? 'class'
                          : widget.keywordDetailType == 1
                              ? 'exchange'
                              : 'gather'
                    });
                  } else if (i == 1) {
                    // widget.filterOpen!();
                    filterOpen();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: AppColors.white,
                  elevation: 0,
                  padding: EdgeInsets.only(left: 12, right: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          width: 1,
                          color: i == 1
                              ? bloc.openFilterValues
                                          .where((element) => element == true)
                                          .toList()
                                          .length >
                                      8
                                  ? AppColors.accent
                                  : AppColors.accent
                              : AppColors.gray200))),
              child: Row(
                children: [
                  customText(
                      (dataSaver.keyword || dataSaver.learnBloc!.search)
                          ? settingBarItemName(i)
                          : '',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                  spaceW(4),
                  i == 1 &&
                          (dataSaver.keyword
                              ? (bloc.openFilterValues
                                      .where((element) => element == true)
                                      .toList()
                                      .length >
                                  8)
                              : (dataSaver.learnBloc!.openFilterValues
                                      .where((element) => element == true)
                                      .toList()
                                      .length >
                                  8))
                      ? Container()
                      : i != 1 ||
                              (dataSaver.keyword
                                              ? bloc.openFilterValues
                                              : dataSaver
                                                  .learnBloc!.openFilterValues)
                                          .where((element) => element == true)
                                          .toList()
                                          .length -
                                      1 ==
                                  0
                          ? Container()
                          : Row(children: [
                              Container(
                                height: 16,
                                padding:
                                    EdgeInsets.only(left: 4.67, right: 4.67),
                                decoration: BoxDecoration(
                                    color: AppColors.accentLight40,
                                    borderRadius: BorderRadius.circular(2.33)),
                                child: Center(
                                  child: customText(
                                      '+${(dataSaver.keyword ? bloc.openFilterValues : dataSaver.learnBloc!.openFilterValues).where((element) => element == true).toList().length - 1}',
                                      style: TextStyle(
                                          color: AppColors.accentDark10,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.BOLD),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T10))),
                                ),
                              ),
                              spaceW(2)
                            ]),
                  Image.asset(
                    AppImages.iSelectACDown,
                    width: 12,
                    height: 12,
                    color: AppColors.gray400,
                  )
                ],
              ),
            ),
          ),
          spaceW(20),
        ],
      ));
    }

    List<Widget> selectType = [];
    for (int i = 0; i < 3; i++) {
      selectType.add(Row(
        children: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                bloc.add(SelectTypeEvent(idx: i));
              },
              child: customText(
                  '${searchType(i)}${bloc.search ? '(${selectTypeLength(i)})' : ''}',
                  style: TextStyle(
                      color: bloc.selectTypeIndex == i
                          ? AppColors.primaryDark10
                          : AppColors.gray500,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T13))),
            ),
          ),
          i != 2 ? spaceW(12) : Container()
        ],
      ));
    }

    return Positioned(
      top: bloc.mostSearchList.length == 0 ? 60 : 106,
      left: 0,
      right: 0,
      child: Container(
        height: 54,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spaceW(20),
            Row(
              children: settingItem,
            ),
            Container(
              height: 36,
              child: Row(
                children: selectType,
              ),
            ),
            spaceW(20)
          ],
        ),
      ),
    );
  }

  settingBarItemName(int idx) {
    if (idx == 0) {
      return dataSaver
          .neighborHood[dataSaver.neighborHood
              .indexWhere((element) => element.representativeFlag == 1)]
          .townName!;
    } else if (idx == 1) {
      return dataSaver.keyword
          ? bloc.openFilterValues
                      .where((element) => element == true)
                      .toList()
                      .length >
                  8
              ? '모든 카테고리'
              : bloc.filterItemName.length == 0
                  ? ''
                  : bloc.filterItemName[bloc.openFilterValues.indexOf(true)]
          : bloc.learnType == 0
              ? dataSaver.learnBloc!.openFilterValues
                          .where((element) => element == true)
                          .toList()
                          .length >
                      8
                  ? '모든 카테고리'
                  : dataSaver.learnBloc!.filterItemName[
                      dataSaver.learnBloc!.openFilterValues.indexOf(true)]
              : '모든 카테고리';
    } else {
      return '';
    }
  }

  line() {
    return Positioned(
        left: 0,
        right: 0,
        top: bloc.mostSearchList.length == 0 ? 104 : 152,
        child: heightLine(height: 1, color: AppColors.gray100));
  }

  content() {
    return Positioned.fill(
      left: 0,
      right: 0,
      top: bloc.mostSearchList.length == 0
          ? bloc.selectTypeIndex == 0
              ? 115
              : 104
          : bloc.selectTypeIndex == 0
              ? 163
              : 152,
      bottom: 0,
      child: !bloc.search
          ? Column(
              children: [
                spaceH(40),
                Image.asset(
                  AppImages.imgEmptySearch,
                  height: 160,
                ),
                customText('검색어를 입력해주세요',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
              ],
            )
          : IndexedStack(
              index: bloc.selectTypeIndex,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: AppColors.white,
                  child: classList(),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: bloc.exchangeList == null ||
                          bloc.exchangeList!.communityData.length == 0
                      ? AppColors.white
                      : AppColors.greenGray50,
                  child: exchangeList(),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: bloc.withMeList == null ||
                          bloc.withMeList!.communityData.length == 0
                      ? AppColors.white
                      : AppColors.greenGray50,
                  child: withMeList(),
                ),
              ],
            ),
    );
  }

  searchNone() {
    return Column(
      children: [
        spaceH(48),
        Image.asset(
          AppImages.imgEmptySearch,
          height: 160,
        ),
        customText(
            '검색하신 ${searchType(bloc.selectTypeIndex)}${bloc.selectTypeIndex == 0 ? '가' : '이'} 아직 없어요',
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T14))),
        spaceH(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customText('새로운 ${searchType(bloc.selectTypeIndex)}',
                style: TextStyle(
                    color: AppColors.accentLight20,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T14))),
            customText('${bloc.selectTypeIndex == 0 ? '가' : '글이'} 등록되면 알려드릴게요',
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T14)))
          ],
        ),
        spaceH(20),
        IntrinsicWidth(
          child: Container(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (bloc.keyword!.keywords.length == 10) {
                  showToast(context: context, text: '키워드는 10개까지만 설정가능해요');
                  return;
                }

                if (bloc.keyword!.keywords.indexWhere((element) =>
                        element.keywordText == bloc.searchController.text) ==
                    -1) {
                  bloc.add(
                      SetKeywordEvent(keyword: bloc.searchController.text));
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: bloc.keyword == null ? AppColors.white : (bloc.keyword!.keywords.indexWhere((element) =>
                              element.keywordText ==
                              bloc.searchController.text) ==
                          -1)
                      ? AppColors.primary
                      : AppColors.white,
                  side: BorderSide(
                      width: (bloc.keyword!.keywords.indexWhere((element) =>
                                  element.keywordText ==
                                  bloc.searchController.text) ==
                              -1)
                          ? 0
                          : 1,
                      color: AppColors.primary),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.only(left: 10, right: 10)),
              child: Center(
                child: customText(
                    '\'${bloc.searchController.text == '' ? bloc.searchText : bloc.searchController.text}\'${(bloc.keyword!.keywords.indexWhere((element) => element.keywordText == bloc.searchController.text) == -1) ? '로 알림 설정하기' : ' 알림 설정 완료'}',
                    style: TextStyle(
                        color: (bloc.keyword!.keywords.indexWhere((element) =>
                                    element.keywordText ==
                                    bloc.searchController.text) ==
                                -1)
                            ? AppColors.white
                            : AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T15))),
              ),
            ),
          ),
        )
      ],
    );
  }

  classCategorySettingBar() {
    return Row(
      children: [
        Container(
          height: 36,
          child: ElevatedButton(
            onPressed: () {
              filterOpen();
            },
            style: ElevatedButton.styleFrom(
                primary: AppColors.white,
                elevation: 0,
                padding: EdgeInsets.only(left: 12, right: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        width: 1,
                        color: bloc.openFilterValues
                                    .where((element) => element == true)
                                    .toList()
                                    .length >
                                8
                            ? AppColors.accent
                            : AppColors.accent))),
            child: Row(
              children: [
                customText(settingBarItemName(1),
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
                spaceW(4),
                (dataSaver.keyword
                        ? (bloc.openFilterValues
                                .where((element) => element == true)
                                .toList()
                                .length >
                            8)
                        : (dataSaver.learnBloc!.openFilterValues
                                .where((element) => element == true)
                                .toList()
                                .length >
                            8))
                    ? Container()
                    : (dataSaver.keyword
                                        ? bloc.openFilterValues
                                        : dataSaver.learnBloc!.openFilterValues)
                                    .where((element) => element == true)
                                    .toList()
                                    .length -
                                1 ==
                            0
                        ? Container()
                        : Row(children: [
                            Container(
                              height: 16,
                              padding: EdgeInsets.only(left: 4.67, right: 4.67),
                              decoration: BoxDecoration(
                                  color: AppColors.accentLight40,
                                  borderRadius: BorderRadius.circular(2.33)),
                              child: Center(
                                child: customText(
                                    '+${(dataSaver.keyword ? bloc.openFilterValues : dataSaver.learnBloc!.openFilterValues).where((element) => element == true).toList().length - 1}',
                                    style: TextStyle(
                                        color: AppColors.accentDark10,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T10))),
                              ),
                            ),
                            spaceW(2)
                          ]),
                Image.asset(
                  AppImages.iSelectACDown,
                  width: 12,
                  height: 12,
                  color: AppColors.gray400,
                )
              ],
            ),
          ),
        ),
        spaceW(10),
      ],
    );
  }

  classList() {
    return (bloc.classList != null && bloc.classList!.classData.length == 0) ||
            bloc.classList == null
        ? Column(
            children: [
              Row(
                children: [spaceW(20), classCategorySettingBar()],
              ),
              searchNone()
            ],
          )
        : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spaceW(20),
                  classCategorySettingBar(),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () {
                      if (bloc.orderType != 2) {
                        bloc.orderType = 2;
                        amplitudeEvent(
                            'class_order', {'page': 'search', 'type': 'cost'});
                        bloc.add(SearchReloadClassEvent());
                      }
                    },
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.only(left: 8, right: 8),
                      color: AppColors.white,
                      child: Center(
                        child: customText(
                            '가격 순${bloc.orderType == 2 ? ' ↓' : ''}',
                            style: TextStyle(
                                color: bloc.orderType == 2
                                    ? AppColors.gray900
                                    : AppColors.gray500,
                                fontWeight: weightSet(
                                    textWeight: bloc.orderType == 2
                                        ? TextWeight.BOLD
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.gray300,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bloc.orderType != 0) {
                        bloc.orderType = 0;
                        amplitudeEvent('class_order',
                            {'page': 'search', 'type': 'recent'});
                        bloc.add(SearchReloadClassEvent());
                      }
                    },
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.only(left: 8, right: 8),
                      color: AppColors.white,
                      child: Center(
                        child: customText(
                            '최신 순${bloc.orderType == 0 ? ' ↓' : ''}',
                            style: TextStyle(
                                color: bloc.orderType == 0
                                    ? AppColors.gray900
                                    : AppColors.gray500,
                                fontWeight: weightSet(
                                    textWeight: bloc.orderType == 0
                                        ? TextWeight.BOLD
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.gray300,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bloc.orderType != 1) {
                        amplitudeEvent(
                            'class_order', {'page': 'search', 'type': 'near'});
                        bloc.orderType = 1;
                        bloc.add(SearchReloadClassEvent());
                      }
                    },
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.only(left: 8, right: 0),
                      color: AppColors.white,
                      child: Center(
                        child: customText(
                            '가까운 순${bloc.orderType == 1 ? ' ↓' : ''}',
                            style: TextStyle(
                                color: bloc.orderType == 1
                                    ? AppColors.gray900
                                    : AppColors.gray500,
                                fontWeight: weightSet(
                                    textWeight: bloc.orderType == 1
                                        ? TextWeight.BOLD
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  ),
                  spaceW(20)
                ],
              ),
              spaceH(10),
              Flexible(
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(SearchReloadClassEvent());
                  },
                  backgroundColor: AppColors.white,
                  color: AppColors.primary,
                  child: ListView.builder(
                    itemBuilder: (context, idx) {
                      return Column(
                        children: [classListItem(idx), spaceH(20)],
                      );
                    },
                    controller: classController,
                    shrinkWrap: true,
                    itemCount: bloc.classList == null
                        ? 0
                        : bloc.classList!.classData.length,
                  ),
                ),
              ),
            ],
          );
  }

  classListItem(index) {
    return GestureDetector(
      onTap: () {
        if (bloc.classList!.classData[index].mineFlag != 1) {
          airbridgeEvent('class_view');
          classEvent(
              'totals_class_clicks',
              bloc.classList!.classData[index].classUuid,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .lati!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .longi!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sidoName!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sigunguName!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .eupmyeondongName!,
              firstFree:
                  bloc.classList!.classData[index].content.firstFreeFlag == 0
                      ? false
                      : true,
              group: bloc.classList!.classData[index].content.groupFlag == 0
                  ? false
                  : true,
              groupCost: bloc.classList!.classData[index].content.costOfPerson
                  .toString());
          classEvent(
              'class_clicks',
              bloc.classList!.classData[index].classUuid,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .lati!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .longi!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sidoName!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sigunguName!,
              dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .eupmyeondongName!,
              firstFree:
                  bloc.classList!.classData[index].content.firstFreeFlag == 0
                      ? false
                      : true,
              group: bloc.classList!.classData[index].content.groupFlag == 0
                  ? false
                  : true,
              groupCost: bloc.classList!.classData[index].content.costOfPerson
                  .toString());
        }
        ClassDetailPage classDetailPage = ClassDetailPage(
          heroTag: 'listImage$index',
          classUuid: bloc.classList!.classData[index].classUuid,
          mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
              .indexWhere((element) => element.representativeFlag == 1)],
          bloc: bloc,
          selectIndex: index,
          profileGet: dataSaver.nonMember ? null : dataSaver.profileGet,
          inputPage: 'main',
        );
        dataSaver.keywordClassDetail = classDetailPage;
        pushTransition(context, classDetailPage).then((value) {
          if (value != null) {
            bloc.add(SearchReloadClassEvent());
          }
        });
      },
      child: Container(
        color: AppColors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Row(
                children: [
                  customText(
                      '${double.parse(bloc.classList!.classData[index].content.distance).toString().split('.')[0].length > 3 ? '${(double.parse(bloc.classList!.classData[index].content.distance) / 1000) > 20 ? '20km+' : '${(double.parse(bloc.classList!.classData[index].content.distance) / 1000).toStringAsFixed(1)}km'} ${bloc.classList!.classData[index].content.hangNames.split(',')[0]}' : '${double.parse(bloc.classList!.classData[index].content.distance).toString().split('.')[0].length == 3 ? (double.parse(bloc.classList!.classData[index].content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(bloc.classList!.classData[index].content.distance).toString().split('.')[0]}m ${bloc.classList!.classData[index].content.hangNames.split(',')[0]}'}',
                      style: TextStyle(
                          color: AppColors.greenGray500,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                  spaceW(8),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.gray300,
                  ),
                  spaceW(8),
                  bloc.classList!.classData[index].member.profile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 16,
                            height: 16,
                            child: CacheImage(
                              imageUrl: bloc
                                  .classList!.classData[index].member.profile!,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            AppImages.dfProfile,
                            width: 16,
                            height: 16,
                          ),
                        ),
                  spaceW(4),
                  customText(
                      bloc.classList!.classData[index].member.nickName.length >
                              8
                          ? bloc.classList!.classData[index].member.nickName
                                  .substring(0, 8) +
                              "...·"
                          : bloc.classList!.classData[index].member.nickName +
                              "·",
                      style: TextStyle(
                          color: AppColors.gray500,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T11))),
                  customText(
                    DateTime.now()
                                .difference(bloc.classList!.classData[index]
                                    .content.createDate)
                                .inMinutes >
                            14400
                        ? bloc.classList!.classData[index].content.createDate
                            .yearMonthDay
                        : timeCalculationText(DateTime.now()
                            .difference(bloc
                                .classList!.classData[index].content.createDate)
                            .inMinutes),
                    style: TextStyle(
                        color: AppColors.gray500,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T11)),
                  ),
                  Expanded(
                      child: Container(
                    height: 30,
                  )),
                ],
              ),
              spaceH(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 128,
                      height: 72,
                      child: CacheImage(
                        imageUrl: bloc
                            .classList!.classData[index].content.image!
                            .toView(
                          context: context,
                        ),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 72,
                          decoration: BoxDecoration(
                              color: AppColors.gray200,
                              borderRadius: BorderRadius.circular(4)),
                          child: Image.asset(
                            AppImages.dfClassMain,
                            width: MediaQuery.of(context).size.width,
                            height: 72,
                          ),
                        ),
                      ),
                    ),
                  ),
                  spaceW(16),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(children: [
                                  customTextSpan(
                                      text: bloc.classList!.classData[index]
                                              .content.title! +
                                          " ",
                                      style: TextStyle(
                                          color: AppColors.gray900,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T14))),
                                  customTextSpan(
                                      text: bloc.classList!.classData[index]
                                          .content.category!.name!,
                                      style: TextStyle(
                                          color: AppColors.gray500,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T11))),
                                ]),
                              ),
                            )
                          ],
                        ),
                        spaceH(6),
                        Container(
                          height: 20,
                          child: bloc.classList!.classData[index].content
                                      .costType ==
                                  'HOUR'
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    bloc.classList!.classData[index].content
                                                .groupFlag ==
                                            1
                                        ? Row(
                                            children: [
                                              Container(
                                                height: 20,
                                                padding: EdgeInsets.only(
                                                    left: 6, right: 6),
                                                child: Center(
                                                    child: customText('그룹할인',
                                                        style: TextStyle(
                                                            color:
                                                                AppColors.white,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .BOLD),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T10)))),
                                                decoration: BoxDecoration(
                                                    color: AppColors.accent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                              ),
                                              spaceW(6)
                                            ],
                                          )
                                        : Container(),
                                    customText(
                                        '${numberFormatter(bloc.classList!.classData[index].content.groupFlag == 1 ? bloc.classList!.classData[index].content.costOfPerson : bloc.classList!.classData[index].content.minCost!)}원 ~',
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14)))
                                  ],
                                )
                              : customText('배움나눔',
                                  style: TextStyle(
                                      color: AppColors.secondaryDark30,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14))),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  exchangeList() {
    return (bloc.exchangeList != null &&
            bloc.exchangeList!.communityData.length == 0)
        ? searchNone()
        : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spaceW(20),
                  Expanded(
                    child: Container(),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bloc.exchangeOrderType != 0) {
                        bloc.exchangeOrderType = 0;
                        // amplitudeEvent('class_order',
                        //     {'page': 'search', 'type': 'recent'});
                        bloc.add(SearchReloadExchangeEvent());
                      }
                    },
                    child: Container(
                      height: 56,
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Center(
                        child: customText(
                            '최신 순${bloc.exchangeOrderType == 0 ? ' ↓' : ''}',
                            style: TextStyle(
                                color: bloc.exchangeOrderType == 0
                                    ? AppColors.gray900
                                    : AppColors.gray500,
                                fontWeight: weightSet(
                                    textWeight: bloc.exchangeOrderType == 0
                                        ? TextWeight.BOLD
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.gray300,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bloc.exchangeOrderType != 1) {
                        // amplitudeEvent(
                        //     'class_order', {'page': 'search', 'type': 'near'});
                        bloc.exchangeOrderType = 1;
                        bloc.add(SearchReloadExchangeEvent());
                      }
                    },
                    child: Container(
                      height: 56,
                      padding: EdgeInsets.only(left: 8, right: 0),
                      child: Center(
                        child: customText(
                            '가까운 순${bloc.exchangeOrderType == 1 ? ' ↓' : ''}',
                            style: TextStyle(
                                color: bloc.exchangeOrderType == 1
                                    ? AppColors.gray900
                                    : AppColors.gray500,
                                fontWeight: weightSet(
                                    textWeight: bloc.exchangeOrderType == 1
                                        ? TextWeight.BOLD
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  ),
                  spaceW(20)
                ],
              ),
              Flexible(
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(SearchReloadExchangeEvent());
                  },
                  backgroundColor: AppColors.white,
                  color: AppColors.primary,
                  child: ListView.builder(
                    itemBuilder: (context, idx) {
                      return communityItem(
                          bloc.exchangeList!.communityData[idx]);
                    },
                    shrinkWrap: true,
                    controller: exchangeController,
                    itemCount: bloc.exchangeList == null
                        ? 0
                        : bloc.exchangeList!.communityData.length,
                  ),
                ),
              ),
            ],
          );
  }

  withMeList() {
    return (bloc.withMeList != null &&
            bloc.withMeList!.communityData.length == 0)
        ? searchNone()
        : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spaceW(20),
                  Expanded(
                    child: Container(),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bloc.withMeOrderType != 0) {
                        bloc.withMeOrderType = 0;
                        // amplitudeEvent('class_order',
                        //     {'page': 'search', 'type': 'recent'});
                        bloc.add(SearchReloadWithMeEvent());
                      }
                    },
                    child: Container(
                      height: 56,
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Center(
                        child: customText(
                            '최신 순${bloc.withMeOrderType == 0 ? ' ↓' : ''}',
                            style: TextStyle(
                                color: bloc.withMeOrderType == 0
                                    ? AppColors.gray900
                                    : AppColors.gray500,
                                fontWeight: weightSet(
                                    textWeight: bloc.withMeOrderType == 0
                                        ? TextWeight.BOLD
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.gray300,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bloc.withMeOrderType != 1) {
                        // amplitudeEvent(
                        //     'class_order', {'page': 'search', 'type': 'near'});
                        bloc.withMeOrderType = 1;
                        bloc.add(SearchReloadWithMeEvent());
                      }
                    },
                    child: Container(
                      height: 56,
                      padding: EdgeInsets.only(left: 8, right: 0),
                      child: Center(
                        child: customText(
                            '가까운 순${bloc.withMeOrderType == 1 ? ' ↓' : ''}',
                            style: TextStyle(
                                color: bloc.withMeOrderType == 1
                                    ? AppColors.gray900
                                    : AppColors.gray500,
                                fontWeight: weightSet(
                                    textWeight: bloc.withMeOrderType == 1
                                        ? TextWeight.BOLD
                                        : TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                      ),
                    ),
                  ),
                  spaceW(20)
                ],
              ),
              Flexible(
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(SearchReloadWithMeEvent());
                  },
                  backgroundColor: AppColors.white,
                  color: AppColors.primary,
                  child: ListView.builder(
                    itemBuilder: (context, idx) {
                      return communityItem(bloc.withMeList!.communityData[idx]);
                    },
                    shrinkWrap: true,
                    controller: withMeController,
                    itemCount: bloc.withMeList == null
                        ? 0
                        : bloc.withMeList!.communityData.length,
                  ),
                ),
              ),
            ],
          );
  }

  communityItem(CommunityData communityData) {
    final span = TextSpan(
        text: communityData.content.contentText!,
        style: TextStyle(
            color: AppColors.greenGray500,
            fontWeight: weightSet(textWeight: TextWeight.BOLD),
            fontSize: fontSizeSet(textSize: TextSize.T12)));
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: MediaQuery.of(context).size.width - 32);

    List<Widget> teachView = [];
    List<Widget> learnView = [];
    List<Widget> meetView = [];

    if (communityData.content.category == 'EXCHANGE' &&
        (communityData.content.teachKeywordString != null &&
            communityData.content.learnKeywordString != null)) {
      List<String> teachTexts =
          communityData.content.teachKeywordString!.split(',');
      List<String> learnTexts =
          communityData.content.learnKeywordString!.split(',');
      for (int i = 0; i < teachTexts.length; i++) {
        teachView.add(RichText(
          text: TextSpan(
            children: [
              customTextSpan(
                  text: '#',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray100
                          : AppColors.primaryLight30,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              customTextSpan(
                  text: '${teachTexts[i]}',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray400
                          : AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15)))
            ],
          ),
        ));
      }
      for (int i = 0; i < learnTexts.length; i++) {
        learnView.add(RichText(
          text: TextSpan(
            children: [
              customTextSpan(
                  text: '#',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray100
                          : AppColors.accentLight30,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              customTextSpan(
                  text: '${learnTexts[i]}',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray400
                          : AppColors.accentDark10,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15)))
            ],
          ),
        ));
      }
    } else if (communityData.content.category == 'WITH_ME' &&
        communityData.content.meetKeywordString != null) {
      List<String> meetTexts =
          communityData.content.meetKeywordString!.split(',');
      for (int i = 0; i < meetTexts.length; i++) {
        meetView.add(RichText(
          text: TextSpan(
            children: [
              customTextSpan(
                  text: '#',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray100
                          : AppColors.primaryLight30,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              customTextSpan(
                  text: '${meetTexts[i]}',
                  style: TextStyle(
                      color: communityData.status == 'DONE'
                          ? AppColors.greenGray400
                          : AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15)))
            ],
          ),
        ));
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: GestureDetector(
        onTap: () {
          if (communityData.mineFlag == 0) {
            amplitudeEvent('community_clicks', {
              'type': communityTypeCreate(
                  communityTypeIdx(communityData.content.category)),
              'bookmark_count': communityData.likeCnt,
              'chat_count': communityData.chatCnt,
              'share_count': communityData.shareCnt,
              'view_count': communityData.readCnt,
              'comment_count': communityData.commentCnt,
              'user_id': communityData.member.memberUuid,
              'user_name': communityData.member.nickName,
              'community_id': communityData.communityUuid,
              'distance': communityData.content.distance,
              'status': communityData.status,
              'hang_name': communityData.content.hangNames
            });
          }
          pushTransition(
              context,
              CommunityDetailPage(
                communityUuid: communityData.communityUuid,
              ));
        },
        child: Column(
          children: [
            communityData.content.category == 'EXCHANGE' &&
                    (communityData.content.teachKeywordString != null &&
                        communityData.content.learnKeywordString != null)
                ? IntrinsicHeight(
                    child: Container(
                        decoration: BoxDecoration(
                          color: communityData.status == 'DONE'
                              ? AppColors.white.withOpacity(0.6)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 12, left: 12, right: 12, bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  customText('알려 드려요',
                                      style: TextStyle(
                                          color: AppColors.greenGray400,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12))),
                                  spaceH(6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          runSpacing: 4,
                                          spacing: 4,
                                          alignment: WrapAlignment.start,
                                          children: teachView,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                              spaceW(12),
                              Image.asset(
                                AppImages.iSwitch,
                                width: 20,
                                height: 20,
                              ),
                              spaceW(12),
                              Expanded(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  customText('배우고 싶어요',
                                      style: TextStyle(
                                          color: AppColors.greenGray400,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12))),
                                  spaceH(6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          runSpacing: 4,
                                          spacing: 4,
                                          alignment: WrapAlignment.end,
                                          children: learnView,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )),
                            ],
                          ),
                        )),
                  )
                : (communityData.content.category == 'WITH_ME' &&
                        communityData.content.meetKeywordString != null)
                    ? Container(
                        decoration: BoxDecoration(
                          color: communityData.status == 'DONE'
                              ? AppColors.white.withOpacity(0.6)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 12, left: 12, right: 12, bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Wrap(
                                  runSpacing: 4,
                                  spacing: 4,
                                  children: meetView,
                                ),
                              ),
                            ],
                          ),
                        ))
                    : Container(),
            spaceH(1),
            Container(
              decoration: BoxDecoration(
                color: communityData.status == 'DONE'
                    ? AppColors.white.withOpacity(0.6)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                            (communityData.content.contentText!
                                        .split('\n')
                                        .length >
                                    2)
                                ? '${communityData.content.contentText!.split('\n')[0].toString() + '\n' + communityData.content.contentText!.split('\n')[1] + '\n' + communityData.content.contentText!.split('\n')[2]}' +
                                    '${tp.computeLineMetrics().length > 2 ? '⋯' : ''}'
                                : communityData.content.contentText!,
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.REGULAR),
                                fontSize: fontSizeSet(textSize: TextSize.T14)),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                        spaceH(20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            customText(
                                '${double.parse(communityData.content.distance).toString().split('.')[0].length > 3 ? '${(double.parse(communityData.content.distance) / 1000) > 20 ? '20km+' : '${(double.parse(communityData.content.distance) / 1000).toStringAsFixed(1)}km'}' : '${double.parse(communityData.content.distance).toString().split('.')[0].length == 3 ? (double.parse(communityData.content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(communityData.content.distance).toString().split('.')[0]}m'} ${communityData.content.hangNames.split(',')[0]}',
                                style: TextStyle(
                                    color: AppColors.greenGray500,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T12))),
                            spaceW(8),
                            Container(
                              width: 1,
                              height: 8,
                              color: AppColors.gray300,
                            ),
                            spaceW(8),
                            communityData.member.profile == null
                                ? Image.asset(
                                    AppImages.dfProfile,
                                    width: 16,
                                    height: 16,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      child: CacheImage(
                                        imageUrl: communityData.member.profile!,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                            spaceW(4),
                            customText(
                                communityData.member.nickName.length > 8
                                    ? communityData.member.nickName
                                            .substring(0, 8) +
                                        "..."
                                    : communityData.member.nickName,
                                style: TextStyle(
                                    color: AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T11))),
                            customText(
                                '·${DateTime.now().difference(communityData.content.createDate).inMinutes > 14400 ? communityData.content.createDate.yearMonthDay : timeCalculationText(DateTime.now().difference(communityData.content.createDate).inMinutes)}',
                                style: TextStyle(
                                    color: AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T11)))
                          ],
                        ),
                        spaceH(12),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: AppColors.gray200,
                  ),
                  spaceH(12),
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        customText('조회 ${communityData.readCnt}',
                            style: TextStyle(
                                color: AppColors.gray600,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                        spaceW(10),
                        Image.asset(
                          AppImages.iChatG,
                          width: 16,
                          height: 16,
                        ),
                        spaceW(4),
                        customText(
                            '${communityData.commentCnt == 0 ? '댓글달기' : communityData.commentCnt} >',
                            style: TextStyle(
                                color: AppColors.gray600,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12)))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is SearchInitState) {
      bloc.selectTypeIndex = widget.keywordDetailType ?? 0;
      if (!dataSaver.keyword) {
        dataSaver.searchBloc = bloc;
      } else {
        if (dataSaver.searchText.length != 0) {
          bloc.search = true;
          bloc.searchController.text = dataSaver.searchText;
          bloc.add(SearchEvent());
        } else {
          dataSaver.searchBloc = bloc;
        }
      }
      setState(() {});
    }

    if (state is SaveFilterState) {
      if (bloc.learnType == 0) {
        bloc.add(SearchReloadClassEvent());
      } else if (bloc.learnType == 1) {}
    }

    if (state is NeighborHoodChangeState) {
      if (bloc.search) {
        bloc.add(SearchReloadClassEvent());
        bloc.add(SearchReloadExchangeEvent());
        bloc.add(SearchReloadWithMeEvent());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    dataSaver.searchBloc = bloc;

    classController = ScrollController()
      ..addListener(() {
        if (classController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.bottomOffset = 0;
          bloc.scrollUnder = false;
        }
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < classController!.offset) &&
            classController!.offset >=
                classController!.position.maxScrollExtent &&
            !classController!.position.outOfRange) {
          bloc.scrollUnder = true;
          bloc.bottomOffset = classController!.offset;
        }
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < classController!.offset) &&
            classController!.offset >=
                (classController!.position.maxScrollExtent * 0.7) &&
            !classController!.position.outOfRange) {
          bloc.add(NewSearchDataEvent());
        }
      });

    exchangeController = ScrollController()
      ..addListener(() {
        if (exchangeController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.exchangeBottomOffset = 0;
          bloc.exchangeScrollUnder = false;
        }
        if (!bloc.exchangeScrollUnder &&
            (bloc.exchangeBottomOffset == 0 ||
                bloc.exchangeBottomOffset < exchangeController!.offset) &&
            exchangeController!.offset >=
                exchangeController!.position.maxScrollExtent &&
            !exchangeController!.position.outOfRange) {
          bloc.exchangeScrollUnder = true;
          bloc.exchangeBottomOffset = exchangeController!.offset;
        }
        if (!bloc.exchangeScrollUnder &&
            (bloc.exchangeBottomOffset == 0 ||
                bloc.exchangeBottomOffset < exchangeController!.offset) &&
            exchangeController!.offset >=
                (exchangeController!.position.maxScrollExtent * 0.7) &&
            !exchangeController!.position.outOfRange) {
          bloc.add(NewSearchDataEvent());
        }
      });

    withMeController = ScrollController()
      ..addListener(() {
        if (withMeController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.withMeBottomOffset = 0;
          bloc.withMeScrollUnder = false;
        }
        if (!bloc.withMeScrollUnder &&
            (bloc.withMeBottomOffset == 0 ||
                bloc.withMeBottomOffset < withMeController!.offset) &&
            withMeController!.offset >=
                withMeController!.position.maxScrollExtent &&
            !withMeController!.position.outOfRange) {
          bloc.withMeScrollUnder = true;
          bloc.withMeBottomOffset = withMeController!.offset;
        }
        if (!bloc.withMeScrollUnder &&
            (bloc.withMeBottomOffset == 0 ||
                bloc.withMeBottomOffset < withMeController!.offset) &&
            withMeController!.offset >=
                (withMeController!.position.maxScrollExtent * 0.7) &&
            !withMeController!.position.outOfRange) {
          bloc.add(NewSearchDataEvent());
        }
      });
  }

  @override
  SearchBloc initBloc() {
    return SearchBloc(context)
      ..add(SearchInitEvent(learnType: widget.learnType));
  }
}
