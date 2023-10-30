import 'dart:async';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/neighborhood/neighborhood_add.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_add_repository.dart';
import 'package:flutter/cupertino.dart';

class NeighborHoodAddBloc extends BaseBloc {
  NeighborHoodAddBloc(BuildContext context) : super(BaseNeighborHoodAddState());

  bool loading = false;

  AddressData? addressData;
  List<Juso> juso = [];
  String searchKeyword = '';
  bool myLocation = false;
  AddressPointData? addressPointData;
  bool search = false;
  bool searching = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is NeighborHoodAddInitEvent) {
      yield NeighborHoodAddInitState();
    }

    if (event is NeighborHoodSearchEvent) {
      loading = true;
      yield LoadingState();
      search = true;
      addressData =
          await NeighborHoodAddRepository.getAddressData(event.keyword);

      searchKeyword = event.keyword;

      if (addressData!.results.common.errorMessage != "정상") {
        juso = [];
        loading = false;
        yield LoadingState();
        return;
      }

      juso = addressData!.results.juso;
      loading = false;
      yield NeighborHoodSearchState();
    }

    if (event is NeighborHoodMyLocationEvent) {
      addressPointData = await NeighborHoodAddRepository.getAddressPointData(
          event.lat, event.lon);

      myLocation = true;
      if (addressPointData!.address != null) {
        searchKeyword = addressPointData!.address!.region3depthName!;
      }

      loading = false;
      yield NeighborHoodMyLocationState();
    }

    if (event is GetCreateAreaEvent) {
      loading = true;
      yield LoadingState();
      late AddressDetailData addressDetailData;
      if (myLocation) {
        addressDetailData =
            await NeighborHoodAddRepository.getAddressDetailData(
                addressPointData!.roadAddress == null
                    ? addressPointData!.address!.addressName!
                    : addressPointData!.roadAddress!.addressName!);
      } else {
        addressDetailData =
            await NeighborHoodAddRepository.getAddressDetailData(
                juso[event.idx!].roadAddr != null
                    ? juso[event.idx!].roadAddr!
                    : juso[event.idx!].jibunAddr!);
      }

      NeighborHood neighborHood = NeighborHood(
          lati: addressDetailData.lat,
          longi: addressDetailData.lon,
          roadAddress: addressDetailData.roadAddress == null
              ? null
              : addressDetailData.roadAddress!.addressName,
          buildingName: addressDetailData.roadAddress == null
              ? null
              : addressDetailData.roadAddress!.buildingName,
          hangName: addressDetailData.address.region3depthHName,
          zipAddress: addressDetailData.address.addressName,
          hangCode: addressDetailData.address.hCode,
          sidoName: addressDetailData.address.region1depthName,
          sigunguName: addressDetailData.address.region2depthName,
          eupmyeondongName: addressDetailData.address.region3depthHName);

      loading = false;
      yield GetCreateAreaState(neighborHood: neighborHood);
    }
  }
}

class GetCreateAreaEvent extends BaseBlocEvent {
  final int? idx;

  GetCreateAreaEvent({this.idx});
}

class GetCreateAreaState extends BaseBlocState {
  final NeighborHood neighborHood;

  GetCreateAreaState({required this.neighborHood});
}

class NeighborHoodMyLocationEvent extends BaseBlocEvent {
  final String lat;
  final String lon;

  NeighborHoodMyLocationEvent({required this.lat, required this.lon});
}

class NeighborHoodMyLocationState extends BaseBlocState {}

class NeighborHoodSearchEvent extends BaseBlocEvent {
  final String keyword;

  NeighborHoodSearchEvent({required this.keyword});
}

class NeighborHoodSearchState extends BaseBlocState {}

class NeighborHoodAddInitEvent extends BaseBlocEvent {}

class NeighborHoodAddInitState extends BaseBlocState {}

class BaseNeighborHoodAddState extends BaseBlocState {}
