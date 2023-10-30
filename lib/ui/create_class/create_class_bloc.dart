import 'dart:async';
import 'dart:io';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/class/variations_class.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/service/image_multiple_upload_service.dart';
import 'package:baeit/data/common/service/image_upload_service.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CreateClassBloc extends BaseBloc {
  CreateClassBloc(BuildContext context) : super(BaseCreateClassState());

  bool loading = false;
  int step = 0;
  int finalStep = 0;
  bool isNextStep = false;
  bool preview = false;
  XFile? imageFile;
  List<Asset> imageFiles = [];
  File? cropImageFile;
  int selectedNeighborHood = 0;
  bool categorySelect = false;
  bool categoryAnimationEnd = false;
  String? category;
  int selectCostType = 0;
  int selectShareType = 0;
  List<TextEditingController> keywordController =
      List.generate(5, (index) => TextEditingController());

  String classUuid = '';

  int firstFreeFlag = 0;
  int groupFlag = 0;
  int? personCount;
  int? costOfPerson;

  List<String> categoryItems = [
    AppStrings.of(StringKey.career),
    AppStrings.of(StringKey.hobby),
    AppStrings.of(StringKey.homeBaseSideJob),
    AppStrings.of(StringKey.healthSports),
    AppStrings.of(StringKey.language),
    AppStrings.of(StringKey.certificateExamination),
    AppStrings.of(StringKey.privateLesson),
    AppStrings.of(StringKey.life),
    AppStrings.of(StringKey.etc),
  ];

  categorySet(String text) {
    switch (text) {
      case '커리어(직무)':
        return 'CAREER';
      case '취미':
        return 'HOBBY';
      case '재택\u00B7부업':
        return 'HOME_BASED';
      case '건강\u00B7스포츠':
        return 'HEALTH';
      case '어학':
        return 'LANGUAGE';
      case '자격증\u00B7시험':
        return 'CERTIFICATE';
      case '학생과외':
        return 'LESSON';
      case '생활':
        return 'LIFE';
      case '기타':
        return 'ETC';
    }
  }

  Class? classDetail;
  List<NeighborHood> neighborHoodList = [];

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is CreateClassInitEvent) {
      selectedNeighborHood = dataSaver.neighborHood
          .indexWhere((element) => element.representativeFlag == 1);
      neighborHoodList.addAll(dataSaver.neighborHood);

      if (event.edit) {
        loading = true;
        yield LoadingState();

        ReturnData returnData = await ClassRepository.getClassDetail(
            event.classUuid!,
            event.neighborHood[selectedNeighborHood].lati!,
            event.neighborHood[selectedNeighborHood].longi!);

        if (returnData.code == 1) {
          classDetail = null;
          classDetail = Class.fromJson(returnData.data);

          neighborHoodList.clear();
          neighborHoodList = [];
          for (int i = 0; i < classDetail!.content.areas!.length; i++) {
            NeighborHood neighborHood = NeighborHood(
                buildingName: classDetail!.content.areas![i].buildingName,
                hangName: classDetail!.content.areas![i].hangName,
                hangCode: classDetail!.content.areas![i].hangCode,
                lati: classDetail!.content.areas![i].lati,
                longi: classDetail!.content.areas![i].longi,
                zipAddress: classDetail!.content.areas![i].zipAddress,
                roadAddress: classDetail!.content.areas![i].roadAddress,
                sidoName: classDetail!.content.areas![i].sidoName,
                sigunguName: classDetail!.content.areas![i].sigunguName,
                eupmyeondongName:
                    classDetail!.content.areas![i].eupmyeondongName);
            neighborHoodList.add(neighborHood);
          }

          loading = false;
          yield CreateClassInitState();
          return;
        } else {
          loading = false;
          yield ErrorState();
        }
      }
      loading = false;
      yield CreateClassInitState();
    }

    if (event is StepChangeEvent) {
      step = event.step;
      if (finalStep == 0) {
        finalStep = step + 1;
      } else if (finalStep - 1 < step) {
        finalStep = step + 1;
      }
      isNextStep = true;
      yield StepChangeState();
    }

    if (event is PreviewChangeEvent) {
      preview = !preview;
      yield PreviewChangeState();
    }

    if (event is GetFileEvent) {
      yield GetFileState();
    }

    if (event is SaveClassEvent) {
      loading = true;
      yield LoadingState();

      ReturnData? imageRes;
      ReturnData? originImageRes;
      if (cropImageFile != null) {
        File originFile = File(imageFile!.path);
        // 업로드 속도 줄여보기
        var dir = await getTemporaryDirectory();
        await FlutterImageCompress.compressAndGetFile(originFile.absolute.path,
                '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                quality: 100)
            .then((value) async {
          originImageRes = ReturnData.fromJson(
              jsonDecode(await ImageUploadService(imageFile: value!).start()));
        });
        imageRes = ReturnData.fromJson(jsonDecode(
            await ImageUploadService(imageFile: cropImageFile!).start()));
      }

      List<Data> subImageRes = [];

      if (event.edit) {
        if (classDetail!.content.images!.length > 0) {
          for (int i = 0; i < classDetail!.content.images!.length; i++) {
            if (classDetail!.content.images![i].representativeFlag != 1 || i != 0) {
              subImageRes.add(classDetail!.content.images![i]);
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
          subImageRes.add(data[i]);
        }
      }

      List<String> keyword = [];
      for (int i = 0; i < keywordController.length; i++) {
        if (keywordController[i].text != '') {
          keyword.add(keywordController[i].text);
        }
      }

      VariationsClass variationsClass = VariationsClass(
          type: event.type,
          status: event.status,
          areas: event.areas,
          costConsultFlag: 0,
          minCost: selectCostType == 0 ? event.minCost : 0,
          costType: selectCostType == 0 ? 'HOUR' : 'SHARE',
          shareType: selectCostType == 1 ? shareType(selectShareType) : null,
          category: categorySet(category!),
          title: event.title,
          classIntroText: event.classContent,
          tutorIntroText: event.teacherContent,
          keywords: keyword,
          representativeFile: event.edit
              ? cropImageFile == null
                  ? classDetail!.content.images!.length == 0
                      ? null
                      : classDetail!.content.images![0]
                  : Data.fromJson(imageRes!.data)
              : Data.fromJson(imageRes!.data),
          // 여기 넣는 부분 바꿔야 함
          representativeOriginFile: event.edit
              ? cropImageFile == null
                  ? classDetail!.content.images!.length == 0
                      ? null
                      : classDetail!.content.images![0]
                  : Data.fromJson(originImageRes!.data)
              : Data.fromJson(originImageRes!.data),
          files: subImageRes.length != 0 ? subImageRes : null,
          classUuid: event.classUuid,
          firstFreeFlag: firstFreeFlag,
          groupFlag: groupFlag,
          personCount: personCount,
          costOfPerson: costOfPerson);

      ReturnData returnData =
          await ClassRepository.classVariations(variationsClass);

      if (returnData.code == 1) {
        if (production == 'prod-release' && kReleaseMode && !event.edit) {
          amplitudeRevenue(productId: 'class_register_completed', price: 6);
          Airbridge.event.send(ViewProductListEvent(
              option: EventOption(action: categorySet(category!))));
          Airbridge.event.send(Event('class_register_completed'));
        }
        classUuid = returnData.data;
        loading = false;
        yield SaveClassState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is SaveTempClassEvent) {
      loading = true;
      yield LoadingState();

      ReturnData? imageRes;
      ReturnData? originImageRes;
      if (cropImageFile != null) {
        File originFile = File(imageFile!.path);
        var dir = await getTemporaryDirectory();
        await FlutterImageCompress.compressAndGetFile(originFile.absolute.path,
                '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                quality: 100)
            .then((value) async {
          originImageRes = ReturnData.fromJson(
              jsonDecode(await ImageUploadService(imageFile: value!).start()));
        });
        imageRes = ReturnData.fromJson(jsonDecode(
            await ImageUploadService(imageFile: cropImageFile!).start()));
      }
      if (cropImageFile != null) {
        imageRes = ReturnData.fromJson(jsonDecode(
            await ImageUploadService(imageFile: cropImageFile!).start()));
      }

      List<Data> subImageRes = [];

      if (event.edit) {
        if (classDetail!.content.images!.length > 0) {
          for (int i = 0; i < classDetail!.content.images!.length; i++) {
            if (classDetail!.content.images![i].representativeFlag != 1) {
              subImageRes.add(classDetail!.content.images![i]);
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
          subImageRes.add(data[i]);
        }
      }

      List<String> keyword = [];
      for (int i = 0; i < keywordController.length; i++) {
        if (keywordController[i].text != '') {
          keyword.add(keywordController[i].text);
        }
      }

      VariationsClass variationsClass = VariationsClass(
          type: event.type,
          status: event.status,
          areas: event.areas,
          costConsultFlag: 0,
          minCost: selectCostType == 0 ? event.minCost : 0,
          costType: selectCostType == 0 ? 'HOUR' : 'SHARE',
          shareType: selectCostType == 1 ? shareType(selectShareType) : null,
          category: category == null ? null : categorySet(category!),
          title: event.title,
          classIntroText: event.classContent,
          tutorIntroText: event.teacherContent,
          keywords: keyword.length == 0 ? null : keyword,
          representativeFile: event.edit
              ? (classDetail!.content.images!.length == 0 ||
                      classDetail!.content.images!.indexWhere(
                              (element) => element.representativeFlag == 1) ==
                          -1)
                  ? imageRes != null
                      ? Data.fromJson(imageRes.data)
                      : null
                  : classDetail!.content.images![0]
              : imageRes != null
                  ? Data.fromJson(imageRes.data)
                  : null,
          representativeOriginFile: event.edit
              ? cropImageFile == null
                  ? classDetail!.content.images == null || classDetail!.content.images!.length == 0
                      ? null
                      : classDetail!.content.images![0]
                  : originImageRes == null ? null : Data.fromJson(originImageRes!.data)
              : originImageRes == null ? null : Data.fromJson(originImageRes!.data),
          files: subImageRes.length != 0 ? subImageRes : null,
          classUuid: event.classUuid,
          firstFreeFlag: firstFreeFlag,
          groupFlag: groupFlag,
          personCount: personCount,
          costOfPerson: costOfPerson);

      ReturnData returnData =
          await ClassRepository.classVariations(variationsClass);

      if (returnData.code == 1) {
        classUuid = returnData.data;
        loading = false;
        yield SaveTempClassState(classUuid: classUuid);
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is CreateClassNeighborHoodRemoveEvent) {
      neighborHoodList.removeAt(event.idx);
      yield CreateClassNeighborHoodRemoveState();
    }

    if (event is CostTypeChangeEvent) {
      selectCostType = event.type;
      yield CostTypeChangeState();
    }

    if (event is ShareTypeChangeEvent) {
      selectShareType = event.type;
      yield ShareTypeChangeState();
    }

    if (event is KeywordSetEvent) {
      yield KeywordSetState();
    }

    if (event is GroupFlagChangeEvent) {
      yield GroupFlagChangeState();
    }
  }
}

class GroupFlagChangeEvent extends BaseBlocEvent {}

class GroupFlagChangeState extends BaseBlocState {}

class KeywordSetEvent extends BaseBlocEvent {}

class KeywordSetState extends BaseBlocState {}

class ShareTypeChangeEvent extends BaseBlocEvent {
  final int type;

  ShareTypeChangeEvent({required this.type});
}

class ShareTypeChangeState extends BaseBlocState {}

class CostTypeChangeEvent extends BaseBlocEvent {
  final int type;

  CostTypeChangeEvent({required this.type});
}

class CostTypeChangeState extends BaseBlocState {}

class CreateClassNeighborHoodRemoveEvent extends BaseBlocEvent {
  final int idx;

  CreateClassNeighborHoodRemoveEvent({required this.idx});
}

class CreateClassNeighborHoodRemoveState extends BaseBlocState {}

class SaveTempClassEvent extends BaseBlocEvent {
  final List<Area> areas;
  final String type;
  final String status;
  final int? minCost;
  final String? title;
  final String? classContent;
  final String? teacherContent;
  final String? classUuid;
  final bool edit;

  SaveTempClassEvent(
      {required this.areas,
      required this.type,
      required this.status,
      this.minCost,
      this.title,
      this.classContent,
      this.teacherContent,
      this.classUuid,
      this.edit = false});
}

class SaveTempClassState extends BaseBlocState {
  final String classUuid;

  SaveTempClassState({required this.classUuid});
}

class SaveClassEvent extends BaseBlocEvent {
  final List<Area> areas;
  final String type;
  final String status;
  final int minCost;
  final String title;
  final String classContent;
  final String teacherContent;
  final String? classUuid;
  final bool edit;

  SaveClassEvent(
      {required this.areas,
      required this.type,
      required this.status,
      required this.minCost,
      required this.title,
      required this.classContent,
      required this.teacherContent,
      this.classUuid,
      this.edit = false});
}

class SaveClassState extends BaseBlocState {}

class GetFileEvent extends BaseBlocEvent {}

class GetFileState extends BaseBlocState {}

class PreviewChangeEvent extends BaseBlocEvent {}

class PreviewChangeState extends BaseBlocState {}

class StepChangeEvent extends BaseBlocEvent {
  final int step;

  StepChangeEvent({required this.step});
}

class StepChangeState extends BaseBlocState {}

class CreateClassInitEvent extends BaseBlocEvent {
  final List<NeighborHood> neighborHood;
  final bool edit;
  final String? classUuid;

  CreateClassInitEvent(
      {required this.neighborHood, required this.edit, this.classUuid});
}

class CreateClassInitState extends BaseBlocState {}

class BaseCreateClassState extends BaseBlocState {}
