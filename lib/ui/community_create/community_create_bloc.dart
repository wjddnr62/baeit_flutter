import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/community/community_create.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/community/repository/community_repository.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/my_create_community/my_create_community_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class CommunityCreateBloc extends BaseBloc {
  CommunityCreateBloc(BuildContext context)
      : super(BaseCommunityCreateState()) {
    on<CommunityCreateInitEvent>(onCommunityCreateInitEvent);
    on<CommunityTypeSelectEvent>(onCommunityTypeSelectEvent);
    on<CommunityTypeViewEvent>(onCommunityTypeViewEvent);
    on<CommunityGetFileEvent>(onCommunityGetFileEvent);
    on<CommunitySaveEvent>(onCommunitySaveEvent);
    on<CommunitySaveTempEvent>(onCommunitySaveTempEvent);
  }

  bool loading = false;
  int communityType = 0;
  bool typeHide = true;
  List<NeighborHood> neighborHoodList = [];
  List<Asset> imageFiles = [];
  CommunityDetail? communityDetail;
  List<Data> imageRes = [];
  String? communityUuid;

  List<TextEditingController> informController =
      List.generate(5, (index) => TextEditingController());
  List<TextEditingController> learnController =
      List.generate(5, (index) => TextEditingController());
  List<TextEditingController> meetController =
      List.generate(5, (index) => TextEditingController());

  onCommunityCreateInitEvent(CommunityCreateInitEvent event, emit) async {
    communityType = event.type;
    neighborHoodList.addAll(dataSaver.neighborHood);

    if (event.edit) {
      loading = true;
      emit(LoadingState());
      ReturnData detailRes = await CommunityRepository.getCommunityDetail(
          communityUuid: event.communityUuid!,
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
          readFlag: 0);

      communityDetail = CommunityDetail.fromJson(detailRes.data);
      communityType = communityTypeIdx(communityDetail!.content.category);

      neighborHoodList.clear();
      neighborHoodList = [];
      for (int i = 0; i < communityDetail!.content.areas.length; i++) {
        NeighborHood neighborHood = NeighborHood(
            buildingName: communityDetail!.content.areas[i].buildingName,
            hangName: communityDetail!.content.areas[i].hangName,
            hangCode: communityDetail!.content.areas[i].hangCode,
            lati: communityDetail!.content.areas[i].lati,
            longi: communityDetail!.content.areas[i].longi,
            zipAddress: communityDetail!.content.areas[i].zipAddress,
            roadAddress: communityDetail!.content.areas[i].roadAddress,
            sidoName: communityDetail!.content.areas[i].sidoName,
            sigunguName: communityDetail!.content.areas[i].sigunguName,
            eupmyeondongName:
                communityDetail!.content.areas[i].eupmyeondongName);
        neighborHoodList.add(neighborHood);
      }

      loading = false;
    }
    emit(CommunityCreateInitState());
  }

  onCommunityTypeSelectEvent(CommunityTypeSelectEvent event, emit) {
    communityType = event.idx;
    emit(CommunityTypeSelectState());
  }

  onCommunityTypeViewEvent(CommunityTypeViewEvent event, emit) {
    if (typeHide) {
      typeHide = false;
    } else {
      typeHide = true;
    }
    emit(CommunityTypeViewState());
  }

  onCommunityGetFileEvent(CommunityGetFileEvent event, emit) {
    emit(CommunityGetFileState());
  }

  onCommunitySaveEvent(CommunitySaveEvent event, emit) async {
    ReturnData res = await CommunityRepository.communityRegistration(
        communityCreate: event.communityCreate);

    dataSaver.learnBloc!.add(CommunityReloadEvent());
    if (dataSaver.myCreateCommunityBloc != null) {
      dataSaver.myCreateCommunityBloc!.add(StatusChangeEvent());
    }

    if (res.data != null && res.code == 1) {
      loading = false;
      emit(CommunitySaveState(communityUuid: res.data));
    } else {
      loading = false;
      emit(ErrorState());
    }
  }

  onCommunitySaveTempEvent(CommunitySaveTempEvent event, emit) async {
    ReturnData res = await CommunityRepository.communityRegistration(
        communityCreate: event.communityCreate);

    communityUuid = res.data;

    dataSaver.learnBloc!.add(CommunityReloadEvent());
    if (dataSaver.myCreateCommunityBloc != null) {
      dataSaver.myCreateCommunityBloc!.add(StatusChangeEvent());
    }

    if (res.data != null && res.code == 1) {
      loading = false;
      emit(CommunitySaveTempState());
    } else {
      loading = false;
      emit(ErrorState());
    }
  }
}

class CommunitySaveEvent extends BaseBlocEvent {
  final CommunityCreate communityCreate;

  CommunitySaveEvent({required this.communityCreate});
}

class CommunitySaveState extends BaseBlocState {
  final String communityUuid;

  CommunitySaveState({required this.communityUuid});
}

class CommunitySaveTempEvent extends BaseBlocEvent {
  final CommunityCreate communityCreate;

  CommunitySaveTempEvent({required this.communityCreate});
}

class CommunitySaveTempState extends BaseBlocState {}

class CommunityGetFileEvent extends BaseBlocEvent {}

class CommunityGetFileState extends BaseBlocState {}

class CommunityTypeSelectEvent extends BaseBlocEvent {
  final int idx;

  CommunityTypeSelectEvent({required this.idx});
}

class CommunityTypeSelectState extends BaseBlocState {}

class CommunityTypeViewEvent extends BaseBlocEvent {}

class CommunityTypeViewState extends BaseBlocState {}

class CommunityCreateInitEvent extends BaseBlocEvent {
  final int type;
  final bool edit;
  final String? communityUuid;

  CommunityCreateInitEvent(
      {required this.type, this.edit = false, this.communityUuid});
}

class CommunityCreateInitState extends BaseBlocState {}

class BaseCommunityCreateState extends BaseBlocState {}
