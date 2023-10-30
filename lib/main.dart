// @dart=2.9
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:flutter/foundation.dart';

import 'config/common.dart';
import 'config/config.dart';

void main() async {
  flavor = Flavor.PROD;
  if (kReleaseMode) {
    production = 'prod-release';
  } else {
    production = 'prod-debug';
  }
  if (!dataSaver.nonMember) {
    stompClient.activate();
  }
  await common(flavor: 'PROD');
}
