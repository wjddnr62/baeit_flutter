import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/service/image_multiple_upload_service.dart';
import 'package:baeit/data/review/repository/review_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ReviewReportBloc extends BaseBloc {
  ReviewReportBloc(BuildContext context) : super(BaseReviewReportState());

  bool loading = false;
  List<Asset> imageFiles = [];

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is ReviewReportInitEvent) {
      yield ReviewReportInitState();
    }

    if (event is ReportEvent) {
      loading = true;
      yield LoadingState();

      List<Data> images = [];
      if (imageFiles.length != 0) {
        List<File> files = [];
        for (int i = 0; i < imageFiles.length; i++) {
          await imageFiles[i].getByteData(quality: 100).then((value) async {
            Directory tempDir = await getTemporaryDirectory();
            String tempPath = tempDir.path;
            var filePath = tempPath +
                '/${Uuid().v4()}.${imageFiles[i].name!.split(".")[1]}';
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
      ReturnData returnData = await ReviewRepository.reviewReport(
          classReviewUuid: event.classReviewUuid,
          reportText: event.reportText ?? '',
          images: images.length == 0 ? null : images);

      if (returnData.code == 1) {
        loading = false;
        yield ReportState();
      } else if (returnData.code == -304) {
        loading = false;
        yield DuplicateReportState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }
  }
}

class ReportEvent extends BaseBlocEvent {
  final String classReviewUuid;
  final String? reportText;

  ReportEvent({required this.classReviewUuid, this.reportText});
}

class ReportState extends BaseBlocState {}

class DuplicateReportState extends BaseBlocState {}

class ReviewReportInitEvent extends BaseBlocEvent {}

class ReviewReportInitState extends BaseBlocState {}

class BaseReviewReportState extends BaseBlocState {}
