import 'dart:convert';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/cheer/cheering.dart';
import 'package:baeit/data/cheer/repository/cheer_repository.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/cupertino.dart';

class NeighborHoodClassBloc extends BaseBloc {
  NeighborHoodClassBloc(BuildContext context)
      : super(BaseNeighborHoodClassState());

  bool isLoading = false;

  int sliderSelectValue = 3;
  int distanceSelectValue = 3;
  int openValue = 3;
  bool saveIng = false;

  bool panelOpen = false;

  double bottomOffset = 0;
  bool scrollUnder = false;

  bool scrollUp = true;
  bool scrollEnd = false;

  bool startScroll = false;
  bool upDownCheck = false;
  double startPixels = 0;

  bool floatingAnimationEnd = true;

  bool specifyNeighborhoodOpen = false;
  bool filterOpen = false;

  List<bool> bookmarkChecks = [];
  List<AnimationController> animationControllers = [];

  bool getCheering = true;

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

  List<bool> openFilterValues = [];
  List<bool> filterValues = [];

  List<String> filterData = [];
  List<String> filterItemName = [];
  List<String> filterItemCheckImage = [];
  List<String> filterItemUnCheckImage = [];

  bool notContainArea = false;

  bool search = false;

  NeighborHood? mainNeighborHood;

  dynamic vsync;

  int? mineClassCnt;
  int nextData = 1;

  bool categoryFilter = false;
  bool view = false;

  setDefaultData() {
    sliderSelectValue = 3;
    filterValues = List.generate(dataSaver.category.length, (index) => true);
    setPublicData();
  }

  setPublicData() {
    dataSaver.classFilterValues = [];
    dataSaver.classFilterValues!.addAll(filterValues);
    dataSaver.sliderSelectValue = sliderSelectValue;
  }

