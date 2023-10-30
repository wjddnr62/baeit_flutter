import 'package:baeit/data/common/image_value.dart';

class Reward {
  final String rewardUuid;
  final String title;
  final String contentText;
  final int availCnt;
  final int viewFlag;
  final int achieveCheckFlag;
  final int achievePeriod;
  final List<Data> bannerImages;
  final List<Data> contentImages;
  final List<Data> noticeImages;

  Reward(
      {required this.rewardUuid,
      required this.title,
      required this.contentText,
      required this.availCnt,
      required this.viewFlag,
      required this.achieveCheckFlag,
      required this.achievePeriod,
      required this.bannerImages,
      required this.contentImages,
      required this.noticeImages});

  factory Reward.fromJson(json) {
    return Reward(
        rewardUuid: json['rewardUuid'],
        title: json['title'],
        contentText: json['contentText'],
        availCnt: json['availCnt'],
        viewFlag: json['viewFlag'],
        achieveCheckFlag: json['achieveCheckFlag'],
        achievePeriod: json['achievePeriod'],
        bannerImages: (json['bannerImages'] as List)
            .map((e) => Data.fromJson(e))
            .toList(),
        contentImages: (json['contentImages'] as List)
            .map((e) => Data.fromJson(e))
            .toList(),
        noticeImages: (json['noticeImages'] as List)
            .map((e) => Data.fromJson(e))
            .toList());
  }
}
