import 'package:baeit/data/cheer/service/cheering_msg_service.dart';
import 'package:baeit/data/cheer/service/cheering_service.dart';
import 'package:baeit/data/cheer/service/get_cheering_service.dart';

class CheerRepository {
  static Future<dynamic> getCheering(int addressEupmyeondongNo) =>
      GetCheeringService(addressEupmyeondongNo: addressEupmyeondongNo).start();

  static Future<dynamic> cheering(String cheeringAreaUuid) =>
      CheeringService(cheeringAreaUuid: cheeringAreaUuid).start();

  static Future<dynamic> cheeringMsg(
          String memberCheeringAreaUuid, String messageText) =>
      CheeringMsgService(
              memberCheeringAreaUuid: memberCheeringAreaUuid,
              messageText: messageText)
          .start();
}
