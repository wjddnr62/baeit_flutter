// @dart=2.9
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/stomp.dart';

import 'config/common.dart';
import 'config/config.dart';

void main() async {
  flavor = Flavor.DEV;
  if (!dataSaver.nonMember) {
    stompClient.activate();
  }
  await common(flavor: 'DEV');
}
