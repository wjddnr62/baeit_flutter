import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/common/image_value.dart';

class ReviewSaveForm {
  final String? classReviewUuid;
  final String classUuid;
  final String contentText;
  final List<Data>? files;
  final List<String> types;

  ReviewSaveForm(
      {this.classReviewUuid,
      required this.classUuid,
      required this.contentText,
      this.files,
      required this.types});

  factory ReviewSaveForm.fromJson(Map<String, dynamic> json) {
    return ReviewSaveForm(
        classReviewUuid: json['classReviewUuid'],
        classUuid: json['classUuid'],
        contentText: json['contentText'],
        files: json['files'] != null
            ? (json['files'] as List).map((e) => Data.fromJson(e)).toList()
            : null,
        types: json['types']);
  }

  toMap() {
    Map<String, dynamic> data = {};
    if (classReviewUuid != null)
      data.addAll({'classReviewUuid': classReviewUuid});
    data.addAll({'classUuid': classUuid});
    data.addAll({'contentText': contentText});
    if (files != null)
      data.addAll({
        'files': files!.map((e) {
          return e.toDecode();
        }).toList()
      });
    data.addAll({
      'types': types.map((e) {
        return e;
      }).toList()
    });
    return data;
  }
}

class Review {
  final String? cursor;
  final String classReviewUuid;
  final DateTime? createDate;
  final DateTime? updateDate;
  final int addressSidoNo;
  final int addressSigunguNo;
  final int addressEupmyeondongNo;
  final String sidoName;
  final String sigunguName;
  final String eupmyeondongName;
  final String contentText;
  final Member writerMember;
  final List<Data>? images;
  final int? answerAddressSidoNo;
  final int? answerAddressSigunguNo;
  final int? answerAddressEupmyeondongNo;
  final String? answerSidoName;
  final String? answerSigunguName;
  final String? answerEupmyeondongName;
  final String? answerText;
  final int answerFlag;
  final DateTime? answerDate;
  final Member? answerMember;
  final ReviewClassInfo reviewClassInfo;
  final int mineFlag;
  final int reportFlag;
  final int editFlag;

  Review(
      {this.cursor,
      required this.classReviewUuid,
      this.createDate,
      this.updateDate,
      required this.addressSidoNo,
      required this.addressSigunguNo,
      required this.addressEupmyeondongNo,
      required this.sidoName,
      required this.sigunguName,
      required this.eupmyeondongName,
      required this.contentText,
      required this.writerMember,
      this.images,
      this.answerAddressSidoNo,
      this.answerAddressSigunguNo,
      this.answerAddressEupmyeondongNo,
      this.answerSidoName,
      this.answerSigunguName,
      this.answerEupmyeondongName,
      this.answerText,
      required this.answerFlag,
      this.answerDate,
      this.answerMember,
      required this.reviewClassInfo,
      required this.mineFlag,
      required this.reportFlag,
      required this.editFlag});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
        cursor: json['cursor'] != null ? json['cursor'] : null,
        classReviewUuid: json['classReviewUuid'],
        createDate: json['createDate'] != null
            ? DateTime.parse(json['createDate'])
            : null,
        updateDate: json['updateDate'] != null
            ? DateTime.parse(json['updateDate'])
            : null,
        addressSidoNo: json['addressSidoNo'],
        addressSigunguNo: json['addressSigunguNo'],
        addressEupmyeondongNo: json['addressEupmyeondongNo'],
        sidoName: json['sidoName'],
        sigunguName: json['sigunguName'],
        eupmyeondongName: json['eupmyeondongName'],
        contentText: json['contentText'],
        writerMember: Member.fromJson(json['writerMember']),
        images: json['images'] != null
            ? (json['images'] as List).map((e) => Data.fromJson(e)).toList()
            : null,
        answerAddressSidoNo: json['answerAddressSidoNo'],
        answerAddressSigunguNo: json['answerAddressSigunguNo'],
        answerAddressEupmyeondongNo: json['answerAddressEupmyeondongNo'],
        answerSidoName: json['answerSidoName'],
        answerSigunguName: json['answerSigunguName'],
        answerEupmyeondongName: json['answerEupmyeondongName'],
        answerText: json['answerText'],
        answerFlag: json['answerFlag'],
        answerDate: json['answerDate'] != null
            ? DateTime.parse(json['answerDate'])
            : null,
        answerMember: json['answerMember'] != null
            ? Member.fromJson(json['answerMember'])
            : null,
        reviewClassInfo: ReviewClassInfo.fromJson(json['classInfo']),
        mineFlag: json['mineFlag'],
        reportFlag: json['reportFlag'],
        editFlag: json['editFlag']);
  }
}

class ReviewList {
  final List<Review> reviewData;
  final int totalRow;

  ReviewList({required this.reviewData, required this.totalRow});

  factory ReviewList.fromJson(Map<String, dynamic> json) {
    return ReviewList(
        reviewData:
            (json['list'] as List).map((e) => Review.fromJson(e)).toList(),
        totalRow: json['totalRow']);
  }
}

class SaveReviewComment {
  final String answerText;
  final String classReviewUuid;

  SaveReviewComment({required this.answerText, required this.classReviewUuid});

