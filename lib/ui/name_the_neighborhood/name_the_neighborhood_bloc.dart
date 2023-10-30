import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/common/repository/common_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_add.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_add_repository.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_edit_repository.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class NameTheNeighborHoodBloc extends BaseBloc {
  NameTheNeighborHoodBloc(BuildContext context)
      : super(BaseNameTheNeighborHoodState());

  bool loading = false;
  NeighborHood? neighborHood;
  bool signUpEnd = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is NameTheNeighborHoodInitEvent) {
      signUpEnd = event.signUpEnd;
      yield NameTheNeighborHoodInitState();
    }

    if (event is NameSaveEvent) {
      loading = true;
      yield LoadingState();

      if (event.edit) {
        if (!dataSaver.nonMember) {
          ReturnData returnData =
              await NeighborHoodEditRepository.neighborHoodNameEdit(
                  event.neighborHood!.memberAreaUuid!, event.townName);

          if (returnData.code == 1) {
            event.neighborHood!.townName = event.townName;
            loading = false;
            yield NameSaveState(neighborHood: event.neighborHood!);
          }
        } else {
          event.neighborHood!.townName = event.townName;
          loading = false;
          yield NameSaveState(neighborHood: event.neighborHood!);
        }
      } else {
        AddressDetailData addressDetailData =
            await NeighborHoodAddRepository.getAddressDetailData(
                event.myLocation
                    ? event.addressPointData!.roadAddress == null
                        ? event.addressPointData!.address!.addressName!
                        : event.addressPointData!.roadAddress!.addressName!
                    : (event.addressPointData != null &&
                                event.addressPointData!.roadAddress != null) &&
                            !event.myLocation
                        ? event.juso!.roadAddr!
                        : event.juso!.jibunAddr!);

        ReturnData addressInfoRes = await CommonRepository.getAddressInfo(
            addressDetailData.address.hCode!);

        NeighborHood neighborHood = NeighborHood(
            townName: event.townName,
            lati: addressDetailData.lat,
            longi: addressDetailData.lon,
            roadAddress: addressDetailData.roadAddress == null
                ? null
                : addressDetailData.roadAddress!.addressName,
            buildingName: addressDetailData.roadAddress == null
                ? null
                : addressDetailData.roadAddress!.buildingName,
            zipAddress: addressDetailData.address.addressName,
            hangName: addressDetailData.address.region3depthHName,
            hangCode: addressDetailData.address.hCode,
            addressEupmyeondongNo: addressInfoRes.data['addressEupmyeondongNo'],
            sidoName: addressDetailData.address.region1depthName,
            sigunguName: addressDetailData.address.region2depthName,
            eupmyeondongName: addressDetailData.address.region3depthHName);

        if (!signUpEnd) {
          dataSaver.clear();
          await prefs!.remove('guest');
          await prefs!.remove('guestNeighborHood');
          ReturnData returnData =
              await NeighborHoodAddRepository.neighborHoodAdd(neighborHood);

          if (returnData.code == 1) {
            await NeighborHoodSelectRepository.setNeighborHoodRepresentative(
                NeighborHood.fromJson(returnData.data).memberAreaUuid!);
            this.neighborHood = NeighborHood.fromJson(returnData.data);
            loading = false;
            yield NameSaveState();
          } else {
            debugPrint(
                "NeighborHoodAddError : ${returnData.code}, ${returnData.message}, ${returnData.data}");
            loading = false;
            yield ErrorState();
          }
          return;
        }

        if (!dataSaver.nonMember) {
          ReturnData returnData =
              await NeighborHoodAddRepository.neighborHoodAdd(neighborHood);

          if (returnData.code == 1) {
            if (!signUpEnd) {
              await NeighborHoodSelectRepository.setNeighborHoodRepresentative(
                  NeighborHood.fromJson(returnData.data).memberAreaUuid!);
            }
            this.neighborHood = NeighborHood.fromJson(returnData.data);
            loading = false;
            yield NameSaveState();
          } else {
            debugPrint(
                "NeighborHoodAddError : ${returnData.code}, ${returnData.message}, ${returnData.data}");
            loading = false;
            yield ErrorState();
          }
        } else {
          this.neighborHood = neighborHood;
          loading = false;
          yield NameSaveState();
        }
      }
    }
  }
}

class NameSaveEvent extends BaseBlocEvent {
  final String townName;
  final Juso? juso;
  final AddressPointData? addressPointData;
  final bool myLocation;
  final bool edit;
  final NeighborHood? neighborHood;

  NameSaveEvent(
      {required this.townName,
      this.juso,
      this.addressPointData,
      required this.myLocation,
      required this.edit,
      this.neighborHood});
}

class NameSaveState extends BaseBlocState {
  final NeighborHood? neighborHood;

  NameSaveState({this.neighborHood});
}

class NameTheNeighborHoodInitEvent extends BaseBlocEvent {
  final bool signUpEnd;

  NameTheNeighborHoodInitEvent({required this.signUpEnd});
}

class NameTheNeighborHoodInitState extends BaseBlocState {}

class BaseNameTheNeighborHoodState extends BaseBlocState {}
