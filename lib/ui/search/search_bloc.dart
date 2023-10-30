import 'dart:async';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/repository/community_repository.dart';
import 'package:baeit/data/keyword/keyword.dart';
import 'package:baeit/data/keyword/repository/keyword_repository.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/widgets.dart';

class SearchBloc extends BaseBloc {
  SearchBloc(BuildContext context) : super(BaseSearchState()) {
    on<SearchInitEvent>(onSearchInitEvent);
    on<MostSearchRemoveAllEvent>(onMostSearchRemoveAllEvent);
    on<SearchEvent>(onSearchEvent);
    on<NewSearchDataEvent>(onNewSearchDataEvent);
    on<SearchReloadClassEvent>(onSearchReloadClassEvent);
    on<SaveFilterEvent>(onSaveFilterEvent);
    on<FilterSetAllEvent>(onFilterSetAllEvent);
    on<NeighborHoodSelecterViewOpenEvent>(onNeighborHoodSelecterViewOpenEvent);
    on<NeighborHoodChangeEvent>(onNeighborHoodChangeEvent);
    on<SelectTypeEvent>(onSelectTypeEvent);
    on<GetKeywordEvent>(onGetKeywordEvent);
    on<SetKeywordEvent>(onSetKeywordEvent);
    on<SearchReloadExchangeEvent>(onSearchReloadExchangeEvent);
    on<SearchReloadWithMeEvent>(onSearchReloadWithMeEvent);
    on<ViewLoadEvent>(onViewLoadEvent);
  }

  bool loading = false;

  bool search = false;

  int learnType = 0;

  TextEditingController searchController = TextEditingController();
  List<String> mostSearchList = [];
  ClassList? classList;

  bool neighborhoodSelecterView = false;
  bool neighborhoodSelecterAnimationEnd = true;

  List<bool> openFilterValues = [];
  List<bool> filterValues = [];

  List<String> openFilterData = [];
  List<String> filterData = [];
  List<String> filterItemName = [];
  List<String> filterItemCheckImage = [];
  List<String> filterItemUnCheckImage = [];

  bool saveIng = false;
  bool categoryFilter = false;

  int selectTypeIndex = 0;

  Keyword? keyword;

  bool setKeywordAlarmView = false;
  Timer? setKeywordAlarmViewTimer;

  String searchText = '';

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

  // Class
  double bottomOffset = 0;
  bool scrollUnder = false;

  bool scrollUp = true;
  bool scrollEnd = false;

  bool startScroll = false;
  bool upDownCheck = false;
  double startPixels = 0;

  int nextData = 1;

  int orderType = 1;

  //

  // exchange
  int exchangeOrderType = 1;

  String exchangeLastCursor = '';

  double exchangeBottomOffset = 0;
  bool exchangeScrollUnder = false;

  bool exchangeScrollUp = true;
  bool exchangeScrollEnd = false;

  bool exchangeStartScroll = false;
  bool exchangeUpDownCheck = false;
  double exchangeStartPixels = 0;

  int exchangeNextData = 1;

  CommunityList? exchangeList;

  //

  // with  me
  int withMeOrderType = 1;

  String withMeLastCursor = '';

  double withMeBottomOffset = 0;
  bool withMeScrollUnder = false;

  bool withMeScrollUp = true;
  bool withMeScrollEnd = false;

  bool withMeStartScroll = false;
  bool withMeUpDownCheck = false;
  double withMeStartPixels = 0;

  int withMeNextData = 1;

  CommunityList? withMeList;

  //

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

