import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/service/image_multiple_upload_service.dart';
import 'package:baeit/data/feedback/feedback.dart';
import 'package:baeit/data/feedback/repository/feedback_repository.dart';
import 'package:baeit/utils/event.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FeedbackBloc extends BaseBloc {
  FeedbackBloc(BuildContext context) : super(BaseFeedbackState());

  bool loading = false;
  int selectTap = 0;
  bool typeSelect = false;
  bool typeAnimationEnd = false;
  String? type;
  List<String> typeItems = ['작동하지 않아요', '이렇게 바꿔주세요', '이런 점 좋아요', '할 말 있어요'];
  int selectItem = 0;
  List<Asset> imageFiles = [];
  int feedbackType = 0;
  Feedback? feedback;
  int nextData = 1;
  double bottomOffset = 0;
  bool scrollUnder = false;

  typeChange(type) {
    switch (type) {
      case 0:
        return 'NOT_WORK';
      case 1:
        return 'UPGRADE';
      case 2:
        return 'LIKE';
      case 3:
        return 'REQUEST';
    }
  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is FeedbackInitEvent) {
      amplitudeEvent('feedback_in', {});
      yield FeedbackInitState();
    }

    if (event is FeedbackTapChangeEvent) {
      if (selectTap != event.select) {
        selectTap = event.select;
        if (selectTap == 1) {
          loading = true;
          yield ScrollTopState();
          nextData = 1;

          ReturnData returnData = await FeedbackRepository.getFeedback(
              answerFlag: feedbackType == 1
                  ? 0
                  : feedbackType == 2
                      ? 1
                      : null);

          if (returnData.code == 1) {
            feedback = null;
            feedback = Feedback.fromJson(returnData.data);

            loading = false;
            yield FeedbackTapChangeState();
          } else {
            loading = false;
            yield ErrorState();
          }
        }
      }
      yield FeedbackTapChangeState();
    }

    if (event is GetFileEvent) {
      yield GetFileState();
    }

    if (event is FeedbackSendEvent) {
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

      FeedbackSend feedbackSend = FeedbackSend(
          feedbackText: event.feedback,
          type: typeChange(selectItem),
          images: images.length == 0 ? null : images);

      ReturnData res = await FeedbackRepository.feedback(feedbackSend);

      if (res.code == 1) {
        amplitudeEvent('feedback_send', {'data': feedbackSend.toMap()});
        loading = false;
        yield FeedbackSendState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is FeedbackTypeChangeEvent) {
      feedbackType = event.idx;
      yield FeedbackTypeChangeState();
    }

    if (event is FeedbackReloadEvent) {
      loading = true;
      yield LoadingState();
      nextData = 1;

      ReturnData returnData = await FeedbackRepository.getFeedback(
          answerFlag: feedbackType == 1
              ? 0
              : feedbackType == 2
                  ? 1
                  : null);

      if (returnData.code == 1) {
        feedback = null;
        feedback = Feedback.fromJson(returnData.data);

        loading = false;
        yield FeedbackReloadState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is GetDataEvent) {
      if (feedback!.feedbackData.length == nextData * 20) {
        yield CheckState();

        ReturnData returnData = await FeedbackRepository.getFeedback(
            answerFlag: feedbackType == 1
                ? 0
                : feedbackType == 2
                    ? 1
                    : null,
            nextCursor: feedback!.feedbackData.last.cursor);

        if (returnData.code == 1) {
          feedback!.feedbackData
              .addAll(Feedback.fromJson(returnData.data).feedbackData);

          nextData += 1;
          yield GetDataState();
        } else {
          yield ErrorState();
        }
      }
    }
  }
}

class ScrollTopState extends BaseBlocState {}

class GetDataEvent extends BaseBlocEvent {}

class GetDataState extends BaseBlocState {}

class FeedbackReloadEvent extends BaseBlocEvent {}

class FeedbackReloadState extends BaseBlocState {}

class FeedbackTypeChangeEvent extends BaseBlocEvent {
  final int idx;

  FeedbackTypeChangeEvent({required this.idx});
}

class FeedbackTypeChangeState extends BaseBlocState {}

class FeedbackSendEvent extends BaseBlocEvent {
  final String feedback;

  FeedbackSendEvent({required this.feedback});
}

class FeedbackSendState extends BaseBlocState {}

class GetFileEvent extends BaseBlocEvent {}

class GetFileState extends BaseBlocState {}

class FeedbackTapChangeEvent extends BaseBlocEvent {
  final int select;

  FeedbackTapChangeEvent({required this.select});
}

class FeedbackTapChangeState extends BaseBlocState {}

class FeedbackInitEvent extends BaseBlocEvent {}

class FeedbackInitState extends BaseBlocState {}

class BaseFeedbackState extends BaseBlocState {}