  Cheering? cheeringData;
  bool cheerFinish = false;
  String share = '';

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // if (event is NeighborHoodClassInitEvent) {
    //   isLoading = true;
    //   search = false;
    //   yield LoadingState();
    //
    //   CommonRepository.getShortLink().then((value) {
    //     share = value.data;
    //   });
    //
    //   if (!dataSaver.nonMember) {
    //     ClassRepository.getMineClassList(type: 'MADE', status: 'NORMAL')
    //         .then((value) {
    //       mineClassCnt = ClassList.fromJson(value.data).classData.length;
    //     });
    //   }
    //
    //   if (dataSaver.category.length == 0) {
    //     ReturnData categoryData = await ClassRepository.getCategory();
    //
    //     dataSaver.category = (categoryData.data as List)
    //         .map((e) => Category.fromJson(e))
    //         .toList();
    //   }
    //
    //   filterValues = List.generate(dataSaver.category.length, (index) => true);
    //   if (dataSaver.classFilterValues != null) {
    //     filterValues = [];
    //     filterValues.addAll(dataSaver.classFilterValues!);
    //   }
    //   if (dataSaver.sliderSelectValue != null) {
    //     sliderSelectValue = dataSaver.sliderSelectValue!;
    //     distanceSelectValue = dataSaver.sliderSelectValue!;
    //     openValue = dataSaver.sliderSelectValue!;
    //   }
    //   setPublicData();
    //
    //   for (int i = 0; i < dataSaver.category.length; i++) {
    //     filterData.add(dataSaver.category[i].classCategoryId!);
    //     filterItemName.add(dataSaver.category[i].name!);
    //     filterItemCheckImage
    //         .add(filterCheckImage(dataSaver.category[i].classCategoryId));
    //     filterItemUnCheckImage
    //         .add(filterUnCheckImage(dataSaver.category[i].classCategoryId));
    //   }
    //
    //   filterData = [];
    //   for (int i = 0; i < filterValues.length; i++) {
    //     if (filterValues[i]) {
    //       filterData.add(dataSaver.category[i].classCategoryId!);
    //     }
    //   }
    //
    //   vsync = event.animationVsync;
    //
    //   if (prefs!.getBool('guest') != null &&
    //       prefs!.getString('guestNeighborHood') != null &&
    //       prefs!.getString('guestNeighborHood') != '') {
    //     List data = jsonDecode(prefs!.getString('guestNeighborHood')!);
    //     dataSaver.neighborHood =
    //         data.map((e) => NeighborHood.fromJson(jsonDecode(e))).toList();
    //     await identifyInit();
    //   }
    //
    //   if (dataSaver.neighborHood.length == 0) {
    //     if (!dataSaver.nonMember) {
    //       ReturnData returnData =
    //           await NeighborHoodSelectRepository.getNeighborHoodList();
    //       for (dynamic data in returnData.data) {
    //         dataSaver.neighborHood.add(NeighborHood.fromJson(data));
    //       }
    //     } else {
    //       ReturnData returnData =
    //           await NeighborHoodSelectRepository.nonMemberArea();
    //       dataSaver.neighborHood.add(NeighborHood.fromJson(returnData.data));
    //
    //       List<String> data = [];
    //
    //       for (int i = 0; i < dataSaver.neighborHood.length; i++) {
    //         data.add(jsonEncode(dataSaver.neighborHood[i].toMapAll()));
    //       }
    //       await prefs!.setString('guestNeighborHood', jsonEncode(data));
    //     }
    //   }
    //
    //   mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
    //       .indexWhere((element) => element.representativeFlag == 1)];
    //
    //   if (event.keyword && dataSaver.keyword) {
    //     dataSaver.keyword = false;
    //     setDefaultData();
    //     search = true;
    //     if (mainNeighborHood!.addressEupmyeondongNo != null) {
    //       CheerRepository.getCheering(mainNeighborHood!.addressEupmyeondongNo!)
    //           .then((value) {
    //         if ((value != null && value.code == 1)) {
    //           this.cheeringData = null;
    //           this.cheeringData = Cheering.fromJson(value.data);
    //           if (value.data == null) {
    //             notContainArea = false;
    //           } else {
    //             if (this.cheeringData!.cheeringCnt >=
    //                 this.cheeringData!.goalCnt) {
    //               cheerFinish = true;
    //             }
    //             notContainArea = true;
    //           }
    //         }
    //         getCheering = false;
    //         add(SetStateEvent());
    //       });
    //     }
    //   } else {
    //     if (dataSaver.neighborHoodClass == null) {
    //       ReturnData returnData = await ClassRepository.getClassList(GetClass(
    //           categories: filterData.join(","),
    //           lati: mainNeighborHood!.lati.toString(),
    //           longi: mainNeighborHood!.longi.toString(),
    //           orderType: 1,
    //           radiusType: sliderSelectValue + 1,
    //           type: 'MADE'));
    //
    //       if (returnData.code == 1) {
    //         dataSaver.neighborHoodClass = ClassList.fromJson(returnData.data);
    //
    //         for (int i = 0;
    //             i < dataSaver.neighborHoodClass!.classData.length;
    //             i++) {
    //           bookmarkChecks.add(false);
    //           animationControllers
    //               .add(AnimationController(vsync: event.animationVsync));
    //         }
    //
    //         if (mainNeighborHood!.addressEupmyeondongNo != null) {
    //           CheerRepository.getCheering(
    //                   mainNeighborHood!.addressEupmyeondongNo!)
    //               .then((value) {
    //             if ((value != null && value.code == 1)) {
    //               this.cheeringData = null;
    //               if (value.data == null) {
    //                 notContainArea = false;
    //               } else {
    //                 this.cheeringData = Cheering.fromJson(value.data);
    //                 if (this.cheeringData!.cheeringCnt >=
    //                     this.cheeringData!.goalCnt) {
    //                   cheerFinish = true;
    //                 }
    //                 notContainArea = true;
    //               }
    //             }
    //             getCheering = false;
    //             add(SetStateEvent());
    //           });
    //         }
    //       }
    //     } else {
    //       for (int i = 0;
    //           i < dataSaver.neighborHoodClass!.classData.length;
    //           i++) {
    //         bookmarkChecks.add(false);
    //         animationControllers
    //             .add(AnimationController(vsync: event.animationVsync));
    //       }
    //
    //       if (mainNeighborHood!.addressEupmyeondongNo != null) {
    //         CheerRepository.getCheering(
    //                 mainNeighborHood!.addressEupmyeondongNo!)
    //             .then((value) {
    //           if ((value != null && value.code == 1)) {
    //             this.cheeringData = null;
    //             this.cheeringData = Cheering.fromJson(value.data);
    //             if (value.data == null) {
    //               notContainArea = false;
    //             } else {
    //               if (this.cheeringData!.cheeringCnt >=
    //                   this.cheeringData!.goalCnt) {
    //                 cheerFinish = true;
    //               }
    //               notContainArea = true;
    //             }
    //           }
    //           getCheering = false;
    //           add(SetStateEvent());
    //         });
    //       }
    //     }
    //   }
    //
    //   view = true;
    //   isLoading = false;
    //   yield NeighborHoodClassInitState();
    // }
    //
    // if (event is SliderValueChangeEvent) {
    //   sliderSelectValue = event.value!;
    //   yield SliderValueChangeState();
    // }
    //
    // if (event is SaveDistanceEvent) {
    //   sliderSelectValue = event.value!;
    //   distanceSelectValue = event.value!;
    //   yield SaveDistanceState();
    // }
    //
    // if (event is OpenSpecifyNeighborhoodRadiusEvent) {
    //   openValue = event.value!;
    //   yield OpenSpecifyNeighborhoodRadiusState();
    // }
    //
    // if (event is PanelOpenEvent) {
    //   panelOpen = event.open!;
    //   yield PanelOpenState();
    // }
    //
    // if (event is ScrollEvent) {
    //   scrollUp = event.scroll!;
    //   yield ScrollState();
    // }
    //
    // if (event is BookmarkEvent) {
    //   if (event.flag == 0) {
    //     bookmarkChecks[event.index!] = true;
    //     dataSaver.neighborHoodClass!.classData[event.index!].likeFlag = 1;
    //     dataSaver.neighborHoodClass!.classData[event.index!].likeCnt =
    //         dataSaver.neighborHoodClass!.classData[event.index!].likeCnt + 1;
    //   } else {
    //     bookmarkChecks[event.index!] = false;
    //     dataSaver.neighborHoodClass!.classData[event.index!].likeFlag = 0;
    //     dataSaver.neighborHoodClass!.classData[event.index!].likeCnt =
    //         dataSaver.neighborHoodClass!.classData[event.index!].likeCnt - 1;
    //   }
    //
    //   yield CheckState();
    //
    //   await ClassRepository.bookmarkClass(
    //       dataSaver.neighborHoodClass!.classData[event.index!].classUuid);
    //
    //   yield BookmarkState();
    // }
    //
    // if (event is BookmarkAnimationEvent) {
    //   if (event.flag == 0) {
    //     bookmarkChecks[event.index] = false;
    //     dataSaver.neighborHoodClass!.classData[event.index].likeFlag = 0;
    //     dataSaver.neighborHoodClass!.classData[event.index].likeCnt =
    //         dataSaver.neighborHoodClass!.classData[event.index].likeCnt - 1;
    //     animationControllers[event.index].reset();
    //   } else {
    //     bookmarkChecks[event.index] = true;
    //     dataSaver.neighborHoodClass!.classData[event.index].likeFlag = 1;
    //     dataSaver.neighborHoodClass!.classData[event.index].likeCnt =
    //         dataSaver.neighborHoodClass!.classData[event.index].likeCnt + 1;
    //     animationControllers[event.index].forward();
    //   }
    //   yield BookmarkAnimationState();
    // }
    //
    // if (event is FilterSetAllEvent) {
    //   if (event.check) {
    //     filterData = [];
    //     for (int i = 0; i < dataSaver.category.length; i++) {
    //       filterValues[i] = true;
    //       filterData.add(dataSaver.category[i].classCategoryId!);
    //     }
    //   } else {
    //     filterData = [];
    //     for (int i = 0; i < dataSaver.category.length - 1; i++) {
    //       filterValues[i + 1] = false;
    //     }
    //     filterData.add(dataSaver.category[0].classCategoryId!);
    //   }
    //   yield FilterSetAllState();
    // }
    //
    // if (event is ScrollEndEvent) {
    //   scrollEnd = true;
    //   yield ScrollEndState();
    // }
    //
    // if (event is GetDataEvent) {
    //   if (dataSaver.neighborHoodClass!.classData.length == nextData * 20) {
    //     yield CheckState();
    //     ReturnData returnData = await ClassRepository.getClassList(GetClass(
    //         categories: filterData.join(","),
    //         lati: mainNeighborHood!.lati.toString(),
    //         longi: mainNeighborHood!.longi.toString(),
    //         orderType: 1,
    //         nextCursor: dataSaver.neighborHoodClass!.classData.last.cursor,
    //         radiusType: sliderSelectValue + 1,
    //         type: 'MADE'));
    //
    //     if (returnData.code == 1) {
    //       int index = dataSaver.neighborHoodClass!.classData.length;
    //       dataSaver.neighborHoodClass!.classData.insertAll(
    //           dataSaver.neighborHoodClass!.classData.length,
    //           ClassList.fromJson(returnData.data).classData);
    //
    //       for (int i = 0;
    //           i < dataSaver.neighborHoodClass!.classData.length - nextData * 20;
    //           i++) {
    //         bookmarkChecks.add(false);
    //         animationControllers.add(AnimationController(vsync: vsync));
    //       }
    //
    //       nextData += 1;
    //       scrollEnd = false;
    //       yield GetDataState(
    //           index: index,
    //           offset: ClassList.fromJson(returnData.data).classData.length);
    //     } else {
    //       yield ErrorState();
    //     }
    //   }
    // }
    //
    // if (event is CheeringEvent) {
    //   if (cheeringData!.selfCheeringFlag != 1) {
    //     isLoading = true;
    //     yield LoadingState();
    //
    //     ReturnData returnData =
    //         await CheerRepository.cheering(cheeringData!.cheeringAreaUuid);
    //     if (returnData.code == 1) {
    //       ReturnData? cheeringData =
    //           mainNeighborHood!.addressEupmyeondongNo == null
    //               ? null
    //               : await CheerRepository.getCheering(
    //                   mainNeighborHood!.addressEupmyeondongNo!);
    //
    //       if (cheeringData != null && cheeringData.code == 1) {
    //         this.cheeringData = null;
    //         cheerFinish = false;
    //         this.cheeringData = Cheering.fromJson(cheeringData.data);
    //         if (this.cheeringData!.cheeringCnt >= this.cheeringData!.goalCnt) {
    //           cheerFinish = true;
    //         }
    //         isLoading = false;
    //         yield CheeringState(uuid: returnData.data);
    //       } else {
    //         isLoading = false;
    //         yield ErrorState();
    //       }
    //     }
    //   } else {
    //     yield CheeringDuplicateState();
    //   }
    // }
    //
    // if (event is SearchViewEvent) {
    //   search = event.search;
    //   yield SearchViewState();
    // }
    //
    // if (event is SearchEvent) {
    //   yield SearchState();
    // }
    //
    // if (event is SaveFilterEvent) {
    //   saveIng = false;
    //   yield SaveFilterState();
    // }
    //
    // if (event is NeighborHoodChangeEvent) {
    //   dataSaver.neighborHood = event.neighborHood;
    //   await identifyInit();
    //   isLoading = true;
    //   yield LoadingState();
    //
    //   mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
    //       .indexWhere((element) => element.representativeFlag == 1)];
    //
    //   ReturnData returnData = await ClassRepository.getClassList(GetClass(
    //       categories: filterData.join(","),
    //       lati: mainNeighborHood!.lati.toString(),
    //       longi: mainNeighborHood!.longi.toString(),
    //       orderType: 1,
    //       radiusType: sliderSelectValue + 1,
    //       type: 'MADE'));
    //
    //   ReturnData cheeringData = await CheerRepository.getCheering(
    //       mainNeighborHood!.addressEupmyeondongNo!);
    //
    //   if (returnData.code == 1 && cheeringData.code == 1) {
    //     dataSaver.neighborHoodClass = ClassList.fromJson(returnData.data);
    //     if (cheeringData.data != null) {
    //       this.cheeringData = null;
    //       cheerFinish = false;
    //       this.cheeringData = Cheering.fromJson(cheeringData.data);
    //       if (this.cheeringData!.cheeringCnt >= this.cheeringData!.goalCnt) {
    //         cheerFinish = true;
    //       }
    //     }
    //
    //     for (int i = 0;
    //         i < dataSaver.neighborHoodClass!.classData.length;
    //         i++) {
    //       bookmarkChecks.add(false);
    //       animationControllers.add(AnimationController(vsync: vsync!));
    //     }
    //
    //     if (cheeringData.data == null) {
    //       notContainArea = false;
    //     } else {
    //       notContainArea = true;
    //     }
    //   }
    //
    //   isLoading = false;
    //   yield NeighborHoodChangeState();
    // }
    //
    // if (event is ReloadClassEvent) {
    //   nextData = 1;
    //   scrollEnd = false;
    //   cheerFinish = false;
    //   isLoading = true;
    //   yield LoadingState();
    //
    //   dataSaver.neighborHoodClass = null;
    //   animationControllers = [];
    //   bookmarkChecks = [];
    //
    //   mainNeighborHood = dataSaver.neighborHood[dataSaver.neighborHood
    //       .indexWhere((element) => element.representativeFlag == 1)];
    //
    //   ReturnData returnData = await ClassRepository.getClassList(GetClass(
    //       categories: filterData.join(","),
    //       lati: mainNeighborHood!.lati.toString(),
    //       longi: mainNeighborHood!.longi.toString(),
    //       orderType: 1,
    //       searchText: search ? event.search : '',
    //       radiusType: sliderSelectValue + 1,
    //       type: 'MADE'));
    //
    //   if (returnData.code == 1) {
    //     dataSaver.neighborHoodClass = ClassList.fromJson(returnData.data);
    //     if (!dataSaver.nonMember) {
    //       ReturnData mineClassRes = await ClassRepository.getMineClassList(
    //           type: 'MADE', status: 'NORMAL');
    //       mineClassCnt = ClassList.fromJson(mineClassRes.data).classData.length;
    //     }
    //
    //     ReturnData? cheeringData =
    //         mainNeighborHood!.addressEupmyeondongNo == null
    //             ? null
    //             : await CheerRepository.getCheering(
    //                 mainNeighborHood!.addressEupmyeondongNo!);
    //
    //     if (cheeringData != null && cheeringData.code == 1) {
    //       if (cheeringData.data == null) {
    //         notContainArea = false;
    //       } else {
    //         this.cheeringData = null;
    //         this.cheeringData = Cheering.fromJson(cheeringData.data);
    //         if (this.cheeringData!.cheeringCnt >= this.cheeringData!.goalCnt) {
    //           cheerFinish = true;
    //         }
    //         notContainArea = true;
    //       }
    //     }
    //
    //     for (int i = 0;
    //         i < dataSaver.neighborHoodClass!.classData.length;
    //         i++) {
    //       bookmarkChecks.add(false);
    //       animationControllers.add(AnimationController(vsync: vsync!));
    //     }
    //
    //     isLoading = false;
    //     yield ReloadClassState();
    //   } else {
    //     isLoading = false;
    //     yield ErrorState();
    //   }
    // }
    //
    // if (event is ClassSearchEvent) {
    //   isLoading = true;
    //   yield LoadingState();
    //
    //   dataSaver.neighborHoodClass = null;
    //   animationControllers = [];
    //   bookmarkChecks = [];
    //
    //   ReturnData returnData = await ClassRepository.getClassList(GetClass(
    //       categories: filterData.join(","),
    //       lati: mainNeighborHood!.lati.toString(),
    //       longi: mainNeighborHood!.longi.toString(),
    //       orderType: 1,
    //       radiusType: sliderSelectValue + 1,
    //       searchText: event.search,
    //       type: 'MADE'));
    //
    //   if (returnData.code == 1) {
    //     dataSaver.neighborHoodClass = ClassList.fromJson(returnData.data);
    //
    //     for (int i = 0;
    //         i < dataSaver.neighborHoodClass!.classData.length;
    //         i++) {
    //       bookmarkChecks.add(false);
    //       animationControllers.add(AnimationController(vsync: vsync!));
    //     }
    //
    //     isLoading = false;
    //     yield ReloadClassState();
    //   } else {
    //     isLoading = false;
    //     yield ErrorState();
    //   }
    // }
    //
    // if (event is ScrollUpEvent) {
    //   yield ScrollUpState();
    // }
    //
    // if (event is SetStateEvent) {
    //   yield SetStateState();
    // }
  }
}

