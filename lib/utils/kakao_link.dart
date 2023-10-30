// import 'package:baeit/config/base_service.dart';
// import 'package:baeit/data/class/repository/class_repository.dart';
// import 'package:kakao_flutter_sdk/all.dart';
//
// kakaoLinkShare({required String classUuid}) async {
//   bool result = await LinkClient.instance.isKakaoLinkAvailable();
//
//   final TextTemplate defaultText = TextTemplate(
//       '카카오 링크 테스트',
//       Link(
//           webUrl: Uri.parse('https://baeit.co.kr'),
//           mobileWebUrl: Uri.parse('https://baeit.co.kr')));
//
//   ClassRepository.updateKakaoLinkCount(classUuid: classUuid);
//
//   try {
//     if (result) {
//       Uri uri = await LinkClient.instance.defaultWithTalk(defaultText);
//       return await LinkClient.instance.launchKakaoTalk(uri);
//     } else {
//       Uri uri = await LinkClient.instance.defaultWithWeb(defaultText);
//       return await launchBrowserTab(uri);
//     }
//   } catch (error) {
//     debugPrint("Kakao link Error : $error");
//   }
// }

import 'package:baeit/config/base_service.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:kakao_flutter_sdk_link/kakao_flutter_sdk_link.dart';

kakaoLinkShare(
    {required String classUuid,
    required String title,
    required String content,
    required String image,
    required String link}) async {
  bool result = await LinkClient.instance.isKakaoLinkAvailable();

  final FeedTemplate defaultFeed = FeedTemplate(
      content: Content(
          title: title,
          description: content,
          imageUrl: Uri.parse(image),
          link: Link(webUrl: Uri.parse(link), mobileWebUrl: Uri.parse(link))),
      buttons: [
        Button(
            title: '구경하러 가기',
            link: Link(webUrl: Uri.parse(link), mobileWebUrl: Uri.parse(link)))
      ]);

  final TextTemplate defaultText = TextTemplate(
      text: '카카오 링크 테스트',
      link: Link(
          webUrl: Uri.parse('https://baeit.co.kr'),
          mobileWebUrl: Uri.parse('https://baeit.co.kr')));

  ClassRepository.updateKakaoLinkCount(classUuid: classUuid);

  try {
    if (result) {
      Uri uri =
          await LinkClient.instance.defaultTemplate(template: defaultFeed);
      return await LinkClient.instance.launchKakaoTalk(uri);
    } else {
      Uri shareUrl = await WebSharerClient.instance
          .defaultTemplateUri(template: defaultFeed);
      return await launchBrowserTab(shareUrl);
    }
  } catch (error) {
    debugPrint("Kakao link Error : $error");
  }
}
