import 'package:baeit/resource/app_colors.dart';
import 'package:flutter/widgets.dart';

heightLine({Color? color, required double height}) {
  return Container(
    width: double.infinity,
    height: height,
    color: color == null ? AppColors.gray100 : color,
  );
}

widthOneLine(double? height, {Color? color}) {
  return Container(
    width: 1,
    height: height,
    color: color == null ? AppColors.gray100 : color,
  );
}