  factory SaveReviewComment.fromJson(Map<String, dynamic> json) {
    return SaveReviewComment(
        answerText: json['answerText'],
        classReviewUuid: json['classReviewUuid']);
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'answerText': answerText});
    data.addAll({'classReviewUuid': classReviewUuid});
    return data;
  }
}

class ReviewDetail {
  final String classReviewUuid;
  final DateTime? createDate;
  final DateTime? updateDate;
  final int addressSidoNo;
  final int addressSigunguNo;
  final int addressEupmyeondongNo;
  final String sidoName;
  final String sigunguName;
  final String eupmyeondongName;
  final String contentText;
  final Member? writerMember;
  final List<ReviewType> types;
  final List<Data>? images;
  final int? answerAddressSidoNo;
  final int? answerAddressSigunguNo;
  final int? answerAddressEupmyeondongNo;
  final String? answerSidoName;
  final String? answerSigunguName;
  final String? answerEupmyeondongName;
  final String? answerText;
  final int answerFlag;
  final DateTime? answerDate;
  final Member? answerMember;
  final ReviewClassInfo classMaster;

  ReviewDetail(
      {required this.classReviewUuid,
      this.createDate,
      this.updateDate,
      required this.addressSidoNo,
      required this.addressSigunguNo,
      required this.addressEupmyeondongNo,
      required this.sidoName,
      required this.sigunguName,
      required this.eupmyeondongName,
      required this.contentText,
      this.writerMember,
      required this.types,
      this.images,
      this.answerAddressSidoNo,
      this.answerAddressSigunguNo,
      this.answerAddressEupmyeondongNo,
      this.answerSidoName,
      this.answerSigunguName,
      this.answerEupmyeondongName,
      this.answerText,
      required this.answerFlag,
      this.answerDate,
      this.answerMember,
      required this.classMaster});

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
        classReviewUuid: json['classReviewUuid'],
        createDate: json['createDate'] != null
            ? DateTime.parse(json['createDate'])
            : null,
        updateDate: json['updateDate'] != null
            ? DateTime.parse(json['updateDate'])
            : null,
        addressSidoNo: json['addressSidoNo'],
        addressSigunguNo: json['addressSigunguNo'],
        addressEupmyeondongNo: json['addressEupmyeondongNo'],
        sidoName: json['sidoName'],
        sigunguName: json['sigunguName'],
        eupmyeondongName: json['eupmyeondongName'],
        contentText: json['contentText'],
        writerMember: json['writerMember'] != null
            ? Member.fromJson(json['writerMember'])
            : null,
        types:
            (json['types'] as List).map((e) => ReviewType.fromJson(e)).toList(),
        images: json['images'] != null
            ? (json['images'] as List).map((e) => Data.fromJson(e)).toList()
            : null,
        answerAddressSidoNo: json['answerAddressSidoNo'],
        answerAddressSigunguNo: json['answerAddressSigunguNo'],
        answerAddressEupmyeondongNo: json['answerAddressEupmyeondongNo'],
        answerSidoName: json['answerSidoName'],
        answerSigunguName: json['answerSigunguName'],
        answerEupmyeondongName: json['answerEupmyeondongName'],
        answerText: json['answerText'],
        answerFlag: json['answerFlag'],
        answerDate: json['answerDate'] != null
            ? DateTime.parse(json['answerDate'])
            : null,
        answerMember: json['answerMember'] != null
            ? Member.fromJson(json['answerMember'])
            : null,
        classMaster: ReviewClassInfo.fromJson(json['classMaster']));
  }
}

class ReviewType {
  final String type;

  ReviewType({required this.type});

  factory ReviewType.fromJson(Map<String, dynamic> json) {
    return ReviewType(type: json['type']);
  }
}

class ReviewClassInfo {
  final String classUuid;
  final String type;
  final String status;

  ReviewClassInfo(
      {required this.classUuid, required this.type, required this.status});

  factory ReviewClassInfo.fromJson(Map<String, dynamic> json) {
    return ReviewClassInfo(
        classUuid: json['classUuid'],
        type: json['type'],
        status: json['status']);
  }
}

class ReviewCount {
  final int typeZeroSumCnt;
  final int typeFirstSumCnt;
  final int typeSecondSumCnt;
  final int typeThirdSumCnt;
  final int typeFourthSumCnt;

  ReviewCount(
      {required this.typeZeroSumCnt,
      required this.typeFirstSumCnt,
      required this.typeSecondSumCnt,
      required this.typeThirdSumCnt,
      required this.typeFourthSumCnt});

  factory ReviewCount.fromJson(json) {
    return ReviewCount(
        typeZeroSumCnt: json['type0SumCnt'],
        typeFirstSumCnt: json['type1SumCnt'],
        typeSecondSumCnt: json['type2SumCnt'],
        typeThirdSumCnt: json['type3SumCnt'],
        typeFourthSumCnt: json['type4SumCnt']);
  }

  toSum() {
    return typeZeroSumCnt +
        typeFirstSumCnt +
        typeSecondSumCnt +
        typeThirdSumCnt +
        typeFourthSumCnt;
  }
}

class ReviewGrade {
  final int num;
  final String type;

  ReviewGrade({required this.num, required this.type});
}
