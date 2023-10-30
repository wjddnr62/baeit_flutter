import 'package:baeit/data/common/image_value.dart';

class Version {
  final String type;
  final String lastVersionText;
  final String nowVersionText;
  final int forceFlag;
  final int passFlag;
  final int lottieFlag;
  final String? contentText;
  final Data? image;

  Version(
      {required this.type,
      required this.lastVersionText,
      required this.nowVersionText,
      required this.forceFlag,
      required this.passFlag,
      required this.lottieFlag,
      this.contentText,
      this.image});

  factory Version.fromJson(data) {
    return Version(
        type: data['type'],
        lastVersionText: data['lastVersionText'],
        nowVersionText: data['nowVersionText'],
        forceFlag: data['forceFlag'],
        passFlag: data['passFlag'],
        lottieFlag: data['lottieFlag'],
        contentText: data['contentText'],
        image: data['image'] != null ? Data.fromJson(data['image']) : null);
  }
}