    loading = false;
    emit(NeighborHoodChangeState());
  }

  onSearchReloadClassEvent(SearchReloadClassEvent event, emit) async {
    nextData = 1;
    scrollEnd = false;
    classList = null;
    loading = true;
    emit(LoadingState());

    ReturnData returnData = await ClassRepository.getMapClass(
        categories: dataSaver.keyword
            ? filterData.join(",")
            : dataSaver.learnBloc!.filterData.join(","),
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati!,
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi!,
        orderType: orderType == 2
            ? 3
            : orderType == 0
                ? 2
                : 1,
        type: 'MADE',
        searchText: searchController.text == '' ? searchText : searchController.text);
    search = true;

    if (returnData.code == 1) {
      classList = ClassList.fromJson(returnData.data);

      loading = false;
      emit(SearchReloadClassState());
    } else {
      loading = false;
      emit(ErrorState());
    }
  }

  onNewSearchDataEvent(NewSearchDataEvent event, emit) async {
    if (selectTypeIndex == 0) {
      if (classList!.classData.length == nextData * 20 &&
          !scrollUnder &&
          dataSaver.lastNextCursor != classList!.classData.last.cursor) {
        scrollUnder = true;
        emit(CheckState());

        dataSaver.lastNextCursor = classList!.classData.last.cursor!;

        ReturnData returnData = await ClassRepository.getMapClass(
            categories: dataSaver.keyword
                ? filterData.join(",")
                : dataSaver.learnBloc!.filterData.join(","),
            lati: dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .lati!,
            longi: dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .longi!,
            orderType: orderType == 2
                ? 3
                : orderType == 0
                    ? 2
                    : 1,
            searchText: searchController.text,
            nextCursor: classList!.classData.last.cursor,
            type: 'MADE');

        if (returnData.code == 1) {
          classList!.classData
              .addAll(ClassList.fromJson(returnData.data).classData );

          nextData += 1;
          scrollUnder = false;
          emit(NewSearchDataState());
        }
      }
    } else if (selectTypeIndex == 1) {
      if (exchangeList!.communityData.length == exchangeNextData * 20 &&
          !exchangeScrollUnder &&
          exchangeLastCursor != exchangeList!.communityData.last.cursor) {
        exchangeScrollUnder = true;

        exchangeLastCursor = exchangeList!.communityData.last.cursor;

        ReturnData exchangeRes = await CommunityRepository.getCommunity(
            lati: dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .lati!,
            longi: dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .longi!,
            orderType: exchangeOrderType == 0 ? 2 : 1,
            category: 'EXCHANGE',
            nextCursor: exchangeLastCursor,
            searchText: searchController.text);

        exchangeList!.communityData
            .addAll(CommunityList.fromJson(exchangeRes.data).communityData);
        exchangeNextData += 1;
        exchangeScrollUnder = false;
        emit(NewSearchDataState());
      }
    } else if (selectTypeIndex == 2) {
      if (withMeList!.communityData.length == withMeNextData * 20 &&
          !withMeScrollUnder &&
          withMeLastCursor != withMeList!.communityData.last.cursor) {
        withMeScrollUnder = true;

        withMeLastCursor = withMeList!.communityData.last.cursor;

        ReturnData withMeRes = await CommunityRepository.getCommunity(
            lati: dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .lati!,
            longi: dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .longi!,
            orderType: withMeOrderType == 0 ? 2 : 1,
            category: 'WITH_ME',
            nextCursor: withMeLastCursor,
            searchText: searchController.text);

        withMeList!.communityData
            .addAll(CommunityList.fromJson(withMeRes.data).communityData);
        withMeNextData += 1;
        withMeScrollUnder = false;
        emit(NewSearchDataState());
      }
    }
  }

  onMostSearchRemoveAllEvent(MostSearchRemoveAllEvent event, emit) async {
    mostSearchList.clear();
    mostSearchList = [];
    await prefs!.remove('mostSearch');

    emit(MostSearchRemoveAllState());
  }

  onSearchEvent(SearchEvent event, emit) async {
    nextData = 1;
    scrollEnd = false;
    classList = null;

    exchangeNextData = 1;
    exchangeScrollEnd = false;
    exchangeList = null;

    withMeNextData = 1;
    withMeScrollEnd = false;
    withMeList = null;

    loading = true;
    searchText = searchController.text;
    emit(LoadingState());

    if (!event.mostSearch) {
      if (mostSearchList
              .indexWhere((element) => element == searchController.text) ==
          -1) {
        if (mostSearchList.length < 20) {
          mostSearchList.add(searchController.text);
          await prefs!.setStringList('mostSearch', mostSearchList);
        } else {
          mostSearchList.removeAt(0);
          mostSearchList.add(searchController.text);
          await prefs!.setStringList('mostSearch', mostSearchList);
        }
      } else {
        mostSearchList.removeAt(mostSearchList
            .indexWhere((element) => element == searchController.text));
        mostSearchList.insert(mostSearchList.length, searchController.text);
        await prefs!.setStringList('mostSearch', mostSearchList);
      }
    } else {
      mostSearchList.removeAt(mostSearchList
          .indexWhere((element) => element == searchController.text));
      mostSearchList.insert(mostSearchList.length, searchController.text);
      await prefs!.setStringList('mostSearch', mostSearchList);
    }

    ReturnData returnData = await ClassRepository.getMapClass(
        categories: dataSaver.keyword
            ? filterData.join(",")
            : dataSaver.learnBloc!.filterData.join(","),
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati!,
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi!,
        orderType: orderType == 2
            ? 3
            : orderType == 0
                ? 2
                : 1,
        searchText: searchController.text,
        type: 'MADE');

    classList = ClassList.fromJson(returnData.data);

    ReturnData exchangeRes = await CommunityRepository.getCommunity(
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati!,
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi!,
        category: 'EXCHANGE',
        orderType: exchangeOrderType == 0 ? 2 : 1,
        searchText: searchController.text);

    exchangeList = CommunityList.fromJson(exchangeRes.data);

    ReturnData withMeRes = await CommunityRepository.getCommunity(
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati!,
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi!,
        category: 'WITH_ME',
        orderType: withMeOrderType == 0 ? 2 : 1,
        searchText: searchController.text);

    withMeList = CommunityList.fromJson(withMeRes.data);

    if ((keyword!.keywords.indexWhere(
            (element) => element.keywordText == searchController.text) ==
        -1)) {
      setKeywordAlarmView = false;
      if (setKeywordAlarmViewTimer != null) {
        setKeywordAlarmViewTimer!.cancel();
      }

      if (selectTypeIndex == 0) {
        if (classList != null && classList!.classData.length != 0) {
          setKeywordAlarmView = true;
        }
      } else if (selectTypeIndex == 1) {
        if (exchangeList != null && exchangeList!.communityData.length != 0) {
          setKeywordAlarmView = true;
        }
      } else if (selectTypeIndex == 2) {
        if (withMeList != null && withMeList!.communityData.length != 0) {
          setKeywordAlarmView = true;
        }
      }
      if (setKeywordAlarmView) {
        setKeywordAlarmViewTimer = Timer(Duration(milliseconds: 5000), () {
          setKeywordAlarmView = false;
          add(ViewLoadEvent());
        });
      }
    } else {
      setKeywordAlarmView = false;
      if (setKeywordAlarmViewTimer != null) {
        setKeywordAlarmViewTimer!.cancel();
      }
    }

    search = true;
    loading = false;
    emit(SearchState());
  }

  onSearchInitEvent(SearchInitEvent event, emit) {
    learnType = event.learnType;

    filterValues = List.generate(dataSaver.category.length, (index) => true);

    if (dataSaver.classFilterValues != null) {
      filterValues = [];
      filterValues.addAll(dataSaver.classFilterValues!);
    }

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

    if (prefs!.getStringList('mostSearch') != null &&
        prefs!.getStringList('mostSearch')!.length != 0) {
      mostSearchList.addAll(prefs!.getStringList('mostSearch')!);
    }

    add(GetKeywordEvent());
    emit(SearchInitState());
  }

  onNeighborHoodSelecterViewOpenEvent(
      NeighborHoodSelecterViewOpenEvent event, emit) {
    neighborhoodSelecterView = true;
    neighborhoodSelecterAnimationEnd = false;
    emit(NeighborHoodSelecterViewOpenState());
  }

  onSaveFilterEvent(SaveFilterEvent event, emit) {
    saveIng = false;
    openFilterValues = filterValues;
    openFilterData = filterData;
    emit(SaveFilterState());
  }

  onFilterSetAllEvent(FilterSetAllEvent event, emit) {
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
  }

  onSelectTypeEvent(SelectTypeEvent event, emit) {
    selectTypeIndex = event.idx;
    emit(SelectTypeState());
  }

  onGetKeywordEvent(GetKeywordEvent event, emit) async {
    keyword = Keyword.fromJson(
        (await KeywordRepository.getKeywordAlarm(type: 'MADE')).data);
    dataSaver.classKeywordNotification = keyword;
    emit(GetKeywordState());
  }

  onSetKeywordEvent(SetKeywordEvent event, emit) async {
    await KeywordRepository.addKeywordAlarm(
        type: 'MADE', keywordText: event.keyword);

    add(GetKeywordEvent());
    emit(SetKeywordState());
  }

  onSearchReloadExchangeEvent(SearchReloadExchangeEvent event, emit) async {
    exchangeNextData = 1;
    exchangeScrollEnd = false;
    exchangeList = null;
    loading = true;
    emit(LoadingState());

    ReturnData exchangeRes = await CommunityRepository.getCommunity(
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati!,
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi!,
        category: 'EXCHANGE',
        orderType: exchangeOrderType == 0 ? 2 : 1,
        searchText: searchController.text == '' ? searchText : searchController.text);

    exchangeList = CommunityList.fromJson(exchangeRes.data);

    search = true;
    loading = false;
    emit(SearchReloadExchangeState());
  }

  onSearchReloadWithMeEvent(SearchReloadWithMeEvent event, emit) async {
    withMeNextData = 1;
    withMeScrollEnd = false;
    withMeList = null;
    loading = true;
    emit(LoadingState());

    ReturnData withMeRes = await CommunityRepository.getCommunity(
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati!,
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi!,
        category: 'WITH_ME',
        orderType: withMeOrderType == 0 ? 2 : 1,
        searchText: searchController.text == '' ? searchText : searchController.text);

    withMeList = CommunityList.fromJson(withMeRes.data);

    search = true;
    loading = false;
    emit(SearchReloadWithMeState());
  }

  onViewLoadEvent(ViewLoadEvent event, emit) {
    emit(ViewLoadState());
  }
}

