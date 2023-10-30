import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/service/image_multiple_upload_service.dart';
import 'package:baeit/data/review/repository/review_repository.dart';
import 'package:baeit/data/review/review.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CreateReviewBloc extends BaseBloc {
  CreateReviewBloc(BuildContext context) : super(BaseCreateReviewState()) {
    on<CreateReviewInitEvent>(onCreateReviewInitEvent);
    on<TypeSelectEvent>(onTypeSelectEvent);
    on<SaveReviewEvent>(onSaveReviewEvent);
    on<GetFileEvent>(onGetFileEvent);
  }

  bool loading = false;
  List<String> reviewType = ['TYPE_0', 'TYPE_1', 'TYPE_2', 'TYPE_3', 'TYPE_4'];
  List<bool> reviewSelect = [];
  List<Asset> imageFiles = [];
  ReviewDetail? reviewDetail;
  bool edit = false;
  String? classReviewUuid;

  onCreateReviewInitEvent(CreateReviewInitEvent event, emit) async {
    for (int i = 0; i < reviewType.length; i++) {
      reviewSelect.add(false);
    }
    edit = event.edit;
    if (edit) {
      classReviewUuid = event.classReviewUuid;
      ReturnData returnData =
          await ReviewRepository.getReviewDetails(event.classReviewUuid!);

      reviewDetail = ReviewDetail.fromJson(returnData.data);
      for (int j = 0; j < reviewDetail!.types.length; j++) {
        for (int i = 0; i < reviewType.length; i++) {
          if (reviewDetail!.types[j].type == reviewType[i]) {
            reviewSelect[i] = true;
          }
        }
      }
    }

    emit(CreateReviewInitState());
  }

  onTypeSelectEvent(TypeSelectEvent event, emit) {
    reviewSelect[event.index] = !event.typeSelect;
    emit(TypeSelectState());
  }

  onSaveReviewEvent(SaveReviewEvent event, emit) async {
    loading = true;
    emit(LoadingState());

    List<Data> images = [];
    if (edit) {
      if (reviewDetail!.images!.length > 0) {
        for (int i = 0; i < reviewDetail!.images!.length; i++) {
          if (reviewDetail!.images![i].representativeFlag != 1) {
            images.add(reviewDetail!.images![i]);
          }
        }
      }
    }

    if (imageFiles.length != 0) {
      List<File> files = [];
      for (int i = 0; i < imageFiles.length; i++) {
        await imageFiles[i].getByteData(quality: 100).then((value) async {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          var filePath =
              tempPath + '/${Uuid().v4()}.${imageFiles[i].name!.split(".")[1]}';
          File file = await File(filePath).writeAsBytes(value.buffer
              .asUint8List(value.offsetInBytes, value.lengthInBytes));
          files.add(file);
        });
      }

      List<Data> data =
          await ImageMultipleUploadService(imageFiles: files).start();
      for (int i = 0; i < data.length; i++) {
        images.add(data[i]);
      }
    }

    List<String> selectTypes = [];
    for (int i = 0; i < reviewSelect.length; i++) {
      if (reviewSelect[i]) {
        selectTypes.add(reviewType[i]);
      }
    }

    ReviewSaveForm reviewSaveForm = ReviewSaveForm(
        classUuid: event.classUuid,
        files: images.length == 0 ? null : images,
        contentText: event.review,
        classReviewUuid: classReviewUuid,
        types: selectTypes);

    ReturnData returnData = await ReviewRepository.saveReview(reviewSaveForm);
    if (returnData.code == 1) {
      loading = false;
      if (classReviewUuid == null) {
        amplitudeEvent('review_completed', {
          'class_uuid': event.classUuid,
          'image_registration': images.length == 0 ? false : true,
          'keyword_count': selectTypes.length,
          'keyword_types': selectTypes.join(',')
        });
      } else {
        amplitudeEvent('review_completed_edit', {
          'class_uuid': event.classUuid,
          'image_registration': images.length == 0 ? false : true,
          'keyword_count': selectTypes.length,
          'keyword_types': selectTypes.join(',')
        });
      }
      emit(SaveReviewState(types: selectTypes));
    } else {
      loading = false;
      emit(ErrorState());
    }
  }

  onGetFileEvent(GetFileEvent event, emit) {
    emit(GetFileState());
  }
}

class GetFileEvent extends BaseBlocEvent {}

class GetFileState extends BaseBlocState {}

class SaveReviewEvent extends BaseBlocEvent {
  final String classUuid;
  final String review;

  SaveReviewEvent({required this.classUuid, required this.review});
}

class SaveReviewState extends BaseBlocState {
  List<String> types;

  SaveReviewState({required this.types});
}

class TypeSelectEvent extends BaseBlocEvent {
  final int index;
  final bool typeSelect;

  TypeSelectEvent({required this.index, required this.typeSelect});
}

class TypeSelectState extends BaseBlocState {}

class CreateReviewInitEvent extends BaseBlocEvent {
  final bool edit;
  final String? classReviewUuid;

  CreateReviewInitEvent({required this.edit, this.classReviewUuid});
}

class CreateReviewInitState extends BaseBlocState {}

class BaseCreateReviewState extends BaseBlocState {}
