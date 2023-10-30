import 'package:baeit/data/class/variations_class.dart';
import 'package:baeit/data/common/image_value.dart';

class CommunityKeyword {
  final String text;
  final String type;

  CommunityKeyword({required this.text, required this.type});

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'type': type});
    data.addAll({'text': text});
    return data;
  }

  toDecode() {
    return {'type': type, 'text': text};
  }
}

class CommunityCreate {
  final List<Area> areas;
  final String category;
  final String? communityUuid;
  final String? contentText;
  final List<Data>? files;
  final String status;
  final List<CommunityKeyword>? informKeyword;
  final List<CommunityKeyword>? learnKeyword;
  final List<CommunityKeyword>? meetKeyword;

  CommunityCreate(
      {required this.areas,
      required this.category,
      this.communityUuid,
      this.contentText,
      this.files,
      required this.status,
      this.informKeyword,
      this.learnKeyword,
      this.meetKeyword});

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({
      'areas': areas.map((e) {
        return e.toDecode();
      }).toList()
    });
    data.addAll({'category': category});
    if (communityUuid != null) {
      data.addAll({'communityUuid': communityUuid});
    }
    if (contentText != null) {
      data.addAll({'contentText': contentText});
    }
    if (files != null) {
      data.addAll({
        'files': files!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    data.addAll({'status': status});
    if (informKeyword != null) {
      data.addAll({
        'teachKeywords': informKeyword!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    if (learnKeyword != null) {
      data.addAll({
        'learnKeywords': learnKeyword!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    if (meetKeyword != null) {
      data.addAll({
        'meetKeywords': meetKeyword!.map((e) {
          return e.toDecode();
        }).toList()
      });
    }
    return data;
  }
}