class ViewLoadEvent extends BaseBlocEvent {}

class ViewLoadState extends BaseBlocState {}

class SearchReloadExchangeEvent extends BaseBlocEvent {}

class SearchReloadExchangeState extends BaseBlocState {}

class SearchReloadWithMeEvent extends BaseBlocEvent {}

class SearchReloadWithMeState extends BaseBlocState {}

class SetKeywordEvent extends BaseBlocEvent {
  final String keyword;

  SetKeywordEvent({required this.keyword});
}

class SetKeywordState extends BaseBlocState {}

class GetKeywordEvent extends BaseBlocEvent {}

class GetKeywordState extends BaseBlocState {}

class SelectTypeEvent extends BaseBlocEvent {
  final int idx;

  SelectTypeEvent({required this.idx});
}

class SelectTypeState extends BaseBlocState {}

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

class NeighborHoodSelecterViewOpenEvent extends BaseBlocEvent {}

class NeighborHoodSelecterViewOpenState extends BaseBlocState {}

class SearchReloadClassEvent extends BaseBlocEvent {}

class SearchReloadClassState extends BaseBlocState {}

class NewSearchDataEvent extends BaseBlocEvent {}

class NewSearchDataState extends BaseBlocState {}

class MostSearchRemoveAllEvent extends BaseBlocEvent {}

class MostSearchRemoveAllState extends BaseBlocState {}

class SearchEvent extends BaseBlocEvent {
  final bool mostSearch;

  SearchEvent({this.mostSearch = false});
}

class SearchState extends BaseBlocState {}

class SearchInitEvent extends BaseBlocEvent {
  final int learnType;

  SearchInitEvent({required this.learnType});
}

class SearchInitState extends BaseBlocState {}

class BaseSearchState extends BaseBlocState {}
