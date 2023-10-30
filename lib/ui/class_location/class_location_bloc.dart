import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class_area.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:uuid/uuid.dart';

class ClassLocationBloc extends BaseBloc {
  ClassLocationBloc(BuildContext context) : super(BaseClassLocationState()) {
    on<ClassLocationInitEvent>(onClassLocationInitEvent);
  }

  bool loading = false;
  ClassArea? classArea;
  List<Marker> markers = [];

  categoryImage(categorySet) {
    switch (categorySet) {
      case 'CAREER':
        return AppImages.pinNearCareer;
      case 'HOBBY':
        return AppImages.pinNearHobby;
      case 'HOME_BASED':
        return AppImages.pinNearNJob;
      case 'HEALTH':
        return AppImages.pinNearSports;
      case 'LANGUAGE':
        return AppImages.pinNearLanguage;
      case 'CERTIFICATE':
        return AppImages.pinNearTest;
      case 'LESSON':
        return AppImages.pinNearLesson;
      case 'LIFE':
        return AppImages.pinNearLife;
      case 'ETC':
        return AppImages.pinNearEtc;
    }
  }

  onClassLocationInitEvent(ClassLocationInitEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    ReturnData returnData = await ClassRepository.getClassArea(
        classUuid: event.classUuid, lati: event.lati, longi: event.longi);

    classArea = ClassArea.fromJson(returnData.data);

    await OverlayImage.fromAssetImage(
            assetName: categoryImage(classArea!.classCategoryId))
        .then((value) {
      markers.add(Marker(
          markerId: Uuid().v4(),
          icon: value,
          width: 64,
          height: 64,
          anchor: AnchorPoint(0.5, 0.5),
          position: LatLng(double.parse(classArea!.areas![0].lati),
              double.parse(classArea!.areas![0].longi))));

      loading = false;
      emit(ClassLocationInitState());
    });
  }
}

class ClassLocationInitEvent extends BaseBlocEvent {
  final String classUuid;
  final String lati;
  final String longi;

  ClassLocationInitEvent(
      {required this.classUuid, required this.lati, required this.longi});
}

class ClassLocationInitState extends BaseBlocState {}

class BaseClassLocationState extends BaseBlocState {}
