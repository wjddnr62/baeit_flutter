import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class_cnt.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/notification/repository/notification_repository.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/data/survey/repository/survey_repository.dart';
import 'package:baeit/data/survey/survey.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/cupertino.dart';

class MyBaeitBloc extends BaseBloc {
  MyBaeitBloc(BuildContext context) : super(BaseMyBaeitState());

  bool loading = false;

  ProfileGet? profileGet;
  ClassCnt? classCnt;
  Survey? survey;
  List<String> banners = [];

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is MyBaeitInitEvent) {
      if (!dataSaver.nonMember) {
        loading = true;
        yield LoadingState();

        ReturnData surveyRes = await SurveyRepository.getSurveyDetail();

        if (surveyRes.data != null) {
          survey =
              Survey.fromJson(surveyRes.data);
        }

        if (survey == null) {
          banners = [AppImages.bnrWordCloud];
        } else {
          banners = [AppImages.bnrWordCloud, AppImages.bnrReview];
        }

        await ClassRepository.getClassCount().then((value) {
          classCnt = ClassCnt.fromJson(value.data);
          add(MyBaeitReloadEvent());
        });

        if (dataSaver.profileGet == null) {
          ProfileRepository.getProfile().then((value) {
            dataSaver.profileGet = ProfileGet.fromJson(value.data);
            add(MyBaeitReloadEvent());
          });
        }

        await NotificationRepository.getNotificationAllCount().then((value) {
          dataSaver.alarmCount = value.data;
          add(MyBaeitReloadEvent());
        });

        loading = false;
        yield MyBaeitInitState();
      }
    }

    if (event is UpdateProfileEvent) {
      loading = true;
      yield LoadingState();

      ProfileRepository.getProfile().then((value) {
        dataSaver.profileGet = ProfileGet.fromJson(value.data);
        add(MyBaeitReloadEvent());
      });
      loading = false;
      yield UpdateProfileState();
    }

    if (event is UpdateDataEvent) {
      ClassRepository.getClassCount().then((value) {
        classCnt = ClassCnt.fromJson(value.data);
        add(MyBaeitReloadEvent());
      });

      NotificationRepository.getNotificationAllCount().then((value) {
        dataSaver.alarmCount = value.data;
        add(MyBaeitReloadEvent());
      });
      yield UpdateDataState();
    }

    if (event is MyBaeitReloadEvent) {
      if (dataSaver.learnBloc != null) {
        dataSaver.learnBloc!.add(GetKeywordCountEvent());
      }
      yield MyBaeitReloadState();
    }
  }
}

class MyBaeitReloadEvent extends BaseBlocEvent {}

class MyBaeitReloadState extends BaseBlocState {}

class UpdateDataEvent extends BaseBlocEvent {}

class UpdateDataState extends BaseBlocState {}

class UpdateProfileEvent extends BaseBlocEvent {}

class UpdateProfileState extends BaseBlocState {}

class MyBaeitInitEvent extends BaseBlocEvent {}

class MyBaeitInitState extends BaseBlocState {}

class BaseMyBaeitState extends BaseBlocState {}
