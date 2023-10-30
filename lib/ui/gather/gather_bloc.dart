import 'dart:convert';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/class_theme.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/widgets.dart';

class GatherBloc extends BaseBloc {
  GatherBloc(BuildContext context) : super(BaseGatherState()) {
    on<GatherInitEvent>(onGatherInitEvent);
    on<BookmarkClassHideEvent>(onBookmarkClassHideEvent);
    on<BookmarkReloadEvent>(onBookmarkReloadEvent);
  }

  bool getData = false;

  bool loading = false;
  List<ClassTheme> classTheme = [];
  ClassList? bookmarkClass;

  onGatherInitEvent(GatherInitEvent event, emit) async {
    if (!getData) {
      getData = true;
      if (event.loading) {
        loading = true;
        emit(LoadingState());
      }
      if (!dataSaver.nonMember) {
        ReturnData bookmarkClassData =
            await ClassRepository.getBookmarkClassList(type: 'MADE', size: 10);
        bookmarkClass = null;
        bookmarkClass = ClassList.fromJson(bookmarkClassData.data);
      }

      if (dataSaver.nonMember) {
        if (dataSaver.neighborHood.length == 0) {
          ReturnData returnData =
              await NeighborHoodSelectRepository.nonMemberArea();
          if (dataSaver.neighborHood.length == 0) {
            dataSaver.neighborHood.add(NeighborHood.fromJson(returnData.data));
          }

          List<String> data = [];

          for (int i = 0; i < dataSaver.neighborHood.length; i++) {
            data.add(jsonEncode(dataSaver.neighborHood[i].toMapAll()));
          }

          if (prefs!.getString('guestNeighborHood') == null) {
            await prefs!.setString('guestNeighborHood', jsonEncode(data));
          }
        }
      }

      ReturnData classThemeData = await ClassRepository.getClassTheme(
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

      classTheme = [];
      classTheme = (classThemeData.data as List)
          .map((e) => ClassTheme.fromJson(e))
          .toList();

      if (event.loading) {
        loading = false;
      }
      getData = false;
      emit(GatherInitState());
    }
  }

  onBookmarkClassHideEvent(BookmarkClassHideEvent event, emit) {
    if (bookmarkClass!.classData
            .indexWhere((element) => element.classUuid == event.classUuid) !=
        -1) {
      if (event.flag == 1) {
        bookmarkClass!
            .classData[bookmarkClass!.classData
                .indexWhere((element) => element.classUuid == event.classUuid)]
            .hide = false;
      } else {
        bookmarkClass!
            .classData[bookmarkClass!.classData
                .indexWhere((element) => element.classUuid == event.classUuid)]
            .hide = true;
      }
    }
    emit(BookmarkClassHideState());
  }

  onBookmarkReloadEvent(BookmarkReloadEvent event, emit) async {
    if (!dataSaver.nonMember) {
      ReturnData bookmarkClassData =
          await ClassRepository.getBookmarkClassList(type: 'MADE', size: 10);
      bookmarkClass = null;
      bookmarkClass = ClassList.fromJson(bookmarkClassData.data);
    }
    emit(BookmarkReloadState());
  }
}

class BookmarkReloadEvent extends BaseBlocEvent {}

class BookmarkReloadState extends BaseBlocState {}

class BookmarkClassHideEvent extends BaseBlocEvent {
  final String classUuid;
  final int flag;

  BookmarkClassHideEvent({required this.classUuid, required this.flag});
}

class BookmarkClassHideState extends BaseBlocState {}

class GatherInitEvent extends BaseBlocEvent {
  final bool loading;

  GatherInitEvent({this.loading = false});
}

class GatherInitState extends BaseBlocState {}

class BaseGatherState extends BaseBlocState {}
