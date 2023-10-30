import 'dart:convert';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_edit_repository.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/cupertino.dart';

class NeighborHoodSelectBloc extends BaseBloc {
  NeighborHoodSelectBloc(BuildContext context)
      : super(BaseNeighborHoodSelectState());

  bool loading = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is NeighborHoodSelectInitEvent) {
      yield NeighborHoodSelectInitState();
    }

    if (event is NeighborHoodSelectEvent) {
      loading = true;
      yield LoadingState();
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

      amplitudeEvent('town_change', {
        'town_sido': dataSaver.neighborHood[dataSaver
            .neighborHood.indexWhere((element) =>
        element.representativeFlag == 1)].sidoName,
        'town_sigungu': dataSaver.neighborHood[dataSaver
            .neighborHood.indexWhere((element) =>
        element.representativeFlag == 1)].sigunguName,
        'town_dongeupmyeon': dataSaver
            .neighborHood[dataSaver
            .neighborHood.indexWhere((element) =>
        element.representativeFlag == 1)].eupmyeondongName,
        'inflow_page': 'keyword_set'
      });

      loading = false;
      yield NeighborHoodSelectCheckState();
    }

    if (event is NeighborHoodRemoveEvent) {
      loading = true;
      yield LoadingState();

      if (!dataSaver.nonMember) {
        ReturnData returnData =
            await NeighborHoodEditRepository.neighborHoodRemove(
                event.memberAreaUuid);

        bool select = false;

        if (returnData.code == 1) {
          loading = false;
          if (dataSaver.neighborHood[event.idx].representativeFlag == 1) {
            select = true;
          }
          dataSaver.neighborHood.removeAt(event.idx);
          if (select) {
            await NeighborHoodSelectRepository.setNeighborHoodRepresentative(
                dataSaver.neighborHood[0].memberAreaUuid!);
            dataSaver.neighborHood[0].representativeFlag = 1;
          }
          dataSaver.learnBloc!.add(NeighborHoodChangeEvent(
              index: dataSaver.neighborHood
                  .indexWhere((element) =>
              element.representativeFlag == 1)));
          await identifyInit();
          yield NeighborHoodRemoveState();
        } else {
          loading = false;
          yield ErrorState();
        }
      } else {
        bool select = false;
        if (dataSaver.neighborHood[event.idx].representativeFlag == 1) {
          select = true;
        }
        dataSaver.neighborHood.removeAt(event.idx);
        if (select) {
          dataSaver.neighborHood[0].representativeFlag = 1;
        }
        await identifyInit();
        List<String> data = [];

        for (int i = 0; i < dataSaver.neighborHood.length; i++) {
          data.add(jsonEncode(dataSaver.neighborHood[i].toMapAll()));
        }
        await prefs!.setString('guestNeighborHood', jsonEncode(data));
        dataSaver.learnBloc!.add(NeighborHoodChangeEvent(
            index: dataSaver.neighborHood
                .indexWhere((element) =>
            element.representativeFlag == 1)));
        loading = false;
        yield NeighborHoodRemoveState();
      }
    }

    if (event is NeighborHoodEditEvent) {
      dataSaver.neighborHood[event.idx] = event.neighborHood;
      await identifyInit();
      yield NeighborHoodEditState();
    }
  }
}

class NeighborHoodEditEvent extends BaseBlocEvent {
  final NeighborHood neighborHood;
  final int idx;

  NeighborHoodEditEvent({required this.neighborHood, required this.idx});
}

class NeighborHoodEditState extends BaseBlocState {}

class NeighborHoodRemoveEvent extends BaseBlocEvent {
  final String memberAreaUuid;
  final int idx;

  NeighborHoodRemoveEvent({required this.memberAreaUuid, required this.idx});
}

class NeighborHoodRemoveState extends BaseBlocState {}

class NeighborHoodSelectEvent extends BaseBlocEvent {
  final int index;

  NeighborHoodSelectEvent({required this.index});
}

class NeighborHoodSelectCheckState extends BaseBlocState {}

class NeighborHoodSelectInitEvent extends BaseBlocEvent {}

class NeighborHoodSelectInitState extends BaseBlocState {}

class BaseNeighborHoodSelectState extends BaseBlocState {}