class SetStateEvent extends BaseBlocEvent {}

class SetStateState extends BaseBlocState {}

class CheeringDuplicateState extends BaseBlocState {}

class ScrollUpEvent extends BaseBlocEvent {}

class ScrollUpState extends BaseBlocState {}

class ClassSearchEvent extends BaseBlocEvent {
  final String search;

  ClassSearchEvent({required this.search});
}

class ClassSearchState extends BaseBlocState {}

class ReloadClassEvent extends BaseBlocEvent {
  final String? search;

  ReloadClassEvent({this.search});
}

class ReloadClassState extends BaseBlocState {}

class NeighborHoodChangeEvent extends BaseBlocEvent {
  final List<NeighborHood> neighborHood;

  NeighborHoodChangeEvent({required this.neighborHood});
}

class NeighborHoodChangeState extends BaseBlocState {}

class SaveFilterEvent extends BaseBlocEvent {}

class SaveFilterState extends BaseBlocState {}

class SearchEvent extends BaseBlocEvent {}

class SearchState extends BaseBlocState {}

class SearchViewEvent extends BaseBlocEvent {
  final bool search;

  SearchViewEvent({required this.search});
}

class SearchViewState extends BaseBlocState {}

class CheeringEvent extends BaseBlocEvent {}

class CheeringState extends BaseBlocState {
  final String uuid;

