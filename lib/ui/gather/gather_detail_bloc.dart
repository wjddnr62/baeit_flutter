import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/widgets.dart';

class GatherDetailBloc extends BaseBloc {
  BuildContext? context;

  GatherDetailBloc(BuildContext context) : super(BaseGatherDetailState()) {
    this.context = context;
    on<GatherDetailInitEvent>(onGatherDetailInitEvent);
    on<NewDataEvent>(onNewDataEvent);
    on<ImageLoadEvent>(onImageLoadEvent);
  }

  bool loading = false;
  String curationThemeUuid = '';
  ClassList? themeData;

  double bottomOffset = 0;
  bool scrollUnder = false;
  int nextData = 1;

  String lastCursor = '';
  bool getData = true;

  onGatherDetailInitEvent(GatherDetailInitEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    curationThemeUuid = event.curationThemeUuid;

    ReturnData themeRes = await ClassRepository.getClassThemeDetail(
        curationThemeUuid: curationThemeUuid,
        lati: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .lati
            .toString(),
        longi: dataSaver
            .neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)]
            .longi
            .toString());

    themeData = ClassList.fromJson(themeRes.data);

    loading = false;
    emit(GatherDetailInitState());
  }

  onNewDataEvent(NewDataEvent event, emit) async {
    if (themeData!.classData.length == nextData * 10 &&
        !scrollUnder &&
        lastCursor != themeData!.classData.last.cursor &&
        getData) {
      getData = false;
      Future.delayed(Duration(milliseconds: 1000), () {
        getData = true;
      });
      scrollUnder = true;
      // emit(CheckState());

      lastCursor = themeData!.classData.last.cursor!;

      ReturnData themeRes = await ClassRepository.getClassThemeDetail(
          curationThemeUuid: curationThemeUuid,
          lati: dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .lati
              .toString(),
          longi: dataSaver
              .neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)]
              .longi
              .toString(),
          cursor: lastCursor);

      themeData!.classData.addAll(ClassList.fromJson(themeRes.data).classData);
      nextData += 1;
      scrollUnder = false;
      emit(NewDataState());
    }
  }

  onImageLoadEvent(ImageLoadEvent event, emit) {
    emit(ImageLoadState());
  }
}

class ImageLoadEvent extends BaseBlocEvent {}

class ImageLoadState extends BaseBlocState {}

class NewDataEvent extends BaseBlocEvent {}

class NewDataState extends BaseBlocState {}

class GatherDetailInitEvent extends BaseBlocEvent {
  final String curationThemeUuid;

  GatherDetailInitEvent({required this.curationThemeUuid});
}

class GatherDetailInitState extends BaseBlocState {}

class BaseGatherDetailState extends BaseBlocState {}
