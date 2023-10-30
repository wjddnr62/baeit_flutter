import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/services.dart';

var currentBackPressTime;

appExitBackPress(context) {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    currentBackPressTime = now;
    showToast(context: context, text: AppStrings.of(StringKey.exitToast));
    return Future.value(false);
  }
  return SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}