  CheeringState({required this.uuid});
}

class GetDataEvent extends BaseBlocEvent {
  final GlobalKey<AnimatedListState> key;

  GetDataEvent({required this.key});
}

class GetDataState extends BaseBlocState {
  final int? index;
  final int? offset;

  GetDataState({this.index, this.offset});
}

class ScrollEndEvent extends BaseBlocEvent {}

class ScrollEndState extends BaseBlocState {}

class FilterSetValueEvent extends BaseBlocEvent {
  final int? index;
  final bool? value;

  FilterSetValueEvent({this.index, this.value});
}

class FilterSetValueState extends BaseBlocState {}

class FilterSetAllEvent extends BaseBlocEvent {
  final bool check;

  FilterSetAllEvent({required this.check});
}

class FilterSetAllState extends BaseBlocState {}

class BookmarkAnimationEvent extends BaseBlocEvent {
  final int index;
  final int flag;

  BookmarkAnimationEvent({required this.index, required this.flag});
}

class BookmarkAnimationState extends BaseBlocState {}

class BookmarkEvent extends BaseBlocEvent {
  final int? index;
  final int flag;
  final bool? bookmark;

  BookmarkEvent({this.index, required this.flag, this.bookmark});
}

class BookmarkState extends BaseBlocState {}

class ScrollEvent extends BaseBlocEvent {
  final bool? scroll;

  ScrollEvent({this.scroll});
}

class ScrollState extends BaseBlocState {}

class PanelOpenEvent extends BaseBlocEvent {
  final bool? open;

  PanelOpenEvent({this.open});
}

class PanelOpenState extends BaseBlocState {}

class OpenSpecifyNeighborhoodRadiusEvent extends BaseBlocEvent {
  final int? value;

  OpenSpecifyNeighborhoodRadiusEvent({this.value});
}

class OpenSpecifyNeighborhoodRadiusState extends BaseBlocState {}

class SaveDistanceEvent extends BaseBlocEvent {
  final int? value;

  SaveDistanceEvent({this.value});
}

class SaveDistanceState extends BaseBlocState {}

class SliderValueChangeEvent extends BaseBlocEvent {
  final int? value;

  SliderValueChangeEvent({this.value});
}

class SliderValueChangeState extends BaseBlocState {}

class NeighborHoodClassInitEvent extends BaseBlocEvent {
  final dynamic animationVsync;
  final bool keyword;

  NeighborHoodClassInitEvent({this.animationVsync, required this.keyword});
}

class NeighborHoodClassInitState extends BaseBlocState {}

class BaseNeighborHoodClassState extends BaseBlocState {}
